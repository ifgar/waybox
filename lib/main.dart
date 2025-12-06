import 'package:flutter/material.dart';
import 'package:waybox/core/options_loader.dart';
import 'package:waybox/screens/home_screen.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final options = await loadOptions();

  await windowManager.ensureInitialized();
  await windowManager.setSize(
    Size(options.width ?? 300, options.height ?? 200),
  );
  await windowManager.setMinimumSize(Size(300, 200));

  if (options.x != null && options.y != null) {
    await windowManager.setPosition(
      Offset(options.x!.toDouble(), options.y!.toDouble()),
    );
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomeScreen());
  }
}
