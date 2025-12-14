import 'dart:io';

import 'package:flutter/material.dart';
import 'package:waybox/components/menu_widget.dart';
import 'package:waybox/core/cli_args.dart';
import 'package:waybox/core/hypr_monitors.dart';
import 'package:waybox/core/menu.dart';
import 'package:waybox/core/menu_loader.dart';
import 'package:waybox/core/waybox_theme.dart';
import 'package:waybox/core/theme_loader.dart';
import 'package:wayland_layer_shell/types.dart';
import 'package:wayland_layer_shell/wayland_layer_shell.dart';

/// Main screen of Waybox.
///
/// Responsibilities:
/// - Loads menu entries (`waybox.xml`) and UI theme (`theme.conf`)
///   asynchronously during initialization.
/// - Renders the interactive menu through `MenuWidget`.
/// - Applies the background color defined by the user.
/// - Automatically closes the popup when the mouse leaves the window
///   (handled via `MouseRegion.onExit`).
///
/// Window size and position are applied earlier in `main.dart`, immediately
/// after reading the configuration.
class HomeScreen extends StatefulWidget {
  final WaylandLayerShell shell;
  final CliArgs cliArgs;
  const HomeScreen({super.key, required this.shell, required this.cliArgs});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Parsed list of menu entries defined in `waybox.xml`.
  List<Menu> items = const [];

  /// UI theme parsed from `theme.conf`. Initialized after loading completes.
  late WayboxTheme theme;

  /// Indicates whether the configuration is still being loaded.
  bool loading = true;

  /// List of Hyprland monitors detected on the system.
  List<HyprMonitorInfo> hyprMonitors = [];

  /// Convenience getter for the Wayland layer-shell plugin.
  WaylandLayerShell get shell => widget.shell;

  /// Whether to apply monitor-specific margins based on reserved areas.
  static const bool _applyMargins = false;

  @override
  void initState() {
    super.initState();

    // Load menu entries and UI theme in parallel to reduce startup time.
    Future.wait([
      loadMenu(fileName: widget.cliArgs.menuFile),
      loadTheme(),
      loadHyprMonitors(),
    ]).then((values) {
      setState(() {
        items = values[0] as List<Menu>;
        theme = values[1] as WayboxTheme;
        hyprMonitors = values[2] as List<HyprMonitorInfo>;
        loading = false;
      });
    });

    // After the first frame, apply monitor-specific margins if possible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_applyMargins) return;
      _applyMonitorMargins(context);
    });
  }

  /// Detects which Hyprland monitor matches Flutter's visible viewport size.
  /// Returns the matching HyprMonitorInfo or null if not found.
  HyprMonitorInfo? _detectCurrentMonitor(BuildContext context) {
    if (hyprMonitors.isEmpty) return null;

    // Get current screen size
    final screen = MediaQuery.of(context).size;
    final w = screen.width.round();
    final h = screen.height.round();

    // Find monitor with matching effective width and height
    for (final m in hyprMonitors) {
      if (m.effectiveWidth == w && m.effectiveHeight == h) {
        return m;
      }
    }
    return null;
  }

  /// Applies margins to the layer-shell surface based on the detected monitor's
  /// reserved areas. Allows overlapping with panels/docks.
  void _applyMonitorMargins(BuildContext context) {
    final detected = _detectCurrentMonitor(context);
    if (detected != null) {
      debugPrint(
        "WAYBOX MONITOR => ${detected.name}  reserved = ${detected.reserved}",
      );

      // Negate reserved values to get margins
      final left = -detected.reserved[0];
      final top = -detected.reserved[1];
      final right = -detected.reserved[2];
      final bottom = -detected.reserved[3];

      // Apply margins one by one
      shell.setMargin(ShellEdge.edgeLeft, left);
      shell.setMargin(ShellEdge.edgeTop, top);
      shell.setMargin(ShellEdge.edgeRight, right);
      shell.setMargin(ShellEdge.edgeBottom, bottom);
      debugPrint("WAYBOX applied margins: L:$left T:$top R:$right B:$bottom");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Transparent area to detect clicks outside the menu and close Waybox
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                exit(0);
              },
              child: Container(color: Colors.transparent),
            ),
          ),

          // Menu container positioned according to user-defined offsets.
          Positioned(
            left: widget.cliArgs.x?.toDouble() ?? 0.0,
            top: widget.cliArgs.y?.toDouble() ?? 0.0,
            child: MouseRegion(
              onExit: (_) => exit(0),
              child: IntrinsicWidth(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.menuBackground,
                    border: Border.all(
                      color: theme.menuBorder,
                      width: theme.menuBorderWidth.toDouble(),
                    ),
                    borderRadius: BorderRadius.circular(
                      theme.menuBorderRadius.toDouble(),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MenuWidget(items: items, theme: theme),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
