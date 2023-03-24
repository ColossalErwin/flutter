//see: https://stackoverflow.com/questions/46651974/swipe-list-item-for-more-options-flutter
//for slideable package

//packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//helpers
import '../helpers/custom_search_delegate_for_manage_games_screen.dart';
//widgets
import '../widgets/user_info.dart';
import '../widgets/app_drawer.dart';
import '../widgets/managed_game_item.dart';
import '../widgets/floating_button/draggable_floating_action_button.dart';
//providers
import '../providers/games.dart';
//screens
import './edit_game_screen/edit_game_screen.dart';
//temp data
import '../temp_data/user_info.dart' as user_info;

class ManageGamesScreen extends StatelessWidget {
  const ManageGamesScreen({Key? key}) : super(key: key);
  static const routeName = "/manage-games";

  Future<void> _refreshGames(BuildContext ctx) async {
    await Provider.of<Games>(ctx, listen: false).fetchGames(GamesOption.userGames);
  }

  @override
  Widget build(BuildContext context) {
    print("build manage games screen");
    final parentKey = GlobalKey();
    return Scaffold(
      body: Stack(
        key: parentKey,
        children: [
          Scaffold(
            /*
            bottomSheet: Container(
              padding: const EdgeInsets.all(8),
              height: 35,
              width: double.infinity,
              color: Colors.grey.withOpacity(0.25),
              child: const FittedBox(
                child: Text(
                  "TIPS: Swipe left to delete a game",
                  style: TextStyle(fontSize: 17),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            */
            appBar: _appBarBuilder(context),
            //we use refresh in the case we delete something directly from the database server
            //and then reload our screen
            body: /*FutureBuilder(
              future: _refreshGames(context),
              builder: (ctx, asyncSnapshot) =>
                  asyncSnapshot.connectionState == ConnectionState.waiting
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : */
                SafeArea(
              child: RefreshIndicator(
                onRefresh: () => _refreshGames(context),
                child: Consumer<Games>(
                  builder: (ctx, gamesData, child) => Padding(
                    padding: const EdgeInsets.all(8),
                    child: SafeArea(
                      child: ListView.builder(
                        itemCount: gamesData.games.length,
                        itemBuilder: (ctx, index) {
                          return Column(
                            children: [
                              ManagedGameItem(
                                id: gamesData.games[index].id,
                                title: gamesData.games[index].title,
                                titleImageURL: gamesData.games[index].titleImageURL,
                                msrp: gamesData.games[index].msrp,
                                platform: gamesData.games[index].platform,
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
            ),
            //),
            drawer: const AppDrawer(),
          ),
          draggableFloatingActionButtonBuilder(
            context: context,
            parentKey: parentKey,
            tooltip: "Add a game to your backlog",
            icon: const Icon(Icons.playlist_add),
            handler: () {
              Navigator.of(context).pushNamed(EditGameScreen.routeName);
            },
            iconColor: Colors.black,
            backgroundColor: Colors.blue.withOpacity(0.8),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _appBarBuilder(BuildContext context) {
    return AppBar(
      title: const FittedBox(child: Text("Manage My Backlog")),
      actions: [
        IconButton(
          tooltip: "Search",
          icon: const Icon(Icons.search),
          onPressed: () {
            showSearch(
              context: context,
              delegate: CustomSearchDelegateForManageGamesScreen(
                  games: Provider.of<Games>(context, listen: false).games),
            );
          },
        ),
        IconButton(
          tooltip: "Filters",
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            //showMenu here
          },
        ),
        //if (user_info.userImageURL != null) UserAvatar(user_info.userImageURL),
        //userImageURL will not be null since we already fetch the user image; just to be careful
        UserInformation(
          user_info.username,
          user_info.userImageURL,
          returnPageRouteName: ManageGamesScreen.routeName,
        ),
        //const UserInformation(null, null)
      ],
    );
  }
}
