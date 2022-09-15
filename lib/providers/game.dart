//could specify portrait title image and landscape title image for a game

//Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//packages
import 'package:flutter/material.dart';

/*
enum TrendingGamesGridOption {
  one,
  two,
  four,
}
*/

enum Platform {
  // ignore: constant_identifier_names
  PS4,
  // ignore: constant_identifier_names
  PS4_and_PS5,
  // ignore: constant_identifier_names
  PS5,
  // ignore: constant_identifier_names
  XBoxOne,
  // ignore: constant_identifier_names
  XBoxS,
  // ignore: constant_identifier_names
  XBoxX,
  // ignore: constant_identifier_names
  XBoxOneSX,
  // ignore: constant_identifier_names
  NintendoSwitch,
  // ignore: constant_identifier_names
  SteamDeck,
  // ignore: constant_identifier_names
  PC,
  // ignore: constant_identifier_names
  others,

  /*
  // ignore: constant_identifier_names
  XboxOne,
  // ignore: constant_identifier_names
  XboxS, //series S
  // ignore: constant_identifier_names
  XboxS_and_XboxX,
  // ignore: constant_identifier_names
  XboxX //series X
  */
}

enum Genre {
  action,
  adventure,
  // ignore: constant_identifier_names
  RPG,
  // ignore: constant_identifier_names
  JRPG, //Japanese RPG
  hackAndSlash,
  sports,
  horror,
  singlePlayer, //single player
  multiPlayer,
  sandbox, //like minecraft (players have less constraints to modify environment)
  // ignore: constant_identifier_names
  PSExclusives,
  // ignore: constant_identifier_names
  XBoxExclusives,
}

enum Rating {
  one,
  two,
  three,
  four,
  five,
}

class MutableGame {
  String id;
  String title;
  Platform platform;
  String description;
  String? longDescription;
  String titleImageURL;
  List<String> imageURLs;
  double msrp;

  bool isFavorite;
  bool isDisliked;
  bool hasFinished;
  bool hasPlayed;
  //if there are no userTitleImageURL then display titleImageURL
  List<String>? userImageURLs;
  String? userDescription;
  double? purchasePrice;
  Rating? userRating;
  String? userTitleImageURL;

  Timestamp? deletedTime;
  Timestamp? releaseDate;
  int? anticipatedLevel;

  Timestamp? lastPlayDate;

  MutableGame({
    required this.id,
    required this.title,
    required this.platform,
    required this.description,
    this.longDescription,
    required this.titleImageURL,
    required this.msrp,
    required this.imageURLs,
    //filter
    this.isFavorite = false,
    this.hasFinished = false,
    this.hasPlayed = false,
    this.isDisliked = false,
    //user stuff
    this.userDescription,
    this.purchasePrice,
    this.userRating,
    this.userImageURLs,
    this.lastPlayDate,
    this.userTitleImageURL,
    //trash
    this.deletedTime,
    //trending
    this.anticipatedLevel,
    this.releaseDate,
  });
  Game copyWith({
    String? id,
    String? title,
    String? description,
    String? longDescription,
    double? msrp,
    Platform? platform,
    String? titleImageURL,
    List<String>? imageURLs,
    //
    String? userDescription,
    String? userTitleImageURL,
    double? purchasePrice,
    Timestamp? lastPlayDate,
    List<String>? userImageURLs,
    Rating? userRating,
    //
    bool? isFavorite,
    bool? isDisliked,
    bool? hasFinished,
    bool? hasPlayed,
    //
    Timestamp? releaseDate,
    int? anticipatedLevel,
    //
    Timestamp? deletedTime,
  }) {
    return Game(
      id: (id == null) ? this.id : id,
      description: (description == null) ? this.description : description,
      msrp: (msrp == null) ? this.msrp : msrp,
      title: (title == null) ? this.title : title,
      longDescription: (longDescription == null) ? this.longDescription : longDescription,
      platform: (platform == null) ? this.platform : platform,
      titleImageURL: (titleImageURL == null) ? this.titleImageURL : titleImageURL,
      imageURLs: (imageURLs == null) ? this.imageURLs : imageURLs,
      //
      lastPlayDate: (lastPlayDate == null) ? this.lastPlayDate : lastPlayDate,
      purchasePrice: (purchasePrice == null) ? this.purchasePrice : purchasePrice,
      userDescription: (userDescription == null) ? this.userDescription : userDescription,
      userImageURLs: (userImageURLs == null) ? this.userImageURLs : userImageURLs,
      userRating: (userRating == null) ? this.userRating : userRating,
      userTitleImageURL: (userTitleImageURL == null) ? this.userTitleImageURL : userTitleImageURL,
      //
      hasFinished: (hasFinished == null) ? this.hasFinished : hasFinished,
      hasPlayed: (hasPlayed == null) ? this.hasPlayed : hasPlayed,
      isDisliked: (isDisliked == null) ? this.isDisliked : isDisliked,
      isFavorite: (isFavorite == null) ? this.isFavorite : isFavorite,

      //
      releaseDate: (releaseDate == null) ? this.releaseDate : releaseDate,
      anticipatedLevel: (anticipatedLevel == null) ? this.anticipatedLevel : anticipatedLevel,
      //
      deletedTime: (deletedTime == null) ? this.deletedTime : deletedTime,
    );
  }

