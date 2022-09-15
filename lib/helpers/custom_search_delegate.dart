//packages
import 'package:flutter/material.dart';
//screens
import '../screens/game_detail_screen.dart';
//providers
import '../providers/game.dart';

class CustomSearchDelegate extends SearchDelegate {
  final List<Game> games;

  CustomSearchDelegate({required this.games})
      : super(
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
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                GameDetailScreen.routeName,
                arguments: matchQuery[index]['id'],
              );
            },
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            splashColor: Colors.blue.withOpacity(0.33),
            child: ListTile(
              title: Text(
                matchQuery[index]['title'],
              ),
              leading: /*Hero(
                tag: "1st image${matchQuery[index]['id']}",
                child:*/
                  CircleAvatar(
                backgroundImage: NetworkImage(
                  matchQuery[index]['titleImageURL'],
                ),
              ),
            ),
            //),
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
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                GameDetailScreen.routeName,
                arguments: matchQuery[index]['id'],
              );
            },
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            splashColor: Colors.blue.withOpacity(0.33),
            child: ListTile(
              title: Text(
                matchQuery[index]['title'],
              ),
              leading: /*Hero(
                tag: "1st image${matchQuery[index]['id']}",
                child:*/
                  CircleAvatar(
                backgroundImage: NetworkImage(
                  matchQuery[index]['titleImageURL'],
                ),
              ),
              //),
            ),
          ),
        );
      },
    );
  }
}
