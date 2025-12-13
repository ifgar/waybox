import 'dart:ui';

/// Holds all configurable UI for Waybox.
///
/// Values are loaded from `~/.config/waybox/theme.conf` and determine:
/// - text color,
/// - hover color for menu items,
/// - background color for the entire menu popup.
///
/// All fields are non-nullable and validated in the loader, ensuring that
/// the UI never receives invalid or missing configuration values.
class WayboxTheme {
  /// Text color used for menu item labels.
  final Color text;

  /// Background color applied when hovering over a menu item.
  final Color hover;

  /// Background color used for the main popup container.
  final Color background;

  const WayboxTheme({
    required this.text,
    required this.hover,
    required this.background,
  });
}
