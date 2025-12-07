import 'dart:ui';

class Options {
  final double width;
  final double height;

  final int x;
  final int y;

  final Color text;
  final Color hover;
  final Color background;

  const Options({
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    required this.text,
    required this.hover,
    required this.background,
  });
}
