//for AppCheck
/*
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
*/
//packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//Firbase
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
//screens
import 'screens/edit_game_screen/edit_game_experience_screen.dart';
import './screens/settings_screen.dart';
import './screens/filter_screen.dart';
import './screens/trash_screen.dart';
import './screens/auth_screen.dart';
import './screens/game_detail_screen.dart';
import './screens/games_overview_screen.dart';
import './screens/manage_games_screen.dart';
import './screens/splash_screen.dart';
import './screens/edit_game_screen/edit_game_screen.dart';
import '../screens/trending_games_screen.dart';
//manager screen
import '../developers/screens/edit_trending_game_screen.dart';
//widgets
import './widgets/app_drawer.dart';
//providers
import '../providers/user_preferences.dart';
import './providers/games.dart';
//temp_data
import '../temp_data/user_info.dart' as user_info;

/// - Improve cart so that it reflects quantity of a unique item instead of 1 for each unique item
/// - Add function to decrement quantity of an item in cart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  /*
  //this segment is for AppCheck and also Main Activity java
  if (kDebugMode) {
    const platform = MethodChannel('samples.flutter.dev/appcheck');
    /*final int r = */ await platform.invokeMethod("installDebug");
  }
  await FirebaseAppCheck.instance.activate(
    webRecaptchaSiteKey: 'recaptcha-v3-site-key',
  );
  */
  //await FirebaseAppCheck.instance.activate();

  Map<String, dynamic> preferences = {};
  Map<String, bool> myCollectionFilters = {};
  try {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then(
      ((document) async {
        //fetch preferences from server
        if (document.data() != null && (document.data())!.containsKey('preferences')) {
          final prefs = document['preferences'] as Map<String, dynamic>;
          print(prefs);
          preferences = {
            'isDarkMode': prefs['isDarkMode'],
            'timeBeforeEmptyTrash': prefs['timeBeforeEmptyTrash'],
          };
        } else {
          //if user doesn't have data
          preferences = {
            'isDarkMode': false,
            'timeBeforeEmptyTrash': 30, //days
          };
          //should create preferences -> isDarkMode on Firebase if user doesn't have one and set it to false
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update(
            {
              "preferences": {
                'isDarkMode': false,
                'timeBeforeEmptyTrash': 30,
              }
            },
          ).onError((error, stackTrace) {
            print(error);
            print(stackTrace.toString());
          });
        }
        //fetch filters from server
        if (document.data() != null && (document.data())!.containsKey('myCollectionFilters')) {
          final filters = document.data()!['myCollectionFilters'] as Map<String, dynamic>;
          print("fetched filters");
          print(filters);

          myCollectionFilters = {
            'showBacklog': filters['showBacklog'],
            'showHaveNotFinished': filters['showHaveNotFinished'],
            'showFinished': filters['showFinished'],
            'showAll': filters['showAll'],
            'hideDislikeds': filters['hideDislikeds'],
          };
        } else {
          myCollectionFilters = {
            'showBacklog': true,
            'showHaveNotFinished': true,
            'showFinished': true,
            'showAll': true,
            'hideDislikeds': false,
          };
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update(
            {
              "myCollectionFilters": {
                'showBacklog': true,
                'showHaveNotFinished': true,
                'showFinished': true,
                'showAll': true,
                'hideDislikeds': false,
              }
            },
          ).onError((error, stackTrace) {
            print(error);
            print(stackTrace.toString());
          });
        }
      }),
    ).onError((error, stackTrace) {
      print(error);
      print(stackTrace.toString());
    });
  } catch (e) {
    print(e);
    //rethrow;
  }

  try {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((document) {
      user_info.username = document['username'];
      user_info.userImageURL = document['image_url'];
      user_info.userEmail = document['email'];
      user_info.hasLoadedCredential = true;
    }).onError((error, stackTrace) {
      print(error);
      print(stackTrace.toString());
    });
  } catch (e) {
    print(e);
  }
  //print(preferences);
  runApp(
    ChangeNotifierProvider<UserPreferences>(
      create: (_) => UserPreferences(
        myCollectionFilters,
        preferences,
      ),
      child: MyApp(
        timeBeforeEmptyTrash: preferences['timeBeforeEmptyTrash'] as int?,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final int? timeBeforeEmptyTrash;
  const MyApp({
    Key? key,
    required this.timeBeforeEmptyTrash,
  }) : super(key: key);

/*
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

//how to use theme in flutter
//see: https://stackoverflow.com/questions/64999808/get-widget-observer-for-widgetsbindingobserver
//in order for this to be deemed as WidgetsBindingObserver we have to use mix in
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  Brightness? _brightness;
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _brightness = WidgetsBinding.instance.window.platformBrightness;
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    if (mounted) {
      setState(() {
        _brightness = WidgetsBinding.instance.window.platformBrightness;
      });
    }
    super.didChangePlatformBrightness();
  }

  CupertinoThemeData get _lightTheme => const CupertinoThemeData(
        brightness: Brightness.light, /* light theme settings */
      );

  CupertinoThemeData get _darkTheme => const CupertinoThemeData(
        brightness: Brightness.dark, /* dark theme settings */
      );
      */
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Games>(
          create: (ctx) => Games(
            timeBeforeEmptyTrash: timeBeforeEmptyTrash,
          ),
        ),
      ],
      //this ensures that whenever the Auth object changes, Material App gets rebuilt
      //how about we wrap this with Consumer???
      child: Consumer<UserPreferences>(
        builder: (context, userPreferences, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'My Backlog',
            //themeMode: ThemeMode.light,
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: const ColorScheme.dark().copyWith(
                onPrimaryContainer: Colors.white70,
                //onPrimary: Colors.white70,
              ),
            ),
            theme: userPreferences.getTheme(),
            //theme.getTheme(),
            home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              //notifies when there's change (login, signup, ...)

              builder: (ctx, userSnapshot) {
                //check if user actually logs out
                //if so hasData = false
                print("connectionState = ${userSnapshot.connectionState}");
                print("hasData = ${userSnapshot.hasData}");

                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen();
                } else if (userSnapshot.hasData) {
                  return const GamesOverviewScreen();
                } else {
                  return const AuthScreen();
                }
              },
            ),
            routes: {
              GamesOverviewScreen.routeName: (ctx) => const GamesOverviewScreen(),
              GameDetailScreen.routeName: (ctx) => const GameDetailScreen(),
              EditGameScreen.routeName: (ctx) => const EditGameScreen(),
              AuthScreen.routeName: (ctx) => const AuthScreen(),
              ManageGamesScreen.routeName: (ctx) => const ManageGamesScreen(),
              TrendingGamesScreen.routeName: (ctx) => const TrendingGamesScreen(),
              FilterScreen.routeName: (ctx) => const FilterScreen(),
              EditTrendingGameScreen.routeName: (ctx) => const EditTrendingGameScreen(),
              AppDrawer.routeName: (ctx) => const AppDrawer(),
              SplashScreen.routeName: (ctx) => const SplashScreen(),
              EditGameExperienceScreen.routeName: (ctx) => const EditGameExperienceScreen(),
              TrashScreen.routeName: (ctx) => const TrashScreen(),
              SettingsScreen.routeName: (ctx) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}

