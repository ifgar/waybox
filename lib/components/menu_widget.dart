import 'dart:io';
import 'package:flutter/material.dart';
import 'package:waybox/core/menu.dart';
import 'package:waybox/core/options.dart';

class MenuWidget extends StatelessWidget {
  final List<Menu> items;
  final Options options;

  const MenuWidget({super.key, required this.items, required this.options});

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map(_buildItem).toList(),
    );
  }

  Widget _buildItem(Menu menu) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        hoverColor: _parseColor(options.hover!),
        onTap: () {
          if (menu.command != null) {
            Process.run("bash", ["-c", menu.command!]);
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            menu.name,
            style: TextStyle(
              color: _parseColor(options.text!),
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

Color _parseColor(String hex) {
  hex = hex.trim();
  if (!hex.startsWith("#")) hex = "#$hex";
  return Color(int.parse(hex.replaceFirst("#", "0xFF")));
}
