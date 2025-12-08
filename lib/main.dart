import 'package:flutter/material.dart';
import 'package:waybox/core/config_init.dart';
import 'package:waybox/core/options_loader.dart';
import 'package:waybox/screens/home_screen.dart';
import 'package:wayland_layer_shell/types.dart';
import 'package:wayland_layer_shell/wayland_layer_shell.dart';

/// Entry point of Waybox.
///
/// Initialization flow:
/// 1. Initialize Flutter bindings.
/// 2. Ensure `~/.config/waybox` exists and populate it with default files
///    if needed.
/// 3. Load user UI/window configuration (`options.conf`).
/// 4. Initialize a Wayland layer-shell surface using `wayland_layer_shell`.
///    If supported:
///       - Create a real layer-shell surface (not a normal window),
///       - Anchor it to the top-left corner,
///       - Apply user-defined margins as coordinates,
///       - Set the layer to `overlay`.
///    If not supported:
///       - Show a minimal fallback screen.
/// 5. Launch the Flutter widget tree (`HomeScreen`).
///
/// All positional/sizing behavior is delegated to Wayland layer-shell.
/// The window is *not* an XDG toplevel, so methods from `window_manager`
/// do not apply in this mode.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initConfigFiles();

  final options = await loadOptions();

  // Initialize Wayland layer-shell surface.
  final waylandLayerShellPlugin = WaylandLayerShell();
  bool isSupported = await waylandLayerShellPlugin.initialize(
    options.width.toInt(),
    options.height.toInt(),
  );
  if (!isSupported) {
    runApp(const MaterialApp(home: Center(child: Text('Not supported'))));
    return;
  }

  // Attach surface to top-left.
  waylandLayerShellPlugin.setAnchor(ShellEdge.edgeLeft, true);
  waylandLayerShellPlugin.setAnchor(ShellEdge.edgeTop, true);

  // Apply offsets from `options.conf`.
  waylandLayerShellPlugin.setMargin(ShellEdge.edgeLeft, options.x);
  waylandLayerShellPlugin.setMargin(ShellEdge.edgeTop, options.y);
  
  waylandLayerShellPlugin.setLayer(ShellLayer.layerOverlay);

  runApp(const MainApp());
}

/// Root widget of the application.
///
/// The UI consists of a single `HomeScreen` rendered without additional
/// routes, as Waybox is meant to be a lightweight, single-purpose popup.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
