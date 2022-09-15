//add validation with property like new Platform, imageURLs for saveForm function properly
//there also a logic error where we click the save button, but the input for additionalImageURL is not saved
//since we use OutlinedButton to deal with it => should check whether the last image in imageURLs
//has the same data as that one (probably not!)
//also use hasChosenPlatform to check when in adding mode

//add feature to delete an added image

//edit or add a game
//check when lose focus from image to others? why image not updated?

//dart
import 'dart:io' as device;
//Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
//packages
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
//providers
import '../../providers/game.dart';
import '../../providers/games.dart';

class EditTrendingGameScreen extends StatefulWidget {
  final String? trendingGameID;
  const EditTrendingGameScreen({
    Key? key,
    this.trendingGameID,
  }) : super(key: key);
  static const routeName = "/edit-trending-game";

  @override
  State<EditTrendingGameScreen> createState() => _EditTrendingGameScreenState();
}

class _EditTrendingGameScreenState extends State<EditTrendingGameScreen> {
  final _msrpFocusNode = FocusNode();
  final _anticipatedLevelFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _titleImageURLFocusNode = FocusNode();
  final _titleImageURLController = TextEditingController();
  final _additionalImageURLFocusNode = FocusNode();
  final _additionalImageURLController = TextEditingController();
  //String _clearedAdditionalImageURLController = "";
  final _form = GlobalKey<FormState>();

  final _addedGame = MutableGame(
    id: "game id",
    title: "some title",
    description: "fun game",
    msrp: 69.99,
    platform: Platform.PS4_and_PS5,
    titleImageURL: "https://m.media-amazon.com/images/I/61ii4p0wziL._AC_SS450_.jpg",
    imageURLs: [],
    isFavorite: false,
    releaseDate: Timestamp.now(),
  );

  ///We have to dispose Focus Nodes after usage or else it will cause memory leaks
  @override
  void dispose() {
    _msrpFocusNode.dispose();
    _anticipatedLevelFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _titleImageURLFocusNode.removeListener(_updateTitleImageURL);
    _additionalImageURLFocusNode.removeListener(_updateAdditionalImageURL);
    _titleImageURLFocusNode.dispose();
    _titleImageURLController.dispose();
    super.dispose();
  }

  late Game _editedGame;
  Map<String, String> _initValues = {
    "title": "",
    "msrp": "",
    "description": "",
    "titleImageURL": "",
    "platform": "",
    "anticipatedLevel": "",
  };

  late String? gameID;
  bool _isInit = true;

  bool _isLoading = false;

  bool _hasPickedPlatform = false;
  bool _hasPickedReleaseDate = false;

