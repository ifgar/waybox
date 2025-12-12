import 'dart:io';

import 'package:flutter/material.dart';
import 'package:waybox/core/config_init.dart';
import 'package:waybox/screens/home_screen.dart';
import 'package:wayland_layer_shell/types.dart';
import 'package:wayland_layer_shell/wayland_layer_shell.dart';

/// Entry point of Waybox.
///
/// Initialization flow:
/// 1. Initialize Flutter bindings.
/// 2. Ensure `~/.config/waybox` exists and populate it with default files
///    if needed.
/// 3. Initialize a Wayland layer-shell surface using `wayland_layer_shell`.
///    If supported:
///       - Create a real layer-shell surface (not a normal window),
///       - Anchor it to the top-left corner,
///       - Apply user-defined margins as coordinates,
///       - Set the layer to `overlay`.
///    If not supported:
///       - Show a minimal fallback screen.
/// 4. Launch the Flutter widget tree (`HomeScreen`).
///
/// All positional/sizing behavior is delegated to Wayland layer-shell.
/// The window is *not* an XDG toplevel, so methods from `window_manager`
/// do not apply in this mode.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initConfigFiles();

  // Initialize Wayland layer-shell surface.
  final waylandLayerShellPlugin = WaylandLayerShell();
  bool isSupported = await waylandLayerShellPlugin.initialize();
  if (!isSupported) {
    runApp(const MaterialApp(home: Center(child: Text('Not supported'))));
    return;
  }

  // Set layer to overlay.
  waylandLayerShellPlugin.setLayer(ShellLayer.layerOverlay);

  // Anchor to all edges.
  waylandLayerShellPlugin.setAnchor(ShellEdge.edgeLeft, true);
  waylandLayerShellPlugin.setAnchor(ShellEdge.edgeRight, true);
  waylandLayerShellPlugin.setAnchor(ShellEdge.edgeTop, true);
  waylandLayerShellPlugin.setAnchor(ShellEdge.edgeBottom, true);

  // Change namespace
  waylandLayerShellPlugin.setNamespace("waybox");

  // Set exclusive keyboard mode to capture all keyboard input.
  waylandLayerShellPlugin.setKeyboardMode(
    ShellKeyboardMode.keyboardModeExclusive,
  );

  // Initialize callbacks (e.g., for Escape key).
  WaylandLayerShell.initCallbacks();
  WaylandLayerShell.onEscape = () {
    exit(0);
  };

  // Kill any previous instance.
  await _killPreviousInstance();

  runApp(MainApp(shell: waylandLayerShellPlugin));
}

/// Kills any previous instance of the application by reading its PID
/// from a temporary file and sending it a SIGTERM signal.
Future<void> _killPreviousInstance() async {
  final pidFile = File("${Directory.systemTemp.path}/waybox.pid");

  if (await pidFile.exists()) {
    final oldPid = int.tryParse(await pidFile.readAsString());
    if (oldPid != null && oldPid != pid) {
      try {
        Process.killPid(oldPid, ProcessSignal.sigterm);
      } catch (_) {}
    }
  }

  await pidFile.writeAsString('$pid');
}

/// Root widget of the application.
///
/// The UI consists of a single `HomeScreen` rendered without additional
/// routes, as Waybox is meant to be a lightweight, single-purpose popup.
class MainApp extends StatelessWidget {
  final WaylandLayerShell shell;
  const MainApp({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(shell: shell),
    );
  }
}
