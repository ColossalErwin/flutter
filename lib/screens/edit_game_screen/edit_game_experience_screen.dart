//dart
import 'dart:io';
//Firebase
import 'package:firebase_auth/firebase_auth.dart';
//packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';
//helpers
import '../../helpers/custom_route.dart';
//providers
import '../../providers/game.dart';
import '../../providers/games.dart';
//screens
import '../game_experience_screen.dart';
import '../manage_games_screen.dart';
//pickers helpers
import './title_image_picker.dart';
import './additional_file_images_builder.dart';
import './additional_images_builder.dart';
import './images_picker.dart';

class EditGameExperienceScreen extends StatefulWidget {
  const EditGameExperienceScreen({
    Key? key,
  }) : super(key: key);
  static const routeName = '/edit-experience';

  @override
  State<EditGameExperienceScreen> createState() => _EditGameExperienceScreenState();
}

class _EditGameExperienceScreenState extends State<EditGameExperienceScreen> {
  bool _isLoading = false;
  final List<String> _deletedStorageImageURLs = [];
  File? _titleImageFile;
  List<File> _pickedImageFiles = [];
  late Map<String, String>? _args;
  String? _gameID;
  String? _returnRouteName;
  late Game _providedGame;
  late Game _initialGame;
  //List<String> tempDeletedURLs = [];
  final List<String> _copiedImageURLs = [];
  bool _isInitInitialGame = false;
  //important so that we only initalize provided game related stuff once
  //if we don't do this then modify concurrent error would occur
  // ignore: non_constant_identifier_names
  //Rating? _UIreflectedRating; //we use this to reflect the actual rating in the UI
  //since if we want to use _providedGame.userRating then we have to await the updateRating function

