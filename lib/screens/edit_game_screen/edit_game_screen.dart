//dart
import 'dart:io' as device;
//Firebase
import 'package:firebase_auth/firebase_auth.dart';
//packages
import 'package:flutter/material.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:provider/provider.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';
//helpers
import '../../helpers/custom_route.dart';
//screens
import '../game_detail_screen.dart';
import '../manage_games_screen.dart';
import './additional_file_images_builder.dart';
import './images_picker.dart';
import '../games_overview_screen.dart';
import './add_detailed_description_screen.dart';
//providers
import '../../providers/game.dart';
import '../../providers/games.dart';
//pickers helper
import './title_image_picker.dart';
import './additional_images_builder.dart';

class EditGameScreen extends StatefulWidget {
  const EditGameScreen({Key? key}) : super(key: key);

  static const routeName = "/edit-game";

  @override
  State<EditGameScreen> createState() => _EditGameScreenState();
}

class _EditGameScreenState extends State<EditGameScreen> {
  late final GlobalKey _parentKey;

  List<device.File> _pickedImageFiles = [];

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _msrpController = TextEditingController();
  final _titleImageURLController = TextEditingController();
  final _additionalImageURLController = TextEditingController();
  final _imdbController = TextEditingController();
/*
'package:flutter/src/material/text_form_field.dart': 
Failed assertion: line 150 pos 15: 'initialValue == null || controller == null': is not true.
If we use controllers, then don't use initialValue for TextFormField since one of them must be null
so if use controller, but want to display initial value, then assign namedController.text = initial value first
*/

  final _msrpFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _titleImageURLFocusNode = FocusNode();
  final _additionalImageURLFocusNode = FocusNode();

  //String _clearedAdditionalImageURLController = "";
  final _form = GlobalKey<FormState>();
  //we only need one form key to validate multiple forms (we have two forms here)
  //see: https://stackoverflow.com/questions/63978505/validating-textformfield-with-two-different-key-in-flutter
  //cannot use 1 globalkey for two variables => incorrect usage

  //this is good for testing since we know there's something wrong if we generate a game with a default dog image
  final _addedGame = MutableGame(
    id: "Demo id: ${DateTime.now().toIso8601String()}",
    title: "Demo title",
    description: "This game is fun!?",
    msrp: 69.99,
    platform: Platform.PS4_and_PS5,
    titleImageURL: "https://m.media-amazon.com/images/I/61ii4p0wziL._AC_SS450_.jpg",
    imageURLs: [],
  );

  ///We have to dispose Focus Nodes after usage or else it will cause memory leaks
  @override
  void dispose() {
    //dispose focus node
    _msrpFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _titleImageURLFocusNode.removeListener(_updateTitleImageURL);
    _additionalImageURLFocusNode.removeListener(_updateAdditionalImageURL);
    //
    _titleImageURLFocusNode.dispose();
    _titleImageURLController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _msrpController.dispose();
    _imdbController.dispose();
    //
    super.dispose();
  }

  Game? _initialGame; //since there are too many errors with handling update
  //we should just store initial values of _editedGame here
  late Game _editedGame; //why does this work? _editedGame is not initalized in the added case
  //it should be coz it's late and not Game?

  late bool _useDeviceImageInput;

  late Map<String, String>? _args;
  String? _gameID;
  String? _returnRouteName;
  bool _isInit = false;

  bool _isLoading = false;

  bool _hasPickedPlatform = false;

  bool _isInitInitialGame = false;

  //List<String> tempDeletedURLs = [];
  final List<String> _copiedImageURLs = [];

  //we want to access the _gameID that was forwarded in user_game_item.dart by
  //Navigator.of(context).pushNamed(EditGameScreen.routeName, arguments: id,);
  //since ModalRoute needs context we cannot do this in initState
  @override
  void didChangeDependencies() {
    if (_isInit == false) {
      _parentKey = GlobalKey();
      _useDeviceImageInput = true;
      _args = ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
      if (_args != null) {
        _gameID = (_args!.containsKey('id')) ? _args!['id'] : null;
        _returnRouteName = _args!['returnRouteName'];
      }

      if (_gameID != null) {
        _hasPickedPlatform = true;
        _editedGame =
            Provider.of<Games>(context).findByID(_gameID as String, GamesOption.userGames);

        for (final String url in _editedGame.imageURLs) {
          _copiedImageURLs.add(url);
        }

        if (_isInitInitialGame == false) {
          List<String> tempArr1 = [];
          for (int index = 0; index < _editedGame.imageURLs.length; index++) {
            tempArr1.add(_editedGame.imageURLs[index]);
          }
          List<String> tempArr2 = [];
          if (_editedGame.userImageURLs != null) {
            for (int index = 0; index < _editedGame.userImageURLs!.length; index++) {
              tempArr2.add(_editedGame.userImageURLs![index]);
            }
          }

          _initialGame = _editedGame.copyWith(
            imageURLs: tempArr1,
            userImageURLs: (_editedGame.userImageURLs == null) ? null : tempArr2,
          );
        }
        _isInitInitialGame = true;

        _addedGame.longDescription = _editedGame.longDescription;
        _addedGame.platform = _editedGame.platform;
        //just for the initial value of the chosen platform button to show correct value
        //since it's based on _addedGame.platform instead
        _titleController.text = _editedGame.title;
        _msrpController.text = _editedGame.msrp.toStringAsFixed(2);
        _descriptionController.text = _editedGame.description;
        _titleImageURLController.text = _editedGame.titleImageURL;
      }
    }

    _isInit = true;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _titleImageURLFocusNode.addListener(_updateTitleImageURL);
    _additionalImageURLFocusNode.addListener(_updateAdditionalImageURL);
    super.initState();
  }

