import 'package:flutter/material.dart';
import 'package:waybox/core/config_init.dart';
import 'package:waybox/core/options_loader.dart';
import 'package:waybox/screens/home_screen.dart';
import 'package:window_manager/window_manager.dart';

/// Entry point of Waybox.
///
/// The initialization sequence is:
/// 1. Ensure Flutter bindings are ready.
/// 2. Initialize the configuration directory (`~/.config/waybox`) and
///    copy default files if they do not exist.
/// 3. Load the user-defined UI/window options.
/// 4. Initialize the window manager and apply size/position.
/// 5. Launch the main widget tree (`HomeScreen`).
///
/// All user-editable configuration is handled before building the UI.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure configuration files exist in ~/.config/waybox.
  // Default files are only copied if missing.
  await initConfigFiles();

  // Load visual and window configuration.
  final options = await loadOptions();

  // Configure the native window before building the widget tree.
  await windowManager.ensureInitialized();

  // Hide title bar
  await windowManager.setTitleBarStyle(
    TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );
  await windowManager.setAlwaysOnTop(true);

  // Apply size from configuration.
  await windowManager.setSize(Size(options.width, options.height));

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
