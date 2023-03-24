//packages
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
//providers
import '../providers/game.dart';
//screens
import '../screens/game_detail_screen.dart';

class GameItem extends StatelessWidget {
  //final GridOption option;
  const GameItem({
    Key? key,
    //this.option = GridOption.two,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    print("build game item");
    final Game providedGame = Provider.of<Game>(context, listen: false);
    final String platform = platformToString(providedGame.platform);
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black54 : null,
          border: Border.all(
            //color: Colors.red,
            width: 0.25,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: GestureDetector(
                  onTap: () {
                    /*
                      print('push game detail page');
                      Navigator.of(context).pushNamed(
                        GameDetailScreen.routeName,
                        arguments: providedGame.id,
                      );
                      */
                    Navigator.of(context).pushNamed(
                      GameDetailScreen.routeName,
                      arguments: providedGame.id,
                    );
                    /*
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        GameDetailScreen.routeName,
                        arguments: providedGame.id,
                        (route) => route.isFirst,
                        //ModalRoute.withName(GamesOverviewScreen.routeName),
                      );
                      */
                  },
                  child: GestureDetector(
                    onTap: () {
                      /*
                      print('push game detail page');
                      Navigator.of(context).pushNamed(
                        GameDetailScreen.routeName,
                        arguments: providedGame.id,
                      );
                      */
                      Navigator.of(context).pushNamed(
                        GameDetailScreen.routeName,
                        arguments: providedGame.id,
                      );
                      /*
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          GameDetailScreen.routeName,
                          arguments: providedGame.id,
                          (route) => route.isFirst,
                          //ModalRoute.withName(GamesOverviewScreen.routeName),
                      );
                      */
                    },
                    child: GridTile(
                      header: SizedBox(
                        height: constraints.maxHeight / 2.75,
                        child: GestureDetector(
                          onTap: () {
                            /*
                              print('push game detail page');
                              Navigator.of(context).pushNamed(
                                GameDetailScreen.routeName,
                                arguments: providedGame.id,
                              );
                              */
                            /*
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                GameDetailScreen.routeName,
                                arguments: providedGame.id,
                                (route) => route.isFirst,
                                //ModalRoute.withName(GamesOverviewScreen.routeName),
                              );
                              */
                            Navigator.of(context).pushNamed(
                              GameDetailScreen.routeName,
                              arguments: providedGame.id,
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 0, constraints.maxHeight / 10),
                            child: GridTileBar(
                              backgroundColor: Colors.black45,
                              title: FittedBox(
                                child: Text(
                                  (providedGame.platform == Platform.PS4_and_PS5 ||
                                          providedGame.platform == Platform.XBoxOneSX ||
                                          providedGame.platform == Platform.others)
                                      ? platform
                                      : "Platform:  $platform",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 13),
                                  softWrap: true,
                                ),
                              ),
                              subtitle: FittedBox(
                                child: Text(
                                  "MSRP:  \$${providedGame.msrp}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 13),
                                  softWrap: true,
                                ),
                              ),
                              trailing: Consumer<Game>(builder: (context, game, child) {
                                if (game.releaseDate != null) {
                                  return GestureDetector(
                                    onTap: () async {
                                      _showReleaseDatePicker(context, game);
                                    },
                                    child: FittedBox(
                                      child: Text(
                                        "${DateFormat.y().format(
                                          game.releaseDate!.toDate(),
                                        )}\nRelease",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }
                                return IconButton(
                                  icon: const Icon(
                                    Icons.edit_calendar,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    _showReleaseDatePicker(context, game);
                                  },
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                      // ignore: sized_box_for_whitespace
                      footer: Container(
                        height: constraints.maxHeight / 2.75,
                        child: GestureDetector(
                          onTap: () {
                            /*
                              print('push game detail page');
                              Navigator.of(context).pushNamed(
                                GameDetailScreen.routeName, arguments: providedGame.id,
                                
                                //arguments: GameDetailArguments(id: providedGame.id),
                              );
                               */
                            Navigator.of(context).pushNamed(
                              GameDetailScreen.routeName,
                              arguments: providedGame.id,
                            );
                            /*
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                GameDetailScreen.routeName,
                                arguments: providedGame.id,
                                (route) => route.isFirst,
                                //ModalRoute.withName(GamesOverviewScreen.routeName),
                              );
                              */
                          },
                          child: Container(
                            //color: Colors.grey,
                            margin: EdgeInsets.fromLTRB(0, constraints.maxHeight / 7.5, 0, 0),
                            child: GridTileBar(
                              backgroundColor: Colors.black45,
                              leading: Consumer<Game>(
                                builder: (ctx, game, _) => IconButton(
                                  tooltip: game.isDisliked ? "Undislike" : "Dislike",
                                  icon: Icon(
                                    game.isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                                    color: game.isDisliked
                                        ? const Color.fromARGB(255, 247, 240, 190)
                                        : Colors.yellow[50],
                                  ),
                                  onPressed: () async {
                                    game.toggleDisliked();
                                  },
                                  color: Colors.white,
                                ),
                              ),
                              //title: Container(), //to push the trailing item to the right
                              /*
                                title: Consumer<Game>(builder: (context, game, child) {
                                  if (game.releaseDate == null) {
                                    return GestureDetector(
                                      onLongPress: () {
                                        //showDiaLog or show snackbar that you have not added a release date for this one
                                      },
                                      onTap: () {
                                        //show pick date to pick release date
                                      },
                                      child: const Icon(
                                        Icons.calendar_month,
                                        size: 20,
                                      ),
                                    );
                                  }
                                  return Container();
                                }),
                                */
                              title: Consumer<Game>(builder: (context, game, child) {
                                return GestureDetector(
                                    onLongPress: () {
                                      //show a tooltip or snackbar "check to mark as have played"
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: (game.hasFinished)
                                              ? const Text(
                                                  "Uncheck to mark as have not played or have played but not finished yet.")
                                              : const Text("Check to mark as have finished."),
                                        ),
                                      );
                                    },
                                    child: Checkbox(
                                      fillColor: (game.hasFinished)
                                          ? MaterialStateProperty.all(Colors.transparent)
                                          : MaterialStateProperty.all(Colors.white38),
                                      checkColor: Colors.white, //Colors.green,
                                      onChanged: ((value) {
                                        game.toggleHasFinished();
                                      }),
                                      value: game.hasFinished,
                                    ));
                              }),
                              //this empty Container is to space the trailing element to the right
                              trailing: Consumer<Game>(
                                builder: (ctx, game, _) => IconButton(
                                  tooltip: game.isFavorite ? "Unfavorite" : "Favorite",
                                  icon: Icon(
                                    game.isFavorite ? Icons.star : Icons.star_border,
                                    color: Colors.red.withOpacity(0.9),
                                  ),
                                  onPressed: () {
                                    game.toggleFavorite();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          /*
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              GameDetailScreen.routeName,
                              arguments: providedGame.id,
                              (route) => route.isFirst,
                              //ModalRoute.withName(GamesOverviewScreen.routeName),
                            );
                            */

                          //print('push game detail page');

                          Navigator.of(context).pushNamed(
                            GameDetailScreen.routeName,
                            arguments: providedGame.id,
                          );
                        },
                        child: SizedBox(
                          child:
                              /*Hero(
                            tag: "1st image${providedGame.id}",
                            child: Image(
                              image: NetworkImage(providedGame.titleImageURL),
                              fit: BoxFit.cover,
                            ),
                          ),
                          */
                              /*FadeInImage(
                            placeholderErrorBuilder: (context, error, stackTrace) {
                              print(error);
                              return Image.asset("assets/images/ps5-placeholder.jpeg");
                            },

                            imageErrorBuilder: (context, error, stackTrace) {
                              print(error);
                              return const Image(
                                image: AssetImage("assets/images/404_thomas.png"),
                              );
                            },

                            placeholder: const AssetImage("assets/images/ps5-placeholder.jpeg"),
                            image: NetworkImage(providedGame.titleImageURL),
                            //see how to know the dimensions of an image: https://stackoverflow.com/questions/44665955/how-do-i-determine-the-width-and-height-of-an-image-in-flutter
                            //fit: BoxFit.fill,
                            fit: BoxFit.cover,
                            height: double.infinity,
                            //in order for landscape images to fit into the squared sizedbox
                          ),*/
                              Image(
                            image: NetworkImage(providedGame.titleImageURL),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print(error);
                              return const Image(
                                image: AssetImage("assets/images/404_thomas.png"),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black54 : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: FittedBox(
                child: SelectableText(
                  providedGame.title,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(
              height: 4,
            ),
          ],
        ),
      );
    });
  }
}

void _showReleaseDatePickerHelper(BuildContext context, Game game) {
  showDatePicker(
    initialDatePickerMode: DatePickerMode.year,
    //we are only interested in showing the year since these already passed their release date
    cancelText: "CANCEL",
    confirmText: "CONFIRM",
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1990),
    lastDate: DateTime(2099),
  ).then(
    (pickedYear) {
      if (pickedYear == null) {
        return;
      }
      game.pickReleaseYear(pickedYear);
    },
  );
}

Future<void> _showReleaseDatePicker(BuildContext context, Game game) async {
  if (game.releaseDate == null) {
    _showReleaseDatePickerHelper(context, game);
  } else {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Choose an option"),
          content: const Text("Pick another release date or remove this one."),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.delete),
              label: const Text("Remove"),
              onPressed: () {
                Navigator.of(context).pop();
                game.pickReleaseYear(null);
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.edit_calendar),
              label: const Text("Change"),
              onPressed: () {
                Navigator.of(context).pop();
                _showReleaseDatePickerHelper(context, game);
              },
            ),
          ],
        );
      },
    );
  }
}
