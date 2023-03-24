//Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
//packages
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//providers
import '../providers/game.dart';
import '../screens/trending_game_detail_screen.dart';
//helopers
import './custom_route.dart';

class CustomSearchDelegateForTrendingGames extends SearchDelegate {
  final List<Game> games;

  CustomSearchDelegateForTrendingGames({required this.games})
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
          'releaseDate': game.releaseDate as Timestamp,
        });
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (ctx, index) {
        final DateTime releaseDate = (matchQuery[index]['releaseDate'] as Timestamp).toDate();
        return Container(
          decoration: BoxDecoration(
            border: Border.all(width: 0.033),
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                CustomRoute(
                  builder: (context) => TrendingGameDetailScreen(
                    trendingGameID: matchQuery[index]['id'],
                  ),
                ),
              );
            },
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            splashColor: Colors.blue.withOpacity(0.33),
            child: ListTile(
              leading: /*Hero(
                tag: "trending game title image ${matchQuery[index]['id']}",
                child:*/
                  CircleAvatar(
                backgroundImage: NetworkImage(
                  matchQuery[index]['titleImageURL'],
                  //),
                ),
              ),
              title: Text(
                matchQuery[index]['title'],
              ),
              trailing: Text(
                releaseDate.isAfter(DateTime.now())
                    ? DateFormat.yMMMd().format(
                        releaseDate,
                      )
                    : "Release in ${DateFormat.y().format(
                        releaseDate,
                      )}",
              ),
            ),
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
          'releaseDate': game.releaseDate,
        });
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (ctx, index) {
        final DateTime releaseDate = (matchQuery[index]['releaseDate'] as Timestamp).toDate();
        return Container(
          decoration: BoxDecoration(
            border: Border.all(width: 0.033),
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                CustomRoute(
                  builder: (context) => TrendingGameDetailScreen(
                    trendingGameID: matchQuery[index]['id'],
                  ),
                ),
              );
            },
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            splashColor: Colors.blue.withOpacity(0.33),
            child: ListTile(
              leading: /*Hero(
                tag: "trending game title image ${matchQuery[index]['id']}",
                child:*/
                  CircleAvatar(
                backgroundImage: NetworkImage(
                  matchQuery[index]['titleImageURL'],
                  // ),
                ),
              ),
              title: Text(
                matchQuery[index]['title'],
              ),
              trailing: Text(
                releaseDate.isAfter(DateTime.now())
                    ? DateFormat.yMMMd().format(
                        releaseDate,
                      )
                    : "Release in ${DateFormat.y().format(
                        releaseDate,
                      )}",
              ),
            ),
          ),
        );
      },
    );
  }
}
