import 'package:waybox/core/menu.dart';
import 'package:xml/xml.dart';

Menu parseMenu(XmlElement element) {
  final name = element.getAttribute("name") ?? "undefined";

  final command = element.getAttribute("command");

  final children = element.findElements("menu").map(parseMenu).toList();

  return Menu(
    name: name,
    command: command,
    children: children.isEmpty ? null : children,
  );
}
