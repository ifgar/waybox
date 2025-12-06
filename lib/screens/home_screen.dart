import 'package:flutter/material.dart';
import 'package:waybox/components/menu_widget.dart';
import 'package:waybox/core/menu.dart';
import 'package:waybox/core/menu_loader.dart';
import 'package:waybox/core/options.dart';
import 'package:waybox/core/options_loader.dart';
import 'package:window_manager/window_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Menu? root;
  Options? options;

  @override
  void initState() {
    super.initState();
    Future.wait([loadMenu(), loadOptions()]).then((values) {
      setState(() {
        root = values[0] as Menu;
        options = values[1] as Options;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (root == null || options == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MouseRegion(
      onExit: (_) {
        windowManager.close();
      },
      child: Scaffold(
        backgroundColor: _parseColor(options!.background!),
        body: MenuWidget(root: root!, options: options!),
      ),
    );
  }
}

Color _parseColor(String hex) =>
    Color(int.parse(hex.replaceFirst("#", "0xFF")));
