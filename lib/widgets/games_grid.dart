//packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//providers
import '../providers/user_preferences.dart';
import '../providers/games.dart';
//widgets
import './game_item.dart';
//import '../temp_data/temp_data.dart';

class GamesGrid extends StatelessWidget {
  final bool showFavoritesOnly;
  //final GridOption gridOption;
  const GamesGrid({
    Key? key,
    required this.showFavoritesOnly,
    //this.gridOption = GridOption.two,
  }) : super(key: key);

  Future<void> _refreshGamesGrid(BuildContext ctx) async {
    await Provider.of<Games>(ctx, listen: false).fetchGames(GamesOption.userGames);
  }

  @override
  Widget build(BuildContext context) {
    final myCollectionFilters =
        Provider.of<UserPreferences>(context, listen: false).myCollectionFilters;
    final mediaQueryData = MediaQuery.of(context);
    print("build games grid");
    final int crossAxisCount;
    if ((MediaQuery.of(context).orientation == Orientation.portrait)) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    //final gamesData = Provider.of<Games>(context);
    //final games = (showFavoritesOnly) ? gamesData.favoriteGames : gamesData.games;
    /*return /*(games.isEmpty && showFavoritesOnly)
        ? const Center(
            child: Text(
              "Do you know that the best story-telling games out there could give us more beautiful stories than any blockbuster's. You have no favorite games yet, so start to love some!",
              textAlign: TextAlign.center,
            ),
          )
        : (games.isEmpty)
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : */
        FutureBuilder(
            future: _refreshGamesGrid(context),
            builder: (context, snapshot) {
              */
    return RefreshIndicator(
      onRefresh: () => _refreshGamesGrid(context),
      child: Consumer<Games>(
        builder: (ctx, gamesData, child) {
          final games = gamesData.getFilteredGames(
            showAll: myCollectionFilters['showAll'] ?? true,
            showBacklog: myCollectionFilters['showBacklog'] ?? true,
            showFinished: myCollectionFilters['showFinished'] ?? true,
            showHaveNotFinished: myCollectionFilters['showHaveNotFinished'] ?? true,
            hideDislikeds: myCollectionFilters['hideDislikeds'] ?? true,
            isInFavoriteMode: showFavoritesOnly,
          );
          if (games.isEmpty && showFavoritesOnly) {
            return ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return SizedBox(
                  height: mediaQueryData.size.height -
                      mediaQueryData.padding.top -
                      mediaQueryData.padding.bottom -
                      kBottomNavigationBarHeight * 2.5,
                  /*-appBar.height*/ //kBottomNavigationBarHeight * 2 is to compensate for the appBar
                  child: const Center(
                    child: Text("You currently don't have any favorite games."),
                  ),
                ); //should write something here or show a picture saying "you don't have any [...] games"
              },
            );
          } else if (games.isEmpty) {
            return ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return const Center();
              },
            );
          }
          return Container(
            //this border is for ios sizing only
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: GridView.builder(
              //dragStartBehavior: DragStartBehavior.down,
              scrollDirection: (MediaQuery.of(context).orientation == Orientation.portrait)
                  ? Axis.vertical
                  : Axis.horizontal,
              padding: const EdgeInsets.all(10),
              itemCount: games.length,
              itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                value: games[index],
                child: GameItem(key: Key(games[index].id)),
                //ProductItem(key: Key(games[index].id)),
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1 / 1,
                //width : height
                crossAxisSpacing: 10, //spacing between columns
                mainAxisSpacing: 10, //spacing between rows
              ),
            ),
          );
        },
      ),
    );
    // });
  }
}
