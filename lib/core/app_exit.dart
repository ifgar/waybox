import 'dart:io';

File _pidFile() {
  final runtimeDir = Platform.environment['XDG_RUNTIME_DIR'];
  if (runtimeDir == null) {
    stderr.writeln("XDG_RUNTIME_DIR not set");
    exit(1);
  }
  return File("$runtimeDir/waybox.pid");
}

File _stateFile() {
  final runtimeDir = Platform.environment['XDG_RUNTIME_DIR'];
  if (runtimeDir == null) {
    stderr.writeln("XDG_RUNTIME_DIR not set");
    exit(1);
  }
  return File("$runtimeDir/waybox.state");
}

void requestExit() {
  final pidFile = _pidFile();
  final stateFile = _stateFile();

  if (pidFile.existsSync()) {
    pidFile.deleteSync();
  }
  if (stateFile.existsSync()) {
    stateFile.deleteSync();
  }
  exit(0);
}
