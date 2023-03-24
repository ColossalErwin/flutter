//packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//helpers
import '../../helpers/custom_route.dart';
//providers
import '../../providers/game.dart';
import '../../providers/games.dart';
//screens
import '../screens/edit_trending_game_screen.dart';

class ManagedTrendingGameItem extends StatelessWidget {
  final String id;
  final String title;
  final double msrp;
  final Platform platform;
  //final String description;
  final String titleImageURL;
  const ManagedTrendingGameItem({
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
    print('build managed trending game item');
    //int deletedIndex = -1;
    //there would be an error (try to access to ancestor widget - unsafe) if we don't store these
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final theme = Theme.of(context);
    final providedTrendingGames = Provider.of<Games>(context, listen: false);
    Game? deletedGame;
    bool? userUndoDelete = false;

    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        try {
          //deletedIndex = await providedTrendingGames.deleteGame(id);
          deletedGame = await providedTrendingGames.deleteGame(id, GamesOption.userGames);

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
                label: "UNDO",
                onPressed: () {
                  userUndoDelete = true;
                  providedTrendingGames.undoDeleteGame(deletedGame);
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
            providedTrendingGames.putToTrash(deletedGame);
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
              content: const Text("Deleted items would go to the trash folder"),
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
        splashColor: Colors.teal.withOpacity(0.7),
        //use InkWell to create an effect for ListTile
        //https://stackoverflow.com/questions/60040972/flutter-listtile-splash-ripple-effect-not-matching-border
        child: ListTile(
          tileColor: const Color.fromARGB(223, 247, 245, 239),
          leading: CircleAvatar(
            ///backgroundImage argument does not take a Widget,
            /// so we cannot use Image.network(imageURL).
            ///Instead, it takes a ImageProvider,
            ///and we have to use something like NetworkImage (a class object)
            backgroundImage: NetworkImage(titleImageURL),
          ),
          title: Text(title),
          //isThreeLine: true,
          subtitle: Text("\$$msrp, \n${platformToString(platform)}"),
          trailing: SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  tooltip: "Edit this game",
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    navigator.push(
                      CustomRoute(
                        builder: (context) => EditTrendingGameScreen(
                          trendingGameID: id,
                        ),
                      ),
                    );
                  },
                  color: theme.primaryColor,
                ),
                IconButton(
                  tooltip: "Add this game to your collection",
                  icon: const Icon(Icons.add),
                  color: Colors.black45,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: const Text("Your backlog is about to grow"),
                          content: const Text(
                            "Are you sure?",
                          ),
                          actions: [
                            TextButton(
                              child: const Text("Cancel"),
                              onPressed: () {
                                navigator.pop(false);
                              },
                            ),
                            TextButton(
                              child: const Text("Okay"),
                              onPressed: () async {
                                navigator.pop(true);
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
    );
  }
}