/*
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.blue,
  primaryContainer: Colors.black54, //primaryContainer: color of containers
  onPrimaryContainer: Colors.white70, //onPrimaryContainertext on containers
  primary: Colors.black26,
  //background color of elevatedbuttons, text color of textbuttons
  onPrimary: Colors.red, //color of text on buttons
  surface: Colors.black26, //surface: color of app bar
  onSurface: Colors.white70, //text on appbar

  secondaryContainer: Colors.yellow,
  secondary: Colors.red,
  tertiary: Colors.red,
  tertiaryContainer: Colors.red,
  shadow: Colors.amber,
  brightness: Brightness.dark,


  background: Colors.yellow,
).copyWith(brightness: Brightness.dark),
*/

/*
if (Platform.isIOS) {
  return CupertinoApp(
    debugShowCheckedModeBanner: false,
    title: 'My Backlog',
    theme: _brightness == Brightness.dark ? _darkTheme : _lightTheme,
    home: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      //notifies when there's change (login, signup, ...)

      builder: (ctx, userSnapshot) {
        //check if user actually logs out
        //if so hasData = false
        print("connectionState = ${userSnapshot.connectionState}");
        print("hasData = ${userSnapshot.hasData}");

        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else if (userSnapshot.hasData) {
          return const GamesOverviewScreen();
        } else {
          return const AuthScreen();
        }
      },
    ),
  );
}
*/
