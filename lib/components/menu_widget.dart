import 'dart:io';
import 'package:flutter/material.dart';
import 'package:waybox/core/menu.dart';
import 'package:waybox/core/options.dart';

class MenuWidget extends StatelessWidget {
  final Menu root;
  final Options options;

  const MenuWidget({super.key, required this.root, required this.options});

  @override
  Widget build(BuildContext context) {
    final items = root.children ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((m) => _buildItem(m)).toList(),
    );
  }

  Widget _buildItem(Menu menu) {
    return InkWell(
      onTap: () {
        if (menu.command != null) {
          Process.run("bash", ["-c", menu.command!]);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          menu.name,
          style: TextStyle(
            color: _parseColor(options.primary!),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

Color _parseColor(String hex) =>
    Color(int.parse(hex.replaceFirst("#", "0xFF")));
