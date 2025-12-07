import 'package:flutter/material.dart';
import 'package:waybox/core/config_init.dart';
import 'package:waybox/core/options_loader.dart';
import 'package:waybox/screens/home_screen.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initConfigFiles();

  final options = await loadOptions();

  await windowManager.ensureInitialized();
  await windowManager.setSize(Size(options.width, options.height));

  await windowManager.setPosition(
    Offset(options.x.toDouble(), options.y.toDouble()),
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomeScreen());
  }
}
