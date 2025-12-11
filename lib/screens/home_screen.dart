import 'dart:io';

import 'package:flutter/material.dart';
import 'package:waybox/components/menu_widget.dart';
import 'package:waybox/core/hypr_monitors.dart';
import 'package:waybox/core/menu.dart';
import 'package:waybox/core/menu_loader.dart';
import 'package:waybox/core/options.dart';
import 'package:waybox/core/options_loader.dart';

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
  const HomeScreen({super.key});

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
