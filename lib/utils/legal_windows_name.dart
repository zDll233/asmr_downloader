String getLegalWindowsName(String name) {
  return name
      .replaceAll(RegExp(r'[<>:"/\\|?*]'), '') // 移除非法字符
      .replaceAll(RegExp(r'\.+$'), '') // 移除末尾句点
      .trim(); // 移除前后空格
}