  MutableGame copyWithMutable({
    String? id,
    String? title,
    String? description,
    String? longDescription,
    double? msrp,
    Platform? platform,
    String? titleImageURL,
    List<String>? imageURLs,
    //
    String? userDescription,
    String? userTitleImageURL,
    double? purchasePrice,
    Timestamp? lastPlayDate,
    List<String>? userImageURLs,
    Rating? userRating,
    //
    bool? isFavorite,
    bool? isDisliked,
    bool? hasFinished,
    bool? hasPlayed,
    //
    Timestamp? releaseDate,
    int? anticipatedLevel,
    //
    Timestamp? deletedTime,
  }) {
    return MutableGame(
      id: (id == null) ? this.id : id,
      description: (description == null) ? this.description : description,
      msrp: (msrp == null) ? this.msrp : msrp,
      title: (title == null) ? this.title : title,
      longDescription: (longDescription == null) ? this.longDescription : longDescription,
      platform: (platform == null) ? this.platform : platform,
      titleImageURL: (titleImageURL == null) ? this.titleImageURL : titleImageURL,
      imageURLs: (imageURLs == null) ? this.imageURLs : imageURLs,
      //
      lastPlayDate: (lastPlayDate == null) ? this.lastPlayDate : lastPlayDate,
      purchasePrice: (purchasePrice == null) ? this.purchasePrice : purchasePrice,
      userDescription: (userDescription == null) ? this.userDescription : userDescription,
      userImageURLs: (userImageURLs == null) ? this.userImageURLs : userImageURLs,
      userRating: (userRating == null) ? this.userRating : userRating,
      userTitleImageURL: (userTitleImageURL == null) ? this.userTitleImageURL : userTitleImageURL,
      //
      hasFinished: (hasFinished == null) ? this.hasFinished : hasFinished,
      hasPlayed: (hasPlayed == null) ? this.hasPlayed : hasPlayed,
      isDisliked: (isDisliked == null) ? this.isDisliked : isDisliked,
      isFavorite: (isFavorite == null) ? this.isFavorite : isFavorite,
      //
      releaseDate: (releaseDate == null) ? this.releaseDate : releaseDate,
      /*(releaseDate == null)
          ? ((this.releaseDate == null) ? null : this.releaseDate!.toDate())
          : releaseDate.toDate(),*/
      //releaseDate is of type Timestamp so convert it to DateTime in Mutable game
      anticipatedLevel: (anticipatedLevel == null) ? this.anticipatedLevel : anticipatedLevel,
      //
      deletedTime: (deletedTime == null) ? this.deletedTime : deletedTime,
    );
  }
}

class Game with ChangeNotifier {
  //final String detailedDescription; // a longer description

  final int? anticipatedLevel; //should only be available for trending games
  //based on the prequel metacritic rating
  //if there is no prequel, then default value should be 80
  final Timestamp? deletedTime; //for deleted items in the trash
  //Map<String, String> buyingLinks. For example {'Amazon': "AmazonLink", 'Target': "TargetLink",}
  //lastPlayed
  //havePlayed

  //bool hasFinished;
  //double metacriticRating; //this is hard and must use some scraping tool -> potentially dealing with code that is not Dart
  final String id;
  final String title;
  final Platform platform;
  final String description; //short description
  final String? longDescription; // longer description
  final String titleImageURL;
  List<String> imageURLs; //require user input (image picker), must be at least one
  //we'll use the first URL as main image, or should we create another variable
  //since maybe it add to the Firebase database randomly and when we retrieve
  //we wouldn't get the order that we want
  //we'll see
  //if we have them separately then imageURLs can be empty and not required.
  final double msrp;

  Timestamp? releaseDate; //for upcoming/trending games

  final String? userTitleImageURL;
  //if there are no userTitleImageURL then display titleImageURL
  List<String>? userImageURLs;
  Rating? userRating;
  String? userDescription;
  double? purchasePrice;

  Timestamp? lastPlayDate;

  //List<Genre> genres;

  //final bool hasFinished;
  //sorting should base on lastPlayDate
  //and hasFinished
  //hasFinished hasFinishedButNotFinished and hasNotPlayed should belong to Map<String, bool>
  //and they should affect each other
  //havePlayedButNotFinished games should be prioritized over never played

  bool isFavorite;
  bool isDisliked;
  bool hasFinished;
  bool hasPlayed;
  //

  Game({
    required this.id,
    required this.title,
    required this.platform,
    required this.description,
    required this.titleImageURL,
    required this.msrp,
    //required this.genres
    this.longDescription,
    //user's input
    this.imageURLs = const [
      "https://asset.vg247.com/ps5_digital_edition_white_console_controller_1.jpg/BROK/resize/1920x1920%3E/format/jpg/quality/80/ps5_digital_edition_white_console_controller_1.jpg"
    ],

    //trash
    this.deletedTime,
    //trending games
    this.releaseDate,
    this.anticipatedLevel,
    //user stuff
    this.purchasePrice,
    this.userTitleImageURL,
    this.userImageURLs,
    this.userRating, //5 star rating, also should be in user experience screen
    this.lastPlayDate, //showPickDate (also should be in user experience screen)
    this.userDescription, //or maybe a placeholder like "Start writing your own experience"
    //
    this.isFavorite = false,
    this.isDisliked = false, //not in database yet
    this.hasFinished = false, //not in database yet
    this.hasPlayed = false,
    //
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, //access in O(1) time
      'title': title,
      'description': description,
      'longDescription': longDescription,
      'msrp': msrp,
      'platform': encodePlatform(platform),
      'titleImageURL': titleImageURL,
      'imageURLs': imageURLs,
      //
      'isFavorite': isFavorite,
      'hasFinished': hasFinished,
      'hasPlayed': hasPlayed,
      'isDisliked': isDisliked,
      //
      'userDescription': userDescription,
      'purchasePrice': purchasePrice,
      'userTitleImageURL': userTitleImageURL,
      'userImageURLs': userImageURLs,
      'lastPlayDate': lastPlayDate,
      'userRating': encodeRating(userRating),
      //
      'releaseDate': releaseDate,
    };
  }

