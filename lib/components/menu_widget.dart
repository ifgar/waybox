import 'dart:io';
import 'package:flutter/material.dart';
import 'package:waybox/core/menu.dart';
import 'package:waybox/core/options.dart';

/// Renders the list of menu entries inside the Waybox popup window.
///
/// Each entry is represented as a tappable item. When clicked, the associated
/// command (if any) is executed via `bash -c`.
///
/// Visual appearance (text color, hover color, background) is controlled by
/// the user configuration defined in `Options`.
class MenuWidget extends StatelessWidget {
  /// The list of menu entries parsed from `waybox.xml`.
  final List<Menu> items;

  /// Global theme and layout options loaded from `options.conf`.
  final Options options;

  const MenuWidget({super.key, required this.items, required this.options});

  @override
  Widget build(BuildContext context) {
    // Each XML entry becomes a list item. The parent widget (HomeScreen)
    // handles overall window layout and background color.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map(_buildItem).toList(),
    );
  }

  /// Builds an individual menu entry widget.
  ///
  /// - Applies hover color using `InkWell`.
  /// - Executes the defined command when tapped.
  /// - Falls back safely if command is empty.
  Widget _buildItem(Menu menu) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        hoverColor: options.hover,
        onTap: () {
          final cmd = menu.command;
          if (cmd != null && cmd.trim().isNotEmpty) {
            // Execute the user-defined command in a bash shell.
            Process.run("bash", ["-c", cmd.trim()]);
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            menu.name,
            style: TextStyle(color: options.text, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
