class CliArgs {
  final String menuFile;
  final int? x;
  final int? y;

  const CliArgs({required this.menuFile, this.x, this.y});
}

CliArgs parseCliArgs(List<String> args) {
  String menuFile = "waybox.xml";
  int? x;
  int? y;

  for (int i = 0; i < args.length; i++) {
    switch (args[i]) {
      case "--menu":
        menuFile = args[i + 1];
        break;
      case "--x":
        x = int.tryParse(args[i + 1]);
        break;
      case "--y":
        y = int.tryParse(args[i + 1]);
        break;
    }
  }

  return CliArgs(menuFile: menuFile, x: x, y: y);
}
