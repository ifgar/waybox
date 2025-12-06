import 'package:flutter/services.dart';
import 'package:waybox/core/menu.dart';
import 'package:xml/xml.dart';

Future<List<Menu>> loadMenu() async {
  final xmlString = await rootBundle.loadString("assets/waybox.xml");
  final doc = XmlDocument.parse(xmlString);
  final root = doc.rootElement;

  return root.findElements("menu").map((element) {
    final name = element.getAttribute("name") ?? "undefined";
    final command = element.getAttribute("command");
    return Menu(name: name, command: command);
  }).toList();
}
