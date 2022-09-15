//should improve by using Cloud Firestore's feature for custom object

//dart
import 'dart:io';
//Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
//packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//helpers
import '../helpers/theme_data.dart';
//providers
import './user_preferences.dart';

import './game.dart';

/*
enum GridOption {
  one,
  two,
}
*/

enum GamesOption {
  userGames,
  trendingGames,
  wishlistGames,
  trashGames,
}

class Games with ChangeNotifier {
  int? _timeBeforeEmptyTrash;
  Games({
    required int? timeBeforeEmptyTrash,
  }) {
    _timeBeforeEmptyTrash = timeBeforeEmptyTrash;
  }
  int? get timeBeforeEmptyTrash {
    return _timeBeforeEmptyTrash;
  }

  Future<void> setTimeBeforeEmptyTrash(int? days, BuildContext context) async {
    _timeBeforeEmptyTrash = days;
    await updateTimeBeforeEmptyTrash(_timeBeforeEmptyTrash, context);
  }

  Future<void> updateTimeBeforeEmptyTrash(int? days, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "preferences": {
            'isDarkMode':
                Provider.of<UserPreferences>(context, listen: false).themeData == darkTheme,
            'timeBeforeEmptyTrash': days,
          }
        },
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });
      notifyListeners();
    } catch (error) {
      print(error);
      //rethrow;
    }
  }

  List<Game> _games = [];

  List<Game> get games {
    List<Game> tempGames = [..._games];
    tempGames.sort(
        (game1, game2) => encodePlatform(game2.platform).compareTo(encodePlatform(game1.platform)));
    return tempGames;
    //this is deep copy
    //spread _games list and create a new List, then return it
  }

  List<Game> getFilteredGames({
    required bool showAll,
    required bool showBacklog,
    required bool showFinished,
    required bool showHaveNotFinished,
    required bool hideDislikeds,
    bool isInFavoriteMode = false,
  }) {
    List<Game> filteredGames = [];

    filteredGames = (isInFavoriteMode ? favoriteGames : _games).where((game) {
      if (hideDislikeds == false || (hideDislikeds == true && game.isDisliked == false)) {
        return game.hasPlayed && game.hasFinished == false && showHaveNotFinished ||
            game.hasFinished && showFinished ||
            game.hasPlayed == false && showBacklog;
      } else {
        return false;
      }
    }).toList();
    return filteredGames;
  }

  List<Game> get favoriteGames {
    List<Game> tempFavGames = _games.where((game) => game.isFavorite).toList();
    tempFavGames.sort((game1, game2) => game1.title.compareTo(game2.title));
    return tempFavGames;
  }

  List<Game> _trendingGames = [];

  List<Game> get trendingGames {
    List<Game> tempGames = [..._trendingGames];
    tempGames.sort((game1, game2) {
      //80 is given as default value if anticipatedLevel is null
      return ((game2.anticipatedLevel == null) ? 80 : game2.anticipatedLevel as int)
          .compareTo((game1.anticipatedLevel == null) ? 80 : game1.anticipatedLevel as int);
    });
    return tempGames;
    //return [..._trendingGames];
  }

  List<Game> _trashGames = [];
  List<Game> get trashGames {
    List<Game> tempGames = [..._trashGames];
    tempGames.sort((game1, game2) {
      Timestamp timestamp1 = game1.deletedTime as Timestamp;
      Timestamp timestamp2 = game2.deletedTime as Timestamp;
      DateTime date1 = timestamp1.toDate();
      DateTime date2 = timestamp2.toDate();
      return date1.compareTo(date2);
    });
    return tempGames;
  }

  List<Game> _wishlist = [];
  List<Game> get wishlist {
    List<Game> tempGames = [..._wishlist];
    tempGames.sort((game1, game2) {
      //80 is given as default value if anticipatedLevel is null
      return ((game2.anticipatedLevel == null) ? 80 : game2.anticipatedLevel as int)
          .compareTo((game1.anticipatedLevel == null) ? 80 : game1.anticipatedLevel as int);
    });
    return tempGames;
  }
  Game findByID(String id, GamesOption gamesOption) {
    if (gamesOption == GamesOption.userGames) {
      return _games.firstWhere((game) => game.id == id);
    } else if (gamesOption == GamesOption.trendingGames) {
      return _trendingGames.firstWhere((game) => game.id == id);
    } else {
      return _trashGames.firstWhere((game) => game.id == id);
    }
  }

  //setEmpty helps we clear data
  //so that the next user trying to log in to the same device would not see any info
  //of the previous user even though it's just a flash
  void reset() {
    _games = [];
    _trendingGames = [];
    _wishlist = [];
    _trashGames = [];
    notifyListeners();
  }

  Future<String> getUserImageURL() async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then(
      (document) {
        return document['image_url'];
      },
    );
  }

  Future<void> restoreTrashGame(Game restoredGame) async {
    print("restoreTrashGame function");
    //should delete a game from trashGames first since it would show that all the trash UI first
    //if we add a game first then delete after that, it would takes a long time to add that game first and then show it on the trash UI
    await deleteGame(
      restoredGame.id,
      GamesOption.trashGames,
      isRestoreMode: true,
    );
    print("delete trash game");
    //not only we add it back to _games, we also must remove it in the trash
    await addGame(
      restoredGame.copyWithMutable(),
      GamesOption.userGames,
      keepID: true,
      //the restore argument is useful in case we don't want to have duplicate items when we restore something that's already there
    );
    print("restore game");
  }

  Future<void> restoreAllTrashGames() async {
    //don't use for each since it would cause the below error
    //Exception: Concurrent modification during iteration
    while (_trashGames.isNotEmpty) {
      await restoreTrashGame(_trashGames.last);
    }
  }

  Future<void> emptyTrash() async {
    while (_trashGames.isNotEmpty) {
      //deleteGame(_trashGames.last.id, GamesOption.trashGames);
      //this is actually inefficient since it uses a search id function
      //we just need to delete the trashGames list from end to its first element (array deletion is O(1) if it's delete last element)
      //so we should add another parameter for the deleteGame function
      //isDeleteLast = true
      await deleteGame(
        _trashGames.last.id,
        GamesOption.trashGames,
        isDeleteLast: true, //delete array from last to first is efficient
      );
    }
  }

  Future<void> fetchAndRemoveOldTrashGames() async {
    //remember to remove an item after 30 days
    //or have a filter whether users want to remove an item after 30 days
    try {
      bool containsTrashGamesKey = false;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then(
        ((docSnapShot) {
          //see: https://stackoverflow.com/questions/69108424/cannot-check-containskey-on-documentsnapshot
          containsTrashGamesKey =
              (docSnapShot.data() as Map<String, dynamic>).containsKey('trashGames');
        }),
      );
      if (containsTrashGamesKey == false) {
        return;
      }

      final List<Game> loadedTrashGames = [];
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then(
        ((value) async {
          final trashGamesList = value["trashGames"] as List<dynamic>;
          for (final trashGame in trashGamesList) {
            List<String> urls = [];
            for (final url in trashGame['imageURLs']) {
              urls.add(url as String);
            }
            List<String> userURLs = [];
            if (trashGame['userImageURLs'] != null) {
              for (final url in trashGame['userImageURLs']) {
                userURLs.add(url as String);
              }
            }

            //should have a compare logic here
            //then remove it directly from here using update Array remove
            final deletedTime = trashGame['deletedTime'] as Timestamp;
            DateTime currentDate = Timestamp.now().toDate();
            DateTime deletedDate = deletedTime.toDate();

            if (currentDate.difference(deletedDate) > Duration(days: _timeBeforeEmptyTrash ?? 30)) {
              print("consider deleting old trash");
              //delete after 30 days of not restoration
              //only activate when users go to trash screen, so there's a way to keep data if pass 30 days
              //as long as users don't go to trash screen
              //might consider using Firebase functions???
              //since we remove the item permanently, we don't really need to use await? or do we?

              if (trashGame['titleImageURL'].startsWith(
                  'https://firebasestorage.googleapis.com/v0/b/video-games-backlog.appspot.com/o/users%2F${FirebaseAuth.instance.currentUser!.uid}')) {
                try {
                  final ref = FirebaseStorage.instance.refFromURL(trashGame['titleImageURL']);
                  await ref.delete().onError((error, stackTrace) {
                    print(error);
                    print(stackTrace.toString());
                  });
                } catch (error) {
                  print(error);
                  // //rethrow;
                }
              }

              if (trashGame['userTitleImageURL'].startsWith(
                  'https://firebasestorage.googleapis.com/v0/b/video-games-backlog.appspot.com/o/users%2F${FirebaseAuth.instance.currentUser!.uid}')) {
                try {
                  final ref = FirebaseStorage.instance.refFromURL(trashGame['userTitleImageURL']);
                  await ref.delete().onError((error, stackTrace) {
                    print(error);
                    print(stackTrace.toString());
                  });
                } catch (error) {
                  print(error);
                  ////rethrow;
                }
              }

              for (String url in urls) {
                if (url.startsWith(
                    'https://firebasestorage.googleapis.com/v0/b/video-games-backlog.appspot.com/o/users%2F${FirebaseAuth.instance.currentUser!.uid}')) {
                  try {
                    final ref = FirebaseStorage.instance.refFromURL(url);
                    await ref.delete().onError((error, stackTrace) {
                      print(error);
                      print(stackTrace.toString());
                    });
                  } on FirebaseException catch (e) {
                    print(e);
                  } catch (error) {
                    print(error);
                    ////rethrow;
                  }
                }
              }

              for (String url in userURLs) {
                if (url.startsWith(
                    'https://firebasestorage.googleapis.com/v0/b/video-games-backlog.appspot.com/o/users%2F${FirebaseAuth.instance.currentUser!.uid}')) {
                  try {
                    final ref = FirebaseStorage.instance.refFromURL(url);
                    await ref.delete().onError((error, stackTrace) {
                      print(error);
                      print(stackTrace.toString());
                    });
                  } on FirebaseException catch (e) {
                    print(e);
                  } catch (error) {
                    print(error);
                    ////rethrow;
                  }
                }
              }

              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update(
                //update will do nothing if we try to add an instance of game that already exists (every field is the same)
                //so we should reflect this logic when dealing with _games too
                {
                  "trashGames": FieldValue.arrayRemove(
                    [
                      {
                        'deletedTime': deletedTime,
                        'id': trashGame['id'] as String,
                        'title': trashGame['title'] as String,
                        'description': trashGame['description'] as String,
                        'longDescription': trashGame['longDescription'] as String?,
                        'msrp': trashGame['msrp'].toDouble(),
                        'platform': trashGame['platform'] as int,
                        'titleImageURL': trashGame['titleImageURL'] as String,
                        'imageURLs': urls,
                        'isFavorite': trashGame['isFavorite'] as bool,
                        'isDisliked': trashGame['isDisliked'] as bool,
                        'hasFinished': trashGame['hasFinished'] as bool,
                        'hasPlayed': trashGame['hasPlayed'] as bool,
                        'purchasePrice': trashGame['purchasePrice'] as double?,
                        'userDescription': trashGame['userDescription'] as String?,
                        'userTitleImageURL': trashGame['userTitleImageURL'] as String?,
                        'userImageURLs': (trashGame['userImageURLs'] == null) ? null : userURLs,
                        'lastPlayDate': trashGame['lastPlayDate'] as Timestamp?,
                        'userRating': trashGame['userRating'] as int?,
                        'releaseDate': trashGame['releaseDate'] as Timestamp?,
                      },
                    ],
                  ),
                },
              );

              //remove then continue to the next element of array
              continue;
            }

            final addedTrashGame = Game(
              deletedTime: deletedTime,
              id: trashGame['id'] as String,
              description: trashGame['description'] as String,
              longDescription: trashGame['longDescription'] as String?,
              title: trashGame['title'] as String,
              titleImageURL: trashGame['titleImageURL'] as String,
              msrp: trashGame['msrp'].toDouble(),
              imageURLs: urls,
              platform: decodePlatform(trashGame['platform']),
              isFavorite: trashGame['isFavorite'] as bool,
              isDisliked: trashGame['isDisliked'] as bool,
              hasFinished: trashGame['hasFinished'] as bool,
              hasPlayed: trashGame['hasPlayed'] as bool,
              purchasePrice: trashGame['purchasePrice'] as double?,
              userDescription: trashGame['userDescription'] as String?,
              lastPlayDate: trashGame['lastPlayDate'],
              userImageURLs: (trashGame['userImageURLs'] == null) ? null : userURLs,
              userRating: decodeRating(trashGame['userRating'] as int?),
              userTitleImageURL: trashGame['userTitleImageURL'] as String?,
              releaseDate: trashGame['releaseDate'] as Timestamp?,
            );
            loadedTrashGames.add(addedTrashGame);
          }
          _trashGames = loadedTrashGames;
        }),
      );
      notifyListeners();
    } on FirebaseException catch (error) {
      print(error);
    } catch (error) {
      print(error);
      // //rethrow;
    }
  }