  //we could use this function to create a new Game game instead of using the mutable class
  Game copyWith({
    String? id,
    String? title,
    String? description,
    String? longDescription,
    double? msrp,
    Platform? platform,
    String? titleImageURL,
    List<String>? imageURLs,
    //
    String? userDescription,
    String? userTitleImageURL,
    double? purchasePrice,
    Timestamp? lastPlayDate,
    List<String>? userImageURLs,
    Rating? userRating,
    //
    bool? isFavorite,
    bool? isDisliked,
    bool? hasFinished,
    bool? hasPlayed,
    //
    Timestamp? releaseDate,
    int? anticipatedLevel,
    //
    Timestamp? deletedTime,
  }) {
    return Game(
      id: (id == null) ? this.id : id,
      description: (description == null) ? this.description : description,
      msrp: (msrp == null) ? this.msrp : msrp,
      title: (title == null) ? this.title : title,
      longDescription: (longDescription == null) ? this.longDescription : longDescription,
      platform: (platform == null) ? this.platform : platform,
      titleImageURL: (titleImageURL == null) ? this.titleImageURL : titleImageURL,
      imageURLs: (imageURLs == null) ? this.imageURLs : imageURLs,
      //
      lastPlayDate: (lastPlayDate == null) ? this.lastPlayDate : lastPlayDate,
      purchasePrice: (purchasePrice == null) ? this.purchasePrice : purchasePrice,
      userDescription: (userDescription == null) ? this.userDescription : userDescription,
      userImageURLs: (userImageURLs == null) ? this.userImageURLs : userImageURLs,
      userRating: (userRating == null) ? this.userRating : userRating,
      userTitleImageURL: (userTitleImageURL == null) ? this.userTitleImageURL : userTitleImageURL,
      //
      hasFinished: (hasFinished == null) ? this.hasFinished : hasFinished,
      hasPlayed: (hasPlayed == null) ? this.hasPlayed : hasPlayed,
      isDisliked: (isDisliked == null) ? this.isDisliked : isDisliked,
      isFavorite: (isFavorite == null) ? this.isFavorite : isFavorite,
      //
      releaseDate: (releaseDate == null) ? this.releaseDate : releaseDate,
      anticipatedLevel: (anticipatedLevel == null) ? this.anticipatedLevel : anticipatedLevel,
      //
      deletedTime: (deletedTime == null) ? this.deletedTime : deletedTime,
    );
  }

