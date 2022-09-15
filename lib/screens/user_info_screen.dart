//user info
//and edit user info

//dart
import 'dart:io';
//packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';
//Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
//temp data
import '../temp_data/user_info.dart' as user_info;

class UserInfoScreen extends StatefulWidget {
  final String returnPageRouteName;
  const UserInfoScreen({
    Key? key,
    required this.returnPageRouteName,
  }) : super(key: key);

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  bool _isLoading = false;

  bool _isInChangeUsernameMode = false;
  File? _pickedImage;

  final Map<String, String?> _initValues = {};
  final _usernameForm = GlobalKey<FormState>();

  bool _isInit = false;
  @override
  void initState() {
    if (_isInit == false) {
      _initValues['userImageURL'] = user_info.userImageURL;
      _initValues['userEmail'] = user_info.userEmail;
      _initValues['username'] = user_info.username;
    }
    print(_initValues);
    _isInit = true;
    super.initState();
  }

  void _pickImage(ImageSource imageSource) async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker
          .pickImage(
        source: imageSource,
        imageQuality: 75, //0-100
        maxWidth: 150,
      )
          .onError((error, stackTrace) {
        print(error);
        print(stackTrace.toString());
      });
      if (pickedImage == null) {
        return;
      }
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
      //widget.imagePickerFn(_pickedImage as File);
    } on PlatformException catch (error) {
      print(error);
    } catch (error) {
      print(error);
    }
  }

  Future<void> changeAvatar() async {
    //String? _storedUserImageURL;
    if (_pickedImage != null) {
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('users')
            .child(FirebaseAuth.instance.currentUser!.uid)
            .child('user_avatar');
        await ref.putFile(_pickedImage!).whenComplete(() => null).then(
          (value) {
            print("Successfully updated user_avatar to the FirebaseStorage");
          },
          onError: (error) {
            print("Error updating document $error");
          },
        );

        user_info.userImageURL = await ref.getDownloadURL();

        print("successfully updated user image to Firebase Storage");

        await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'image_url': user_info.userImageURL}).then(
          (value) => print("Successfully updated image_url to FirebaseFirestore!"),
          onError: (e) => print("Error updating user avatar $e"),
        );
        //Navigator.of(context).pushReplacementNamed(GamesOverviewScreen.routeName);
      } on FirebaseException catch (error) {
        print(error);
        rethrow;
      } catch (error) {
        print(error);
        rethrow;
      }
    }
  }

  Future<void> changeUsername() async {
    if (_initValues['username'] != user_info.username) {
      try {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'username': user_info.username}).then(
          (value) => print("Successfully updated username to FirebaseFirestore!"),
          onError: (e) => print("Error updating username $e"),
        );
      } on FirebaseException catch (error) {
        print(error);
        rethrow;
      } catch (error) {
        print(error);
        rethrow;
      }
    }
  }

  Future<void> makeChanges() async {
    final isValid = _usernameForm.currentState?.validate();
    //will have an error: null check operator use on null if try to cancel the confirm button then click on save again
    //so should check if isValid is null
    //maybe should use this condition for other parts of edit game screen

    //THIS WOULD GET STUCK IN SOME CASES WHEN WE DONT CHOOSE THE INPUT so check again
    //cannot really save after that
    /*
    if (isValid == null) {
      return;
    }
    */
    //if we use final isValid = _usernameForm.currentState!.validate();
    //instead, then we don't have to check if isValid is null since it would never be null
    //since if currentState is null, an error would occure
    //if we use ? then it would return null if currentState is null
    //then we have to check if isValid is null
    if (isValid != null && !isValid) {
      return;
    }
    _usernameForm.currentState?.save();
    setState(() {
      _isInChangeUsernameMode = false;
    });

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Are you sure?"),
          content: const Text("This action will make changes to your account"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Okay"),
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  _isLoading = true;
                });
                await changeAvatar();
                await changeUsername();
                setState(() {
                  _isLoading = false;
                });
                if (!mounted) return;
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(widget.returnPageRouteName);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Information"),
        actions: [
          IconButton(
            onPressed: () async {
              await makeChanges();
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: (_isLoading)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Making changes to your account ..."),
                ],
              ), //this would show a loading spinner
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    //subtitle: const Text("user avatar"),
                    leading: (_pickedImage != null)
                        ? Hero(
                            tag: "user_avatar",
                            child: CircleAvatar(
                              backgroundImage: FileImage(_pickedImage!),
                            ),
                          )
                        : Hero(
                            tag: "user_avatar",
                            child: CircleAvatar(
                              backgroundImage: (user_info.userImageURL == null)
                                  ? null
                                  : NetworkImage(user_info.userImageURL!),
                            ),
                          ),
                    subtitle: TextButton.icon(
                      icon: const Icon(Icons.zoom_in),
                      label: const Text(
                        "Zoom in",
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        SwipeImageGallery(
                          hideStatusBar: false,
                          backgroundColor: Colors.black54,
                          //use current Image Index found in CarouselSllider to jump to the right image here
                          context: context,
                          children: (user_info.userImageURL == null)
                              ? null
                              : [Image.network(user_info.userImageURL!)],
                          heroProperties: const [
                            ImageGalleryHeroProperties(tag: 'user_avatar'),
                          ],
                        ).show();
                      },
                    ),
                    trailing: TextButton.icon(
                      icon: const Icon(Icons.image), //const Icon(Icons.change_circle),
                      onPressed: () async {
                        await showDialog<void>(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              title: const Text("Choose an option."),
                              content:
                                  const Text("Browse images from the gallery or use the camera."),
                              actions: [
                                TextButton.icon(
                                  icon: const Icon(Icons.camera_alt_outlined),
                                  label: const Text("Camera"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _pickImage(ImageSource.camera);
                                  },
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.image),
                                  label: const Text("Gallery"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _pickImage(ImageSource.gallery);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      label: const Text("Change user avatar"),
                    ),
                  ),
                  if (_isInChangeUsernameMode == false)
                    ListTile(
                      subtitle: const Text("username"),
                      title: SelectableText(user_info.username ?? ""),
                      //since we already has the flag hasUserCredentials before going to this page,
                      //it is kind of unecessary
                      trailing: TextButton.icon(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            _isInChangeUsernameMode = true;
                          });
                        },
                        label: const Text("Change username"),
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          children: [
                            Flexible(
                              child: Form(
                                key: _usernameForm,
                                child: TextFormField(
                                  initialValue: user_info.username ?? "",
                                  onEditingComplete: () {
                                    setState(() {});
                                  },
                                  onSaved: (inputValue) {
                                    user_info.username = inputValue;
                                  },
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).unfocus();
                                    //FocusScope.of(context).requestFocus(_additionalImageURLFocusNode);
                                  },
                                  autocorrect: true,
                                  textCapitalization: TextCapitalization.words,
                                  enableSuggestions: false,
                                  //key: const ValueKey('username'),
                                  validator: (inputValue) {
                                    if (inputValue == null ||
                                        inputValue.isEmpty ||
                                        inputValue.length < 4) {
                                      return "Please enter at least 4 characters.";
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: "username",
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: constraints.maxWidth / 3.5,
                              //height: constraints.maxHeight * 0.75,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 237, 237, 237),
                                border: Border.all(
                                  color: Colors.black54,
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextButton(
                                child: const Text("Confirm"),
                                onPressed: () {
                                  final isValid = _usernameForm.currentState?.validate();
                                  if (isValid != null && !isValid) {
                                    return;
                                  }
                                  _usernameForm.currentState?.save();
                                  setState(() {
                                    _isInChangeUsernameMode = false;
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ListTile(
                    isThreeLine: true,
                    subtitle: const Text("email address"),
                    title: SelectableText(user_info.userEmail ?? ""),
                    //since we already has the flag hasUserCredentials before going to this page,
                    //it is kind of unecessary
                    trailing: const Text(
                      "Email cannot be changed",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  ListTile(
                    leading: TextButton.icon(
                      icon: const Icon(Icons.arrow_back), //const Icon(Icons.change_circle),
                      onPressed: () async {
                        await showDialog<void>(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              title: const Text("Are you sure?"),
                              content:
                                  const Text("Changes you have made will be lost if you do this."),
                              actions: [
                                TextButton(
                                  child: const Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text("Okay"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      label: const Text("Cancel"),
                    ),
                    trailing: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(elevation: 1),
                      icon: const Icon(Icons.save), //const Icon(Icons.change_circle),
                      onPressed: () async {
                        await makeChanges();
                      },
                      label: const Text("Confirm"),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
