//see: https://stackoverflow.com/questions/51535621/using-navigator-popuntil-and-route-without-fixed-name/51535958#51535958
/*
 you do not use named routes or we want to the navigator to First active, you can use
Navigator.of(context).popUntil((route) => route.isFirst)
we use pushAndRemoveUntil with (route) => route.isFirst) for app drawer navigation
*/

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
                //why use this code?
                //there is something wrong when signing out if we use pushReplacement

                //we don't want to use push since if we use push
                //then the stack would grows significantly when user directs through pages from the AppDrawer
                //widgets/pages of the stack get rebuilt behind the scences even they are not being shown
                //For some unknown reason, after signing out (using pushReplacement here),
                //there is no stream, and StreamBuilder just not does anything
                //only these two
                //D/FirebaseAuth(12663): Notifying id token listeners about a sign-out event.
                //D/FirebaseAuth(12663): Notifying auth state listeners about a sign-out event.

                //and not
                //D/FirebaseAuth( 5051): Notifying id token listeners about a sign-out event.
                //D/FirebaseAuth( 5051): Notifying auth state listeners about a sign-out event.
                //D/EGL_emulation( 5051): app_time_stats: avg=84.66ms min=10.77ms max=1045.75ms count=15
                //I/flutter ( 5051): connectionState = ConnectionState.active
                //I/flutter ( 5051): hasData = false

                //hasData must be false for user to actually sign out

                //the log would show something like above and no hasData being printed even when we use print hasData
                //so there is no stream??? or it go in an infinite loop (it stuck in overview screen)
                //However, it works just fine if we use push for the GamesOverviewScreen and other screens in the appdrawer
                //so one work around is to use while (canPop) {pop} to pop all the pages, then use push
                //this would guarantee that the stack will not grow in size
                //and also guarantee that we use push
                //Notice that if we use pushNamedAndRemoveUntil, it wouln't work
                //work however could potentially briefly show previous pages to users so should find a way to push then pop the next to top page
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

                //Navigator.of(context).popAndPushNamed(GamesOverviewScreen.routeName); //might work but each time one more page is added to the stack, so not efficient
                //push and remove until is potentially the same as while (canpop) {pop} then push
                //however we push first and remove the next to top element until the condition is true so it wouldn't briefly show previous page to users, so it's better
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
                  /*
                  while (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }

                  Navigator.of(context).push(
                    CustomRoute(
                      builder: (context) => const ManageTrendingGamesScreen(),
                    ),
                  );
                  */

                  Navigator.of(context).pushAndRemoveUntil(
                    CustomRoute(
                      builder: (context) => const ManageTrendingGamesScreen(),
                    ),
                    (route) => route.isFirst,
                  );
                },
              ),

            /*
            const Divider(),
            ListTile(
              //set filters
              leading: const Icon(Icons.search),
              title: const Text("Advanced Search"),
              onTap: () {
                /*
                while (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                Navigator.of(context).push(
                  CustomRoute(
                    builder: (context) => const TrashScreen(),
                  ),
                );
                */
                Navigator.of(context).pushAndRemoveUntil(
                  CustomRoute(
                    builder: (context) => const SearchScreen(),
                  ),
                  (route) => route.isFirst,
                );
              },
            ),
            */
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
                //don't use pushReplacementNamed for this
                //first reason is it's gonna replace the AppDrawer which render the AppDrawer dead
                //we can open the AppDrawer after that
                //and secondly, the old time sign out problem when we can't sign out after use pushReplacementNamed
                //if we use push then definitely pop as many pages as possible before it to avoid the stack growing in size

                /*
                while (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                */
                //should check print log if it's necessary to pop
                //since it would briefly display the previous pages (Gamesoverviewscreen)
                //and we don't really want that to happen
                //check how many widgets get rebuil behind the scene in each case for while pop and not using while pop
                //actually they cost the same, so we should just use pushNamed for this

                //ignore above statements
                /*
                while (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }

                Navigator.of(context).pushNamed(
                  TrendingGamesScreen.routeName,
                  arguments: {'selectedPageIndex': 1},
                );
                */
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
                /*
                while (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                Navigator.of(context).push(
                  CustomRoute(
                    builder: (context) => const FilterScreen(),
                  ),
                );
                */
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
                /*
                while (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                Navigator.of(context).push(
                  CustomRoute(
                    builder: (context) => const TrashScreen(),
                  ),
                );
                */
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