  MutableGame copyWithMutable({
    String? id,
    String? title,
    String? description,
    String? longDescription,
    double? msrp,
    Platform? platform,
    String? titleImageURL,
    List<String>? imageURLs,
    //
    String? userDescription,
    String? userTitleImageURL,
    double? purchasePrice,
    Timestamp? lastPlayDate,
    List<String>? userImageURLs,
    Rating? userRating,
    //
    bool? isFavorite,
    bool? isDisliked,
    bool? hasFinished,
    bool? hasPlayed,
    //
    Timestamp? releaseDate,
    int? anticipatedLevel,
    //
    Timestamp? deletedTime,
  }) {
    return MutableGame(
      id: (id == null) ? this.id : id,
      description: (description == null) ? this.description : description,
      msrp: (msrp == null) ? this.msrp : msrp,
      title: (title == null) ? this.title : title,
      longDescription: (longDescription == null) ? this.longDescription : longDescription,
      platform: (platform == null) ? this.platform : platform,
      titleImageURL: (titleImageURL == null) ? this.titleImageURL : titleImageURL,
      imageURLs: (imageURLs == null) ? this.imageURLs : imageURLs,
      //
      lastPlayDate: (lastPlayDate == null) ? this.lastPlayDate : lastPlayDate,
      purchasePrice: (purchasePrice == null) ? this.purchasePrice : purchasePrice,
      userDescription: (userDescription == null) ? this.userDescription : userDescription,
      userImageURLs: (userImageURLs == null) ? this.userImageURLs : userImageURLs,
      userRating: (userRating == null) ? this.userRating : userRating,
      userTitleImageURL: (userTitleImageURL == null) ? this.userTitleImageURL : userTitleImageURL,
      //
      hasFinished: (hasFinished == null) ? this.hasFinished : hasFinished,
      hasPlayed: (hasPlayed == null) ? this.hasPlayed : hasPlayed,
      isDisliked: (isDisliked == null) ? this.isDisliked : isDisliked,
      isFavorite: (isFavorite == null) ? this.isFavorite : isFavorite,
      //
      releaseDate: (releaseDate == null) ? this.releaseDate : releaseDate,
      /*(releaseDate == null)
          ? ((this.releaseDate == null) ? null : this.releaseDate!.toDate())
          : releaseDate.toDate(),*/
      //releaseDate is of type Timestamp so convert it to DateTime in Mutable game
      anticipatedLevel: (anticipatedLevel == null) ? this.anticipatedLevel : anticipatedLevel,
      //
      deletedTime: (deletedTime == null) ? this.deletedTime : deletedTime,
    );
  }

//see: https://stackoverflow.com/questions/46757614/how-to-update-an-array-of-objects-with-firestore
//see this to see why we cannot modify an element of the array easily: https://www.youtube.com/watch?v=o7d5Zeic63s&list=PLl-K7zZEsYLluG5MCVEzXAQ7ACZBCuZgZ&t=525s
//to MAKE UP for this (each time we toggle favorite, the games array on Firebase gets rearranged)
//thus when we refresh the page, they are in different positions!
//we should have a filter by date of latest plays, or filter by names!
//we can use arrayRemove and then arrayUnion, but what's the point of that?, it's just a minor field
  Future<void> toggleFavorite() async {
    bool oldStatus = isFavorite;
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "games": FieldValue.arrayRemove(
            [
              {
                'id': id,
                'title': title,
                'description': description,
                'longDescription': longDescription,
                'msrp': msrp,
                'platform': encodePlatform(platform),
                'titleImageURL': titleImageURL,
                'imageURLs': imageURLs,
                'isFavorite': isFavorite,
                'isDisliked': isDisliked,
                'hasFinished': hasFinished,
                'hasPlayed': hasPlayed,
                'userDescription': userDescription,
                'purchasePrice': purchasePrice,
                'userTitleImageURL': userTitleImageURL,
                'userImageURLs': userImageURLs,
                'lastPlayDate': lastPlayDate,
                'userRating': encodeRating(userRating),
                'releaseDate': releaseDate,
              },
            ],
          ),
        },
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });

      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "games": FieldValue.arrayUnion(
            [
              {
                'id': id,
                'title': title,
                'description': description,
                'longDescription': longDescription,
                'msrp': msrp,
                'platform': encodePlatform(platform),
                'titleImageURL': titleImageURL,
                'imageURLs': imageURLs,
                'isFavorite': !oldStatus,
                'isDisliked': (oldStatus == false) ? false : isDisliked,
                'hasFinished': hasFinished,
                'hasPlayed': hasPlayed,
                'userDescription': userDescription,
                'purchasePrice': purchasePrice,
                'userTitleImageURL': userTitleImageURL,
                'userImageURLs': userImageURLs,
                'lastPlayDate': lastPlayDate,
                'userRating': encodeRating(userRating),
                'releaseDate': releaseDate,
              },
            ],
          ),
        },
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });

      isFavorite = !oldStatus;
      if (isFavorite) {
        isDisliked = false;
      }
      notifyListeners();
    } catch (error) {
      //print(error);
      //rethrow;
    }
  }

  Future<void> toggleDisliked() async {
    bool oldStatus = isDisliked;
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "games": FieldValue.arrayRemove(
            [
              {
                'id': id,
                'title': title,
                'description': description,
                'longDescription': longDescription,
                'msrp': msrp,
                'platform': encodePlatform(platform),
                'titleImageURL': titleImageURL,
                'imageURLs': imageURLs,
                'isFavorite': isFavorite,
                'isDisliked': isDisliked,
                'hasFinished': hasFinished,
                'hasPlayed': hasPlayed,
                'userDescription': userDescription,
                'purchasePrice': purchasePrice,
                'userTitleImageURL': userTitleImageURL,
                'userImageURLs': userImageURLs,
                'lastPlayDate': lastPlayDate,
                'userRating': encodeRating(userRating),
                'releaseDate': releaseDate,
              },
            ],
          ),
        },
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });

      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "games": FieldValue.arrayUnion(
            [
              {
                'id': id,
                'title': title,
                'description': description,
                'longDescription': longDescription,
                'msrp': msrp,
                'platform': encodePlatform(platform),
                'titleImageURL': titleImageURL,
                'imageURLs': imageURLs,
                'isFavorite': (oldStatus == false) ? false : isFavorite,
                'isDisliked': !oldStatus,
                'hasFinished': hasFinished,
                'hasPlayed': hasPlayed,
                'userDescription': userDescription,
                'purchasePrice': purchasePrice,
                'userTitleImageURL': userTitleImageURL,
                'userImageURLs': userImageURLs,
                'lastPlayDate': lastPlayDate,
                'userRating': encodeRating(userRating),
                'releaseDate': releaseDate,
              },
            ],
          ),
        },
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });

      isDisliked = !oldStatus;
      if (isDisliked) {
        isFavorite = false;
      }
      notifyListeners();
    } catch (error) {
      //print(error);
      //rethrow;
    }
  }

  Future<void> toggleHasFinished() async {
    bool oldStatus = hasFinished;
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "games": FieldValue.arrayRemove(
            [
              {
                'id': id,
                'title': title,
                'description': description,
                'longDescription': longDescription,
                'msrp': msrp,
                'platform': encodePlatform(platform),
                'titleImageURL': titleImageURL,
                'imageURLs': imageURLs,
                'isFavorite': isFavorite,
                'isDisliked': isDisliked,
                'hasFinished': hasFinished,
                'hasPlayed': hasPlayed,
                'userDescription': userDescription,
                'purchasePrice': purchasePrice,
                'userTitleImageURL': userTitleImageURL,
                'userImageURLs': userImageURLs,
                'lastPlayDate': lastPlayDate,
                'userRating': encodeRating(userRating),
                'releaseDate': releaseDate,
              },
            ],
          ),
        },
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });

      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "games": FieldValue.arrayUnion(
            [
              {
                'id': id,
                'title': title,
                'description': description,
                'longDescription': longDescription,
                'msrp': msrp,
                'platform': encodePlatform(platform),
                'titleImageURL': titleImageURL,
                'imageURLs': imageURLs,
                'isFavorite': isFavorite,
                'isDisliked': isDisliked,
                'hasFinished': !oldStatus,
                'hasPlayed': (!oldStatus == true) ? true : hasPlayed,
                'userDescription': userDescription,
                'purchasePrice': purchasePrice,
                'userTitleImageURL': userTitleImageURL,
                'userImageURLs': userImageURLs,
                'lastPlayDate': lastPlayDate,
                'userRating': encodeRating(userRating),
                'releaseDate': releaseDate,
              },
            ],
          ),
        },
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });
      if (!oldStatus == true) {
        hasPlayed = true;
      }
      hasFinished = !oldStatus;
      notifyListeners();
    } catch (error) {
      //print(error);
      //rethrow;
    }
  }

  Future<void> toggleHasPlayed() async {
    bool oldStatus = hasPlayed;
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "games": FieldValue.arrayRemove(
            [
              {
                'id': id,
                'title': title,
                'description': description,
                'longDescription': longDescription,
                'msrp': msrp,
                'platform': encodePlatform(platform),
                'titleImageURL': titleImageURL,
                'imageURLs': imageURLs,
                'isFavorite': isFavorite,
                'isDisliked': isDisliked,
                'hasFinished': hasFinished,
                'hasPlayed': oldStatus,
                'userDescription': userDescription,
                'purchasePrice': purchasePrice,
                'userTitleImageURL': userTitleImageURL,
                'userImageURLs': userImageURLs,
                'lastPlayDate': lastPlayDate,
                'userRating': encodeRating(userRating),
                'releaseDate': releaseDate,
              },
            ],
          ),
        },
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });

      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "games": FieldValue.arrayUnion(
            [
              {
                'id': id,
                'title': title,
                'description': description,
                'longDescription': longDescription,
                'msrp': msrp,
                'platform': encodePlatform(platform),
                'titleImageURL': titleImageURL,
                'imageURLs': imageURLs,
                'isFavorite': isFavorite,
                'isDisliked': isDisliked,
                'hasFinished': (!oldStatus == false) ? false : hasFinished,
                'hasPlayed': !oldStatus,
                'userDescription': userDescription,
                'purchasePrice': purchasePrice,
                'userTitleImageURL': userTitleImageURL,
                'userImageURLs': userImageURLs,
                'lastPlayDate': (!oldStatus == false) ? null : lastPlayDate,
                'userRating': encodeRating(userRating),
                'releaseDate': releaseDate,
              },
            ],
          ),
        },
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });
      if (!oldStatus == false) {
        lastPlayDate = null; //if has not played then lastPlayDate must be null
        hasFinished = false;
      }
      hasPlayed = !oldStatus;
      notifyListeners();
    } catch (error) {
      //print(error);
      //rethrow;
    }
  }
