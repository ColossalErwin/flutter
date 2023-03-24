//packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//providers
import '../providers/game.dart';
import '../providers/games.dart';
//screens
import '../screens/edit_game_screen/edit_game_experience_screen.dart';
import '../screens/edit_game_screen/edit_game_screen.dart';
import '../screens/game_detail_screen.dart';
import '../screens/manage_games_screen.dart';
//temp data
import '../temp_data/temp_data.dart' as temp_data;

class ManagedGameItem extends StatelessWidget {
  final String id;
  final String title;
  final double msrp;
  final Platform platform;
  //final String description;
  final String titleImageURL;
  const ManagedGameItem({
    Key? key,
    required this.id,
    required this.title,
    required this.titleImageURL,
    required this.msrp,
    required this.platform,
    //required this.description, //this parameter is for the undoDelete function
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    print('build managed game item');
    //int deletedIndex = -1;
    //there would be an error (try to access to ancestor widget - unsafe) if we don't store these
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final theme = Theme.of(context);
    final providedGames = Provider.of<Games>(context, listen: false);
    Game? deletedGame;
    bool? userUndoDelete = false;

    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        try {
          //deletedIndex = await providedGames.deleteGame(id);
          deletedGame = await providedGames.deleteGame(id, GamesOption.userGames);

          const Duration snackBarDuration = Duration(seconds: 3);
          //disable hidCurrentSnackBar to enable undo delete multiple deleted items
          scaffoldMessenger.hideCurrentSnackBar();
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                "Successfully deleted $title",
                textAlign: TextAlign.center,
              ),
              duration: snackBarDuration,
              action: SnackBarAction(
                textColor: Colors.red,
                label: "UNDO",
                onPressed: () {
                  userUndoDelete = true;
                  providedGames.undoDeleteGame(deletedGame);
                },
              ),
            ),
          );
          await Future.delayed(snackBarDuration).then((_) {
            //wait for user confirmation whether they undo the deleted item or not
            //if pass 5 seconds, put it to trash
            //deletedGame = null; //don't really need to set it to null here
          });
          if (userUndoDelete == false) {
            providedGames.putToTrash(deletedGame);
          }
        } catch (error) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text("Deleting failed!", textAlign: TextAlign.center),
            ),
          );
        }
      },
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text("Are you sure?"),
              content: const Text(
                "Deleted items would stay in the trash for 30 days. You can set your preference in the settings.",
              ),
              actions: [
                TextButton(
                  child: const Text("No"),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    //Navigator.of(context).pop would close the AlertDialog
                    //since the anonymous function needs to return a Future obj that contains boolean
                    //and ShowDialog can return a Future object
                    //we can pass a boolean value to the pop method inside AlertDialog
                    //this value would then become the boolean value return for the Future obj of showDialog
                  },
                ),
                TextButton(
                  child: const Text("Yes"),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
      },
      background: Container(
        color: Colors.grey,
        alignment: Alignment.centerRight,
        //padding: const EdgeInsets.only(right: 0),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Spacer(), //use to push elements of Rows/Columns
            Flexible(
              child: Container(
                color: Colors.grey,
                child: const Text(
                  "Move to trash",
                  textAlign: TextAlign.end,
                ),
              ),
            ),
            Flexible(
              child: Container(
                color: Colors.grey,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                margin: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 4,
                ),
                child: const Icon(
                  Icons.delete,
                  color: Colors.black,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ),
      //use InkWell to create an effect for ListTile
      //https://stackoverflow.com/questions/60040972/flutter-listtile-splash-ripple-effect-not-matching-border
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        onDoubleTap: () {
          Navigator.of(context).pushNamed(
            GameDetailScreen.routeName,
            arguments: id,
          );
        },

        onTap: () async {
          if (temp_data.managedItemTipsCounter2 == 0) {
            await showDialog<void>(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: const Text("Tips:"),
                  content: const Text(
                      "Double tap for a game detail.\n\nSwipe left to move a game to the trash."),
                  actions: [
                    TextButton(
                      child: const Text("Okay"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              },
            );
          }
          temp_data.managedItemTipsCounter2++;
          if (temp_data.managedItemTipsCounter2 == 3) {
            temp_data.managedItemTipsCounter2 = 0;
          }
        },

        onLongPress: () async {
          if (temp_data.managedItemTipsCounter1 == 0) {
            await showDialog<void>(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: const Text("Tips:"),
                  content: const Text(
                      "Double tap for a game detail.\n\nSwipe left to move a game to the trash."),
                  actions: [
                    TextButton(
                      child: const Text("Okay"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              },
            );
          }
          temp_data.managedItemTipsCounter1++;
          if (temp_data.managedItemTipsCounter1 == 3) {
            temp_data.managedItemTipsCounter1 = 0;
          }
        },
        splashColor: Colors.teal.withOpacity(0.7),
        //use InkWell to create an effect for ListTile
        //https://stackoverflow.com/questions/60040972/flutter-listtile-splash-ripple-effect-not-matching-border
        child: ListTile(
          /*
          onTap: () {
            Navigator.of(context).pushNamed(
              GameDetailScreen.routeName,
              arguments: id,
            );
          },
          */
          tileColor: (Theme.of(context).brightness == Brightness.light)
              ? const Color.fromARGB(223, 247, 245, 239)
              : null,
          leading: Hero(
            tag: "1st image$id",
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                  GameDetailScreen.routeName,
                  arguments: id,
                );
              },
              child: CircleAvatar(
                ///backgroundImage argument does not take a Widget,
                /// so we cannot use Image.network(imageURL).
                ///Instead, it takes a ImageProvider,
                ///and we have to use something like NetworkImage (a class object)
                backgroundImage: NetworkImage(titleImageURL),
              ),
            ),
          ),
          title: Text(title),
          //isThreeLine: true,
          subtitle: Text("\$$msrp, \n${platformToString(platform)}"),
          trailing: SizedBox(
            width: 100,
            child: FittedBox(
              child: Row(
                children: [
                  IconButton(
                    tooltip: "Edit this game",
                    icon: Icon(
                      Icons.edit,
                      color: (isDarkTheme) ? Colors.white70 : null,
                    ),
                    onPressed: () {
                      navigator.pushNamed(
                        EditGameScreen.routeName,
                        arguments: {
                          'id': id,
                          'returnRouteName': ManageGamesScreen.routeName,
                        },
                      );
                    },
                    color: theme.primaryColor,
                  ),
                  IconButton(
                    tooltip: "Edit gaming experience",
                    icon: Icon(
                      Icons.person_outlined,
                      color: (isDarkTheme) ? Colors.blueGrey : null,
                    ), //const Icon(Icons.edit_note),
                    onPressed: () {
                      navigator.pushNamed(
                        EditGameExperienceScreen.routeName,
                        arguments: {
                          'id': id,
                          'returnRouteName': ManageGamesScreen.routeName,
                        },
                      );
                    },
                    color: theme.primaryColor,
                  ),
                  IconButton(
                    tooltip: "Swipe left to put to trash",
                    icon: const Icon(
                      Icons.delete,
                      size: 17.5,
                    ),
                    color: (isDarkTheme) ? Colors.brown : Colors.black54,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            title: const Text("Are you sure you want to remove this game?"),
                            content: const Text(
                              "Swipe left to put it in the trash.",
                            ),
                            actions: [
                              TextButton(
                                child: const Text("Okay"),
                                onPressed: () async {
                                  navigator.pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
