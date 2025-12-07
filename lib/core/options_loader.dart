import 'dart:io';

import 'package:waybox/core/options.dart';

Future<Options> loadOptions() async {
  final home = Platform.environment["HOME"];
  final path = "$home/.config/waybox/options.conf";

  final txt = await File(path).readAsString();
  final lines = txt.split("\n");

  String? section;
  double? width;
  double? height;
  int? x;
  int? y;
  String? text;
  String? hover;
  String? background;

  for (final raw in lines) {
    final line = raw.trim();
    if (line.isEmpty) continue;

    if (line.startsWith("[") && line.endsWith("]")) {
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
      if (key == "x") x = int.tryParse(value);
      if (key == "y") y = int.tryParse(value);
    }

    if (section == "theme") {
      if (key == "text") text = value;
      if (key == "hover") hover = value;
      if (key == "background") background = value;
    }
  }

  return Options(
    width: width ?? 300,
    height: height ?? 200,
    x: x ?? 100,
    y: y ?? 100,
    text: text ?? "#FFFFFF",
    hover: hover ?? "#CCCCCC",
    background: background ?? "#222222",
  );
}