/*
  Future<bool> isInWishlist() async {
    bool isInWishList = false;
    //this function only works if we know if a function is wishlist or not
    //so gotta have some function to do that and store a bool value for each trending game item
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then(((docSnapShot) async {
      final mapData = (docSnapShot.data() as Map<String, dynamic>);
      if (mapData.containsKey('wishlist')) {
        for (final gameData in mapData['wishlist'] as List<dynamic>) {
          if (id == gameData['id']) {
            isInWishList = true;
            break;
          }
        }
      } else {
        isInWishList = false;
      }
    }));
    return isInWishList;
  }
  */

/*
  Future<void> toggleWishlist({
    required String trendingGameID,
    required bool isArrayRemoveMode,
  }) async {
    //idea: algorithm would be O(N*M)
    //N is length of trending games
    //M is length of list of ids for wishlisted trending_games

    bool containsWishlistKey = false;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then(
      ((docSnapShot) async {
        //see: https://stackoverflow.com/questions/69108424/cannot-check-containskey-on-documentsnapshot
        containsWishlistKey = (docSnapShot.data() as Map<String, dynamic>).containsKey('wishlist');
        if (containsWishlistKey == false) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update(
            {
              "wishlist": FieldValue.arrayUnion(
                [trendingGameID],
              ),
            },
          ).onError((error, stackTrace) {
            print(error);
            print(stackTrace.toString());
          });
        } else {
          final List<String> trendingGameIDs = docSnapShot.data()!['wishlist'] as List<String>;
          for (final String id in trendingGameIDs) {
            if (trendingGameID == id) {}
          }
        }
      }),
    );
    

/*
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
            }*/
    notifyListeners();
  }
  */

  Future<void> updateRating(Rating? rating) async {
    //bool oldStatus = isDisliked;
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "games": FieldValue.arrayRemove(
            [
              {
                'id': id,
                'title': title,
                'description': description,
                'longDescription': longDescription,
                'msrp': msrp,
                'platform': encodePlatform(platform),
                'titleImageURL': titleImageURL,
                'imageURLs': imageURLs,
                'isFavorite': isFavorite,
                'isDisliked': isDisliked,
                'hasFinished': hasFinished,
                'hasPlayed': hasPlayed,
                'userDescription': userDescription,
                'purchasePrice': purchasePrice,
                'userTitleImageURL': userTitleImageURL,
                'userImageURLs': userImageURLs,
                'lastPlayDate': lastPlayDate,
                'userRating': encodeRating(userRating),
                'releaseDate': releaseDate,
              },
            ],
          ),
        },
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });

      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "games": FieldValue.arrayUnion(
            [
              {
                'id': id,
                'title': title,
                'description': description,
                'longDescription': longDescription,
                'msrp': msrp,
                'platform': encodePlatform(platform),
                'titleImageURL': titleImageURL,
                'imageURLs': imageURLs,
                'isFavorite': isFavorite,
                'isDisliked': isDisliked,
                'hasFinished': hasFinished,
                'hasPlayed': hasPlayed,
                'userDescription': userDescription,
                'purchasePrice': purchasePrice,
                'userTitleImageURL': userTitleImageURL,
                'userImageURLs': userImageURLs,
                'lastPlayDate': lastPlayDate,
                'userRating': encodeRating(rating),
                'releaseDate': releaseDate,
              },
            ],
          ),
        },
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });
      userRating = rating;
      notifyListeners();
    } catch (error) {
      //print(error);
      //rethrow;
    }
  }

  Future<void> updatePurchasePrice(String inputValue) async {
    double price = double.parse(inputValue);

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "games": FieldValue.arrayRemove(
            [
              {
                'id': id,
                'title': title,
                'description': description,
                'longDescription': longDescription,
                'msrp': msrp,
                'platform': encodePlatform(platform),
                'titleImageURL': titleImageURL,
                'imageURLs': imageURLs,
                'isFavorite': isFavorite,
                'isDisliked': isDisliked,
                'hasFinished': hasFinished,
                'hasPlayed': hasPlayed,
                'userDescription': userDescription,
                'purchasePrice': purchasePrice,
                'userTitleImageURL': userTitleImageURL,
                'userImageURLs': userImageURLs,
                'lastPlayDate': lastPlayDate,
                'userRating': encodeRating(userRating),
                'releaseDate': releaseDate,
              },
            ],
          ),
        },
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });

      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "games": FieldValue.arrayUnion(
            [
              {
                'id': id,
                'title': title,
                'description': description,
                'longDescription': longDescription,
                'msrp': msrp,
                'platform': encodePlatform(platform),
                'titleImageURL': titleImageURL,
                'imageURLs': imageURLs,
                'isFavorite': isFavorite,
                'isDisliked': isDisliked,
                'hasFinished': hasFinished,
                'hasPlayed': hasPlayed,
                'userDescription': userDescription,
                'purchasePrice': price,
                'userTitleImageURL': userTitleImageURL,
                'userImageURLs': userImageURLs,
                'lastPlayDate': lastPlayDate,
                'userRating': encodeRating(userRating),
                'releaseDate': releaseDate,
              },
            ],
          ),
        },
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });
      purchasePrice = price;
      notifyListeners();
    } catch (error) {
      //print(error);
      //rethrow;
    }
  }

  Future<void> updateLastPlayDate(DateTime? lastPlayingTime) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "games": FieldValue.arrayRemove(
            [
              {
                'id': id,
                'title': title,
                'description': description,
                'longDescription': longDescription,
                'msrp': msrp,
                'platform': encodePlatform(platform),
                'titleImageURL': titleImageURL,
                'imageURLs': imageURLs,
                'isFavorite': isFavorite,
                'isDisliked': isDisliked,
                'hasFinished': hasFinished,
                'hasPlayed': hasPlayed,
                'userDescription': userDescription,
                'purchasePrice': purchasePrice,
                'userTitleImageURL': userTitleImageURL,
                'userImageURLs': userImageURLs,
                'lastPlayDate': lastPlayDate,
                'userRating': encodeRating(userRating),
                'releaseDate': releaseDate,
              },
            ],
          ),
        },
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });

      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "games": FieldValue.arrayUnion(
            [
              {
                'id': id,
                'title': title,
                'description': description,
                'longDescription': longDescription,
                'msrp': msrp,
                'platform': encodePlatform(platform),
                'titleImageURL': titleImageURL,
                'imageURLs': imageURLs,
                'isFavorite': isFavorite,
                'isDisliked': isDisliked,
                'hasFinished': hasFinished,
                'hasPlayed': hasPlayed,
                'userDescription': userDescription,
                'purchasePrice': purchasePrice,
                'userTitleImageURL': userTitleImageURL,
                'userImageURLs': userImageURLs,
                'lastPlayDate':
                    (lastPlayingTime == null) ? null : Timestamp.fromDate(lastPlayingTime),
                'userRating': encodeRating(userRating),
                'releaseDate': releaseDate,
              },
            ],
          ),
        },
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });
      lastPlayDate = (lastPlayingTime == null) ? null : Timestamp.fromDate(lastPlayingTime);
      notifyListeners();
    } catch (error) {
      //print(error);
      //rethrow;
    }
  }

  Future<void> updateUserDescription(String inputValue) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "games": FieldValue.arrayRemove(
            [
              {
                'id': id,
                'title': title,
                'description': description,
                'longDescription': longDescription,
                'msrp': msrp,
                'platform': encodePlatform(platform),
                'titleImageURL': titleImageURL,
                'imageURLs': imageURLs,
                'isFavorite': isFavorite,
                'isDisliked': isDisliked,
                'hasFinished': hasFinished,
                'hasPlayed': hasPlayed,
                'userDescription': userDescription,
                'purchasePrice': purchasePrice,
                'userTitleImageURL': userTitleImageURL,
                'userImageURLs': userImageURLs,
                'lastPlayDate': lastPlayDate,
                'userRating': encodeRating(userRating),
                'releaseDate': releaseDate,
              },
            ],
          ),
        },
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });

      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "games": FieldValue.arrayUnion(
            [
              {
                'id': id,
                'title': title,
                'description': description,
                'longDescription': longDescription,
                'msrp': msrp,
                'platform': encodePlatform(platform),
                'titleImageURL': titleImageURL,
                'imageURLs': imageURLs,
                'isFavorite': isFavorite,
                'isDisliked': isDisliked,
                'hasFinished': hasFinished,
                'hasPlayed': hasPlayed,
                'userDescription': inputValue,
                'purchasePrice': purchasePrice,
                'userTitleImageURL': userTitleImageURL,
                'userImageURLs': userImageURLs,
                'lastPlayDate': lastPlayDate,
                'userRating': encodeRating(userRating),
                'releaseDate': releaseDate,
              },
            ],
          ),
        },
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });
      userDescription = inputValue;
      notifyListeners();
    } catch (error) {
      //print(error);
      //rethrow;
    }
  }

  Future<void> pickReleaseYear(DateTime? year) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "games": FieldValue.arrayRemove(
            [
              {
                'id': id,
                'title': title,
                'description': description,
                'longDescription': longDescription,
                'msrp': msrp,
                'platform': encodePlatform(platform),
                'titleImageURL': titleImageURL,
                'imageURLs': imageURLs,
                'isFavorite': isFavorite,
                'isDisliked': isDisliked,
                'hasFinished': hasFinished,
                'hasPlayed': hasPlayed,
                'userDescription': userDescription,
                'purchasePrice': purchasePrice,
                'userTitleImageURL': userTitleImageURL,
                'userImageURLs': userImageURLs,
                'lastPlayDate': lastPlayDate,
                'userRating': encodeRating(userRating),
                'releaseDate': releaseDate,
              },
            ],
          ),
        },
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });

      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "games": FieldValue.arrayUnion(
            [
              {
                'id': id,
                'title': title,
                'description': description,
                'longDescription': longDescription,
                'msrp': msrp,
                'platform': encodePlatform(platform),
                'titleImageURL': titleImageURL,
                'imageURLs': imageURLs,
                'isFavorite': isFavorite,
                'isDisliked': isDisliked,
                'hasFinished': hasFinished,
                'hasPlayed': hasPlayed,
                'userDescription': userDescription,
                'purchasePrice': purchasePrice,
                'userTitleImageURL': userTitleImageURL,
                'userImageURLs': userImageURLs,
                'lastPlayDate': lastPlayDate,
                'userRating': encodeRating(userRating),
                'releaseDate': (year == null) ? null : Timestamp.fromDate(year),
              },
            ],
          ),
        },
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });

      releaseDate = (year == null) ? null : Timestamp.fromDate(year);
      notifyListeners();
    } catch (error) {
      //print(error);
      //rethrow;
    }
  }
}

