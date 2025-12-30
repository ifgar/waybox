import 'package:flutter/material.dart';
import 'package:waybox/components/menu_widget.dart';
import 'package:waybox/core/app_exit.dart';
import 'package:waybox/core/cli_args.dart';
import 'package:waybox/core/menu.dart';
import 'package:waybox/core/menu_loader.dart';
import 'package:waybox/core/waybox_theme.dart';
import 'package:waybox/core/theme_loader.dart';

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
  final CliArgs cliArgs;
  const HomeScreen({super.key, required this.cliArgs});

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


  @override
  void initState() {
    super.initState();

    // Load menu entries and UI theme in parallel to reduce startup time.
    Future.wait([
      loadMenu(fileName: widget.cliArgs.menuFile),
      loadTheme(),
    ]).then((values) {
      setState(() {
        items = values[0] as List<Menu>;
        theme = values[1] as WayboxTheme;
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Transparent area to detect clicks outside the menu and close Waybox
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => requestExit(),
              child: Container(color: Colors.transparent),
            ),
          ),

          // Menu container positioned according to user-defined offsets.
          Positioned(
            left: widget.cliArgs.x?.toDouble() ?? 0.0,
            top: widget.cliArgs.y?.toDouble() ?? 0.0,
            child: MouseRegion(
              onExit: (_) => requestExit(),
              child: IntrinsicWidth(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.menuBackground,
                    border: theme.menuBorderWidth > 0
                        ? Border.all(
                            color: theme.menuBorder,
                            width: theme.menuBorderWidth.toDouble(),
                          )
                        : null,
                    borderRadius: BorderRadius.circular(
                      theme.menuBorderRadius.toDouble(),
                    ),
                  ),
                  child: MenuWidget(items: items, theme: theme),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
