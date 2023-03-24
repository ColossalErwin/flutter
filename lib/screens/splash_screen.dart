//packages
import 'package:flutter/material.dart';
//widgets
import '../widgets/app_drawer.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const routeName = '/splash';

  @override
  Widget build(BuildContext context) {
    print("build splash screen");
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(child: Text("My backlog")),
      ),
      body: const Center(
        child: Text('Loading...'),
      ),
      drawer: const AppDrawer(),
    );
  }
}
