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
    //save navigatorState (i.e. Navigator.of(context)) to deal with the error
    //trying to access widget's ancestor
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
              },
            ),
            TextButton(
              child: const Text("Okay"),
              onPressed: () async {
                while (navigatorState.canPop()) {
                  navigatorState.pop();
                }
                gamesData.reset();
                temp_data.reset();
                user_info.reset();
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        );
      },
    );
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
