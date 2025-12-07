import 'dart:io';

import 'package:flutter/services.dart';

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