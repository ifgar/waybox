import 'dart:ui';

/// Holds all configurable UI and window parameters for Waybox.
///
/// Values are loaded from `~/.config/waybox/options.conf` and determine:
/// - text color,
/// - hover color for menu items,
/// - background color for the entire menu popup.
///
/// All fields are non-nullable and validated in the loader, ensuring that
/// the UI never receives invalid or missing configuration values.
class Options {
  /// Text color used for menu item labels.
  final Color text;

  /// Background color applied when hovering over a menu item.
  final Color hover;

  /// Background color used for the main popup container.
  final Color background;

  const Options({
    required this.text,
    required this.hover,
    required this.background,
  });
}