int encodePlatform(Platform platform) {
  if (platform == Platform.PS4) {
    return 0;
  } else if (platform == Platform.PS4_and_PS5) {
    return 1;
  } else if (platform == Platform.PS5) {
    return 2;
  } else if (platform == Platform.XBoxOne) {
    return 3;
  } else if (platform == Platform.XBoxOneSX) {
    return 4;
  } else if (platform == Platform.XBoxS) {
    return 5;
  } else if (platform == Platform.XBoxX) {
    return 6;
  } else if (platform == Platform.NintendoSwitch) {
    return 7;
  } else if (platform == Platform.SteamDeck) {
    return 8;
  } else if (platform == Platform.PC) {
    return 9;
  } else {
    return 10; //other platforms
  }
}

Platform decodePlatform(int encodedPlatform) {
  if (encodedPlatform == 0) {
    return Platform.PS4;
  } else if (encodedPlatform == 1) {
    return Platform.PS4_and_PS5;
  } else if (encodedPlatform == 2) {
    return Platform.PS5;
  } else if (encodedPlatform == 3) {
    return Platform.XBoxOne;
  } else if (encodedPlatform == 4) {
    return Platform.XBoxOneSX;
  } else if (encodedPlatform == 5) {
    return Platform.XBoxS;
  } else if (encodedPlatform == 6) {
    return Platform.XBoxX;
  } else if (encodedPlatform == 7) {
    return Platform.NintendoSwitch;
  } else if (encodedPlatform == 8) {
    return Platform.SteamDeck;
  } else if (encodedPlatform == 9) {
    return Platform.PC;
  } else {
    return Platform.others;
  }
}

