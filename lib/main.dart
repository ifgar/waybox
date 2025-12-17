import 'dart:io';

import 'package:flutter/material.dart';
import 'package:waybox/core/app_exit.dart';
import 'package:waybox/core/cli_args.dart';
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
void main(List<String> args) async {
  await _killPreviousInstance();

  WidgetsFlutterBinding.ensureInitialized();

  await initConfigFiles();

  final cliArgs = parseCliArgs(args);

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
    ShellKeyboardMode.keyboardModeOnDemand,
  );

  // Initialize callbacks (e.g., for Escape key).
  WaylandLayerShell.initCallbacks();
  WaylandLayerShell.onEscape = () {
    requestExit();
  };

  runApp(MainApp(cliArgs: cliArgs));
}

/// Handles existing PID file and creates a new one for the current process.
/// This ensures that only one instance of Waybox runs at a time.
/// If a previous instance is found, it is terminated.
Future<void> _killPreviousInstance() async {
  final runtimeDir = Platform.environment['XDG_RUNTIME_DIR'];
  if (runtimeDir == null) {
    stderr.writeln("XDG_RUNTIME_DIR not set");
    exit(1);
  }
  final pidFile = File("$runtimeDir/waybox.pid");

  if (await pidFile.exists()) {
    final oldPid = int.tryParse(await pidFile.readAsString());
    if (oldPid != null && oldPid != pid) {
      try {
        Process.killPid(oldPid, ProcessSignal.sigterm);
      } catch (_) {}
    }
  }
  await pidFile.writeAsString('$pid');

  void cleanup() {
    if (pidFile.existsSync()) {
      final current = pidFile.readAsStringSync();
      // Only remove the PID file if this instance owns it.
      // Prevents a newer instance from losing its PID when an old one exits.
      if (current.trim() == pid.toString()) pidFile.deleteSync();
    }
    exit(0);
  }

  ProcessSignal.sigint.watch().listen((_) => cleanup());
  ProcessSignal.sigterm.watch().listen((_) => cleanup());
}

/// Root widget of the application.
///
/// The UI consists of a single `HomeScreen` rendered without additional
/// routes, as Waybox is meant to be a lightweight, single-purpose popup.
class MainApp extends StatelessWidget {
  final CliArgs cliArgs;
  const MainApp({super.key, required this.cliArgs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(cliArgs: cliArgs),
    );
  }
}
