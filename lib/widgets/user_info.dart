//packages
import 'package:flutter/material.dart';
//Firebase
import 'package:firebase_auth/firebase_auth.dart';
//screens
import '../screens/user_info_screen.dart';
//providers
import 'package:provider/provider.dart';
import '../providers/games.dart';
//helpers
import '../helpers/custom_route.dart';
//temp data
import '../temp_data/temp_data.dart' as temp_data;
import '../temp_data/user_info.dart' as user_info;

class UserInformation extends StatelessWidget {
  final String returnPageRouteName;
  //final bool isFromHomePage;
  final String? _userName;
  final String? _userImageURL;
  const UserInformation(
    this._userName,
    this._userImageURL, {
    Key? key,
    //this.isFromHomePage = false,
    required this.returnPageRouteName,
  }) : super(key: key);

  void _logout(BuildContext context, NavigatorState navigatorState, Games gamesData) async {
    //save navigatorState (i.e. Navigator.of(context)) to deal with
    //trying to access widget's ancestor which is unsafe
    //why try to use a pop up dialog for this user avatar _logout function?
    //because unlike appdrawer's _logout
    //this _logout pop the last page and go to black page
    //so it pop one more than it should
    //even though having the same code
    //1/ while (canPop) pop
    //2/ set temp_data empty/null
    //3/ await signOut
    //Thus in order to replicate successful log out from the AppDrawer
    //notice that AppDrawer is treated like a page and we actually pop it one
    //so use something that we can pop like the AppDrawer
    //the easy choice is a popup dialog to replicated popping the appdrawer "page"
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Are you sure?"),
          content: const Text("This action will log you out."),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () async {
                navigatorState.pop();
                //replace Navigator.of(context)
              },
            ),
            TextButton(
              child: const Text("Okay"),
              onPressed: () async {
                while (navigatorState.canPop()) {
                  navigatorState.pop();
                }
                gamesData.reset();
                //Games gamesData = Provider.of<Games>(context, listen: false);
                //setEmpty's purpose is to avoid next user seeing data from previous user after loggin in
                //set _games and _trendingGames to empty
                //maybe we should also store Provider.of<Games>(context) since it uses context
                temp_data.reset();
                user_info.reset();
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        );
      },
    );
    /*
    while (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      //have to do this since there're problems with login out
      //after we direct to GamesOverviewScreen from the AppDrawer
    }

    //though we should use await for signOut since it's asynchronous
    //using await here would not work (after signOut attempting to sign in again wouldn't work)
    //BUT DOES IT ACTUALLY SIGN OUT???
    //check if hasData of snapshot from the StreamBuilder is false?
    //with this code it is

    //await Future.delayed(const Duration(seconds: 1));
    temp_data.deletedGames = [];
    temp_data.isFetchUserGames = false;
    temp_data.isFetchTrendingGames = false;
    user_info.userImageURL = null;
    user_info.username = null;
    user_info.userEmail = null;
    ////if we use pop then we can't actually signout if we enter custom gamesoverviewscreen
    FirebaseAuth.instance.signOut();
    //will go to blank page (black screen) if use while {pop} and then sign out
    //D/FirebaseAuth(12663): Notifying id token listeners about a sign-out event.
    //D/FirebaseAuth(12663): Notifying auth state listeners about a sign-out event.
    //unlike AppDrawer's _logout for some reason
    //probably related to the drawer being open when _logout
    //so gotta push the AuthScreen at the end to avoid this issue

    //the problem with signOut might be related to not changing the function to async
    //since signOut handling with Firebase and its return type is a Future
    //however, when changing to async and await the signOut function
    //then after sign out we cannot actually sign in again
    //doesn't really work as intended

    //convert this widget to stateful only to use this push function at the end to go back to the Auth Screen
    //since with the current code it would go to a black screen (pop more than it should)
    //and we have to avoid "Do not use BuildContexts across async gaps." by using "mounted"
    //which is a property of a State class

    if (!mounted) return;
    Navigator.push(
      context,
      CustomRoute(
        builder: (context) => const AuthScreen(),
      ),
    );
    */
  }

  @override
  Widget build(BuildContext context) {
    final NavigatorState navigatorState = Navigator.of(context);
    final Games gamesData = Provider.of<Games>(context, listen: false);
    if (_userImageURL == null && _userName == null) {
      return Container();
    }
    return FittedBox(
      //to fit the small app bar
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: Text(_userName ?? ""),
          ),
          GestureDetector(
            onTap: () {
              //see: https://stackoverflow.com/questions/61756271/how-to-set-flutter-showmenu-starting-point
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(1, 0, 0, 0),
                items: [
                  //if (isFromHomePage)
                  PopupMenuItem<int>(
                    value: 0,
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).pop();
                        if (user_info.hasLoadedCredential) {
                          Navigator.of(context).push(
                            CustomRoute(
                              builder: (context) =>
                                  UserInfoScreen(returnPageRouteName: returnPageRouteName),
                            ),
                          );
                        }
                      },
                      leading: const Icon(
                        Icons.person,
                        //color: Colors.blue,
                      ),
                      title: const Text(
                        "User Information",
                        //style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 1, //(isFromHomePage) ? 1 : 0,
                    child: ListTile(
                      onTap: () {
                        _logout(context, navigatorState, gamesData);
                      },
                      leading: const Icon(
                        Icons.logout,
                        //color: Colors.blue,
                      ),
                      title: const Text(
                        "Log Out",
                        //style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              );
            }, //maybe use showMenu or showModal
            child: Hero(
              tag: "user_avatar",
              child: CircleAvatar(
                backgroundImage: _userImageURL == null ? null : NetworkImage(_userImageURL!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
