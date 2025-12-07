import 'dart:io';
import 'dart:ui';

import 'package:waybox/core/options.dart';

final _defaults = Options(
    width: 300,
    height: 200,
    x: 100,
    y: 100,
    text: Color(0xFFFFFFFF),
    hover: Color(0xFF222222),
    background: Color(0xFF000000),
  );

Future<Options> loadOptions() async {
  final home = Platform.environment["HOME"];
  final path = "$home/.config/waybox/options.conf";
  final file = File(path);

  if (!file.existsSync()) {
    return _defaults;
  }

  List<String> lines;
  try {
    lines = await file.readAsLines();
  } catch (_) {
    return _defaults;
  }

  String? section;
  double width = _defaults.width;
  double height = _defaults.height;
  int x = _defaults.x;
  int y = _defaults.y;
  Color text = _defaults.text;
  Color hover = _defaults.hover;
  Color background = _defaults.background;

  for (final raw in lines) {
    final line = raw.trim();
    if (line.isEmpty) continue;

    if (line.startsWith("[") && line.endsWith("]")) {
      section = line.substring(1, line.length - 1);
      continue;
    }

    if(!line.contains("=")) continue;

    final parts = line.split("=");
    if (parts.length != 2) continue;

    final key = parts[0].trim();
    final value = parts[1].trim();

    if (section == "size") {
      if (key == "width") width = double.tryParse(value) ?? _defaults.width;
      if (key == "height") height = double.tryParse(value) ?? _defaults.height;
      if (key == "x") x = int.tryParse(value) ?? _defaults.x;
      if (key == "y") y = int.tryParse(value) ?? _defaults.y;
    }

    if (section == "theme") {
      if (key == "text") text = _parseColor(value, _defaults.text);
      if (key == "hover") hover = _parseColor(value, _defaults.hover);
      if (key == "background") background = _parseColor(value, _defaults.background);
    }
  }

  return Options(
    width: width,
    height: height,
    x: x,
    y: y,
    text: text,
    hover: hover,
    background: background,
  );
}

Color _parseColor(String value, Color fallback) {
  final hex = value.toUpperCase();

  final regex = RegExp(r'^#([0-9A-F]{3}|[0-9A-F]{6}|[0-9A-F]{8})$');
  if (!regex.hasMatch(hex)) return fallback;

  String clean = hex.substring(1);

  if(clean.length == 3){
    clean = clean.split("").map((c)=> "$c$c").join();
  }

  if(clean.length == 6){
    clean = "FF$clean";
  }

  return Color(int.parse(clean, radix: 16));
}