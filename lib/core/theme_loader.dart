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
  Color menuBackground = _defaults.menuBackground;
  int menuBorderRadius = _defaults.menuBorderRadius;
  Color menuBorder = _defaults.menuBorder;
  int menuBorderWidth = _defaults.menuBorderWidth;

  Color itemText = _defaults.itemText;
  String itemFontFamily = _defaults.itemFontFamily;
  Color itemHover = _defaults.itemHover;
  Color itemHoverText = _defaults.itemTextHover;

  Color separator = _defaults.separator;
  int separatorThickness = _defaults.separatorThickness;

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
        menuBackground = _parseColor(value, _defaults.menuBackground);
      }
      if (key == "borderRadius") menuBorderRadius = int.tryParse(value) ?? 4;
      if (key == "border") {
        menuBorder = _parseColor(value, _defaults.menuBorder);
      }
      if (key == "borderWidth") menuBorderWidth = int.tryParse(value) ?? 0;
    }

    if (section == "item") {
      if (key == "text") itemText = _parseColor(value, _defaults.itemText);
      if (key == "fontFamily") itemFontFamily = value;
      if (key == "hover") itemHover = _parseColor(value, _defaults.itemHover);
      if (key == "hoverText") {
        itemHoverText = _parseColor(value, _defaults.itemTextHover);
      }
    }

    if (section == "separator") {
      if (key == "color") separator = _parseColor(value, _defaults.separator);
      if (key == "thickness") {
        separatorThickness = int.tryParse(value) ?? _defaults.separatorThickness;
      }
    }
  }

  return WayboxTheme(
    menuBackground: menuBackground,
    menuBorderRadius: menuBorderRadius,
    menuBorder: menuBorder,
    menuBorderWidth: menuBorderWidth,
    itemText: itemText,
    itemFontFamily: itemFontFamily,
    itemHover: itemHover,
    itemTextHover: itemHoverText,
    separator: separator,
    separatorThickness: separatorThickness,
  );
}

/// Built-in fallback configuration returned when the user config is missing,
/// unreadable or partially invalid.
final _defaults = WayboxTheme(
  menuBackground: Color(0xFF000000),
  menuBorderRadius: 4,
  menuBorder: Color(0xFF202020),
  menuBorderWidth: 0,
  itemText: Color(0xFFFFFFFF),
  itemFontFamily: "",
  itemHover: Color(0xFF222222),
  itemTextHover: Color(0xFFFFFFFF),
  separator: Color(0xFF2C2C2C),
  separatorThickness: 1,
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
