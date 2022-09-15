//This widget currently rebuilds too many times for unknown reasons
//probably because of trending game item

//packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//providers
import '../providers/games.dart';
//widgets
import './trending_game_item.dart';

class TrendingGamesGrid extends StatelessWidget {
  final bool showWishlistOnly;
  const TrendingGamesGrid({
    Key? key,
    required this.showWishlistOnly,
  }) : super(key: key);

  Future<void> _refreshTrendingGamesGrid(BuildContext ctx) async {
    await Provider.of<Games>(ctx, listen: false)
        .fetchGames(showWishlistOnly ? GamesOption.wishlistGames : GamesOption.trendingGames);
  }

  @override
  Widget build(BuildContext context) {
    final bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final mediaQueryData = MediaQuery.of(context);
    print("build trending games grid");

    /*return FutureBuilder(
        future: _refreshTrendingGamesGrid(context),
        builder: (context, snapshot) {
          */
    //trending games could be trending games or wishlisted games
    return RefreshIndicator(
      onRefresh: () => _refreshTrendingGamesGrid(context),
      child: Consumer<Games>(builder: (context, gamesData, child) {
        final trendingGames = (showWishlistOnly) ? gamesData.wishlist : gamesData.trendingGames;
        if (trendingGames.isEmpty && showWishlistOnly) {
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
                  child: Text("You currently don't have any trending games in your wishlist."),
                ),
              );
            },
          );
        } else if (trendingGames.isEmpty) {
          return ListView.builder(
            itemCount: 1,
            itemBuilder: (context, index) {
              return const Center();
            },
          );
        }
        return GridView.builder(
          scrollDirection: (isPortrait) ? Axis.vertical : Axis.horizontal,
          padding: const EdgeInsets.all(10),
          itemCount: trendingGames.length,
          itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
            value: trendingGames[index],
            child: TrendingGameItem(key: Key(trendingGames[index].id)),
            //ProductItem(key: Key(games[index].id)),
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: (isPortrait) ? 1 / 0.875 : 1 / 1, //width then height
            crossAxisSpacing: 10,
            mainAxisSpacing: 5,
          ),
        );
      }),
    );
    //});
  }
}
