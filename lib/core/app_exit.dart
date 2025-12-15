import 'dart:io';

final _pidFile = File('/run/user/${Platform.environment['UID']}/waybox.pid');

void requestExit() {
  if (_pidFile.existsSync()) _pidFile.deleteSync();
  exit(0);
}
