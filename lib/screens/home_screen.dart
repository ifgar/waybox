import 'dart:io';

import 'package:flutter/material.dart';
import 'package:waybox/components/menu_widget.dart';
import 'package:waybox/core/hypr_monitors.dart';
import 'package:waybox/core/menu.dart';
import 'package:waybox/core/menu_loader.dart';
import 'package:waybox/core/options.dart';
import 'package:waybox/core/options_loader.dart';
import 'package:wayland_layer_shell/types.dart';
import 'package:wayland_layer_shell/wayland_layer_shell.dart';

/// Main screen of Waybox.
///
/// Responsibilities:
/// - Loads menu entries (`waybox.xml`) and UI options (`options.conf`)
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
  const HomeScreen({super.key, required this.shell});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Parsed list of menu entries defined in `waybox.xml`.
  List<Menu> items = const [];

  /// UI options parsed from `options.conf`. Initialized after loading completes.
  late Options options;

  /// Indicates whether the configuration is still being loaded.
  bool loading = true;

  List<HyprMonitorInfo> hyprMonitors = [];
  WaylandLayerShell get shell => widget.shell;

  @override
  void initState() {
    super.initState();

    // Load menu entries and UI options in parallel to reduce startup time.
    Future.wait([loadMenu(), loadOptions(), loadHyprMonitors()]).then((values) {
      setState(() {
        items = values[0] as List<Menu>;
        options = values[1] as Options;
        hyprMonitors = values[2] as List<HyprMonitorInfo>;
        loading = false;
      });
    });
  }

  /// Detects which Hyprland monitor matches Flutter's visible viewport size.
  /// Returns the matching HyprMonitorInfo or null if not found.
  HyprMonitorInfo? detectCurrentMonitor(BuildContext context) {
    if (hyprMonitors.isEmpty) return null;

    final screen = MediaQuery.of(context).size;
    final w = screen.width.round();
    final h = screen.height.round();

    for (final m in hyprMonitors) {
      if (m.effectiveWidth == w && m.effectiveHeight == h) {
        return m;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Try to detect on which monitor Waybox is currently displayed.
    final detected = detectCurrentMonitor(context);
    if (detected != null) {
      debugPrint(
        "WAYBOX MONITOR => ${detected.name}  reserved = ${detected.reserved}",
      );
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
            left: options.x.toDouble(),
            top: options.y.toDouble(),
            child: MouseRegion(
              onExit: (_) => exit(0),
              child: IntrinsicWidth(
                child: IntrinsicHeight(
                  child: Container(
                    decoration: BoxDecoration(
                      color: options.background,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MenuWidget(items: items, options: options),
                    ),
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
