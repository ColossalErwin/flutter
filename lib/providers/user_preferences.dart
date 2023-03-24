//SHARED PREFERENCES, as it names suggests if we use it
//then all users with the same device would have use the same preferences
//Supported data types are int, double, bool, String and List<String>
//so we cannot use Map with user id to differentiate users in a device
//so it's less ideal than fetching preferences from server

//should also have filters based on userRatings

//should have filters to fetch data only once to improve performance or fetch it each time
//for both trending and games overview screen

//should have filters to show only multi players or single players games
//should have filters to show only Xbox, only PS5 (exclusive games)

//also have filter fo enable infinite scroll images in game detail screen (maybe not)

//filter screen should use bottom navigation bars
//one would be for genre filters (show only) games belong to the genre that you like
//should also have filters for how many items on the grid (cross axis)

//show Description or not also should be an option
//if grids element are 2 for cross axis then show Description should always be off

//cross axis count for gamesoverviewscreen 1 or 2
//if 2 then title should be underneath

//Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//helpers
import '../helpers/theme_data.dart';
//providers
import './games.dart';
//import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences with ChangeNotifier {
  ThemeData getTheme() {
    if (_preferences.containsKey('isDarkMode')) {
      return (_preferences['isDarkMode'] == null)
          ? lightTheme
          : (_preferences['isDarkMode'])
              ? darkTheme
              : lightTheme;
    }
    return lightTheme;
  }

  ThemeData get themeData {
    if (_preferences.containsKey('isDarkMode')) {
      return (_preferences['isDarkMode'] == null)
          ? lightTheme
          : (_preferences['isDarkMode'])
              ? darkTheme
              : lightTheme;
    }
    return lightTheme;
  }

  UserPreferences(Map<String, bool> myCollectionFilters, Map<String, dynamic> preferences) {
    _preferences = preferences;
    _myCollectionFilters = myCollectionFilters;
  }

  Map<String, bool> _myCollectionFilters = {};
  //have played: showFinished & showHaveNotFinished
  //have not played: showBacklog
  //show all: have played + have not played

  Map<String, bool> get myCollectionFilters {
    return _myCollectionFilters;
  }

  Map<String, dynamic> _preferences = {};
  Map<String, dynamic> get preferences {
    return _preferences;
  }
  /*
  bool? _didFetchFiltersFromSharedPreferences;
  bool? get didFetchFiltersFromSharedPreferences {
    return _didFetchFiltersFromSharedPreferences;
  }
  */

  //should add try catch logic for filters also in case update to Firebase fails
  Future<void> toggleShowBacklog() async {
    //must be very careful about default rule as well as precedence of these
    //check games overview screen about defualt rule as well as precedence
    //default: show backlog (have not played), and have played not finished
    //if showAll is true, everything is true,
    //if there is one false, showAll is false,
    //if everything is true and showAll become false, then to default mode, showFinished is false
    //one case we have not thought is what if every filter is false???
    //should we don't show anything? yes!!!
    if (_myCollectionFilters['showBacklog'] == null) {
      return;
    }

    _myCollectionFilters['showBacklog'] = !_myCollectionFilters['showBacklog']!;
    if (_myCollectionFilters['showBacklog'] == true &&
        _myCollectionFilters['showHaveNotFinished'] == true &&
        _myCollectionFilters['showFinished'] == true) {
      _myCollectionFilters['showAll'] = true;
    }
    if (_myCollectionFilters['showBacklog'] == false) {
      _myCollectionFilters['showAll'] = false;
    }
    await updateMyCollectionFilters();
    notifyListeners();
  }

  Future<void> toggleShowHaveNotFinished() async {
    if (_myCollectionFilters['showHaveNotFinished'] == null) {
      return;
    }
    _myCollectionFilters['showHaveNotFinished'] = !_myCollectionFilters['showHaveNotFinished']!;
    if (_myCollectionFilters['showBacklog'] == true &&
        _myCollectionFilters['showHaveNotFinished'] == true &&
        _myCollectionFilters['showFinished'] == true) {
      _myCollectionFilters['showAll'] = true;
    }
    if (_myCollectionFilters['showHaveNotFinished'] == false) {
      _myCollectionFilters['showAll'] = false;
    }
    await updateMyCollectionFilters();
    notifyListeners();
  }

  Future<void> toggleShowFinished() async {
    if (_myCollectionFilters['showFinished'] == null) {
      return;
    }
    _myCollectionFilters['showFinished'] = !_myCollectionFilters['showFinished']!;
    if (_myCollectionFilters['showBacklog'] == true &&
        _myCollectionFilters['showHaveNotFinished'] == true &&
        _myCollectionFilters['showFinished'] == true) {
      _myCollectionFilters['showAll'] = true;
    }
    if (_myCollectionFilters['showFinished'] == false) {
      _myCollectionFilters['showAll'] = false;
    }
    await updateMyCollectionFilters();
    notifyListeners();
  }

  Future<void> toggleShowAll() async {
    if (_myCollectionFilters['showAll'] == null) {
      return;
    }
    //must be very careful about default rule as well as precedence of these
    //check games overview screen about defualt rule as well as precedence
    //default: show backlog (have not played), and have played not finished
    //if showAll is true, everything is true,
    //if there is one false, showAll is false,
    //if everything is true and showAll become false, then to default mode, showFinished is false
    //one case we have not thought is what if every filter is false???
    //should we don't show anything? yes!!!
    _myCollectionFilters['showAll'] = !_myCollectionFilters['showAll']!;
    if (_myCollectionFilters['showAll'] == true) {
      _myCollectionFilters['showBacklog'] = true;
      _myCollectionFilters['showHaveNotFinished'] = true;
      _myCollectionFilters['showFinished'] = true;
    } else {
      _myCollectionFilters['showBacklog'] = true;
      _myCollectionFilters['showHaveNotFinished'] = true;
      _myCollectionFilters['showFinished'] = false;
    }
    await updateMyCollectionFilters();
    notifyListeners();
  }

  Future<void> toggleHideDislikeds() async {
    if (_myCollectionFilters['hideDislikeds'] == null) {
      return;
    }
    _myCollectionFilters['hideDislikeds'] = !_myCollectionFilters['hideDislikeds']!;
    await updateMyCollectionFilters();
    notifyListeners();
  }

  Future<void> updateMyCollectionFilters() async {
    /*
    try {
      final prefs = await SharedPreferences.getInstance().catchError((e) {
        print(e);
      });
      await prefs.setBool('showAll', _myCollectionFilters['showAll']!);
      await prefs.setBool('showBacklog', _myCollectionFilters['showBacklog']!);
      await prefs.setBool('showHaveNotFinished', _myCollectionFilters['showHaveNotFinished']!);
      await prefs.setBool('showFinished', _myCollectionFilters['showFinished']!);
      await prefs.setBool('hideDislikeds', _myCollectionFilters['hideDislikeds']!);
    } catch (e) {
      print(e);
    }
    */

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "myCollectionFilters": {
            'showBacklog': _myCollectionFilters['showBacklog'],
            'showHaveNotFinished': _myCollectionFilters['showHaveNotFinished'],
            'showFinished': _myCollectionFilters['showFinished'],
            'showAll': _myCollectionFilters['showAll'],
            'hideDislikeds': _myCollectionFilters['hideDislikeds'],
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

  Future<void> setThemeMode(Brightness brightness, BuildContext context) async {
    if (brightness == Brightness.dark) {
      _preferences['isDarkMode'] = true;
      await updatePreferences(Brightness.dark, context);
    } else {
      _preferences['isDarkMode'] = false;
      await updatePreferences(Brightness.light, context);
    }
    notifyListeners();
  }

  Future<void> updatePreferences(Brightness brightness, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          "preferences": {
            'isDarkMode': (brightness == Brightness.dark) ? true : false,
            'timeBeforeEmptyTrash': Provider.of<Games>(context, listen: false).timeBeforeEmptyTrash,
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
}

//legacy code for fetching
//these are now in main and do not belong to this class anymore
/*
  /*
  Future<void> fetchUserPreferences() async {
    await fetchPreferences();
    await fetchFilters();
    notifyListeners();
  }
  */
  /*
  Future<void> fetchFilters() async {
    //doesn't need to check if myCollectionFilters exist since it is created upon signing up

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then(
        ((value) {
          final filters = value['myCollectionFilters'] as Map<String, dynamic>;
          print("fetched filters");
          print(filters);

          _myCollectionFilters = {
            'showBacklog': filters['showBacklog'],
            'showHaveNotFinished': filters['showHaveNotFinished'],
            'showFinished': filters['showFinished'],
            'showAll': filters['showAll'],
            'hideDislikeds': filters['hideDislikeds'],
          };
          /*//the below code wouldn't work, try the above code!
          _myCollectionFilters['showBacklog'] = (filters)['showBacklog'] as bool;
          _myCollectionFilters['showHaveNotFinished'] = filters['showHaveNotFinishedg'] as bool;
          _myCollectionFilters['showFinished'] = filters['showFinished'] as bool;
          _myCollectionFilters['showAll'] = filters['showAll'] as bool;
          */
        }),
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });
    } catch (e) {
      print(e);
      //rethrow;
    }
    print("finish fetching filters");
    print(_myCollectionFilters);
    notifyListeners();
  }
  */

  /*
  Future<void> fetchPreferences() async {
    //doesn't need to check if myCollectionFilters exist since it is created upon signing up

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then(
        ((value) {
          final preferences = value['preferences'] as Map<String, dynamic>;
          print("fetched preferences");
          print(preferences);

          _preferences = {
            'isDarkMode': preferences['isDarkMode'],
          };
        }),
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });
    } catch (e) {
      print(e);
      //rethrow;
    }
    print("finish fetching preferences");
    print(_preferences);
    notifyListeners();
  }
  */
*/