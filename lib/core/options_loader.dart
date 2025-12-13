import 'dart:io';
import 'dart:ui';

import 'package:waybox/core/options.dart';

/// Loads Waybox UI and layout options from `~/.config/waybox/options.conf`.
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
/// [coords]
/// x=100
/// y=100
///
/// [theme]
/// text=#FFFFFF
/// hover=#222222
/// background=#000000
/// ```
Future<Options> loadOptions() async {
  final home = Platform.environment["HOME"];
  final path = "$home/.config/waybox/options.conf";
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
  Color text = _defaults.text;
  Color hover = _defaults.hover;
  Color background = _defaults.background;

  for (final raw in lines) {
    final line = raw.trim();
    if (line.isEmpty) continue;

    // Identify section headers like [size] or [theme]
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

    if (section == "theme") {
      // Colors are validated via a strict hex parser.
      if (key == "text") text = _parseColor(value, _defaults.text);
      if (key == "hover") hover = _parseColor(value, _defaults.hover);
      if (key == "background")
        background = _parseColor(value, _defaults.background);
    }
  }

  return Options(
    text: text,
    hover: hover,
    background: background,
  );
}

/// Built-in fallback configuration returned when the user config is missing,
/// unreadable or partially invalid.
final _defaults = Options(
  text: Color(0xFFFFFFFF),
  hover: Color(0xFF222222),
  background: Color(0xFF000000),
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
