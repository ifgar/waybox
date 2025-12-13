import 'dart:io';

import 'package:flutter/services.dart';

/// Initializes Waybox's user-editable configuration directory.
///
/// This function ensures:
/// - `~/.config/waybox` exists.
/// - Default config files (`waybox.xml`, `theme.conf`) are copied from
///   assets **only if missing**, so user modifications are never overwritten.
Future<void> initConfigFiles() async {
  final home = Platform.environment["HOME"];
  final dir = Directory("$home/.config/waybox");

  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  await _copyIfMissing("assets/waybox.xml", "${dir.path}/waybox.xml");
  await _copyIfMissing("assets/theme.conf", "${dir.path}/theme.conf");
}

/// Copies a file from assets into the config directory **only if it does not
/// already exist**.
///
/// This prevents overwriting user-customized configuration files during updates.

Future<void> _copyIfMissing(String asset, String dest) async {
  final file = File(dest);
  if (file.existsSync()) return;

  final data = await rootBundle.load(asset);
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  await file.writeAsBytes(bytes);
}