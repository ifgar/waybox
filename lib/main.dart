import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waybox/core/options_loader.dart';
import 'package:waybox/screens/home_screen.dart';
import 'package:window_manager/window_manager.dart';

Future<void> initConfigFiles() async {
  final home = Platform.environment["HOME"];
  final dir = Directory("$home/.config/waybox");

  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  await _copyIfMissing("assets/waybox.xml", "${dir.path}/waybox.xml");
  await _copyIfMissing("assets/options.conf", "${dir.path}/options.conf");
}

Future<void> _copyIfMissing(String asset, String dest) async {
  final file = File(dest);
  if (file.existsSync()) return;

  final data = await rootBundle.load(asset);
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  await file.writeAsBytes(bytes);
}

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