String platformToString(Platform platform) {
  if (platform == Platform.PS4) {
    return "PS4";
  } else if (platform == Platform.PS4_and_PS5) {
    return "PS4 & PS5";
  } else if (platform == Platform.PS5) {
    return "PS5";
  } else if (platform == Platform.XBoxOne) {
    return "XBox One";
  } else if (platform == Platform.XBoxOneSX) {
    return "XBox One, Series S & X";
  } else if (platform == Platform.XBoxS) {
    return "XBox Series S";
  } else if (platform == Platform.XBoxX) {
    return "XBox Series X";
  } else if (platform == Platform.NintendoSwitch) {
    return "Nintendo Switch";
  } else if (platform == Platform.SteamDeck) {
    return "Steam Deck";
  } else if (platform == Platform.PC) {
    return "PC";
  } else {
    return "Other Platforms";
  }
}

Rating? decodeRating(int? rating) {
  if (rating == 1) {
    return Rating.one;
  } else if (rating == 2) {
    return Rating.two;
  } else if (rating == 3) {
    return Rating.three;
  } else if (rating == 4) {
    return Rating.four;
  } else if (rating == 5) {
    return Rating.five;
  }
  return null;
}

int? encodeRating(Rating? rating) {
  if (rating == Rating.one) {
    return 1;
  } else if (rating == Rating.two) {
    return 2;
  } else if (rating == Rating.three) {
    return 3;
  } else if (rating == Rating.four) {
    return 4;
  } else if (rating == Rating.five) {
    return 5;
  }
  return null;
}

List<Map<String, dynamic>> gamesToListOfMaps(List<Game> games) {
  List<Map<String, dynamic>> tempList = [];
  for (Game game in games) {
    tempList.add(gameToMap(game));
  }
  return tempList;
}

Map<String, dynamic> gameToMap(Game game) {
  return {
    'id': game.id, //access in O(1) time
    'title': game.title,
    'description': game.description,
    'longDescription': game.longDescription,
    'msrp': game.msrp,
    'platform': encodePlatform(game.platform),
    'titleImageURL': game.titleImageURL,
    'imageURLs': game.imageURLs,
    //
    'isFavorite': game.isFavorite,
    'hasFinished': game.hasFinished,
    'hasPlayed': game.hasPlayed,
    'isDisliked': game.isDisliked,
    //
    'userDescription': game.userDescription,
    'purchasePrice': game.purchasePrice,
    'userTitleImageURL': game.userTitleImageURL,
    'userImageURLs': game.userImageURLs,
    'lastPlayDate': game.lastPlayDate,
    'userRating': encodeRating(game.userRating),
    //
    'releaseDate': game.releaseDate,
  };
}

