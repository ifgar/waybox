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
  /// Background color used for the main popup container.
  final Color menuBackground;

  /// Border radius applied to the popup window.
  final int menuRadius;

  /// Text color used for menu item labels.
  final Color itemText;

  /// Background color applied when hovering over a menu item.
  final Color itemHover;

  /// Text color applied when hovering over a menu item.
  final Color itemTextHover;

  const WayboxTheme({
    required this.menuBackground,
    required this.menuRadius,
    required this.itemText,
    required this.itemHover,
    required this.itemTextHover,
  });
}