//this function is for fetching userGames, trendingGames, or wishlistGames
//wishlist is copied of wishlisted trendingGames, but in user's data
  Future<void> fetchGames(GamesOption gamesOption) async {
    print("fetch Games started. Load option is:");
    print(gamesOption);
    try {
      bool containsGames = false;
      await FirebaseFirestore.instance
          .collection((gamesOption == GamesOption.trendingGames) ? "trending_games" : "users")
          .doc((gamesOption == GamesOption.trendingGames)
              ? "9M3SDp36oHDhBJ0AF1vM"
              : FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then(
        ((docSnapShot) async {
          //see: https://stackoverflow.com/questions/69108424/cannot-check-containskey-on-documentsnapshot
          containsGames = (docSnapShot.data() == null)
              ? false
              : (docSnapShot.data())!
                  .containsKey((gamesOption == GamesOption.wishlistGames) ? 'wishlist' : 'games');
          if (containsGames == false) {
            return;
          }
          final List<Game> loadedGames = [];

          //print(value);
          //print(value["games"]);

          final gamesList =
              docSnapShot[(gamesOption == GamesOption.wishlistGames) ? "wishlist" : "games"]
                  as List<dynamic>;
          for (final Map<String, dynamic> element in gamesList) {
            List<String> urls = [];
            for (final elem in element['imageURLs']) {
              urls.add(elem as String);
            }
            List<String>? userURLs = [];
            if (element.containsKey('userImageURLs')) {
              if (element['userImageURLs'] != null) {
                for (final elem in element['userImageURLs']) {
                  userURLs.add(elem as String);
                }
              } else {
                userURLs = null;
              }
            }

            final addedGame = Game(
              id: element['id'] as String,
              description: element['description'] as String,
              longDescription: element['longDescription'] as String?,
              title: element['title'] as String,
              titleImageURL: element['titleImageURL'] as String,
              msrp: element['msrp'].toDouble(),
              //in the case if msrp is int we use this or else it would throw the error type int is not a subtype of type double
              imageURLs: urls,
              platform: decodePlatform(element['platform']),
              //filters
              isFavorite: element.containsKey('isFavorite') ? element['isFavorite'] as bool : false,
              isDisliked: element.containsKey('isDisliked') ? element['isDisliked'] as bool : false,
              hasFinished:
                  element.containsKey('hasFinished') ? element['hasFinished'] as bool : false,
              hasPlayed: element.containsKey('hasPlayed') ? element['hasPlayed'] as bool : false,
              //users
              purchasePrice: (element.containsKey('purchasePrice') == false)
                  ? null
                  : (element['purchasePrice'] != null)
                      ? element['purchasePrice'].toDouble() as double?
                      : null,
              userDescription: element.containsKey('userDescription')
                  ? element['userDescription'] as String?
                  : null,
              userRating: element.containsKey('userRating')
                  ? decodeRating(element['userRating'] as int?)
                  : null,
              userTitleImageURL:
                  element.containsKey('userTitleImageURL') ? element['userTitleImageURL'] : null,
              lastPlayDate: element.containsKey('lastPlayDate') ? element['lastPlayDate'] : null,
              userImageURLs: userURLs,
              //trending game
              releaseDate:
                  element.containsKey('releaseDate') ? element['releaseDate'] as Timestamp? : null,
              anticipatedLevel: element.containsKey('anticipatedLevel')
                  ? (element['anticipatedLevel'] as int?)
                  //we actually shouldn't give anticipatedLevel a default value here
                  //instead give it a temporary default value in the sort function
                  //Reason: suppose on the database, the anticipated Level is null
                  //and we set its value here to be 80, then arrayRemove would fail since it couldn't find the object (80 != null)
                  //arrayRemove couldn't find the exact match for the game!
                  : null,
            );
            loadedGames.add(addedGame);
          }
          //we use loadedGames since if we refresh and use _games.add(addedGame) then we would fetch and add the same data
          //->so we need loadedGames as a temporary List for each fetching

          if (gamesOption == GamesOption.userGames) {
            _games = loadedGames;
          } else if (gamesOption == GamesOption.trendingGames) {
            _trendingGames = loadedGames;
          } else if (gamesOption == GamesOption.wishlistGames) {
            _wishlist = loadedGames;
          }
          notifyListeners();
        }),
      ).onError((error, stackTrace) {
        print("fetch data error");
        print(error);
        print(stackTrace.toString());
      });
    } on FirebaseException catch (error) {
      print(error);
    } catch (error) {
      //print(error);
      //rethrow;
    }
  }

  //this function should be Future bool so that we know if we add something successfully or not

  Future<bool> addTrendingGameToCollection(Game addedTrendingGame, BuildContext ctx) async {

    if (trashGames.isEmpty) {
      await fetchAndRemoveOldTrashGames();
    }

    bool? hasAdded;

    String? detailedDescription;

    if (addedTrendingGame.longDescription != null) {
      detailedDescription = addedTrendingGame.longDescription!.replaceAll('~', '\n');
    }
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then(
        ((docSnapShot) async {
          //see: https://stackoverflow.com/questions/69108424/cannot-check-containskey-on-documentsnapshot
          bool containsTrendingGameIDsKey = false;
          containsTrendingGameIDsKey =
              (docSnapShot.data() as Map<String, dynamic>).containsKey('trendingGameIDs');
          if (containsTrendingGameIDsKey == false) {
            hasAdded = true;
            addGame(
              addedTrendingGame.copyWithMutable(
                id: addedTrendingGame.id + Timestamp.now().toString(),
                longDescription: detailedDescription,
                anticipatedLevel: null,
              ),
              GamesOption.userGames,
            );
            await FirebaseFirestore.instance
                .collection("users")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .update(
              {
                "trendingGameIDs": FieldValue.arrayUnion(
                  [
                    addedTrendingGame.id,
                  ],
                ),
              },
            ).onError((error, stackTrace) {
              print(error);
              print(stackTrace.toString());
            });

            return true;
          } else {
            bool containsID = false;

            for (final String id in docSnapShot.data()!['trendingGameIDs']) {
              if (addedTrendingGame.id == id) {
                containsID = true;
                break;
              }
            }
            if (containsID == true) {
              //if there are duplicates, then notify the users, then ask if he/she wants to keep or remove them before adding
              int duplicateIndex = 0;
              List<int> duplicateIndices = [];
              for (Game game in games) {
                if (game.id.startsWith(addedTrendingGame.id)) {
                  duplicateIndices.add(duplicateIndex);
                }
                duplicateIndex++;
              }
              int trashDuplicateIndex = 0;
              List<int> trashDuplicateIndices = [];
              
              //IMPORTANT for checking duplicates
              //this would yield 0 if we have not fetched trash games
              print("trash games length is");
              print(trashGames.length);
              //since the only way to fetch trash games is to call fetch trash (we do that whenever we enter trash screen)
              //but if we did not go there before clicking the add button, then trash Games have not been fetched and trashGames length is zero
              //while it's not actually zero
              //therefore we have to call fetchTrash here
              for (Game trashGame in trashGames) {
                if (trashGame.id.startsWith(addedTrendingGame.id)) {
                  trashDuplicateIndices.add(trashDuplicateIndex);
                }
                trashDuplicateIndex++;
              }
              int totalDuplicates = duplicateIndices.length + trashDuplicateIndices.length;
              if (totalDuplicates > 0) {
                await showDialog<void>(
                  context: ctx,
                  builder: (ctx) {
                    return AlertDialog(
                      title: const Text("Important:."),
                      content: (duplicateIndices.isNotEmpty && trashDuplicateIndices.isNotEmpty)
                          ? Text(
                              "Our records indicate that you have $totalDuplicates duplicates of this game in your collection, with ${trashDuplicateIndices.length} in your trash.",
                            )
                          : (trashDuplicateIndices.isNotEmpty && duplicateIndices.isEmpty)
                              ? Text(
                                  "Our records indicate that you have $totalDuplicates of this game in your trash.",
                                )
                              : Text(
                                  "Our records indicate that you have $totalDuplicates duplicate(s) of this game in your collection.",
                                ),
                      actions: [
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () {
                            hasAdded = false;
                            Navigator.of(ctx).pop();
                          },
                        ),
                        TextButton(
                          child: (totalDuplicates > 1)
                              ? Text(
                                  "Proceed and remove $totalDuplicates duplicate(s).",
                                  textAlign: TextAlign.end,
                                )
                              : const Text(
                                  "Proceed and remove the duplicate.",
                                  textAlign: TextAlign.end,
                                ),
                          onPressed: () async {
                            await showDialog<bool>(
                              context: ctx,
                              builder: (ctx) {
                                return AlertDialog(
                                  title: const Text("Are you sure?"),
                                  content: const Text(
                                      "This action cannot be undone. The duplicate(s) would be permanently removed."),
                                  actions: [
                                    TextButton(
                                      child: const Text("Cancel"),
                                      onPressed: () {
                                        hasAdded = false;
                                        Navigator.of(ctx).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text("Proceed"),
                                      onPressed: () async {
                                        hasAdded = true;
                                        Navigator.of(ctx).pop();
                                        Navigator.of(ctx).pop();
                                        //also needs to update the database
                                        //remove from _games

                                        final List<String> removedGameIDs = [];
                                        for (final Game game in _games) {
                                          if (game.id.startsWith(addedTrendingGame.id)) {
                                            removedGameIDs.add(game.id);
                                          }
                                        }
                                        for (String id in removedGameIDs) {
                                          deleteGame(id, GamesOption.userGames);
                                        }
                                        final List<String> removedTrashGameIDs = [];
                                        for (final Game trashGame in _trashGames) {
                                          if (trashGame.id.startsWith(addedTrendingGame.id)) {
                                            removedTrashGameIDs.add(trashGame.id);
                                          }
                                        }
                                        for (String id in removedTrashGameIDs) {
                                          deleteGame(id, GamesOption.trashGames);
                                        }
                                        //try to improve the code using stored indices arrays instead of searching a game using ids again

                                        await addGame(
                                          addedTrendingGame.copyWithMutable(
                                            id: addedTrendingGame.id + Timestamp.now().toString(),
                                            longDescription: detailedDescription,
                                            anticipatedLevel: null,
                                          ),
                                          GamesOption.userGames,
                                          keepID: true,
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        TextButton(
                          child: const Text(
                            "Proceed and keep all duplicate(s).",
                            textAlign: TextAlign.end,
                          ),
                          onPressed: () async {
                            await showDialog<bool>(
                              context: ctx,
                              builder: (ctx) {
                                return AlertDialog(
                                  title: const Text("Are you sure?"),
                                  content: const Text(
                                    "This would add another duplicate to your collection.",
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text("Cancel"),
                                      onPressed: () {
                                        hasAdded = false;
                                        Navigator.of(ctx).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text("Proceed"),
                                      onPressed: () async {
                                        hasAdded = true;
                                        Navigator.of(ctx).pop();
                                        Navigator.of(ctx).pop();
                                        addGame(
                                          addedTrendingGame.copyWithMutable(
                                            id: addedTrendingGame.id + Timestamp.now().toString(),
                                            longDescription: detailedDescription,
                                            anticipatedLevel: null,
                                          ),
                                          GamesOption.userGames,
                                          keepID: true,
                                        );
                                      },
                                    )
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              } else {
                //if there are no duplicates even though there's the id in the array (there's also the keyword)
                hasAdded = true;
                addGame(
                  addedTrendingGame.copyWithMutable(
                    id: addedTrendingGame.id + Timestamp.now().toString(),
                    longDescription: detailedDescription,
                    anticipatedLevel: null,
                  ),
                  GamesOption.userGames,
                  keepID: true,
                );
              }
            } else {
              hasAdded = true;
              //if has trendingGameIDs keyword but not containing the id
              //just add and not showing any thing
              addGame(
                addedTrendingGame.copyWithMutable(
                  id: addedTrendingGame.id + Timestamp.now().toString(),
                  longDescription: detailedDescription,
                  anticipatedLevel: null,
                ),
                GamesOption.userGames,
                keepID: true,
              );

              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update(
                {
                  "trendingGameIDs": FieldValue.arrayUnion(
                    [
                      addedTrendingGame.id,
                    ],
                  ),
                },
              ).onError((error, stackTrace) {
                print(error);
                print(stackTrace.toString());
              });
              ;
            }
          }
        }),
      ).onError((error, stackTrace) {
        print("error adding trending game");
        print(error);
        print(stackTrace.toString());
      });
      notifyListeners();
    } catch (error) {
      print("Already in collection");
      print(error);
    }
    //print("Final return value is $hasAdded");
    return hasAdded ?? false;
  }

  Future<void> addGame(
    MutableGame mutableGame,
    GamesOption gamesOption, {
    bool keepID = false,
    File? imageFile,
    List<File>? imageFiles,
  }) async {
    print("addGame function");
    if (gamesOption == GamesOption.userGames) {
      String timestamp; //timestamp is used as id

      if (keepID == true) {
        //the restore option is useful in case we don't want to have duplicate items
        timestamp = mutableGame.id;
      } else {
        timestamp = Timestamp.now().toString();
      }
      print("time stamp is ${timestamp}");

      //post titleImageURL here to Firebase storage
      //then _addedGame.titleImageURL = url from firebase
      if (imageFile != null) {
        try {
          final ref = FirebaseStorage.instance
              .ref()
              .child('users')
              .child(FirebaseAuth.instance.currentUser!.uid)
              .child('games')
              .child(timestamp)
              .child('titleImageURL');
          await ref.putFile(imageFile).whenComplete(() => null).catchError((e) {
            print(e);
          });

          mutableGame.titleImageURL = await ref.getDownloadURL().catchError((e) {
            print(e);
          });
        } catch (error) {
          print(error);
          ////rethrow;
        }
      }
      if (imageFiles != null) {
        try {
          for (File imageFile in imageFiles) {
            final ref = FirebaseStorage.instance
                .ref()
                .child('users')
                .child(FirebaseAuth.instance.currentUser!.uid)
                .child('games')
                .child(timestamp)
                .child('imageURLs')
                .child(Timestamp.now().toString());
            await ref.putFile(imageFile).whenComplete(() => null).catchError((e) {
              print(e);
            });
            mutableGame.imageURLs.add(await ref.getDownloadURL().catchError((e) {
              print(e);
            }));
          }
        } on FirebaseException catch (error) {
          print(error);
        } catch (error) {
          print(error);
          //rethrow;
        }
      }
      
      final addedGame = mutableGame.copyWith(id: timestamp, releaseDate: mutableGame.releaseDate);

      try {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update(
          //update will do nothing if we try to add an instance of game that already exists (every field is the same)
          //so we should reflect this logic when dealing with _games too
          {
            "games": FieldValue.arrayUnion(
              [
                {
                  'id': timestamp,
                  'title': addedGame.title,
                  'description': addedGame.description,
                  'longDescription': addedGame.longDescription,
                  'msrp': addedGame.msrp,
                  'platform': encodePlatform(addedGame.platform),
                  'titleImageURL': addedGame.titleImageURL,
                  'imageURLs': addedGame.imageURLs,
                  //
                  'isFavorite': addedGame.isFavorite,
                  'isDisliked': addedGame.isDisliked,
                  'hasFinished': addedGame.hasFinished, //restore also uses addGame
                  'hasPlayed': addedGame.hasPlayed,
                  //user stuff
                  'userDescription': addedGame.userDescription,
                  'purchasePrice': addedGame.purchasePrice,
                  'userTitleImageURL': addedGame.userTitleImageURL,
                  'userImageURLs': addedGame.userImageURLs,
                  'lastPlayDate': addedGame.lastPlayDate,
                  'userRating': encodeRating(addedGame.userRating),
                  //
                  'releaseDate': addedGame.releaseDate, //should be optional in edit game screen
                },
              ],
            ),
          },
        ).onError((error, stackTrace) {
          print(error);
          print(stackTrace.toString());
        });
        _games.add(addedGame);
        notifyListeners();
      } on FirebaseException catch (error) {
        print(error);
      } catch (error) {
        //print(error);
        //rethrow;
      }
    } else if (gamesOption == GamesOption.trendingGames) {
      String timestamp;

      timestamp = Timestamp.now().toString();

      final addedGame = mutableGame.copyWith(id: timestamp);

      try {
        await FirebaseFirestore.instance
            .collection("trending_games")
            .doc("9M3SDp36oHDhBJ0AF1vM")
            .update(
          {
            "games": FieldValue.arrayUnion(
              [
                {
                  'id': timestamp,
                  'title': addedGame.title,
                  'description': addedGame.description,
                  'longDescription': addedGame.longDescription,
                  'msrp': addedGame.msrp,
                  'platform': encodePlatform(addedGame.platform),
                  'titleImageURL': addedGame.titleImageURL,
                  'imageURLs': addedGame.imageURLs,
                  //trending games
                  'anticipatedLevel': addedGame.anticipatedLevel,
                  'releaseDate': addedGame.releaseDate,
                },
              ],
            ),
          },
        ).onError((error, stackTrace) {
          print(error);
          print(stackTrace.toString());
        });
        _trendingGames.add(addedGame);
        notifyListeners();
      } on FirebaseException catch (error) {
        print(error);
      } catch (error) {
        //print(error);
        // //rethrow;
      }
    }
  }

  Future<void> updateGame({
    required String id,
    required Game initialGame,
    //can just pass initial value of imageURLs, we pass Game object since there would be other data
    //like userImageURLs that would share the same logic
    required Game editedGame,
    required GamesOption gamesOption,
    File? imageFile,
    List<File>? imageFiles,
    File? userImageFile,
    List<File>? userImageFiles,
    List<String> deletedStorageImageURLs = const [],
    List<String> deletedStorageUserImageURLs = const [],
  }) async {
    print("initial game userImageURLs");
    print("${initialGame.userImageURLs}");
    print("updateGame function");
    if (gamesOption == GamesOption.userGames) {
      final gameIndex = _games.indexWhere((game) => game.id == id);
    /*
    W/NetworkRequest(31639): No App Check token for request.
    E/StorageException(31639): StorageException has occurred.
    E/StorageException(31639): User does not have permission to access this object.
    E/StorageException(31639):  Code: -13021 HttpResult: 403
    E/StorageException(31639): {  "error": {    "code": 403,    "message": "Permission denied."  }}
    E/StorageException(31639): java.io.IOException: {  "error": {    "code": 403,    "message": "Permission denied."  }}
    E/StorageException(31639): 	at com.google.firebase.storage.network.NetworkRequest.parseResponse(NetworkRequest.java:445)
    ...
    */

    //SOLUTION: it turns out the reason we cannot use delete() in Firebase storage is because
    //we have not modified the storage rule
    //initially it only allows users read and create
    //we need write in order to delete

      if (gameIndex >= 0) {
        if (deletedStorageImageURLs.isNotEmpty) {
          try {
            for (String storageImageURL in deletedStorageImageURLs) {
              final ref = FirebaseStorage.instance.refFromURL(storageImageURL);
              //see find ref by url: https://stackoverflow.com/questions/49945312/delete-a-file-from-firebase-storage-using-download-url-with-cloud-functions
              await ref.delete().onError((error, stackTrace) {
                print(error);
                print(stackTrace.toString());
              });
            }
          } on FirebaseException catch (error) {
            print(error);
            //rethrow;
          } catch (error) {
            print(error);
            //rethrow;
          }
        }

        if (deletedStorageUserImageURLs.isNotEmpty) {
          try {
            for (String storageUserImageURL in deletedStorageUserImageURLs) {
              final ref = FirebaseStorage.instance.refFromURL(storageUserImageURL);
              //see find ref by url: https://stackoverflow.com/questions/49945312/delete-a-file-from-firebase-storage-using-download-url-with-cloud-functions
              await ref.delete().onError((error, stackTrace) {
                print(error);
                print(stackTrace.toString());
              });
            }
          } on FirebaseException catch (error) {
            print(error);
            //rethrow;
          } catch (error) {
            print(error);
            //rethrow;
          }
        }

        try {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update(
            {
              "games": FieldValue.arrayRemove(
                [
                  {
                    'description': initialGame.description, //_games[gameIndex].description,
                    'longDescription': initialGame.longDescription,
                    'id': initialGame.id,
                    'msrp': initialGame.msrp, //_games[gameIndex].msrp,
                    'platform': encodePlatform(initialGame.platform),
                    'title': initialGame.title, //_games[gameIndex].title,
                    'titleImageURL': initialGame.titleImageURL, //_games[gameIndex].titleImageURL,
                    'imageURLs': initialGame.imageURLs,
                    //IMPORTANT: avoid shallow copy for array (imageURLs and userImageURLs)
                    //REASON: shallow copy (arrays share the same address passed by value)
                    //since we modify imageURLs array, it affect others that share the same address
                    //also findById returns a value of the address and it's still shallow copy
                    //therefore, it's unreliable to use _games[index]
                    //MUST use initialGame, or array for initial imageURLs (deep copy to a temp array)
                    //filters
                    'isFavorite': initialGame.isFavorite, //_games[gameIndex].isFavorite,
                    'hasFinished': initialGame.hasFinished,
                    'hasPlayed': initialGame.hasPlayed,
                    'isDisliked': initialGame.isDisliked,
                    //user stuff
                    'purchasePrice': initialGame.purchasePrice, //_games[gameIndex].purchasePrice,
                    'userDescription': initialGame.userDescription,
                    'userTitleImageURL': initialGame.userTitleImageURL,
                    'userImageURLs': (initialGame.userImageURLs == null)
                        ? null
                        : (initialGame.userImageURLs!.isEmpty)
                            ? null
                            : initialGame.userImageURLs,
                    //use the above code instead
                    /*
                        (initialGame.userImageURLs != null && initialGame.userImageURLs!.isEmpty)
                            ? null
                            : initialGame.userImageURLs,
                    */
                    'lastPlayDate': initialGame.lastPlayDate,
                    'userRating': encodeRating(initialGame.userRating),
                    'releaseDate': initialGame.releaseDate,
                  },
                ],
              ),
            },
          ).onError((error, stackTrace) {
            print(error);
            print(stackTrace.toString());
          });

          String? storedTitleImageURL;

          if (imageFile != null) {
            try {
              final ref = FirebaseStorage.instance
                  .ref()
                  .child('users')
                  .child(FirebaseAuth.instance.currentUser!.uid)
                  .child('games')
                  .child(id)
                  .child('titleImageURL');
              await ref.putFile(imageFile).whenComplete(() => null).catchError((e) {
                print(e);
              });

              storedTitleImageURL = await ref.getDownloadURL().catchError((e) {
                print(e);
              });
            } on FirebaseException catch (error) {
              print(error);
              //rethrow;
            } catch (error) {
              print(error);
              //rethrow;
            }
          }

          if (imageFiles != null && imageFiles.isNotEmpty) {
            try {
              for (File imageFile in imageFiles) {
                final ref = FirebaseStorage.instance
                    .ref()
                    .child('users')
                    .child(FirebaseAuth.instance.currentUser!.uid)
                    .child('games')
                    .child(id)
                    .child('imageURLs')
                    .child(Timestamp.now().toString());

                await ref.putFile(imageFile).whenComplete(() => null).catchError((e) {
                  print(e);
                });
                editedGame.imageURLs.add(await ref.getDownloadURL().catchError((e) {
                  print(e);
                }));
              }
            } on FirebaseException catch (error) {
              print(error);
              //rethrow;
            } catch (error) {
              print(error);
              //rethrow;
            }
          }

          String? storedUserTitleImageURL;

          if (userImageFile != null) {
            try {
              final ref = FirebaseStorage.instance
                  .ref()
                  .child('users')
                  .child(FirebaseAuth.instance.currentUser!.uid)
                  .child('games')
                  .child(id)
                  .child('userTitleImageURL');
              await ref.putFile(userImageFile).whenComplete(() => null).catchError((e) {
                print(e);
              });

              storedUserTitleImageURL = await ref.getDownloadURL().catchError((e) {
                print(e);
              });
              print(storedUserTitleImageURL);
            } on FirebaseException catch (error) {
              print(error);
              //rethrow;
            } catch (error) {
              print(error);
              //rethrow;
            }
          }

          if (userImageFiles != null && userImageFiles.isNotEmpty) {
            try {
              //we can not use add in case the list is null so we have to initialize it first
              editedGame.userImageURLs ??= [];

              for (File file in userImageFiles) {
                final ref = FirebaseStorage.instance
                    .ref()
                    .child('users')
                    .child(FirebaseAuth.instance.currentUser!.uid)
                    .child('games')
                    .child(id)
                    .child('userImageURLs')
                    .child(Timestamp.now().toString());

                await ref.putFile(file).whenComplete(() => null).catchError((e) {
                  print(e);
                });
                editedGame.userImageURLs!.add(await ref.getDownloadURL().catchError((e) {
                  print(e);
                }));
              }
            } on FirebaseException catch (error) {
              print(error);
              //rethrow;
            } catch (error) {
              print(error);
              //rethrow;
            }
          }

          await FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update(
            {
              "games": FieldValue.arrayUnion(
                [
                  {
                    'id': id,
                    'title': editedGame.title,
                    'description': editedGame.description,
                    'longDescription': editedGame.longDescription,
                    'msrp': editedGame.msrp,
                    'platform': encodePlatform(editedGame.platform),
                    'titleImageURL': storedTitleImageURL ?? editedGame.titleImageURL,
                    'imageURLs': editedGame.imageURLs,
                    //filters
                    'isFavorite': editedGame.isFavorite,
                    'hasFinished': editedGame.hasFinished,
                    'hasPlayed': editedGame.hasPlayed,
                    'isDisliked': editedGame.isDisliked,
                    //user stuff
                    'userDescription': editedGame.userDescription,
                    'purchasePrice': editedGame.purchasePrice,
                    'userTitleImageURL': storedUserTitleImageURL ?? editedGame.userTitleImageURL,
                    'userImageURLs': //editedGame.userImageURLs,
                        (editedGame.userImageURLs == null)
                            ? null
                            : (editedGame.userImageURLs!.isEmpty)
                                ? null
                                : editedGame.userImageURLs,
                    'lastPlayDate': editedGame.lastPlayDate,
                    'userRating': encodeRating(editedGame.userRating),
                    //when add a game from trending -> collection
                    'releaseDate': editedGame.releaseDate,
                  },
                ],
              ),
            },
          ).onError((error, stackTrace) {
            print(error);
            print(stackTrace.toString());
          });
          _games[gameIndex] = editedGame.copyWith(
            id: id,
            titleImageURL: (storedTitleImageURL == null) ? null : storedTitleImageURL,
            userTitleImageURL: (storedUserTitleImageURL == null) ? null : storedUserTitleImageURL,
            //because userTitleImageURLs could be null at the begininning, but if there files to add, it is not null anymore
            //we also have to update it value
            //userImageURLs: editedGame.userImageURLs,
          );
          notifyListeners();
        } on FirebaseException catch (error) {
          print(error);
          //rethrow;
        } catch (error) {
          //print(error);
          //rethrow;
        }
      } else {
        print("Index is: $gameIndex");
      }
    } else if (gamesOption == GamesOption.trendingGames) {
      final trendingGameIndex = _trendingGames.indexWhere((trendingGame) => trendingGame.id == id);
      if (trendingGameIndex >= 0) {
        print("_games length is ${_trendingGames.length}");
        print("Index is: $trendingGameIndex");
        try {
          await FirebaseFirestore.instance
              .collection("trending_games")
              .doc("9M3SDp36oHDhBJ0AF1vM")
              .update(
            {
              "games": FieldValue.arrayRemove(
                [
                  {
                    'id': id,
                    'title': _trendingGames[trendingGameIndex].title,
                    'description': _trendingGames[trendingGameIndex].description,
                    'msrp': _trendingGames[trendingGameIndex].msrp,
                    'anticipatedLevel': _trendingGames[trendingGameIndex].anticipatedLevel,
                    'platform': encodePlatform(_trendingGames[trendingGameIndex].platform),
                    'titleImageURL': _trendingGames[trendingGameIndex].titleImageURL,
                    'imageURLs': _trendingGames[trendingGameIndex].imageURLs,
                    'releaseDate': _trendingGames[trendingGameIndex].releaseDate,
                  },
                ],
              ),
            },
          ).onError((error, stackTrace) {
            print(error);
            print(stackTrace.toString());
          });

          await FirebaseFirestore.instance
              .collection("trending_games")
              .doc("9M3SDp36oHDhBJ0AF1vM")
              .update(
            {
              "games": FieldValue.arrayUnion(
                [
                  {
                    'id': id,
                    'title': editedGame.title,
                    'description': editedGame.description,
                    'longDescription': editedGame.longDescription,
                    'msrp': editedGame.msrp,
                    'platform': encodePlatform(editedGame.platform),
                    'titleImageURL': editedGame.titleImageURL,
                    'imageURLs': editedGame.imageURLs,
                    'anticipatedLevel': editedGame.anticipatedLevel,
                    'releaseDate': editedGame.releaseDate!,
                  },
                ],
              ),
            },
          ).onError((error, stackTrace) {
            print(error);
            print(stackTrace.toString());
          });

          //only perform the action if we successfully modify the database
          _trendingGames[trendingGameIndex] = editedGame; //update the game in local memory
          notifyListeners();
        } on FirebaseException catch (error) {
          print(error);
          //rethrow;
        } catch (error) {
          //print(error);
          //rethrow;
        }
      } else {
        print("Index is: $trendingGameIndex");
      }
    }
  }

  Future<Game?> deleteGame(
    String id,
    GamesOption gamesOption, {
    bool isDeleteLast = false,
    bool isRestoreMode = false,
    int? knownIndex,
  }) async {
    final int deletedGameIndex;
    final Game deletedGame;

    if (gamesOption == GamesOption.userGames) {
      if (isDeleteLast == true && _games.isNotEmpty) {
        deletedGameIndex = _games.length - 1;
      } else if (knownIndex != null) {
        deletedGameIndex = knownIndex;
      } else {
        deletedGameIndex = _games.indexWhere((game) => game.id == id);
      }

      deletedGame = _games.elementAt(deletedGameIndex); //remove from the list
      //but is still accessible before garbage collection
      _games.removeAt(deletedGameIndex);

    } else {
      if (isDeleteLast == true && _trashGames.isNotEmpty) {
        deletedGameIndex = _trashGames.length - 1;

      else {
        deletedGameIndex = _trashGames.indexWhere((trashGame) => trashGame.id == id);
      }

      deletedGame = _trashGames.elementAt(deletedGameIndex);
      _trashGames.removeAt(deletedGameIndex);
    }

    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
            (gamesOption == GamesOption.userGames)
                ? {
                    "games": FieldValue.arrayRemove(
                      [
                        {
                          'id': deletedGame.id,
                          'title': deletedGame.title,
                          'description': deletedGame.description,
                          'longDescription': deletedGame.longDescription,
                          'msrp': deletedGame.msrp,
                          'platform': encodePlatform(deletedGame.platform),
                          'titleImageURL': deletedGame.titleImageURL,
                          'imageURLs': deletedGame.imageURLs,
                          //filters
                          'isFavorite': deletedGame.isFavorite,
                          'hasFinished': deletedGame.hasFinished,
                          'hasPlayed': deletedGame.hasPlayed,
                          'isDisliked': deletedGame.isDisliked,
                          //
                          'userDescription': deletedGame.userDescription,
                          'purchasePrice': deletedGame.purchasePrice,
                          'userTitleImageURL': deletedGame.userTitleImageURL,
                          'userImageURLs': deletedGame.userImageURLs,
                          'lastPlayDate': deletedGame.lastPlayDate,
                          'userRating': encodeRating(deletedGame.userRating),
                          //
                          'releaseDate': deletedGame.releaseDate,
                        },
                      ],
                    ),
                  }
                : {
                    "trashGames": FieldValue.arrayRemove(
                      [
                        {
                          'deletedTime': deletedGame.deletedTime,
                          'id': deletedGame.id,
                          'title': deletedGame.title,
                          'description': deletedGame.description,
                          'longDescription': deletedGame.longDescription,
                          'msrp': deletedGame.msrp,
                          'platform': encodePlatform(deletedGame.platform),
                          'titleImageURL': deletedGame.titleImageURL,
                          'imageURLs': deletedGame.imageURLs,
                          'isFavorite': deletedGame.isFavorite,
                          'hasFinished': deletedGame.hasFinished,
                          'hasPlayed': deletedGame.hasPlayed,
                          'isDisliked': deletedGame.isDisliked,
                          'userDescription': deletedGame.userDescription,
                          'purchasePrice': deletedGame.purchasePrice,
                          'userTitleImageURL': deletedGame.userTitleImageURL,
                          'userImageURLs': deletedGame.userImageURLs,
                          'lastPlayDate': deletedGame.lastPlayDate,
                          'userRating': encodeRating(deletedGame.userRating),
                          'releaseDate': deletedGame.releaseDate,
                        },
                      ],
                    ),
                  },
          )
          .onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });
      if (gamesOption == GamesOption.trashGames && isRestoreMode == false) {
        if (deletedGame.titleImageURL.startsWith(
            'https://firebasestorage.googleapis.com/v0/b/video-games-backlog.appspot.com/o/users%2F${FirebaseAuth.instance.currentUser!.uid}')) {
          try {
            final ref = FirebaseStorage.instance.refFromURL(deletedGame.titleImageURL);
            await ref.delete().onError((error, stackTrace) {
              print(error);
              print(stackTrace.toString());
            });
          } catch (error) {
            print(error);
            //rethrow;
          }
        }

        if (deletedGame.userTitleImageURL != null) {
          if (deletedGame.userTitleImageURL!.startsWith(
              'https://firebasestorage.googleapis.com/v0/b/video-games-backlog.appspot.com/o/users%2F${FirebaseAuth.instance.currentUser!.uid}')) {
            try {
              final ref = FirebaseStorage.instance.refFromURL(deletedGame.userTitleImageURL!);
              await ref.delete().onError((error, stackTrace) {
                print(error);
                print(stackTrace.toString());
              });
            } catch (error) {
              print(error);
              //rethrow;
            }
          }
        }

        for (String url in deletedGame.imageURLs) {
          if (url.startsWith(
              'https://firebasestorage.googleapis.com/v0/b/video-games-backlog.appspot.com/o/users%2F${FirebaseAuth.instance.currentUser!.uid}')) {
            try {
              final ref = FirebaseStorage.instance.refFromURL(url);
              await ref.delete().onError((error, stackTrace) {
                print(error);
                print(stackTrace.toString());
              });
            } on FirebaseException catch (error) {
              print(error);
            } catch (error) {
              print(error);
            }
          }
        }

        if (deletedGame.userImageURLs != null) {
          for (String url in deletedGame.userImageURLs!) {
            if (url.startsWith(
                'https://firebasestorage.googleapis.com/v0/b/video-games-backlog.appspot.com/o/users%2F${FirebaseAuth.instance.currentUser!.uid}')) {
              try {
                final ref = FirebaseStorage.instance.refFromURL(url);
                await ref.delete().onError((error, stackTrace) {
                  print(error);
                  print(stackTrace.toString());
                });
              } on FirebaseException catch (error) {
                print(error);
              } catch (error) {
                print(error);
              }
            }
          }
        }
      }
      print("There's no error");

      return deletedGame;
    } on FirebaseException catch (error) {
      print(error);
    } catch (error) {
      if ((gamesOption == GamesOption.userGames)) {
        _games.insert(deletedGameIndex, deletedGame);
      } else {
        _trashGames.insert(deletedGameIndex, deletedGame);
      }
      notifyListeners();
      print(error);
      //rethrow;
      //null value would be returned on deleting fail
    }
    return null; // in case cannot delete
  }

  Future<void> undoDeleteGame(Game? deletedGame) async {

    if (deletedGame == null) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "games": FieldValue.arrayUnion(
            [
              {
                'id': deletedGame.id, //access in O(1) time
                'title': deletedGame.title,
                'description': deletedGame.description,
                'longDescription': deletedGame.longDescription,
                'msrp': deletedGame.msrp,
                'platform': encodePlatform(deletedGame.platform),
                'titleImageURL': deletedGame.titleImageURL,
                'imageURLs': deletedGame.imageURLs,
                //
                'isFavorite': deletedGame.isFavorite,
                'hasFinished': deletedGame.hasFinished,
                'hasPlayed': deletedGame.hasPlayed,
                'isDisliked': deletedGame.isDisliked,
                //
                'userDescription': deletedGame.userDescription,
                'purchasePrice': deletedGame.purchasePrice,
                'userTitleImageURL': deletedGame.userTitleImageURL,
                'userImageURLs': deletedGame.userImageURLs,
                'lastPlayDate': deletedGame.lastPlayDate,
                'userRating': encodeRating(deletedGame.userRating),
                //
                'releaseDate': deletedGame.releaseDate,
              },
            ],
          ),
        },
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });
      
      //actually we don't need to remember the deletedIndex, since we sort the array each time we undo delete,
      //so the item will be at its original position after the array being sorted

      _games.add(deletedGame);

      notifyListeners();
    } on FirebaseException catch (error) {
      print(error);
    } catch (error) {
      //print(error);
      //rethrow;
    }
  }

  Future<void> putToTrash(Game? deletedGame) async {
    if (deletedGame == null) {
      return;
    }
    try {
      Timestamp deletedTime = Timestamp.now();
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "trashGames": FieldValue.arrayUnion(
            [
              {
                'deletedTime': deletedTime,
                'id': deletedGame.id,
                //
                'title': deletedGame.title,
                'description': deletedGame.description,
                'longDescription': deletedGame.longDescription,
                'msrp': deletedGame.msrp,
                'platform': encodePlatform(deletedGame.platform),
                'titleImageURL': deletedGame.titleImageURL,
                'imageURLs': deletedGame.imageURLs,
                //
                'isFavorite': deletedGame.isFavorite,
                'hasFinished': deletedGame.hasFinished,
                'hasPlayed': deletedGame.hasPlayed,
                'isDisliked': deletedGame.isDisliked,
                //user
                'userDescription': deletedGame.userDescription,
                'purchasePrice': deletedGame.purchasePrice,
                'userTitleImageURL': deletedGame.userTitleImageURL,
                'userImageURLs': deletedGame.userImageURLs,
                'lastPlayDate': deletedGame.lastPlayDate,
                'userRating': encodeRating(deletedGame.userRating),
                //
                'releaseDate': deletedGame.releaseDate
              },
            ],
          ),
        },
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });
    } on FirebaseException catch (error) {
      print(error);
    } catch (error) {
      //print(error);
      //rethrow;
    }
  }

  Future<void> toggleWishlist(Game trendingGame, {required bool toggleOption}) async {
    //this function only works if we know if we know in advance a game is in wishlist or not
    //see the isInWIshlist function
    if (toggleOption == true) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "wishlist": FieldValue.arrayUnion(
            [
              {
                'id': trendingGame.id,
                'title': trendingGame.title,
                'description': trendingGame.description,
                'titleImageURL': trendingGame.titleImageURL,
                'imageURLs': trendingGame.imageURLs,
                'platform': encodePlatform(trendingGame.platform),
                'longDescription': trendingGame.longDescription,
                'msrp': trendingGame.msrp,
                'releaseDate': trendingGame.releaseDate,
                'anticipatedLevel': trendingGame.anticipatedLevel,
              },
            ],
          ),
        },
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });
      _wishlist.add(trendingGame);
    } else {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "wishlist": FieldValue.arrayRemove(
            [
              {
                'id': trendingGame.id,
                'title': trendingGame.title,
                'description': trendingGame.description,
                'titleImageURL': trendingGame.titleImageURL,
                'imageURLs': trendingGame.imageURLs,
                'platform': encodePlatform(trendingGame.platform),
                'longDescription': trendingGame.longDescription,
                'msrp': trendingGame.msrp,
                'releaseDate': trendingGame.releaseDate,
                'anticipatedLevel': trendingGame.anticipatedLevel,
              },
            ],
          ),
        },
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });
      //_wishlist.remove(trendingGame);
      _wishlist.removeWhere((wishlistedGame) {
        return wishlistedGame.id == trendingGame.id;
      });
    }
    notifyListeners();
  }

  bool isInWishlist(String trendingGameID) {
    int index = _wishlist.indexWhere((game) {
      return game.id == trendingGameID;
    });
    return (index == -1) ? false : true;
  }
}

