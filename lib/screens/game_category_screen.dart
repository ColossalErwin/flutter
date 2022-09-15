//also there could be two tabs, 1 tab to show categories, the other show backlog by days (this month, last three months, last 6 months, ...)

//should show category folders so that we can click on them to explore furthur
//these folders should based on major genres, so we might need to make this like the meals app
//packages
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