  //we want to access the gameID that was forwarded in user_game_item.dart by
  //Navigator.of(context).pushNamed(EditGameScreen.routeName, arguments: id,);
  //since ModalRoute needs context we cannot do this in initState
  @override
  void didChangeDependencies() {
    if (_isInit) {
      gameID = widget.trendingGameID;

      if (gameID != null) {
        _hasPickedPlatform = true;
        _hasPickedReleaseDate = true;
        _editedGame =
            Provider.of<Games>(context).findByID(gameID as String, GamesOption.trendingGames);

        _addedGame.platform = _editedGame.platform;
        _addedGame.releaseDate = _editedGame.releaseDate;
        //just for the initial value of the chosen platform button to show correct value
        //since it's based on _addedGame.platform instead

        String decodedPlatform = platformToString(_editedGame.platform);
        _initValues = {
          "title": _editedGame.title,
          "msrp": _editedGame.msrp.toStringAsFixed(2),
          "description": _editedGame.description,
          "titleImageURL": _editedGame.titleImageURL,
          "anticipatedLevel": (_editedGame.anticipatedLevel == null)
              ? "Not available"
              : _editedGame.anticipatedLevel!.toStringAsFixed(0),
          "platform": decodedPlatform,
        };
        _titleImageURLController.text = _editedGame.titleImageURL;
      }
    }
    _isInit = false;
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
    if (gameID != null) {
      try {
        //though _editedGame initally have imageURLs (not empty), we still wanna check since we could just delete them in edit mode
        if (_editedGame.imageURLs.isEmpty == false) {
          _additionalImageURLController.text = "https://placeholder.jpeg";
          //this is actually just dummy data
          //since we use the OutlinedButton to deal with imageURLs and
          //clear TextEditingController text each time we click the button
          //at the end there would be no user input, but we want at least one additional imageURL
          //so we check if _editedGame.imageURLs is empty, if it's not then there're actually images
          //and we just need to add some dummy data in order for it to get through the validation process
          //_clearedAdditionalImageURLController;
        }

        //we use _form global key to get access to a specific Form widget inside the widget tree
        //if we want to access to another form, then create another key for that one
        final isValid = _form.currentState?.validate();
        //this validate() function will trigger all the validators in the form
        if (!isValid!) {
          if (_additionalImageURLController.text == "https://placeholder.jpeg") {
            _additionalImageURLController.clear();
          }
          return;
        }
        _form.currentState?.save();
        setState(() {
          _isLoading = true;
        });
/* //these two can never be false in editing mode
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
        if (_hasPickedReleaseDate == false) {
          await showDialog<void>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text("Missing required information!"),
                content: const Text("You haven't added a release date for this game."),
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

        */
        if (_editedGame.imageURLs.isEmpty == true) {
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

        _editedGame = Game(
          id: gameID as String,

          ///We use _addedGame for these attributes since in the form we feed _addedGame the inputs, not _editedGame
          ///but why? because Game is immutable so we cannot change its fields
          ///but we can do it with a mutable object
          ///that's why we create MutableGame class since we don't want to recreate Game each time
          description: _addedGame.description,
          title: _addedGame.title,
          msrp: _addedGame.msrp,
          titleImageURL: _addedGame.titleImageURL,
          platform: _addedGame.platform, //new
          releaseDate: _addedGame.releaseDate,
          anticipatedLevel: _addedGame.anticipatedLevel,
          longDescription: _addedGame.longDescription,
          //we already set _addedGame releaseDate = _editedGame release Date
          //so guarantee not null? since each editedGame should have a releaseDate
          ///We use _addedGame for these attributes since in the form we feed _addedGame the inputs, not _editedGame

          ///The only exception to the immutable rule is an object of type final List
          ///though it's final, we can still modify imageURLs since only the reference is final
          ///if the reference on the other hand point to a const literal List then we cannot modify it though
          imageURLs: _editedGame.imageURLs,

          /// These are the unmodifiable attributes in Edit Game mode so we use _editedGame's
          isFavorite: _editedGame.isFavorite,
          userDescription: _editedGame.userDescription,

          purchasePrice: _editedGame.purchasePrice,
          userRating: _editedGame.userRating,
        );
        _form.currentState?.save();
        setState(() {
          _isLoading = true;
        });

        //mounted is a special property of Stateful widget use to check using context between async gap
        if (!mounted) return;
        await Provider.of<Games>(context, listen: false).updateGame(
          id: _editedGame.id,
          initialGame: _editedGame,
          //temporarily pass this, even though it's not due to shallow copy
          editedGame: _editedGame,
          gamesOption: GamesOption.trendingGames,
        );
        setState(
          () {
            _isLoading = false;
          },
        );
        if (!mounted) return;
        Navigator.of(context).pop();
      } catch (error) {
        //print(error);
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
                    Navigator.of(context).pop(); //this will close  the pop up dialog
                    FocusScope.of(context).unfocus();
                  },
                )
              ],
            );
          },
        );
      }
    } else {
      // if (gameID == null) //or addGame case
      try {
        if (_addedGame.imageURLs.isEmpty == false) {
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
        if (!isValid!) {
          if (_additionalImageURLController.text == "https://placeholder.jpeg") {
            _additionalImageURLController.clear();
          }
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
                  )
                ],
              );
            },
          );
          return;
        }
        if (_hasPickedReleaseDate == false) {
          await showDialog<void>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text("Missing required information!"),
                content: const Text("You haven't added a release date for this game."),
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
        if (_addedGame.imageURLs.isEmpty == true) {
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

        _form.currentState?.save();
        setState(() {
          _isLoading = true;
        });
        if (!mounted) return;
        await Provider.of<Games>(context, listen: false).addGame(
          _addedGame,
          GamesOption.trendingGames,
        );
        setState(
          () {
            _isLoading = false;
          },
        );
        if (!mounted) return;
        Navigator.of(context).pop();
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
                    Navigator.of(context).pop(); //this will close  the pop up dialog
                    _additionalImageURLController.clear();
                    FocusScope.of(context).unfocus();
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
    print("build edit trending game screen");
    return Scaffold(
      appBar: AppBar(
        title: (gameID == null)
            ? const FittedBox(child: Text("Add A Trending Game"))
            : FittedBox(child: Text("Edit ${_editedGame.title}")),
        actions: [
          IconButton(
            onPressed: () => _saveForm(),
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: (_isLoading)
          ? const Center(
              child: CircularProgressIndicator(), //this would show a loading spinner
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues["title"],
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
                        _addedGame.title = inputValue!;
                      },
                    ),
                    LayoutBuilder(builder: (ctx, constraints) {
                      return Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(10),
                            width: constraints.maxWidth / 2.5,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.gamepad_outlined, color: Colors.black),
                              label: (_hasPickedPlatform)
                                  ? Text(
                                      "Chosen Platform: ${platformToString(_addedGame.platform)}")
                                  : const Text(
                                      "Picked Game Platform",
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                    ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: ctx,
                                  builder: (_) {
                                    return (device.Platform.isIOS)
                                        ? platformPicker()
                                        : FractionallySizedBox(
                                            heightFactor: (MediaQuery.of(context).orientation ==
                                                    Orientation.portrait)
                                                ? 0.75
                                                : 1,
                                            child: platformPicker(),
                                          );
                                  },
                                );
                                FocusScope.of(context).unfocus();
                              },
                            ),
                          ),
                          Flexible(
                            child: TextFormField(
                              initialValue: _initValues["msrp"],
                              validator: (inputValue) {
                                if (inputValue == null) {
                                  return "Please enter an msrp";
                                }
                                if (double.tryParse(inputValue) == null) {
                                  //tryParse would return null if passing fails
                                  //(users enter something that cannot be parsed as a number)
                                  return "Please enter a valid number";
                                }
                                if (double.parse(inputValue) < 0) {
                                  return "Please enter a value no less than zero";
                                }
                                return null; //return null means input is correct
                              },
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: "MSRP"),
                              textInputAction: TextInputAction.next,
                              focusNode: _msrpFocusNode,
                              onFieldSubmitted: (_) {
                                //we don't really need inputValue, so just use _ is OK
                                FocusScope.of(context).requestFocus(_anticipatedLevelFocusNode);
                                //if we click next, it will jump to the field with the requestFocusNode
                                //which is _msrpFocusNode for msrp field
                              },
                              onSaved: (inputValue) {
                                _addedGame.msrp = double.parse(inputValue!);
                              },
                            ),
                          ),
                        ],
                      );
                    }),
                    LayoutBuilder(builder: (ctx, constraints) {
                      return Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(10),
                            width: constraints.maxWidth / 2.5,
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.calendar_month,
                                color: Colors.amber,
                              ),
                              label: (_hasPickedReleaseDate)
                                  ? Text(
                                      "Release Date is: ${DateFormat.yMMMMd().format(_addedGame.releaseDate!.toDate())}")
                                  : const Text(
                                      "Choose Release Date",
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                    ),
                              onPressed: () async {
                                releaseDatePicker();

                                FocusScope.of(context).unfocus();
                              },
                            ),
                          ),
                          Flexible(
                            child: TextFormField(
                              //initialValue: _initValues["anticipatedLevel"], //not required
                              validator: (inputValue) {
                                if (inputValue == null) {
                                  return null;
                                } else {
                                  //inputValue could be null, but if it's not null, then it must be valid
                                  if (int.tryParse(inputValue) == null) {
                                    //tryParse would return null if passing fails
                                    //(users enter something that cannot be parsed as a number)
                                    return "Please enter a valid number";
                                  }
                                  if (int.parse(inputValue) < 0 || int.parse(inputValue) > 100) {
                                    return "Please enter an integer from 0 to 100";
                                  }
                                }
                                return null; //return null means input is correct
                              },
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText: "Anticipated Level (not required)"),
                              textInputAction: TextInputAction.next,
                              focusNode: _anticipatedLevelFocusNode,
                              onFieldSubmitted: (_) {
                                //we don't really need inputValue, so just use _ is OK
                                FocusScope.of(context).requestFocus(_descriptionFocusNode);
                                //if we click next, it will jump to the field with the requestFocusNode
                                //which is _msrpFocusNode for msrp field
                              },
                              onSaved: (inputValue) {
                                _addedGame.anticipatedLevel = int.parse(inputValue!);
                              },
                            ),
                          ),
                        ],
                      );
                    }),
                    TextFormField(
                      initialValue: _initValues["description"],
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
                        _addedGame.description = inputValue!;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_titleImageURLFocusNode);
                      },
                    ),
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
                              color: Colors.grey,
                            ),
                          ),
                          alignment: Alignment.center, //for Text("Add a URL")
                          child: (_titleImageURLController.text.isEmpty)
                              ? const FittedBox(child: Text("Add a URL"))
                              : Image.network(
                                  _titleImageURLController.text,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Image(
                                      image: AssetImage("assets/images/404_eye.png"),
                                    );
                                  },
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
                              FocusScope.of(context).requestFocus(_additionalImageURLFocusNode);
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
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
                                return "Please enter a valid image URL, prefering one ending with .png, .jpg, .jpeg, ...";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                                labelText: 'Add Additional Image URL(s) (at least one)'),
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
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(width: 1.5),
                            padding: const EdgeInsets.all(7),
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
                              if (gameID == null) {
                                _addedGame.imageURLs.add(_additionalImageURLController.text);
                              } else {
                                _editedGame.imageURLs.add(_additionalImageURLController.text);
                              }

                              /*_clearedAdditionalImageURLController =
                                  _additionalImageURLController.text;*/
                              _additionalImageURLController.clear();
                              FocusScope.of(context).unfocus();
                            });
                          },
                          child: const Text("Add Image URL"),
                        ),
                      ],
                    ),
                    additionalImagesBuilder((gameID != null)
                        ? MutableGame(
                            imageURLs: _editedGame.imageURLs,
                            id: '',
                            description: '',
                            title: '',
                            titleImageURL: '',
                            msrp: 0.0,
                            platform: Platform.PS4_and_PS5,
                          )
                        : _addedGame),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        initialValue: _editedGame.longDescription,
                        keyboardType: TextInputType.multiline,
                        maxLines: 35,
                        decoration: InputDecoration(
                          labelText: (gameID != null)
                              ? "Add a detailed description for ${_editedGame.title}"
                              : "Add a detailed description for this game",
                        ),
                        textInputAction: TextInputAction.next,
                        //go to the next input after we confirm/Enter
                        //go to a focus node if we use the below code
                        onFieldSubmitted: (inputValue) {
                          //we don't really need inputValue, so just use _ instead of inputValue is OK
                          //FocusScope.of(context).requestFocus(_msrpFocusNode);
                          //if we click next, it will jump to the field with the requestFocusNode
                          //which is _msrpFocusNode for msrp field
                        },
                        onSaved: (inputValue) {
                          _addedGame.longDescription = inputValue;
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget additionalImagesBuilder(MutableGame targetedGame) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Row(
          children: [
            imageContainerBuilder(ctx, constraints, targetedGame, 0),
            if (targetedGame.imageURLs.isNotEmpty)
              imageContainerBuilder(ctx, constraints, targetedGame, 1),
            if (targetedGame.imageURLs.length >= 2)
              imageContainerBuilder(ctx, constraints, targetedGame, 2),
            if (targetedGame.imageURLs.length >= 3)
              imageContainerBuilder(ctx, constraints, targetedGame, 3),
            if (targetedGame.imageURLs.length >= 4)
              imageContainerBuilder(ctx, constraints, targetedGame, 4),
            if (targetedGame.imageURLs.length > 5)
              Flexible(
                child: Row(
                  children: [
                    Flexible(
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          targetedGame.imageURLs[targetedGame.imageURLs.length - 1],
                        ),
                        //child: Text("+${targetedGame.imageURLs.length - 5}"),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        "+${targetedGame.imageURLs.length - 5}",
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget imageContainerBuilder(
      BuildContext ctx, BoxConstraints constraints, MutableGame game, int index) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: constraints.maxWidth / 8,
          height: constraints.maxWidth / 8 / 16 * 10,
          //image usually has a ratio of width : height = 16 / 9 or maybe 16/10
          margin: const EdgeInsets.only(top: 7, right: 9.5),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.grey,
            ),
          ),
          alignment: Alignment.center, //for Text("Add a URL")
          child: (game.imageURLs.length < index + 1)
              ? const FittedBox(
                  child: Text(
                    "Add a URL",
                    textAlign: TextAlign.center,
                  ),
                )
              : Image.network(
                  errorBuilder: (context, error, stackTrace) {
                    return const Image(
                      image: AssetImage("assets/images/404_eye.png"),
                    );
                  },
                  game.imageURLs[index],
                  fit: BoxFit.cover,
                ),
        ),
        /*
        Positioned(
          top: -2.5,
          right: 2,
          child: GestureDetector(
            onTap: () async {
              await showDialog<void>(
                context: ctx,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Are you sure?"),
                    content: const Text("This will delete this image."),
                    actions: [
                      TextButton(
                        child: const Text("Okay"),
                        onPressed: () {
                          setState(() {
                            game.imageURLs.removeAt(index);
                          });
                          Navigator.of(context).pop(); //this will close  the pop up dialog
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Stack(
              children: const [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.grey,
                ),
                Positioned(
                  top: -1.25,
                  right: -2.5,
                  child: Icon(
                    Icons.remove,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
        ),
        */
        if (game.imageURLs.length >= index + 1)
          Positioned(
            top: -15,
            right: -10,
            child: IconButton(
              icon: const Icon(
                Icons.highlight_remove_sharp,
              ),
              onPressed: () async {
                await showDialog<void>(
                  context: ctx,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Are you sure?"),
                      content: const Text("This action will delete this image."),
                      actions: [
                        TextButton(
                          child: const Text("Close"),
                          onPressed: () {
                            Navigator.of(context).pop(); //this will close  the pop up dialog
                            FocusScope.of(context).unfocus();
                          },
                        ),
                        TextButton(
                          child: const Text("Confirm"),
                          onPressed: () {
                            setState(() {
                              game.imageURLs.removeAt(index);
                            });
                            Navigator.of(context).pop(); //this will close  the pop up dialog
                            FocusScope.of(context).unfocus();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget platformPicker() {
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          return Column(
            children: [
              //use either Expanded or Flexible in this situation (we want each row of column has the same width)
              //so we use LayoutBuilder for constraint
              //preferably Expanded since it keeps expands instead of shrinking like Flexible
              //we can definitely wrap these into a simpler widget but for now just leave them like that for study purpose
              Expanded(
                child: SizedBox(
                  width: constraints.maxWidth / 2.5,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey,
                    ),
                    icon: const Icon(Icons.gamepad),
                    label: const Text("PS4"),
                    onPressed: () {
                      setState(() {
                        _hasPickedPlatform = true;
                        _addedGame.platform = Platform.PS4;
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              const Divider(thickness: 2),
              Expanded(
                child: SizedBox(
                  width: constraints.maxWidth / 2.5,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey,
                    ),
                    icon: const Icon(Icons.gamepad),
                    label: const Text("PS4 & PS5"),
                    onPressed: () {
                      setState(() {
                        _hasPickedPlatform = true;
                        _addedGame.platform = Platform.PS4_and_PS5;
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              const Divider(thickness: 2),
              Expanded(
                child: SizedBox(
                  width: constraints.maxWidth / 2.5,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey,
                    ),
                    icon: const Icon(Icons.gamepad),
                    label: const Text("PS5"),
                    onPressed: () {
                      setState(() {
                        _hasPickedPlatform = true;
                        _addedGame.platform = Platform.PS5;
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> releaseDatePicker() async {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
    ).then(
      (value) {
        if (value == null) {
          return;
        } else {
          setState(() {
            _addedGame.releaseDate = Timestamp.fromDate(value);
            _hasPickedReleaseDate = true;
          });
        }
      },
    );
  }
}