  void _updateTitleImageURL() {
    //if we lose focus of imageURL from TextFormField by clicking other where in the form
    //then update image!
    if (!_titleImageURLFocusNode.hasFocus) {
      if ((!_titleImageURLController.text.startsWith('http') &&
              !_titleImageURLController.text.startsWith('https')) ||
          (!_titleImageURLController.text.endsWith('.png') &&
              !_titleImageURLController.text.endsWith('.jpg') &&
              !_titleImageURLController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  void _updateAdditionalImageURL() {
    //if we lose focus of imageURL from TextFormField by clicking other where in the form
    //then update image!
    if (!_additionalImageURLFocusNode.hasFocus) {
      if ((!_additionalImageURLController.text.startsWith('http') &&
              !_additionalImageURLController.text.startsWith('https')) ||
          (!_additionalImageURLController.text.endsWith('.png') &&
              !_additionalImageURLController.text.endsWith('.jpg') &&
              !_additionalImageURLController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  //_saveForm needs to interact with the Form widget inside the build method
  //we need a Global Key for that

  //we need to change the return type to Future<void> because
  //async would automatically wraps the code inside a Future object
  Future<void> _saveForm() async {
    if (_gameID != null) {
      try {
        String tempTitleImageURL = _titleImageURLController.text;
        //though _editedGame initally have imageURLs (not empty), we still wanna check since we could just delete them in edit mode
        if (_copiedImageURLs.isNotEmpty || _pickedImageFiles.isNotEmpty) {
          _additionalImageURLController.text = "https://placeholder.jpeg";
          //this is actually just dummy data
          //since we use the OutlinedButton to deal with imageURLs and
          //clear TextEditingController text each time we click the button
          //at the end there would be no user input, but we want at least one additional imageURL
          //so we check if _editedGame.imageURLs is empty, if it's not then there're actually images
          //and we just need to add some dummy data in order for it to get through the validation process
          //_clearedAdditionalImageURLController;
        }

        if (_initialGame!.titleImageURL.startsWith("https://firebasestorage.googleapis.com/") &&
            _useDeviceImageInput == false) {
          tempTitleImageURL = _titleImageURLController.text;
          _titleImageURLController.text = "https://placeholder.jpeg";
        }
        //we use _form global key to get access to a specific Form widget inside the widget tree
        //if we want to access to another form, then create another key for that one
        final isValid = _form.currentState?.validate();
        //this validate() function will trigger all the validators in the form
        if (isValid == null) {
          return;
        }
        if (!isValid) {
          if (_additionalImageURLController.text == "https://placeholder.jpeg") {
            _additionalImageURLController.clear();
          }
          if (_titleImageURLController.text == "https://placeholder.jpeg") {
            _titleImageURLController.text = tempTitleImageURL;
          }
          return;
        }

        _titleImageURLController.text = tempTitleImageURL;

        if (_hasPickedPlatform == false) {
          await showDialog<void>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text("Missing required information!"),
                content: const Text("You haven't picked a gaming platform yet, which is required."),
                actions: [
                  TextButton(
                    child: const Text("Okay"),
                    onPressed: () {
                      Navigator.of(context).pop(); //this will close  the pop up dialog
                      _additionalImageURLController.clear();
                      FocusScope.of(context).unfocus();
                    },
                  )
                ],
              );
            },
          );
          return;
        }
        if (_copiedImageURLs.isEmpty && _pickedImageFiles.isEmpty) {
          await showDialog<void>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text("Missing required information!"),
                content: const Text("You haven't added an addition image yet, which is required."),
                actions: [
                  TextButton(
                    child: const Text("Okay"),
                    onPressed: () {
                      Navigator.of(context).pop(); //this will close  the pop up dialog
                      _additionalImageURLController.clear();
                      //FocusScope.of(context).unfocus();
                    },
                  )
                ],
              );
            },
          );
          return; //return since we need at least one additional image URL
        }

        await showDialog<void>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text("Are you sure?"),
              content: const Text("Click confirm to finish editing."),
              actions: [
                TextButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("Keep editing"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    //Focus.of(context).unfocus();
                  },
                ),
                TextButton(
                  child: const Text("Confirm"),
                  onPressed: () async {
                    Navigator.of(context).pop(); //pop the alert dialog
                    _form.currentState?.save();
                    setState(() {
                      _isLoading = true;
                    });

                    _editedGame = _editedGame.copyWith(
                      id: _gameID as String,
                      description: _addedGame.description,
                      longDescription: (_addedGame.longDescription != null)
                          ? _addedGame.longDescription
                          : _initialGame!.longDescription,
                      title: _addedGame.title,
                      msrp: _addedGame.msrp,
                      titleImageURL: (_useDeviceImageInput == true && _titleImageFile == null)
                          ? _initialGame!.titleImageURL
                          : _addedGame.titleImageURL,
                      platform: _addedGame.platform,
                      imageURLs: _copiedImageURLs,
                    );

                    //mounted is a special property of Stateful widget use to check using context between async gap
                    if (!mounted) return;

                    print("deleted image urls are");
                    print(_deletedStorageImageURLs);

                    if (_useDeviceImageInput == false) {
                      //maybe not using await here so that we don't have to see the load spinner, however we might go to the screen without actual updated data
                      await Provider.of<Games>(context, listen: false).updateGame(
                        id: _editedGame.id,
                        initialGame: _initialGame as Game,
                        editedGame: _editedGame,
                        gamesOption: GamesOption.userGames,
                        imageFiles: _pickedImageFiles,
                        deletedStorageImageURLs: _deletedStorageImageURLs,
                      );
                    } else {
                      //maybe not using await here so that we don't have to see the load spinner, however we might go to the screen without actual updated data
                      await Provider.of<Games>(context, listen: false).updateGame(
                        id: _editedGame.id,
                        initialGame: _initialGame as Game,
                        editedGame: _editedGame,
                        gamesOption: GamesOption.userGames,
                        imageFile: _titleImageFile,
                        imageFiles: _pickedImageFiles,
                        deletedStorageImageURLs: _deletedStorageImageURLs,
                      );
                    }

                    setState(
                      () {
                        _isLoading = false;
                      },
                    );
                    if (!mounted) return;

                    setState(
                      () {
                        _isLoading = false;
                      },
                    );
                    if (!mounted) return;

                    //this is the edit case so we should not worry about from home page as the add case
                    //however, we are still concerned if edit is from a game detail page
                    //use pushAndRemove until instead of push replacement since
                    //we can access game detail page from manage games page also
                    if (_returnRouteName == GameDetailScreen.routeName) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        GameDetailScreen.routeName,
                        (route) => route.isFirst,
                        arguments: _gameID,
                      );
                    } else {
                      Navigator.of(context).pushAndRemoveUntil(
                        CustomRoute(
                          builder: (context) => const ManageGamesScreen(),
                        ),
                        (route) => route.isFirst,
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      } catch (error) {
        print(error);
        await showDialog<void>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text("An error occured!"),
              content: const Text("Something went wrong"),
              actions: [
                TextButton(
                  child: const Text("Okay"),
                  onPressed: () {
                    /*
                    Navigator.of(context).pop(); //this will close  the pop up dialog
                    FocusScope.of(context).unfocus();
                    */
                    Navigator.of(context).pop(); //this will close  the pop up dialog
                    if (_returnRouteName == GameDetailScreen.routeName) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        GameDetailScreen.routeName,
                        (route) => route.isFirst,
                        arguments: _gameID,
                      );
                    } else {
                      Navigator.of(context).pushAndRemoveUntil(
                        CustomRoute(
                          builder: (context) => const ManageGamesScreen(),
                        ),
                        (route) => route.isFirst,
                      );
                    }
                  },
                )
              ],
            );
          },
        );
      }
    } else {
      // if (_gameID == null) //or addGame case
      try {
        if (_copiedImageURLs.isNotEmpty || _pickedImageFiles.isNotEmpty) {
          _additionalImageURLController.text = "https://placeholder.jpeg";
          //this is actually just dummy data
          //since we use the OutlinedButton to deal with imageURLs and
          //clear TextEditingController text each time we click the button
          //at the end there would be no user input, but we want at least one additional imageURL
          //so we check if _addedGame.imageURLs is empty, if it's not then there're actually images
          //and we just need to add some dummy data in order for it to get through the validation process
          //_clearedAdditionalImageURLController;
        }
        final isValid = _form.currentState?.validate();
        if (isValid == null) {
          return;
        }
        if (!isValid) {
          if (_additionalImageURLController.text == "https://placeholder.jpeg") {
            _additionalImageURLController.clear();
          }
          return;
        }
        if (_titleImageFile == null && _useDeviceImageInput == true) {
          await showDialog<void>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text("Missing required information!"),
                content: const Text("You haven't chosen a title image from your device."),
                actions: [
                  TextButton(
                    child: const Text("Okay"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      FocusScope.of(context).unfocus();
                    },
                  )
                ],
              );
            },
          );
          return;
        }

        if (_hasPickedPlatform == false) {
          await showDialog<void>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text("Missing required information!"),
                content: const Text("You haven't picked a gaming platform yet, which is required."),
                actions: [
                  TextButton(
                    child: const Text("Okay"),
                    onPressed: () {
                      Navigator.of(context).pop(); //this will close  the pop up dialog
                      _additionalImageURLController.clear();
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ],
              );
            },
          );
          return;
        }
        if (_copiedImageURLs.isEmpty && _pickedImageFiles.isEmpty) {
          await showDialog<void>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text("Missing required information!"),
                content: const Text("You haven't added an addition image yet, which is required."),
                actions: [
                  TextButton(
                    child: const Text("Okay"),
                    onPressed: () {
                      Navigator.of(context).pop(); //this will close  the pop up dialog
                      _additionalImageURLController.clear();
                      FocusScope.of(context).unfocus();
                    },
                  )
                ],
              );
            },
          );
          return; //return since we need at least one additional image URL
        }

        await showDialog<void>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text("Are you sure?"),
              content: const Text("Click confirm to finish editing."),
              actions: [
                TextButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("Keep editing"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    //Focus.of(context).unfocus();
                  },
                ),
                TextButton(
                  child: const Text("Confirm"),
                  onPressed: () async {
                    Navigator.of(context).pop(); //pop the alert dialog
                    _form.currentState?.save();
                    setState(() {
                      _isLoading = true;
                    });

                    _addedGame.imageURLs = _copiedImageURLs;

                    if (!mounted) return;
                    if (_useDeviceImageInput == false) {
                      await Provider.of<Games>(context, listen: false).addGame(
                        _addedGame,
                        GamesOption.userGames,
                        imageFiles: _pickedImageFiles,
                      );
                    } else {
                      await Provider.of<Games>(context, listen: false).addGame(
                        _addedGame,
                        GamesOption.userGames,
                        imageFile: _titleImageFile,
                        imageFiles: _pickedImageFiles,
                      );
                    }

                    setState(
                      () {
                        _isLoading = false;
                      },
                    );
                    if (!mounted) return;

                    if (_returnRouteName == GamesOverviewScreen.routeName) {
                      Navigator.of(context).pushReplacement(
                        CustomRoute(
                          builder: (context) => const GamesOverviewScreen(),
                        ),
                      );
                    } else {
                      Navigator.of(context).pushReplacement(
                        CustomRoute(
                          builder: (context) => const ManageGamesScreen(),
                        ),
                        //(route) => route.isFirst,
                      );
                    }
                  },
                ),
              ],
            );
          },
        );

        //save should be push or pushReplacement so that it updates the page, instead of pop
      } catch (error) {
        print(error);
        //we use await here since we want user to press the pop up dialog button
        //before we go back to the user's games screen
        await showDialog<void>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text("An error occured!"),
              content: const Text("Something went wrong"),
              actions: [
                TextButton(
                  child: const Text("Okay"),
                  onPressed: () {
                    /*
                    Navigator.of(context).pop(); //this will close  the pop up dialog
                    _additionalImageURLController.clear();
                    FocusScope.of(context).unfocus();
                    */
                    Navigator.of(context).pop(); //this will close  the pop up dialog
                    //since we use temp_data to reflect the database
                    //if something went wrong we should direct back and reload a page rather than using pop
                    //since if we use pop then there might be a chance that when we return a temp data is there that doesn't match the database
                    if (_returnRouteName == GamesOverviewScreen.routeName) {
                      Navigator.of(context).pushReplacement(
                        CustomRoute(
                          builder: (context) => const GamesOverviewScreen(),
                        ),
                      );
                    } else {
                      Navigator.of(context).pushAndRemoveUntil(
                        CustomRoute(
                          builder: (context) => const ManageGamesScreen(),
                        ),
                        (route) => route.isFirst,
                      );
                    }
                  },
                )
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    //final bool isPortrait = mediaQueryData.orientation == Orientation.portrait;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    print("build edit game screen");
    return Scaffold(
      body: Stack(
        key: _parentKey,
        children: [
          Scaffold(
            appBar: AppBar(
              title: (_gameID == null)
                  ? const FittedBox(child: Text("Add A Game"))
                  : FittedBox(child: Text("Edit ${_editedGame.title}")),
              actions: [
                LayoutBuilder(builder: (context, constraints) {
                  return OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                    onPressed: () async {
                      //showMenu or showDialog
                      //then show Modal Bottom Sheet to enter the url
                      //Populate your data???
                      //ask user to enter an imdb url for the game in order for the auto fill feature to be useful

                      await showDialog<void>(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            title: const Text("Tired already?"),
                            content: const Text("Do you want to fill this form with IMDb data?"),
                            actions: [
                              TextButton(
                                child: const Text("No"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  FocusScope.of(context).unfocus();
                                },
                              ),
                              TextButton(
                                child: const Text("Yes"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  FocusScope.of(context).unfocus();
                                  showModalBottomSheet(
                                    constraints: const BoxConstraints.expand(),
                                    context: context,
                                    builder: (contex) {
                                      return GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {},
                                        child: _imdbURLWidgetBuilder(),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const FittedBox(
                      child: Text(
                        "IMDb",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  );
                }),
                IconButton(
                  onPressed: () => _saveForm(),
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
                        Text("Saving ..."),
                      ],
                    ), //this would show a loading spinner
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _form,
                      child: ListView(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextFormField(
                              controller: _titleController,
                              //initialValue: (_initialGame != null) ? _initialGame!.title : null,
                              validator: (inputValue) {
                                if (inputValue == null || inputValue.isEmpty) {
                                  return "Please enter something for title";
                                }
                                return null; //return null means input is correct
                              },
                              decoration: const InputDecoration(labelText: "Title"),
                              textInputAction: TextInputAction.next,
                              //go to the next input after we confirm/Enter
                              //go to a focus node if we use the below code
                              onFieldSubmitted: (inputValue) {
                                //we don't really need inputValue, so just use _ instead of inputValue is OK
                                FocusScope.of(context).requestFocus(_msrpFocusNode);
                                //if we click next, it will jump to the field with the requestFocusNode
                                //which is _msrpFocusNode for msrp field
                              },
                              onSaved: (inputValue) {
                                if (inputValue == null) {
                                  return;
                                }
                                _addedGame.title = inputValue;
                              },
                            ),
                          ),
                          LayoutBuilder(
                            builder: (ctx, constraints) {
                              return Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(10),
                                    width: constraints.maxWidth / 2.5,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.gamepad),
                                      label: (_hasPickedPlatform)
                                          ? Text(
                                              (_addedGame.platform == Platform.PS4_and_PS5 ||
                                                      _addedGame.platform == Platform.XBoxOneSX ||
                                                      _addedGame.platform == Platform.others ||
                                                      _addedGame.platform ==
                                                          Platform.NintendoSwitch ||
                                                      _addedGame.platform == Platform.SteamDeck)
                                                  ? platformToString(_addedGame.platform)
                                                  : "Chosen Platform: ${platformToString(_addedGame.platform)}",
                                              textAlign: TextAlign.center,
                                            )
                                          : const Text(
                                              "Picked Game Platform",
                                              softWrap: true,
                                              textAlign: TextAlign.center,
                                            ),
                                      onPressed: () {
                                        _showPickPlatform();
                                        FocusScope.of(context).unfocus();
                                      },
                                    ),
                                  ),
                                  Flexible(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: TextFormField(
                                        controller: _msrpController,
                                        /*initialValue: (_initialGame != null)
                                            ? _initialGame!.msrp.toStringAsFixed(2)
                                            : null,
                                        */
                                        validator: (inputValue) {
                                          if (inputValue == null) {
                                            return "Please enter a msrp";
                                          }
                                          if (double.tryParse(inputValue) == null) {
                                            //tryParse would return null if passing fails
                                            //(users enter something that cannot be parsed as a number)
                                            return "Please enter a valid number";
                                          }
                                          if (double.parse(inputValue) < 0) {
                                            return "Please enter a value no less than zero";
                                            //a game could be free to play though
                                          }
                                          return null; //return null means input is correct
                                        },
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(labelText: "MSRP"),
                                        textInputAction: TextInputAction.next,
                                        focusNode: _msrpFocusNode,
                                        onFieldSubmitted: (_) {
                                          //we don't really need inputValue, so just use _ is OK
                                          FocusScope.of(context)
                                              .requestFocus(_descriptionFocusNode);
                                          //if we click next, it will jump to the field with the requestFocusNode
                                          //which is _msrpFocusNode for msrp field
                                        },
                                        onSaved: (inputValue) {
                                          if (inputValue == null) {
                                            return;
                                          }
                                          _addedGame.msrp = double.parse(inputValue);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextFormField(
                              controller: _descriptionController,
                              /*initialValue:
                                  (_initialGame != null) ? _initialGame!.description : null,*/
                              validator: (inputValue) {
                                if (inputValue == null) {
                                  return "Please enter something for description";
                                }
                                if (inputValue.length < 10) {
                                  return "A description must be at least 10-character long";
                                }
                                return null; //return null means input is correct
                              },
                              decoration: const InputDecoration(labelText: "Description"),
                              maxLines: 3, //height is 3 lines
                              keyboardType: TextInputType.multiline,
                              //multiline keyboard enable a newline
                              //(when we press Enter it starts a newline instead of submitting)
                              textInputAction: TextInputAction.next,
                              focusNode: _descriptionFocusNode,
                              onSaved: (inputValue) {
                                if (inputValue == null) {
                                  return;
                                }
                                _addedGame.description = inputValue;
                              },
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(_titleImageURLFocusNode);
                              },
                            ),
                          ),
                          const SizedBox(height: 5),
                          SwitchListTile.adaptive(
                            tileColor: Colors.blue.withOpacity(0.25),
                            activeColor: Colors.green,
                            title: (mediaQueryData.orientation == Orientation.portrait)
                                ? FittedBox(
                                    child: SelectableText(
                                      "Select title image from gallery or camera.",
                                      style: TextStyle(
                                        color: (_useDeviceImageInput)
                                            ? Colors.black
                                            : Colors.black.withOpacity(0.45),
                                      ),
                                    ),
                                  )
                                : SelectableText(
                                    "Select title image from gallery or camera.",
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      color: (_useDeviceImageInput)
                                          ? Colors.black
                                          : Colors.black.withOpacity(0.45),
                                    ),
                                  ),
                            value: _useDeviceImageInput,
                            onChanged: (boolValue) {
                              setState(() {
                                _useDeviceImageInput = boolValue;
                              });
                            },
                          ),
                          if (_useDeviceImageInput == false)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100, // / 16 * 10
                                  //aspect ratio of images is usually width : height = 16 : 9
                                  //for better display just use 16 : 10
                                  margin: const EdgeInsets.only(top: 8, right: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.black,
                                    ),
                                  ),
                                  alignment: Alignment.center, //for Text("Add a URL")
                                  child: (_titleImageURLController.text.isEmpty)
                                      ? const FittedBox(child: Text("Add a URL"))
                                      : GestureDetector(
                                          onTap: () {
                                            SwipeImageGallery(
                                              hideStatusBar: false,
                                              backgroundColor: Colors.black54,
                                              //use current Image Index found in CarouselSllider to jump to the right image here
                                              context: context,
                                              children: [
                                                Image.network(_titleImageURLController.text)
                                              ],
                                              heroProperties: const [
                                                ImageGalleryHeroProperties(tag: 'user_avatar'),
                                              ],
                                            ).show();
                                          },
                                          child: Image.network(
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Image(
                                                image: AssetImage("assets/images/404_eye.png"),
                                              );
                                            },
                                            _titleImageURLController.text,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                                Flexible(
                                  //Expanded would cause some error with the image so use Flexible for TextFormField
                                  //reference: https://stackoverflow.com/questions/51809451/how-to-solve-renderbox-was-not-laid-out-in-flutter-in-a-card-widget
                                  child: TextFormField(
                                    //initialValue: _initValues["imageURL"],
                                    //if we use controller then we don't use initialValue or else it's gonna generate an error
                                    validator: (inputValue) {
                                      if (inputValue == null) {
                                        return "Please enter an image URL";
                                      }
                                      if (!inputValue.startsWith("http://") &&
                                          !inputValue.startsWith("https://")) {
                                        return "Please enter a valid URL";
                                      }
                                      if (!inputValue.endsWith(".png") &&
                                          !inputValue.endsWith(".jpg") &&
                                          !inputValue.endsWith(".jpeg")) {
                                        return "Please enter a valid image URL";
                                        //actually an image URL can also end with number
                                        //as in https://cdn.cloudflare.steamstatic.com/steam/apps/1343240/capsule_616x353.jpg?t=1660838507
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(labelText: 'Title Image URL'),
                                    keyboardType: TextInputType.url,
                                    textInputAction: TextInputAction.done,
                                    //submit the entire form (done action)
                                    controller: _titleImageURLController,
                                    focusNode: _titleImageURLFocusNode,
                                    //we use this controller so that we could get access to this input value from the above Container
                                    onEditingComplete: () {
                                      setState(() {});
                                    },
                                    onSaved: (inputValue) {
                                      _addedGame.titleImageURL = inputValue!;
                                    },
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context).unfocus();
                                      //FocusScope.of(context).requestFocus(_additionalImageURLFocusNode);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          if (_useDeviceImageInput)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  width: 100,
                                  height: 100,
                                  margin: const EdgeInsets.only(top: 8, right: 10),
                                  decoration: BoxDecoration(
                                    backgroundBlendMode: BlendMode.colorDodge,
                                    color: isDarkMode
                                        ? Colors.grey.withOpacity(0.75)
                                        : const Color.fromARGB(255, 228, 228, 228),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: (_gameID != null && _titleImageFile == null)
                                      ? GestureDetector(
                                          onTap: () {
                                            SwipeImageGallery(
                                              hideStatusBar: false,
                                              backgroundColor: Colors.black54,
                                              //use current Image Index found in CarouselSllider to jump to the right image here
                                              context: context,
                                              children: [
                                                Image.network(_initialGame!.titleImageURL)
                                              ],
                                              heroProperties: const [
                                                ImageGalleryHeroProperties(tag: 'user_avatar'),
                                              ],
                                            ).show();
                                          },
                                          child: Hero(
                                              tag: '1st image$_gameID',
                                              child: Image.network(_initialGame!.titleImageURL)),
                                        )
                                      : ((_titleImageFile == null)
                                          ? const Text(
                                              "No Image Selected",
                                              textAlign: TextAlign.center,
                                            )
                                          : GestureDetector(
                                              onTap: () {
                                                SwipeImageGallery(
                                                  hideStatusBar: false,
                                                  backgroundColor: Colors.black54,
                                                  //use current Image Index found in CarouselSllider to jump to the right image here
                                                  context: context,
                                                  children: [
                                                    Image.file(_titleImageFile as device.File)
                                                  ],
                                                  heroProperties: const [
                                                    ImageGalleryHeroProperties(tag: 'user_avatar'),
                                                  ],
                                                ).show();
                                              },
                                              child: Image.file(_titleImageFile as device.File),
                                            )),
                                ),
                                const Flexible(
                                  child: Text(
                                    "Add a title image from your device:",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                //const Spacer(),
                                TitleImagePicker(
                                  _imagePicker,
                                ),
                              ],
                            ),
                          //if (_useDeviceImageInput == false)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(top: 8),
                            color: Colors.blue.withOpacity(0.25),
                            child: const FittedBox(
                              child: Text(
                                "Add at least one additional image from your device or a url",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          //if (_useDeviceImageInput)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                ImagesPicker(_imagesPicker),
                                AdditionalFileImagesBuilder(
                                  imageFiles: _pickedImageFiles,
                                  manageImagesFn: _managePickedImages,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: TextFormField(
                                          //initialValue: _initValues["imageURL"],
                                          //if we use controller then we don't use initialValue or else it's gonna generate an error
                                          validator: (inputValue) {
                                            if (inputValue == null) {
                                              return "Please enter an image URL";
                                            }
                                            if (!inputValue.startsWith("http://") &&
                                                !inputValue.startsWith("https://")) {
                                              return "Please enter a valid URL \nor add at least one image file";
                                            }
                                            if (!inputValue.endsWith(".png") &&
                                                !inputValue.endsWith(".jpg") &&
                                                !inputValue.endsWith(".jpeg")) {
                                              return "Please enter a valid image URL, prefering one ending with .png, .jpg, .jpeg, ...";
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                            labelText: 'Add image URL(s):',
                                            labelStyle: TextStyle(
                                              //fontStyle: FontStyle.italic,
                                              overflow: TextOverflow.fade,
                                            ),
                                          ),
                                          keyboardType: TextInputType.url,
                                          //textInputAction: TextInputAction.done,
                                          //submit the entire form (done action)
                                          controller: _additionalImageURLController,
                                          focusNode: _additionalImageURLFocusNode,
                                          //we use this controller so that we could get access to this input value from the above Container
                                          onEditingComplete: () {
                                            FocusScope.of(context).unfocus();
                                            //dismiss the keyboard by using unfocus
                                            //setState(() {});
                                          },

                                          onSaved: (inputValue) {
                                            FocusScope.of(context).unfocus();
                                            //we let the below OutlinedButton deal with handling the input!
                                          },
                                        ),
                                      ),
                                    ),
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        elevation: 1,
                                        side: const BorderSide(width: 0.69),
                                        padding: const EdgeInsets.all(7),
                                        //backgroundColor: Colors.blue.withOpacity(0.15),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          String inputValue = _additionalImageURLController.text;
                                          if ((!inputValue.startsWith('http') &&
                                                  !inputValue.startsWith('https')) ||
                                              (!inputValue.endsWith('.png') &&
                                                  !inputValue.endsWith('.jpg') &&
                                                  !inputValue.endsWith('.jpeg'))) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: const Text("Please enter a valid URL"),
                                                backgroundColor: Theme.of(context).errorColor,
                                              ),
                                            );
                                            return;
                                          }
                                          if (inputValue == "https://placeholder.jpeg") {
                                            _additionalImageURLController.clear();
                                            FocusScope.of(context).unfocus();
                                            return;
                                          }
                                          //add validator here (like a Snackbar if the url is incorrect)
                                          _copiedImageURLs.add(inputValue);

                                          /*_clearedAdditionalImageURLController =
                                              _additionalImageURLController.text;*/
                                          _additionalImageURLController.clear();
                                          FocusScope.of(context).unfocus();
                                        });
                                      },
                                      child: const Text("Add image URL"),
                                    ),
                                  ],
                                ),
                                AdditionalImagesBuilder(
                                  imageURLs: _copiedImageURLs,
                                  manageImagesFn: _manageImageURLs,
                                  //deletedIndexFn: _storeDeletedURLIndices,
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  icon: Icon(
                                    Icons.edit,
                                    color: isDarkMode ? Colors.grey : null,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      CustomRoute(
                                        builder: (context) => (_gameID != null)
                                            ? AddDetailedDescriptionScreen(
                                                addDetailedDescription: _addDetailedDescription,
                                                title: _editedGame.title,
                                                detailedDescription: _addedGame.longDescription,
                                              )
                                            : AddDetailedDescriptionScreen(
                                                addDetailedDescription: _addDetailedDescription,
                                              ),
                                      ),
                                    );
                                  },
                                  label: (_gameID != null)
                                      ? (_addedGame.longDescription == null ||
                                              _addedGame.longDescription!.isEmpty)
                                          ? const Text(
                                              "Add a detailed description.",
                                              style: TextStyle(color: Colors.blue),
                                            )
                                          : const Text(
                                              "Edit your detailed description",
                                              style: TextStyle(color: Colors.blue),
                                            )
                                      : const Text(
                                          "Add a detailed description.",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          /*
          draggableFloatingActionButtonBuilder(
            context: context,
            parentKey: _parentKey,
            tooltip: "Add a more detailed description.",
            icon: const Icon(Icons.description),
            handler: () {
              Navigator.of(context).push(
                CustomRoute(
                  builder: (context) => (_gameID != null)
                      ? AddDetailedDescriptionScreen(
                          addDetailedDescription: _addDetailedDescription,
                          title: _editedGame.title,
                          detailedDescription: _addedGame.longDescription,
                        )
                      : AddDetailedDescriptionScreen(
                          addDetailedDescription: _addDetailedDescription,
                        ),
                ),
              );
            },
            iconColor: Colors.black,
            backgroundColor: Colors.blue.withOpacity(0.69),
          ),
          */
        ],
      ),
    );
  }

  void _managePickedImages(List<bool> deletedIndices) {
    //print(deletedIndices);
    //print(_pickedImageFiles.length);
    List<device.File> tempFilesList = [];
    for (int i = 0; i < deletedIndices.length; i++) {
      if (deletedIndices[i] == false) {
        //checkbox value is false for items not marked as deleted
        // print(_pickedImageFiles[i].path);
        tempFilesList.add(_pickedImageFiles[i]);
      }
    }
    _pickedImageFiles = tempFilesList;
    //print(_pickedImageFiles.length);
    setState(() {});
  }

/*
  void _storeDeletedURLIndices(int index) {
    //print("Deleted index is: ");
    if (_editedGame.imageURLs[index].startsWith(
        'https://firebasestorage.googleapis.com/v0/b/video-games-backlog.appspot.com/o/users%2F${FirebaseAuth.instance.currentUser!.uid}')) {
      _deletedStorageImageURLs.add(_editedGame.imageURLs[index]);
    }
    //print(_editedGame.imageURLs[index]);
  }
*/
  final List<String> _deletedStorageImageURLs = [];
  //final List<int> _deletedIndices = [];
  void _manageImageURLs(List<bool> deletedIndices) {
    print("bool values are:");
    print(deletedIndices);
    for (int i = deletedIndices.length - 1; i >= 0; i--) {
      //we cannot just use _copiedImageURLs.removeAt coz we have to remove a lot of items
      //so first we have to sort the deleted indices
      //and then we're gonna remove from right to left so that it wouldn't affect our array position
      if (deletedIndices[i] == true) {
        try {
          print("remove at $i");
          _copiedImageURLs.removeAt(i);
          if (_editedGame.imageURLs[i].startsWith(
              'https://firebasestorage.googleapis.com/v0/b/video-games-backlog.appspot.com/o/users%2F${FirebaseAuth.instance.currentUser!.uid}')) {
            _deletedStorageImageURLs.add(_editedGame.imageURLs[i]);
          }
        } catch (e) {
          print("error with removing imageURLs");
          print(e);
        }
      }

      //https://firebasestorage.googleapis.com/v0/b/video-games-backlog.appspot.com/o/users%2FvRzo1kGFObWY9yrpgs4Ne6roY0p1       %2Fgames%2FTimestamp(seconds%3D1662003845%2C%20nanoseconds%3D959119000)%2FimageURLs%2FTimestamp(seconds%3D1662003847%2C%20nanoseconds%3D172432000)?alt=media&token=ae0be72c-0dca-4f44-bd3f-7c014bd57a54
      //https://firebasestorage.googleapis.com/v0/b/video-games-backlog.appspot.com/o/users%2FvRzo1kGFObWY9yrpgs4Ne6roY0p1       %2Fgames%2FTimestamp(seconds%3D1661786037%2C%20nanoseconds%3D327339000)%2FimageURLs%2FTimestamp(seconds%3D1662009162%2C%20nanoseconds%3D745436000)?alt=media&token=88ffbc5d-e87f-46e6-88a6-620f40d40453
    }
    setState(() {});
  }

  void _imagePicker(device.File imageFile) {
    setState(() {
      _titleImageFile = imageFile;
    });
  }

  device.File? _titleImageFile;

  void _imagesPicker(List<device.File> imageFiles) {
    /*
    for (device.File imageFile in imageFiles) {
      _pickedImageFiles.add(imageFile);
    }
    */
    //the below code would work if we want to add more images, not the above
    //since imageFiles wouldn't lose the images that we picked
    //already checked to make sure
    setState(() {
      _pickedImageFiles = imageFiles;
    });
  }

  void _addDetailedDescription(String? description) {
    _addedGame.longDescription = description;
  }

  void _setPickedPlatform(Platform platform) {
    setState(() {
      _hasPickedPlatform = true;
      _addedGame.platform = platform;
    });
  }

  void _showPickPlatform() {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(0, 0, 0, 1),
      items: [
        //PlayStation
        PopupMenuItem<int>(
          value: 0,
          child: ListTile(
            onTap: () {
              Navigator.of(context).pop();
              _showPickPlatformHelper(0);
            },
            leading: const Icon(Icons.gamepad),
            title: const Text("PlayStation"),
          ),
        ),
        //XBox
        PopupMenuItem<int>(
          value: 1,
          child: ListTile(
            onTap: () {
              Navigator.of(context).pop();
              _showPickPlatformHelper(1);
            },
            leading: const Icon(Icons.gamepad),
            title: const Text("Xbox"),
          ),
        ),
        //Nintendo Switch
        PopupMenuItem<int>(
          value: 2,
          child: ListTile(
            onTap: () {
              Navigator.of(context).pop();
              _setPickedPlatform(Platform.NintendoSwitch);
            },
            leading: const Icon(Icons.gamepad),
            title: const Text("Nintendo Switch"),
          ),
        ),
        //Nintendo Switch
        PopupMenuItem<int>(
          value: 3,
          child: ListTile(
            onTap: () {
              Navigator.of(context).pop();
              _setPickedPlatform(Platform.SteamDeck);
            },
            leading: const Icon(Icons.gamepad),
            title: const Text("Steam Deck"),
          ),
        ),
        PopupMenuItem<int>(
          value: 4,
          child: ListTile(
            onTap: () {
              Navigator.of(context).pop();
              _setPickedPlatform(Platform.PC);
            },
            leading: const Icon(Icons.gamepad),
            title: const Text("PC"),
          ),
        ),
        PopupMenuItem<int>(
          value: 5,
          child: ListTile(
            onTap: () {
              Navigator.of(context).pop();
              _setPickedPlatform(Platform.others);
            },
            leading: const Icon(Icons.gamepad),
            title: const Text("Other Platforms"),
          ),
        ),
      ],
    );
  }

  void _showPickPlatformHelper(int value) {
    final List<Platform> playstation = [
      Platform.PS4,
      Platform.PS4_and_PS5,
      Platform.PS5,
    ];
    final List<Platform> xbox = [
      Platform.XBoxOne,
      Platform.XBoxOneSX,
      Platform.XBoxS,
      Platform.XBoxX,
    ];
    List<PopupMenuEntry<int>> items = [];

    if (value == 0) {
      int counter = 0;
      for (final Platform platform in playstation) {
        items.add(
          PopupMenuItem<int>(
            value: counter,
            child: ListTile(
              onTap: () {
                Navigator.of(context).pop();
                _setPickedPlatform(platform);
              },
              leading: const Icon(Icons.gamepad),
              title: Text(platformToString(platform)),
            ),
          ),
        );
        counter++;
      }
    } else if (value == 1) {
      int counter = 0;
      for (final Platform platform in xbox) {
        items.add(
          PopupMenuItem<int>(
            value: counter,
            child: ListTile(
              onTap: () {
                Navigator.of(context).pop();
                _setPickedPlatform(platform);
              },
              leading: const Icon(Icons.gamepad),
              title: Text(platformToString(platform)),
            ),
          ),
        );
        counter++;
      }
    }

    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(0, 0, 0, 1),
      items: items,
    );
  }

  Widget _imdbURLWidgetBuilder() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              leading: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(elevation: 1),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text("Go back"),
              ),
            ),
            const Text(
              "Please provide an IMDb URL for this game.\nLook for the game title you want on IMDb, then copy and paste its URL here.",
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            //imdb form
            TextFormField(
              controller: _imdbController,
              onEditingComplete: () {
                setState(() {});
              },
              onSaved: (inputValue) async {},
              onFieldSubmitted: (inputValue) async {
                _imdbController.text = inputValue;

                final myURL = _imdbController.text;
                final metadata = await MetadataFetch.extract(myURL);
                if (metadata != null) {
                  print(metadata);
                  /*
                  print(metadata);
                  print(metadata.title);
                  print(metadata.description);
                  print(metadata.image);
                  print(metadata.url);
                  */
                  setState(() {
                    //should have a substring and regex function to retrieve the release date from imdb
                    //regex is 4 digit next to each other (year). Then set _editedGame (actually only _addedGame release date to)
                    _titleController.text = metadata.title ?? _titleController.text;
                    _descriptionController.text =
                        metadata.description ?? _descriptionController.text;
                    _titleImageURLController.text = metadata.image ?? _titleImageURLController.text;
                  });
                  setState(() {
                    _useDeviceImageInput = false;
                  });
                  //set this so that it display the image from what we fetch from IMDb instead
                }
                setState(() {
                  _useDeviceImageInput = false;
                });
              },
              enableSuggestions: false,
              keyboardType: TextInputType.url,
              validator: (inputValue) {
                if (inputValue == null) {
                  return "Please enter an IMDb URL";
                }

                if (!inputValue.startsWith("https://www.imdb.com/title/") &&
                    !inputValue.startsWith("http://www.imdb.com/title/")) {
                  return "Please enter a valid IMDb URL.\nFor example: the valid URL for God Of War (2018) is or starts with: \nhttps://www.imdb.com/title/tt5838588/";
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: "IMDb link",
              ),
            ),
            const SizedBox(height: 15),
            /*if (mediaQueryData.orientation == Orientation.portrait)*/
            const SelectableText("A valid URL from IMDb should be similar to:"),
            const SelectableText(
              "https://www.imdb.com/title/tt5838588/",
              style: TextStyle(color: Colors.green),
            ),
            const SelectableText("You can copy this URL and try on your own."),
            const SizedBox(height: 5),
            Image.asset(
              "assets/images/imdb_url_example.png",
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}
