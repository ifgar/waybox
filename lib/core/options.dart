import 'dart:ui';

/// Holds all configurable UI and window parameters for Waybox.
///
/// Values are loaded from `~/.config/waybox/options.conf` and determine:
/// - window size and position,
/// - text color,
/// - hover color for menu items,
/// - background color for the entire menu popup.
///
/// All fields are non-nullable and validated in the loader, ensuring that
/// the UI never receives invalid or missing configuration values.
class Options {
  /// Width of the Waybox window in logical pixels.
  final double width;

  /// Height of the Waybox window in logical pixels.
  final double height;

  /// Initial X position of the window on screen.
  final int x;

  /// Initial Y position of the window on screen.
  final int y;

  /// Text color used for menu item labels.
  final Color text;

  /// Background color applied when hovering over a menu item.
  final Color hover;

  /// Background color used for the main popup container.
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
