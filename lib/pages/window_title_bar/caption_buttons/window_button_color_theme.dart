import 'dart:ui';

class ButtonBgColorScheme {
  const ButtonBgColorScheme({
    required this.normal,
    required this.hovered,
    required this.pressed,
  });
  final Color normal;
  final Color hovered;
  final Color pressed;
}

class ButtonIconColorScheme {
  const ButtonIconColorScheme({
    required this.normal,
    required this.hovered,
    required this.pressed,
    required this.disabled,
  });
  final Color normal;
  final Color hovered;
  final Color pressed;
  final Color disabled;
}
