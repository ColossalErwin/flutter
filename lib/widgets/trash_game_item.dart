//packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//provider
import '../providers/game.dart';
import '../providers/games.dart';
//temp data
import '../temp_data/temp_data.dart' as temp_data;

class TrashGameItem extends StatelessWidget {
  final String id;
  final String title;
  final double msrp;
  final Platform platform;
  //final String description;
  final String titleImageURL;
  const TrashGameItem({
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    print('build trash game item');
    //int deletedIndex = -1;
    //there would be an error (try to access to ancestor widget - unsafe) if we don't store these
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    //final navigator = Navigator.of(context);
    final theme = Theme.of(context);
    final providedGames = Provider.of<Games>(context, listen: false);

    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        try {
          await providedGames.deleteGame(id, GamesOption.trashGames);
          const Duration snackBarDuration = Duration(seconds: 3);
          //disable hidCurrentSnackBar to enable undo delete multiple deleted items
          scaffoldMessenger.hideCurrentSnackBar();
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                "Permenantly deleted $title.",
                textAlign: TextAlign.center,
              ),
              duration: snackBarDuration,
            ),
          );
        } catch (error) {
          print(error);
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
              content: const Text("This action will PERMANENTLY delete this game."),
              actions: [
                TextButton(
                  child: const Text("No"),
                  onPressed: () {
                    Navigator.of(context).pop(false);
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
                  "Remove permanently",
                  textAlign: TextAlign.end,
                ),
              ),
            ),
            Flexible(
              child: Container(
                color: Colors.grey,
                alignment: Alignment.center,
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
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        onLongPress: () async {
          if (temp_data.trashItemTipsCounter == 0) {
            await showDialog<void>(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: const Text("Tips:"),
                  content:
                      const Text("Swipe or use the trash icon to remove this game permanently."),
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
          temp_data.trashItemTipsCounter++;
          if (temp_data.trashItemTipsCounter == 3) {
            temp_data.trashItemTipsCounter = 0;
          }
        },
        splashColor: Colors.green,
        child: ListTile(
          tileColor: isDarkMode ? null : const Color.fromARGB(223, 247, 245, 239),
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
                  tooltip: "Restore from trash",
                  icon: Icon(
                    Icons.restore,
                    color: isDarkMode ? Colors.yellow.withOpacity(0.67) : null,
                  ),
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Are you sure?"),
                          content: const Text("This action will restore this item."),
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
                                await providedGames.restoreTrashGame(
                                  providedGames.findByID(id, GamesOption.trashGames),
                                );
                              },
                              child: const Text("Okay"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  color: theme.primaryColor,
                ),
                IconButton(
                  tooltip: "Remove from backlog",
                  icon: const Icon(Icons.delete_forever_outlined),
                  color: isDarkMode ? Colors.brown : Colors.red,
                  onPressed: () async {
                    await showDialog<void>(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: const Text("Are you sure?"),
                          content: const Text(
                              "This action will permanently delete this game. You won't be able to restore it"),
                          actions: [
                            TextButton(
                              child: const Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text("Confirm"),
                              onPressed: () async {
                                try {
                                  Navigator.of(context).pop();
                                  await providedGames.deleteGame(id, GamesOption.trashGames);
                                  const Duration snackBarDuration = Duration(seconds: 3);
                                  //disable hidCurrentSnackBar to enable undo delete multiple deleted items
                                  scaffoldMessenger.hideCurrentSnackBar();
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Permenantly deleted $title.",
                                        textAlign: TextAlign.center,
                                      ),
                                      duration: snackBarDuration,
                                    ),
                                  );
                                } catch (error) {
                                  print(error);
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text("Deleting failed!", textAlign: TextAlign.center),
                                    ),
                                  );
                                }
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
