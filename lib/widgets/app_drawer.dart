//Firebase
import 'package:firebase_auth/firebase_auth.dart';
//packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//providers
import '../providers/games.dart';
//helpers
import '../helpers/custom_route.dart';
//screens
import '../screens/settings_screen.dart';
import '../screens/filter_screen.dart';
import '../screens/games_overview_screen.dart';
import '../screens/manage_games_screen.dart';
import '../screens/trending_games_screen.dart';
import '../screens/trash_screen.dart';
//manager screens
import '../developers/screens/manage_trending_games_screen.dart';
//temp data
import '../temp_data/temp_data.dart' as temp_data;
import '../temp_data/user_info.dart' as user_info;

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);
  static const routeName = '/app-drawer';

  @override
  Widget build(BuildContext context) {
    print("build app drawer");
    bool testingMode = false;
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              title: const Text("Select an option"),
              automaticallyImplyLeading: false, //never add a back button
              actions: [
                IconButton(
                  tooltip: "Close app drawer",
                  icon: const Icon(Icons.arrow_left),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("My Backlog"),
              onTap: () async {
                /*
                while (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                Navigator.of(context).pushNamed(GamesOverviewScreen.routeName);
                */
                Navigator.of(context).pushAndRemoveUntil(
                  CustomRoute(
                    builder: (context) => const GamesOverviewScreen(),
                  ),
                  (route) => route.isFirst, //GamesOverviewScreen is route.isFirst
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.gamepad),
              title: const Text("Manage My Backlog"),
              onTap: () async {
                Navigator.of(context).pushAndRemoveUntil(
                  CustomRoute(
                    builder: (context) => const ManageGamesScreen(),
                  ),
                  (route) => route.isFirst,
                );
              },
            ),
            if (testingMode == true) const Divider(),
            if (testingMode == true)
              ListTile(
                //set filters
                leading: const Icon(Icons.edit_sharp),
                title: const Text("Manage Trending Games"),
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    CustomRoute(
                      builder: (context) => const ManageTrendingGamesScreen(),
                    ),
                    (route) => route.isFirst,
                  );
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text("Trending Games"),
              onTap: () {
                /*
                while (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }

                Navigator.of(context).pushNamed(TrendingGamesScreen.routeName);
                */
                Navigator.of(context).pushAndRemoveUntil(
                  CustomRoute(
                    builder: (context) => const TrendingGamesScreen(),
                  ),
                  (route) => route.isFirst,
                );
              },
            ),
            const Divider(),
            ListTile(
              //set themes, ...
              leading: const Icon(Icons.favorite),
              title: const Text("Wishlist"),
              trailing: const Icon(Icons.shopping_cart),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  TrendingGamesScreen.routeName,
                  arguments: {'selectedPageIndex': 1},
                  (route) => route.isFirst,
                );
              },
            ),
            const Divider(),
            ListTile(
              //set themes, ...
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  SettingsScreen.routeName,
                  (route) => route.isFirst,
                );
              },
            ),
            const Divider(),
            ListTile(
              //set filters
              leading: const Icon(Icons.filter_alt_outlined),
              title: const Text("Filters"),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  CustomRoute(
                    builder: (context) => const FilterScreen(),
                  ),
                  (route) => route.isFirst,
                );
              },
            ),
            const Divider(),
            ListTile(
              //set filters
              leading: const Icon(Icons.delete),
              title: const Text("Trash"),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  CustomRoute(
                    builder: (context) => const TrashScreen(),
                  ),
                  (route) => route.isFirst,
                );
              },
            ),
            /*
            if (testingMode == true) const Divider(),
            if (testingMode == true)
              ListTile(
                //set filters
                leading: const Icon(Icons.delete_sweep_sharp),
                title: const Text("App Manager's Trash"),
                onTap: () {
                  /*
                  while (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }

                  Navigator.of(context).push(
                    CustomRoute(
                      builder: (context) => const DeveloperTrashScreen(),
                    ),
                  );
                  */

                  Navigator.of(context).pushAndRemoveUntil(
                    CustomRoute(
                      builder: (context) => const DeveloperTrashScreen(),
                    ),
                    (route) => route.isFirst,
                  );
                },
              ),
              */
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Sign Out"),
              onTap: () {
                _logout(
                  context,
                  Navigator.of(context),
                  Provider.of<Games>(context, listen: false),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

//this is the logout function from user_avatar.dart
void _logout(BuildContext context, NavigatorState navigatorState, Games gamesData) async {
  //print("log out function");
  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text("Are you sure?"),
        content: const Text("This action will log you out"),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () async {
              navigatorState.pop();
              //store Navigator.of(context) to navigatorState
            },
          ),
          TextButton(
            child: const Text("Okay"),
            onPressed: () async {
              while (navigatorState.canPop()) {
                navigatorState.pop();
              }

              //should await since GamesOverView use temp_data, and here we set temp_data to null
              //await navigatorState.pushNamed(AuthScreen.routeName);
              //navigatorState.pop();

              gamesData.reset();
              temp_data.reset();
              user_info.reset();
              await FirebaseAuth.instance.signOut();
              //maybe use push restorableState AuthScreen here
              //navigatorState.pushReplacementNamed('/');
            },
          ),
        ],
      );
    },
  );
}
