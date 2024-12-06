bool isSourceIdValid(String sourceId) =>
    RegExp(r'^(RJ|VJ|BJ)?\d+$', caseSensitive: false).hasMatch(sourceId);

String getLegalWindowsName(String name) {
  return name
      .replaceAll(RegExp(r'[<>:"/\\|?*]'), '') // 移除非法字符
      .replaceAll(RegExp(r'\.+$'), '') // 移除末尾句点
      .trim(); // 移除前后空格
}