final List<Game> demoGames = [
  Game(
    id: Timestamp.now().toString(),
    title: "(DEMO) Sekiro: Shadows Die Twice",
    titleImageURL:
        "https://image.api.playstation.com/vulcan/img/rnd/202010/2723/knxU5uU5aKvQChKX5OvWtSGC.png",
    imageURLs: [
      "https://cdn.akamai.steamstatic.com/steam/apps/814380/ss_15f0e9982621aed44900215ad283811af0779b1d.1920x1080.jpg",
      "https://s3.amazonaws.com/prod-media.gameinformer.com/styles/full/s3/2019/03/20/02020928/1.jpg",
      "https://s3.amazonaws.com/prod-media.gameinformer.com/styles/full/s3/2019/01/07/5701440d/news1.jpg",
      "https://www.gameaxis.com/wp-content/uploads/2019/04/SekiroShadowDieTwice_Review_01.jpg",
    ],
    msrp: 59.99,
    description:
        "(This is a demo game item that is added after you signing up)\nIn Sekiro™: Shadows Die Twice you are the 'one-armed wolf', a disgraced and disfigured warrior rescued from the brink of death. Bound to protect a young lord who is the descendant of an ancient bloodline, you become the target of many vicious enemies, including the dangerous Ashina clan.",
    platform: Platform.PS4,
    hasPlayed: true,
    hasFinished: true,
    isDisliked: false,
    isFavorite: true,
    lastPlayDate: Timestamp.fromDate(DateTime(2022)),
    longDescription:
        "Return from death and take revenge on those who wronged you.\nEnter a dark and brutal new gameplay experience from the creators of Bloodborne and the Dark Souls series.\n\nSekiro: Shadows Die Twice is an intense, third-person, action-adventure set against the bloody backdrop of 14th-century Japan. Step into the role of a disgraced warrior brought back from the brink of death whose mission is to rescue his master and exact revenge on his arch nemesis.\n\nExploring a vast interconnected world, you'll come face-to-face with larger than life foes and gruelling one-on-one duels.\n\nUnleash an arsenal of deadly prosthetic weapons and powerful ninja abilities to bring down your adversaries and combine steal and verticality to deal death from the shadows.",
    releaseDate: Timestamp.fromDate(DateTime(2019, 3, 21)),
    purchasePrice: 21.99,
    userDescription:
        "Fantastic game, but will be difficult for some, so you might need to learn how to time deflections perfectly before proceed.",
    userRating: Rating.five,
    userTitleImageURL:
        "https://firebasestorage.googleapis.com/v0/b/video-games-backlog.appspot.com/o/clients%2FSekiro%2Fsekiro%20demo%20title.jpeg?alt=media&token=eead36a8-af9d-4359-b60f-61838b731778",
    userImageURLs: [
      "https://firebasestorage.googleapis.com/v0/b/video-games-backlog.appspot.com/o/clients%2FSekiro%2Fsekiro%201.jpeg?alt=media&token=cf340437-8a6d-49ff-b7f5-8e5760c1ae4b",
      "https://firebasestorage.googleapis.com/v0/b/video-games-backlog.appspot.com/o/clients%2FSekiro%2Fsekiro%202.jpeg?alt=media&token=cc41fc5e-29e6-4a7d-9b11-8ef720ef0c8e",
    ],
  ),
  Game(
    id: Timestamp.now().toString(),
    title: "(DEMO) The Last Of Us: Part II",
    titleImageURL:
        "https://image.api.playstation.com/vulcan/img/rnd/202010/2618/w48z6bzefZPrRcJHc7L8SO66.png",
    imageURLs: [
      "https://assets-prd.ignimgs.com/2022/06/11/lastofuspart2-blogroll-1589913932452-1632710613376-1640320316070-1654977724834.jpg",
      "https://cdn.mos.cms.futurecdn.net/uGo2FAu5MzNKdceMcWdU4i.jpg",
      "https://cdn.mos.cms.futurecdn.net/emDLV2mjpNGsawvm94FrAE.png",
      "https://assets1.ignimgs.com/2020/05/06/the-last-of-us-2---gold-screens-14-1588807678894.jpg",
    ],
    msrp: 59.99,
    description:
        "(This is a demo game item that is added after you signing up)\nSet five years after The Last of Us (2013), the game focuses on two playable characters in a post-apocalyptic United States whose lives intertwine: Ellie, who sets out for revenge after suffering a tragedy, and Abby, a soldier who becomes involved in a conflict between her militia and a religious cult.",
    platform: Platform.PS4,
    hasPlayed: true,
    hasFinished: false,
    isDisliked: false,
    isFavorite: false,
    lastPlayDate: Timestamp.fromDate(DateTime(2021)),
    longDescription:
        "Confront the devastating physical and emotional repercussions of Ellie's actions.\nFive years after their dangerous journey across the post-pandemic United States, Ellie and Joel have settled down in Jackson, Wyoming. Living amongst a thriving community of survivors has allowed them peace and stability, despite the constant threat of the infected and other, more desperate survivors.\n\nWhen a violent event disrupts that peace, Ellie embarks on a relentless journey to carry out justice and find closure. As she hunts those responsible one by one, she is confronted with the devastating physical and emotional repercussions of her actions.",
    releaseDate: Timestamp.fromDate(DateTime(2020, 6, 19)),
    purchasePrice: 19.99,
    userDescription: "They turned Ellie into a monster.",
    userRating: Rating.five,
    userTitleImageURL:
        "https://firebasestorage.googleapis.com/v0/b/video-games-backlog.appspot.com/o/clients%2FTLOU%202%2Ftlou%202%20title%20image.jpeg?alt=media&token=9b0fac15-facd-4126-bc35-4f81f7d2c2c0",
    userImageURLs: [
      "https://firebasestorage.googleapis.com/v0/b/video-games-backlog.appspot.com/o/clients%2FTLOU%202%2Ftlou%202%20disc%201.jpeg?alt=media&token=5ee3e531-c60c-4ea9-a30d-6d397ba471f6",
      "https://firebasestorage.googleapis.com/v0/b/video-games-backlog.appspot.com/o/clients%2FTLOU%202%2Ftlou%202%20disc%202.jpeg?alt=media&token=93d54053-8412-49bf-9582-d98a5cd8960d",
      "https://firebasestorage.googleapis.com/v0/b/video-games-backlog.appspot.com/o/clients%2FTLOU%202%2Ftlou%202%20back%20cover.jpeg?alt=media&token=18f2ae6d-f9b2-4347-8577-6957b064c4d4",
    ],
  ),
];
  /*
  factory Game.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    final Platform decodedPlatform; //Firebase doesn't support enum
    if (data?['platform'] == 0) {
      decodedPlatform = Platform.PS4;
    } else if (data?['platform'] == 1) {
      decodedPlatform = Platform.PS5;
    } else {
      decodedPlatform = Platform.PS4_and_PS5;
    }
    return Game(
      id: data?['id'],
      title: data?['title'],
      platform: decodedPlatform,
      description: data?['description'],
      titleImageURL: data?['titleImageURL'],
      msrp: data?['msrp'],
      //regions: data?['regions'] is Iterable ? List.from(data?['regions']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    final int encodedPlatform; //Firebase doesn't support enum
    if (platform == Platform.PS4) {
      encodedPlatform = 0;
    } else if (platform == Platform.PS5) {
      encodedPlatform = 1;
    } else {
      encodedPlatform = 2;
    }
    return {
      "id": id,
      "title": title,
      "platform": encodedPlatform,
      "description": description,
      "titleImageURL": titleImageURL,
      "msrp": msrp,
    };
  }
  */

/*
  Future<void> toggleFavoriteStatus(String token, String userID) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.parse(
        "https://my-shop-9ea08-default-rtdb.firebaseio.com/userFavorites/$userID/$id.json?auth=$token"); //id is productID

    try {
      FirebaseFirestore.instance.collection('users/$uid').add(
        {
          'text': _enteredMessage,
          'createdAt': Timestamp.now(), //this is the timestamp to use orderBy method
          //Timestamp is supported by Cloud Firestore database
          'userID': user.uid,
          'username': userData.data()!['username'],
          'userImage': userData.data()!['image_url'],
        },
      );
      /*
      final response = await http.patch(
        url,
        body: json.encode({"isFavorite": !oldStatus}),
      );
      */
      final response = await http.put(
        url,
        body: json.encode(isFavorite),
      );
      if (response.statusCode >= 400) {
        isFavorite = oldStatus; //set back to the old isFavorite if HTTPException occurs
        notifyListeners();
        throw HTTPException("Could not update the product");
      }
    } on HTTPException {
      //
    } catch (error) {
      //
    }
  }
  */


