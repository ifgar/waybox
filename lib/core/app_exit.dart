import 'dart:io';

File _pidFile() {
  final runtimeDir = Platform.environment['XDG_RUNTIME_DIR'];
  if (runtimeDir == null) {
    stderr.writeln('XDG_RUNTIME_DIR not set');
    exit(1);
  }
  return File('$runtimeDir/waybox.pid');
}

void requestExit() {
  final pidFile = _pidFile();
  if (pidFile.existsSync()) pidFile.deleteSync();
  exit(0);
}
