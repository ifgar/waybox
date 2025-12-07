import 'dart:io';

import 'package:waybox/core/menu.dart';
import 'package:xml/xml.dart';

Future<List<Menu>> loadMenu() async {
  final home = Platform.environment["HOME"];
  final path = "$home/.config/waybox/waybox.xml";
  final file = File(path);

  if (!file.existsSync()) {
    return [];
  }

  String xmlString;
  try {
    xmlString = await file.readAsString();
  } catch (_) {
    return [];
  }

  XmlDocument doc;
  try {
    doc = XmlDocument.parse(xmlString);
  } catch (_) {
    return [];
  }

  final root = doc.rootElement;

  final menus = <Menu>[];

  for (final element in root.findElements("menu")) {
    final name = element.getAttribute("name");
    if (name == null || name.trim().isEmpty) {
      continue;
    }

    final command = element.getAttribute("command");

    menus.add(Menu(name: name, command: command?.trim()));
  }

  return menus;
}
