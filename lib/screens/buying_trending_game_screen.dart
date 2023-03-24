//packages
import 'package:flutter/material.dart';

class BuyingTrendingGameScreen extends StatelessWidget {
  final String trendingGameID;
  const BuyingTrendingGameScreen({
    Key? key,
    required this.trendingGameID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("buying game screen");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Buying This Game"),
      ),
    );
  }
}
