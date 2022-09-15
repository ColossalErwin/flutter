//dart
import 'dart:io';
//Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
//packages
import 'package:flutter/material.dart';
//widgets
import '../widgets/auth/auth_form.dart';
//providers
import '../providers/game.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);
  static const routeName = 'auth';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  void _submitAuthForm(
    String email,
    String? username, //username is not required in login mode so it's null in login mode
    //therefore, we use String? instead of String
    File? imageFile, //similar to username, imageFile is null in login case
    String password,
    bool isLogin,
  ) async {
    UserCredential userCredential;
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        //signInWithEmailAndPassword returns Future<UserCredential>
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final ref = FirebaseStorage.instance
            .ref()
            .child('users')
            .child(userCredential.user!.uid)
            .child('user_avatar');
        await ref
            .putFile(
              imageFile as File,
              //SettableMetadata(),
            )
            .whenComplete(() => null);
        //ref is a reference function
        //the first child is the parent folder
        //second child is the sub folder

        final url = await ref.getDownloadURL();

        //set returns a Future so use await
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set(
          {
            'username': username,
            'email': email,
            'image_url': url,
            'games': gamesToListOfMaps(demoGames),
            'myCollectionFilters': {
              'showBacklog': true,
              'showHaveNotFinished': true,
              'showFinished': true,
              'showAll': true,
              'hideDislikeds': false,
            },
            'preferences': {
              'isDarkMode': false,
              'timeBeforeEmptyTrash': 30,
            }
          },
        );
      }
    } on FirebaseAuthException catch (error) {
      var message = "An error occurred, please check your credentials";
      if (error.message != null) {
        message = error.message as String;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      //print(error.runtimeType); //to know what type of Exception this error belongs to
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("build auth screen");
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(
        submitFunction: _submitAuthForm,
        isLoading: _isLoading,
      ),
    );
  }
}
