import 'dart:io';
import 'dart:ui';

import 'package:waybox/core/waybox_theme.dart';

/// Loads Waybox UI from `~/.config/waybox/theme.conf`.
///
/// The loader is designed to be fault-tolerant:
/// - If the file does not exist → returns default values.
/// - If the file cannot be read → defaults.
/// - If the file contains invalid numeric values → defaults.
/// - If color values are invalid → fallback to previously known values.
/// - Unknown keys and sections are ignored safely.
///
/// Supported structure:
/// ```ini
/// [theme]
/// text=#FFFFFF
/// hover=#222222
/// background=#000000
/// ```
Future<WayboxTheme> loadTheme() async {
  final home = Platform.environment["HOME"];
  final path = "$home/.config/waybox/theme.conf";
  final file = File(path);

  // If configuration is missing, use built-in safe defaults.
  if (!file.existsSync()) {
    return _defaults;
  }

  List<String> lines;
  try {
    lines = await file.readAsLines();
  } catch (_) {
    // Unreadable file → behave as if empty.
    return _defaults;
  }

  String? section;

  // Initialize values with defaults.
  Color background = _defaults.menuBackground;
  int radius = _defaults.menuRadius;

  Color text = _defaults.itemText;
  String fontFamily = _defaults.itemFontFamily;
  Color hover = _defaults.itemHover;
  Color hoverText = _defaults.itemTextHover;

  for (final raw in lines) {
    final line = raw.trim();
    if (line.isEmpty) continue;

    // Identify section headers
    if (line.startsWith("[") && line.endsWith("]")) {
      section = line.substring(1, line.length - 1);
      continue;
    }

    // Must contain key=value
    if (!line.contains("=")) continue;

    final parts = line.split("=");
    if (parts.length != 2) continue;

    final key = parts[0].trim();
    final value = parts[1].trim();

    if (section == "menu") {
      if (key == "background") {
        background = _parseColor(value, _defaults.menuBackground);
      }
      if (key == "radius") radius = int.tryParse(value) ?? 4;
    }

    if (section == "item") {
      if (key == "text") text = _parseColor(value, _defaults.itemText);
      if (key == "fontFamily") fontFamily = value;
      if (key == "hover") hover = _parseColor(value, _defaults.itemHover);
      if (key == "hoverText") {
        hoverText = _parseColor(value, _defaults.itemTextHover);
      }
    }
  }

  return WayboxTheme(
    menuBackground: background,
    menuRadius: radius,
    itemText: text,
    itemFontFamily: fontFamily,
    itemHover: hover,
    itemTextHover: hoverText,
  );
}

/// Built-in fallback configuration returned when the user config is missing,
/// unreadable or partially invalid.
final _defaults = WayboxTheme(
  menuBackground: Color(0xFF000000),
  menuRadius: 4,
  itemText: Color(0xFFFFFFFF),
  itemFontFamily: "",
  itemHover: Color(0xFF222222),
  itemTextHover: Color(0xFFFFFFFF),
);

/// Parses a color from a hex string in the formats:
/// - `#RGB`
/// - `#RRGGBB`
/// - `#AARRGGBB`
///
/// Any invalid format returns the provided fallback.
///
/// This keeps the application stable even if the user edits the file by hand.
Color _parseColor(String value, Color fallback) {
  final hex = value.toUpperCase();

  final regex = RegExp(r'^#([0-9A-F]{3}|[0-9A-F]{6}|[0-9A-F]{8})$');
  if (!regex.hasMatch(hex)) return fallback;

  String clean = hex.substring(1);

  // Expand #RGB → #RRGGBB
  if (clean.length == 3) {
    clean = clean.split("").map((c) => "$c$c").join();
  }

  // If no alpha is provided → use FF (opaque)
  if (clean.length == 6) {
    clean = "FF$clean";
  }

  return Color(int.parse(clean, radix: 16));
}