  @override
  void didChangeDependencies() {
//deep copy
    if (_isInitInitialGame == false) {
      _args = ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
      //actually we make sure that _args would never be null so we can leave out this check null part
      //if (_args != null) {
      _gameID = (_args!.containsKey('id')) ? _args!['id'] : null;
      _returnRouteName = _args!['returnRouteName'];
      //}
      _providedGame = Provider.of<Games>(context).findByID(_gameID!, GamesOption.userGames);
      //_UIreflectedRating = (_providedGame.userRating == null) ? null : _providedGame.userRating;

      if (_providedGame.userImageURLs != null) {
        for (final String url in _providedGame.userImageURLs!) {
          _copiedImageURLs.add(url);
        }
      }
      List<String> tempArr1 = [];
      for (int index = 0; index < _providedGame.imageURLs.length; index++) {
        tempArr1.add(_providedGame.imageURLs[index]);
      }
      List<String> tempArr2 = [];
      if (_providedGame.userImageURLs != null) {
        for (int index = 0; index < _providedGame.userImageURLs!.length; index++) {
          tempArr2.add(_providedGame.userImageURLs![index]);
        }
      }
      _initialGame = _providedGame.copyWith(
        imageURLs: tempArr1,
        userImageURLs: (_providedGame.userImageURLs == null)
            ? null
            : (_providedGame.userImageURLs!.isEmpty)
                ? null
                : tempArr2,
      );
      print("provided Game userImageURLs is");
      print(_providedGame.userImageURLs);
      print("initial Game userImageURLs is");
      print(_initialGame.userImageURLs);
      print("copiedImageURLs length is ${_copiedImageURLs.length}");
    }
    _isInitInitialGame = true;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(child: Text("My Experience with ${_providedGame.title}")),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              await showDialog<void>(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    title: const Text("Are your sure?"),
                    content: const Text("Click confirm to finish editing."),
                    actions: [
                      TextButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text("Keep Editing"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text("Confirm"),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          setState(() {
                            _isLoading = true;
                          });
                          //CONCURRENT MODIFICATION error when we try to use
                          //_providedGame = _providedGame.copyWith(userImageURLs: _copiedImageURLs);
                          //it is related to didChangeDependencies since it would rebuilt again
                          //so we gotta have something like isInit yet (flag) so that it only init once
                          //To avoid that when we cannot assign _providedGame or use the copyWith method for it
                          _providedGame = _providedGame.copyWith(userImageURLs: _copiedImageURLs);

                          //why do we have the above code
                          //since we use copiedImageURLs to manage images and not providedGame.userImageURLs (not directly)
                          //since we don't want to alter temp_data => then when users don't upload, the temp_data got modified
                          //so we use the copied one
                          //but when we actually click save, we should modify the temp data
                          //that's why we update providedGame with a new object with an altered userImageURLs array
                          await Provider.of<Games>(context, listen: false).updateGame(
                            id: _gameID!,
                            initialGame: _initialGame,
                            editedGame: _providedGame,
                            gamesOption: GamesOption.userGames,
                            userImageFile: _titleImageFile,
                            userImageFiles: _pickedImageFiles,
                            deletedStorageUserImageURLs: _deletedStorageImageURLs,
                          );
                          setState(() {
                            _isLoading = false;
                          });

                          if (!mounted) return;

                          if (_returnRouteName == ManageGamesScreen.routeName) {
                            Navigator.of(context).pushAndRemoveUntil(
                              CustomRoute(
                                builder: (context) => const ManageGamesScreen(),
                              ),
                              (route) => route.isFirst,
                            );
                          } else {
                            Navigator.of(context).pushAndRemoveUntil(
                              CustomRoute(
                                builder: (context) => GameExperienceScreen(id: _providedGame.id),
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
            },
          ),
        ],
      ),
      body: (_isLoading)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text("Saving ..."),
                ],
              ), //this would show a loading spinner
            )
          : Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Container(
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
                          child: (_providedGame.userTitleImageURL != null &&
                                  _titleImageFile == null)
                              ? GestureDetector(
                                  onTap: () {
                                    {
                                      SwipeImageGallery(
                                        hideStatusBar: false,
                                        backgroundColor: Colors.black54,
                                        //use current Image Index found in CarouselSllider to jump to the right image here
                                        context: context,
                                        children: [Image.network(_providedGame.userTitleImageURL!)],
                                        heroProperties: const [
                                          ImageGalleryHeroProperties(tag: 'user_title_image_url'),
                                        ],
                                      ).show();
                                    }
                                  },
                                  child: Hero(
                                      tag: '1st image$_gameID',
                                      child: Image.network(_providedGame.userTitleImageURL!)),
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
                                          children: [Image.file(_titleImageFile as File)],
                                          heroProperties: const [
                                            ImageGalleryHeroProperties(tag: 'user_avatar'),
                                          ],
                                        ).show();
                                      },
                                      child: Image.file(_titleImageFile as File),
                                    )),
                        ),
                      ),
                      const Flexible(
                        child: Text(
                          "Add an image of this game that you bought:",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      TitleImagePicker(
                        _imagePicker,
                      ),

                      //const Spacer(),
                    ],
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 8),
                    color: Colors.blue.withOpacity(0.25),
                    child: const FittedBox(
                      child: Text(
                        "Add more pictures of this game.",
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
                  if (_providedGame.userImageURLs != null)
                    AdditionalImagesBuilder(
                      imageURLs: _copiedImageURLs,
                      manageImagesFn: _manageImageURLs,
                      //deletedIndexFn: _storeDeletedURLIndices,
                    ),
                ],
              ),
            ),
    );
  }

  void _imagePicker(File imageFile) {
    setState(() {
      _titleImageFile = imageFile;
    });
  }

  void _imagesPicker(List<File> imageFiles) {
    setState(() {
      _pickedImageFiles = imageFiles;
    });
  }

  void _managePickedImages(List<bool> deletedIndices) {
    List<File> tempFilesList = [];
    for (int i = 0; i < deletedIndices.length; i++) {
      if (deletedIndices[i] == false) {
        tempFilesList.add(_pickedImageFiles[i]);
      }
    }
    _pickedImageFiles = tempFilesList;
    setState(() {});
  }

  void _manageImageURLs(List<bool> deletedIndices) {
    print("enter manageImageURLs function");
    print("_copiedImageURLs length is ${_copiedImageURLs.length}");
    print("bool values are:");
    print(deletedIndices);
    for (int i = deletedIndices.length - 1; i >= 0; i--) {
      //we cannot just use _copiedImageURLs.removeAt coz we have to remove a lot of items
      //so first we have to sort the deleted indices
      //and then we're gonna remove from right to left so that it wouldn't affect our array position
      if (deletedIndices[i] == true && _providedGame.userImageURLs != null) {
        try {
          print("remove at $i");
          print("_copiedImageURLs length is ${_copiedImageURLs.length}");
          _copiedImageURLs.removeAt(i);
          if (_providedGame.userImageURLs![i].startsWith(
              'https://firebasestorage.googleapis.com/v0/b/video-games-backlog.appspot.com/o/users%2F${FirebaseAuth.instance.currentUser!.uid}')) {
            _deletedStorageImageURLs.add(_providedGame.userImageURLs![i]);
          }
        } catch (e) {
          print(e);
        }
      }
      //https://firebasestorage.googleapis.com/v0/b/video-games-backlog.appspot.com/o/users%2FvRzo1kGFObWY9yrpgs4Ne6roY0p1       %2Fgames%2FTimestamp(seconds%3D1662003845%2C%20nanoseconds%3D959119000)%2FimageURLs%2FTimestamp(seconds%3D1662003847%2C%20nanoseconds%3D172432000)?alt=media&token=ae0be72c-0dca-4f44-bd3f-7c014bd57a54
      //https://firebasestorage.googleapis.com/v0/b/video-games-backlog.appspot.com/o/users%2FvRzo1kGFObWY9yrpgs4Ne6roY0p1       %2Fgames%2FTimestamp(seconds%3D1661786037%2C%20nanoseconds%3D327339000)%2FimageURLs%2FTimestamp(seconds%3D1662009162%2C%20nanoseconds%3D745436000)?alt=media&token=88ffbc5d-e87f-46e6-88a6-620f40d40453
    }
    setState(() {});
  }

/*
  void _storeDeletedURLIndices(int index) {
    //print("Deleted index is: ");
    if (_providedGame.userImageURLs![index].startsWith(
        'https://firebasestorage.googleapis.com/v0/b/video-games-backlog.appspot.com/o/users%2F${FirebaseAuth.instance.currentUser!.uid}')) {
      _deletedStorageImageURLs.add(_providedGame.userImageURLs![index]);
    }
    //print(_providedGame.userImageURLs[index]);
  }
  */
}
