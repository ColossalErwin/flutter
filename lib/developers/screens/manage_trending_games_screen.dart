//see: https://stackoverflow.com/questions/46651974/swipe-list-item-for-more-options-flutter
//for slideable package

//packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//providers
import '../../providers/games.dart';
//widgets
import '../../widgets/user_info.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/floating_button/draggable_floating_action_button.dart';
//manager widgets
import '../widgets/managed_trending_game_item.dart';
//screens
import './edit_trending_game_screen.dart';
//temp data
import '../../temp_data/user_info.dart' as user_info;

class ManageTrendingGamesScreen extends StatelessWidget {
  const ManageTrendingGamesScreen({Key? key}) : super(key: key);
  static const routeName = "/manage-trending-games";

  Future<void> _refreshGames(BuildContext ctx) async {
    await Provider.of<Games>(ctx, listen: false).fetchGames(GamesOption.trendingGames);
  }

  @override
  Widget build(BuildContext context) {
    print("build manage trending games screen");
    final parentKey = GlobalKey();
    return Scaffold(
      body: Stack(
        key: parentKey,
        children: [
          Scaffold(
            appBar: AppBar(
              title: const FittedBox(child: Text("Manage Trending Games")),
              actions: [
                IconButton(
                  tooltip: "More options",
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
                //if (user_info.userImageURL != null) UserAvatar(user_info.userImageURL),
                //userImageURL will not be null since we already fetch the user image; just to be careful
                UserInformation(
                  user_info.username,
                  user_info.userImageURL,
                  returnPageRouteName: ManageTrendingGamesScreen.routeName,
                ),
                //const UserInformation(null, null)
              ],
            ),
            //we use refresh in the case we delete something directly from the database server
            //and then reload our screen
            body: FutureBuilder(
              future: _refreshGames(context),
              builder: (ctx, asyncSnapshot) =>
                  asyncSnapshot.connectionState == ConnectionState.waiting
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : RefreshIndicator(
                          onRefresh: () => _refreshGames(context),
                          child: Consumer<Games>(
                            builder: (ctx, gamesData, child) => Padding(
                              padding: const EdgeInsets.all(8),
                              child: ListView.builder(
                                itemCount: gamesData.trendingGames.length,
                                itemBuilder: (ctx, index) {
                                  return Column(
                                    children: [
                                      ManagedTrendingGameItem(
                                        id: gamesData.trendingGames[index].id,
                                        title: gamesData.trendingGames[index].title,
                                        titleImageURL: gamesData.trendingGames[index].titleImageURL,
                                        msrp: gamesData.trendingGames[index].msrp,
                                        platform: gamesData.trendingGames[index].platform,
                                      ),
                                      const Divider(thickness: 2.1),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
            ),
            drawer: const AppDrawer(),
          ),
          draggableFloatingActionButtonBuilder(
            context: context,
            parentKey: parentKey,
            tooltip: "Add a trending game",
            icon: const Icon(Icons.playlist_add),
            handler: () {
              Navigator.of(context).pushNamed(EditTrendingGameScreen.routeName);
            },
            iconColor: Colors.black,
            backgroundColor: Colors.green,
          ),
        ],
      ),
    );
  }
}
