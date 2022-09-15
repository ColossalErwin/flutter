//packages
import 'package:flutter/material.dart';
//providers
import '../providers/game.dart';
//widgets
import '../widgets/managed_game_item.dart';

class CustomSearchDelegateForManageGamesScreen extends SearchDelegate {
  final List<Game> games;

  CustomSearchDelegateForManageGamesScreen({
    required this.games,
  }) : super(
          keyboardType: TextInputType.name,
          //searchFieldDecorationTheme: InputDecorationTheme(),
          searchFieldLabel: "Enter a game title",
          //searchFieldStyle: TextStyle(),
          //textInputAction: TextInputAction.newline
          //textInputAction: TextInputAction.search
        );

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Map<String, dynamic>> matchQuery = [];

    for (final Game game in games) {
      if (game.title.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add({
          'id': game.id,
          'title': game.title,
          'titleImageURL': game.titleImageURL,
          'platform': game.platform,
          'msrp': game.msrp,
        });
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (ctx, index) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(width: 0.033),
          ),
          child: ManagedGameItem(
            id: matchQuery[index]['id'],
            msrp: matchQuery[index]['msrp'],
            platform: matchQuery[index]['platform'],
            title: matchQuery[index]['title'],
            titleImageURL: matchQuery[index]['titleImageURL'],
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Map<String, dynamic>> matchQuery = [];

    for (final Game game in games) {
      if (game.title.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add({
          'id': game.id,
          'title': game.title,
          'titleImageURL': game.titleImageURL,
          'platform': game.platform,
          'msrp': game.msrp,
        });
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (ctx, index) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(width: 0.033),
          ),
          child: ManagedGameItem(
            id: matchQuery[index]['id'],
            msrp: matchQuery[index]['msrp'],
            platform: matchQuery[index]['platform'],
            title: matchQuery[index]['title'],
            titleImageURL: matchQuery[index]['titleImageURL'],
          ),
        );
      },
    );
  }
}
