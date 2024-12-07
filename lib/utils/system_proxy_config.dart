// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'dart:ffi';
import 'package:asmr_downloader/utils/log.dart';
import 'package:ffi/ffi.dart';

// https://learn.microsoft.com/en-us/windows/win32/api/winhttp/nf-winhttp-winhttpgetieproxyconfigforcurrentuser

base class WINHTTP_CURRENT_USER_IE_PROXY_CONFIG extends Struct {
  @Int32()
  external int fAutoDetect;

  external Pointer<Utf16> lpszAutoConfigUrl;
  external Pointer<Utf16> lpszProxy;
  external Pointer<Utf16> lpszProxyBypass;
}

class SystemProxyConfig {
  bool? fAutoDetect;
  String? autoConfigUrl;
  String? proxy;
  String? proxyBypass;

  SystemProxyConfig({
    this.fAutoDetect,
    this.autoConfigUrl,
    this.proxy,
    this.proxyBypass,
  });

  static final _WinHttpGetIEProxyConfigForCurrentUser =
      DynamicLibrary.open('winhttp.dll').lookupFunction<
              Int32 Function(
                  Pointer<WINHTTP_CURRENT_USER_IE_PROXY_CONFIG> pProxyConfig),
              int Function(
                  Pointer<WINHTTP_CURRENT_USER_IE_PROXY_CONFIG> pProxyConfig)>(
          'WinHttpGetIEProxyConfigForCurrentUser');

  static final _GlobalFree = DynamicLibrary.open('kernel32.dll').lookupFunction<
      Pointer<Void> Function(Pointer<Void> mem),
      Pointer<Void> Function(Pointer<Void> mem)>('GlobalFree');

  factory SystemProxyConfig.getConfig() {
    final proxyConfig = calloc<WINHTTP_CURRENT_USER_IE_PROXY_CONFIG>();

    try {
      final result = _WinHttpGetIEProxyConfigForCurrentUser(proxyConfig);

      if (result != 0) {
        final configRef = proxyConfig.ref;
        final systemProxyConfig = SystemProxyConfig();

        systemProxyConfig.fAutoDetect = configRef.fAutoDetect != 0;

        if (configRef.lpszAutoConfigUrl != nullptr) {
          systemProxyConfig.autoConfigUrl =
              configRef.lpszAutoConfigUrl.toDartString();
          _GlobalFree(configRef.lpszAutoConfigUrl.cast());
        }

        if (configRef.lpszProxy != nullptr) {
          systemProxyConfig.proxy = configRef.lpszProxy.toDartString();
          _GlobalFree(configRef.lpszProxy.cast());
        }

        if (configRef.lpszProxyBypass != nullptr) {
          systemProxyConfig.proxyBypass =
              configRef.lpszProxyBypass.toDartString();
          _GlobalFree(configRef.lpszProxyBypass.cast());
        }

        return systemProxyConfig;
      } else {
        Log.error('Failed to get system proxy config');
        return SystemProxyConfig();
      }
    } finally {
      calloc.free(proxyConfig);
    }
  }

  /// 返回代理配置 PROXY host:port; PROXY host2:port2; DIRECT, 如果代理地址获取失败则直接返回 DIRECT
  static String get systemProxy {
    final proxy = SystemProxyConfig.getConfig().proxy;
    if (proxy == null || proxy.isEmpty) {
      return 'DIRECT';
    }

    return '${proxy.split(';').map((e) => 'PROXY ${e.trim()}').join('; ')}; DIRECT';
  }
}
