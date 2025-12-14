import 'dart:io';
import 'package:flutter/material.dart';
import 'package:waybox/core/menu.dart';
import 'package:waybox/core/waybox_theme.dart';

/// Renders the list of menu entries inside the Waybox popup window.
///
/// Each entry is represented as a tappable item. When clicked, the associated
/// command (if any) is executed via `bash -c`.
///
/// Visual appearance (text color, hover color, background) is controlled by
/// the user configuration defined in `WayboxTheme`.
class MenuWidget extends StatelessWidget {
  /// The list of menu entries parsed from `waybox.xml`.
  final List<Menu> items;

  /// Global theme loaded from `theme.conf`.
  final WayboxTheme theme;

  const MenuWidget({super.key, required this.items, required this.theme});

  @override
  Widget build(BuildContext context) {
    // Each XML entry becomes a list item. The parent widget (HomeScreen)
    // handles overall window layout and background color.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((m) => _MenuItem(menu: m, theme: theme)).toList(),
    );
  }
}

/// Individual menu item widget.
/// Tappable and highlights on hover.
/// Executes the associated command when clicked.
class _MenuItem extends StatefulWidget {
  final Menu menu;
  final WayboxTheme theme;

  const _MenuItem({required this.menu, required this.theme});

  @override
  State<_MenuItem> createState() => __MenuItemState();
}

class __MenuItemState extends State<_MenuItem> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    if(widget.menu.name == "separator-space") {
      return const SizedBox(height: 8,);
    }
    
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        hoverColor: widget.theme.itemHover,
        onTap: () {
          final cmd = widget.menu.command;
          if (cmd != null && cmd.trim().isNotEmpty) {
            // Execute the user-defined command in a bash shell.
            Process.run("bash", ["-c", cmd.trim()]);
          }
        },
        onHover: (value) {
          setState(() {
            isHovering = value;
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            widget.menu.name,
            style: TextStyle(
              fontFamily: widget.theme.itemFontFamily,
              color: isHovering
                  ? widget.theme.itemTextHover
                  : widget.theme.itemText,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
