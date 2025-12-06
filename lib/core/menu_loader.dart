import 'package:flutter/services.dart';
import 'package:waybox/core/menu.dart';
import 'package:waybox/core/menu_parser.dart';
import 'package:xml/xml.dart';

Future<Menu> loadMenu() async {
  final xmlString = await rootBundle.loadString("assets/waybox.xml");
  final doc = XmlDocument.parse(xmlString);

  final root = doc.rootElement;
  return parseMenu(root);
}