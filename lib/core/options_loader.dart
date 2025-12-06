import 'package:flutter/services.dart';
import 'package:waybox/core/options.dart';

Future<Options> loadOptions() async {
  final text = await rootBundle.loadString("assets/options.conf");
  final lines = text.split("\n");

  String? section;
  double? width;
  double? height;
  String? primary;
  String? secondary;
  String? background;

  for (final raw in lines) {
    final line = raw.trim();
    if (line.isEmpty) continue;

    if (line.startsWith("[]") && line.endsWith("]")) {
      section = line.substring(1, line.length - 1);
      continue;
    }

    final parts = line.split("=");
    if (parts.length != 2) continue;

    final key = parts[0].trim();
    final value = parts[1].trim();

    if (section == "size") {
      if (key == "width") width = double.tryParse(value);
      if (key == "height") height = double.tryParse(value);
    }

    if (section == "theme") {
      if (key == "primary") primary = value;
      if (key == "secondary") secondary = value;
      if (key == "background") background = value;
    }
  }

  return Options(
    width: width,
    height: height,
    primary: primary,
    secondary: secondary,
    background: background,
  );
}
