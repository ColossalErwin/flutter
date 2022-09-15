//future feature
import 'package:flutter/material.dart';
//screens
import '../widgets/app_drawer.dart';

class GamesCategoryScreen extends StatefulWidget {
  const GamesCategoryScreen({Key? key}) : super(key: key);

  @override
  State<GamesCategoryScreen> createState() => _GamesCategoryScreenState();
}

class _GamesCategoryScreenState extends State<GamesCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    print("build game category screen");
    return const Scaffold(
      drawer: AppDrawer(),
      body: Center(
        child: Text("This feature will be added soon."),
      ),
    );
  }
}
