//fix the issue where trash screen appears to have nothing and we have to reload it
//then it shows a lot -> wrong. Probably related to not using Future Builder
//so we probably have to use FutureBuilder anytime soon

//maybe if we want to use the floating button then we can't use Consumer

//see: https://stackoverflow.com/questions/46651974/swipe-list-item-for-more-options-flutter
//for slideable package

//packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//helpers
import '../helpers/custom_search_delegate_for_trash_screen.dart';
//providers
import '../providers/games.dart';
//widgets
import '../widgets/user_info.dart';
import '../widgets/app_drawer.dart';
import '../widgets/floating_button/draggable_floating_action_button.dart';
import '../widgets/trash_game_item.dart';
//temp data
import '../temp_data/user_info.dart' as user_info;

class TrashScreen extends StatelessWidget {
  const TrashScreen({Key? key}) : super(key: key);
  static const routeName = '/trash';

  Future<void> _refreshTrash(BuildContext ctx) async {
    await Provider.of<Games>(ctx, listen: false).fetchAndRemoveOldTrashGames();
  }

  Future<void> _restoreAllTrashGames(BuildContext ctx) async {
    await Provider.of<Games>(ctx, listen: false).restoreAllTrashGames();
  }

  Future<void> _emptyTrash(BuildContext ctx) async {
    await Provider.of<Games>(ctx, listen: false).emptyTrash();
  }
  /*
  bool _isTrashEmpty(BuildContext ctx) {
    if (Provider.of<Games>(ctx, listen: false).trashGames.isEmpty) {
      return true;
    }
    return false;
  }
  */

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    print("build trash screen");
    final parentKey = GlobalKey();
    //if we use refresh indicator and consumer, then we shouldn't use Provider here or else it would crash

    return Scaffold(
      body: Stack(
        key: parentKey,
        children: [
          Scaffold(
            appBar: AppBar(
              title: const FittedBox(child: Text("Trash")),
              actions: [
                Consumer<Games>(
                  builder: (context, gamesData, child) {
                    if (gamesData.trashGames.isEmpty) {
                      return Container();
                    }
                    return IconButton(
                      color: isDarkMode ? null : Colors.black,
                      tooltip: "Scraping some trash",
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        showSearch(
                          context: context,
                          delegate: CustomSearchDelegateForTrashScreen(
                              games: Provider.of<Games>(context, listen: false).trashGames),
                        );
                      },
                    );
                  },
                ),
                Consumer<Games>(
                  builder: (context, gamesData, child) {
                    if (gamesData.trashGames.isEmpty) {
                      return Container();
                    }
                    return IconButton(
                      color: isDarkMode ? Colors.red : Colors.black,
                      tooltip: "Empty Trash Bin",
                      icon: const Icon(Icons.delete_forever_outlined),
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Are you sure?"),
                              content: const Text(
                                  "This action will empty the trash and you cannot restore your games anymore."),
                              actions: [
                                TextButton(
                                  child: const Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    _emptyTrash(context);
                                    //await _restoreAllTrashGames(context);
                                    //setState(() {});
                                  },
                                  child: const Text("Okay"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                UserInformation(
                  user_info.username,
                  user_info.userImageURL,
                  returnPageRouteName: TrashScreen.routeName,
                ),
              ],
            ),
            //we use refresh in the case we delete something directly from the database server
            //and then reload our screen
            body: FutureBuilder(
              future: _refreshTrash(context),
              builder: (ctx, asyncSnapshot) => asyncSnapshot.connectionState ==
                      ConnectionState.waiting
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _refreshTrash(context),
                      child: Consumer<Games>(
                        builder: (ctx, gamesData, child) => Padding(
                          padding: const EdgeInsets.all(8),
                          child: (gamesData.trashGames.isEmpty)

                              //Refresh indicator only works with list view. so we have to put something inside ListView for it to actually show
                              ? ListView.builder(
                                  itemCount: 1,
                                  itemBuilder: (context, snapshot) {
                                    return Column(
                                      children: [
                                        const SizedBox(
                                          child: Text(
                                            "OOPS ... Your games're not here mate!",
                                            style: TextStyle(
                                              fontSize: 25,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(height: 25),
                                        Image.asset(
                                          "assets/images/trash_panda_in_trash_can.jpeg",
                                          fit: BoxFit.cover,
                                        ),
                                        const Text(
                                          "credit: u/nukeem14\nsource: https://www.reddit.com/r/trashpandas/comments/9yal3w/just_had_to_rescue_these_two_little_trash_pandas",
                                        ),
                                      ],
                                    );
                                  },
                                )
                              : ListView.builder(
                                  itemCount: gamesData.trashGames.length,
                                  itemBuilder: (ctx, index) {
                                    return Column(
                                      children: [
                                        TrashGameItem(
                                          id: gamesData.trashGames[index].id,
                                          title: gamesData.trashGames[index].title,
                                          titleImageURL: gamesData.trashGames[index].titleImageURL,
                                          msrp: gamesData.trashGames[index].msrp,
                                          platform: gamesData.trashGames[index].platform,
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

          //there's a problem, after refresh empty trash screen -> has trash screen
          //the button still has the _refresh function instead of restore all function
          //so we should also use Consumer for it
          //cannot use Consumer
          //maybe if we want to use the floating button then we can't use Consumer
          //should we not use Consumer and convert this widget to stateful

          Consumer<Games>(builder: (context, gamesData, child) {
            if (gamesData.trashGames.isEmpty) {
              return Container();
            }
            return draggableFloatingActionButtonBuilder(
              context: context,
              parentKey: parentKey,
              tooltip: "Restore",
              icon: const Icon(Icons.restore),
              handler: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Are you sure?"),
                      content: const Text("This action will restore ALL games from the trash."),
                      actions: [
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                            //setState(() {});
                          },
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await _restoreAllTrashGames(context);
                          },
                          child: const Text("Okay"),
                        ),
                      ],
                    );
                  },
                );
              },
              iconColor: Colors.black,
              backgroundColor: Colors.amber,
            );
          }),
        ],
      ),
    );
  }
}
