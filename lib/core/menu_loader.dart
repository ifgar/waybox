import 'dart:io';

import 'package:waybox/core/menu.dart';
import 'package:xml/xml.dart';

/// Loads the user-defined menu items from `~/.config/waybox/waybox.xml`.
///
/// This function performs several safety checks:
/// - Returns an empty list if the file does not exist.
/// - Returns an empty list if reading fails (permissions, corrupted file, etc.).
/// - Returns an empty list if the XML is malformed.
/// - Ignores any `<menu>` elements missing a valid `name` attribute.
///
/// The goal is to remain stable under any user-caused configuration error.
Future<List<Menu>> loadMenu() async {
  final home = Platform.environment["HOME"];
  final path = "$home/.config/waybox/waybox.xml";
  final file = File(path);

  // If the config file is missing, Waybox still runs but displays no menu.
  if (!file.existsSync()) {
    return [];
  }

  String xmlString;
  try {
    xmlString = await file.readAsString();
  } catch (_) {
    // Could not read the file → treat as empty.
    return [];
  }

  XmlDocument doc;
  try {
    doc = XmlDocument.parse(xmlString);
  } catch (_) {
    // XML is invalid or partially corrupted.
    return [];
  }

  final root = doc.rootElement;
  final menus = <Menu>[];

  // Each <menu> element is expected to contain:
  //   <menu name="Example" command="some command" />
  for (final element in root.findElements("menu")) {
    final name = element.getAttribute("name");
    if (name == null || name.trim().isEmpty) {
      // Skip entries without a valid visible label.
      continue;
    }

    final command = element.getAttribute("command");

    menus.add(Menu(name: name, command: command?.trim()));
  }

  return menus;
}
