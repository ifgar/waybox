class Menu {
  final String name;
  final List<Menu>? children;
  final String? command;

  const Menu({required this.name, this.children, this.command});

  bool get isLeaf => command != null && (children == null || children!.isEmpty);
}
