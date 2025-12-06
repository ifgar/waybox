import 'dart:io';

import 'package:flutter/material.dart';
import 'package:waybox/core/menu.dart';

class MenuWidget extends StatelessWidget {
  final Menu menu;
  final double indent;
  const MenuWidget({super.key, required this.menu, this.indent = 0});

  @override
  Widget build(BuildContext context) {
    final isLeaf = menu.isLeaf;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: indent),
          child: InkWell(
            onTap: isLeaf
                ? () {
                    Process.run("bash", ["-c", menu.command!]);
                  }
                : null,
            child: Text(
              menu.name,
              style: TextStyle(color: isLeaf ? Colors.blue : Colors.white),
            ),
          ),
        ),

        if (menu.children != null)
          ...menu.children!.map(
            (child) => MenuWidget(menu: child, indent: indent + 16),
          ),
      ],
    );
  }
}
