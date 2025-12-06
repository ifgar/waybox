import 'package:flutter/material.dart';
import 'package:waybox/components/menu_widget.dart';
import 'package:waybox/core/menu.dart';
import 'package:waybox/core/menu_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Menu? root;

  @override
  void initState() {
    super.initState();
    loadMenu().then((m) {
      setState(() {
        root = m;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (root == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      return Scaffold(
        body: ListView(children: [MenuWidget(menu: root!)]),
      );
    }
  }
}
