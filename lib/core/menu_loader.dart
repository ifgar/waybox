import 'dart:io';

import 'package:waybox/core/menu.dart';
import 'package:xml/xml.dart';

Future<List<Menu>> loadMenu() async {
  final home = Platform.environment["HOME"];
  final path = "$home/.config/waybox/waybox.xml";
  final xmlString = await File(path).readAsString();

  final doc = XmlDocument.parse(xmlString);
  final root = doc.rootElement;

  return root.findElements("menu").map((element) {
    final name = element.getAttribute("name") ?? "undefined";
    final command = element.getAttribute("command");
    return Menu(name: name, command: command);
  }).toList();
}
