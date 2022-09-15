//dart
import 'dart:math';
//packages
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';
//providers
import '../providers/game.dart';
import '../providers/games.dart';
//screens
import 'edit_game_screen/edit_game_experience_screen.dart';

class GameExperienceScreen extends StatefulWidget {
  final String id;
  const GameExperienceScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<GameExperienceScreen> createState() => _GameExperienceScreenState();
}

class _GameExperienceScreenState extends State<GameExperienceScreen> {
  final _formKey = GlobalKey<FormState>();
  late Game _providedGame;
  bool _expandRating = false;
  final List<Image> _images = [];
  //final List<Widget> _imagesWrappedByHeroes = [];
  //final List<ImageGalleryHeroProperties> _heroProperties = [];
  late int _counter;
  late Axis _scrollDirection;
  bool _playingStatusEditMode = false;
  bool _purchasePriceEditMode = false;
  bool _userDescriptionEditMode = false;
  final _purchasePriceController = TextEditingController();
  final _userDescriptionController = TextEditingController();

  bool _userDescriptionExpandMode = true;

  @override
  void didChangeDependencies() {
    _scrollDirection = (Random().nextInt(100) > 50) ? Axis.vertical : Axis.horizontal;
    _providedGame =
        Provider.of<Games>(context, listen: false).findByID(widget.id, GamesOption.userGames);
    _userDescriptionController.text =
        _providedGame.userDescription ?? "Put on some thoughts about this game.";
    _counter = 0;
    if (_providedGame.userImageURLs != null && _providedGame.userImageURLs!.isNotEmpty) {
      for (String url in _providedGame.userImageURLs!) {
        print(url);
        _images.add(
          Image.network(
            url,
            errorBuilder: (context, error, stackTrace) {
              return const Image(
                image: AssetImage("assets/images/404_eye.png"),
              );
            },
          ),
        );
        /*
        _imagesWrappedByHeroes.add(
          _images[_counter],
        );

        
        _heroProperties.add(
          ImageGalleryHeroProperties(
            tag: url + _counter.toString(),
          ),
        );
        */
        _counter++;
      }
    }
    print("_images.length");
    print(_images.length);

    super.didChangeDependencies();
  }

  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    _currentImageIndex = Random().nextInt(_providedGame.imageURLs.length);
    print("build game experience screen");
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          //Creates a material design app bar that can be placed in a [CustomScrollView].
          SliverAppBar(
            //see how to modify the appbar: https://stackoverflow.com/questions/51508257/how-to-change-the-appbar-back-button-color
            centerTitle: true,
            leading: IconButton(
              icon: Stack(
                children: const [
                  Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 35,
                  ),
                  Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  ),
                ],
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            iconTheme: const IconThemeData(
              color: Colors.white, //change your color here
              shadows: [
                Shadow(color: Colors.black),
              ],
            ),
            actions: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      EditGameExperienceScreen.routeName,
                      arguments: {
                        'id': widget.id,
                        'returnRouteName': '',
                      },
                    );
                  },
                ),
              ),
            ],
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              //adding a border for title
              //since there might be a chance that the background image color and our text's color are the same
              //see: https://www.kindacode.com/snippet/adding-a-border-to-text-in-flutter/

              title: FittedBox(
                child: Stack(
                  children: [
                    // Implement the stroke
                    Text(
                      _providedGame.title,
                      style: TextStyle(
                        fontSize: 30,
                        letterSpacing: 2,
                        //fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 7.5
                          ..color = Colors.black,
                      ),
                    ),
                    // The text inside
                    Text(
                      _providedGame.title,
                      style: const TextStyle(
                        fontSize: 30,
                        letterSpacing: 2,
                        //fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ), //Text(_providedGame.title),
              ),
              background: Image.network(
                errorBuilder: (context, error, stackTrace) {
                  return const Image(
                    image: AssetImage("assets/images/404_eye.png"),
                  );
                },
                _providedGame.userTitleImageURL ?? _providedGame.titleImageURL,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(
                  height: 15,
                ),
                if (_playingStatusEditMode == true)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.5),
                    child: CheckboxListTile(
                      activeColor: Colors.red.withOpacity(0.85),
                      title: Text(
                        "Have you played this game:",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      value: _providedGame.hasPlayed,
                      onChanged: (val) async {
                        await _providedGame.toggleHasPlayed();
                        setState(() {});
                      },
                    ),
                  ),
                if (_playingStatusEditMode == true)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.5),
                    child: CheckboxListTile(
                      activeColor: Colors.red.withOpacity(0.85),
                      title: Text(
                        "Have you finished this game:",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      value: _providedGame.hasFinished,
                      onChanged: (val) async {
                        await _providedGame.toggleHasFinished();
                        setState(() {});
                      },
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    FittedBox(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: const Text(
                          "Playing status:",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16.5),
                        ),
                      ),
                    ),
                    FittedBox(
                      child: (_providedGame.hasFinished == true)
                          ? TextButton.icon(
                              icon: const Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                              onPressed: null,
                              label: const Text(
                                "Finished",
                                style: TextStyle(
                                  color: Colors.green,
                                ),
                              ),
                            )
                          : Text(
                              (_providedGame.hasPlayed == true ||
                                      _providedGame.lastPlayDate != null)
                                  ? "Have played,\nbut not finished"
                                  : "Have not played",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                            ),
                    ),
                    const Spacer(),
                    FittedBox(
                      child: IconButton(
                        icon: (_playingStatusEditMode == false)
                            ? Icon(
                                Icons.edit,
                                color: isDarkMode ? Colors.white54 : Colors.black54,
                              )
                            : Icon(
                                Icons.arrow_drop_up,
                                color: isDarkMode ? Colors.white54 : Colors.black54,
                              ),
                        onPressed: () {
                          setState(() {
                            _playingStatusEditMode = !_playingStatusEditMode;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: TextButton.icon(
                      label: (_providedGame.lastPlayDate != null)
                          ? Text(DateFormat.yM().format(_providedGame.lastPlayDate!.toDate()))
                          : const Text("Last playing time"),
                      icon: const Icon(
                        Icons.edit_calendar,
                        color: Colors.blue,
                      ),
                      onPressed: () async {
                        await showDialog<void>(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              title: const Text("Choose your last playing time."),
                              content: (_providedGame.hasFinished)
                                  ? null
                                  : const Text(
                                      "When a date has been chosen, it means that you have played this game."),
                              actions: [
                                TextButton(
                                  child: const Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text("Proceed"),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    await showDatePicker(
                                      initialDatePickerMode: DatePickerMode.year,
                                      cancelText: "CANCEL",
                                      confirmText: "CONFIRM",
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1990),
                                      lastDate: DateTime.now(),
                                    ).then(
                                      (pickedDate) async {
                                        //even if value is null it's ok
                                        await _providedGame.updateLastPlayDate(pickedDate);
                                      },
                                    );
                                    setState(() {});
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    FittedBox(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: const Text(
                          "My rating:",
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 16.5),
                        ),
                      ),
                    ),
                    if (_expandRating == false)
                      FittedBox(
                        child: Row(
                          children: (_providedGame.userRating == null)
                              ? [
                                  const Text("N/A"),
                                  const SizedBox(width: 5),
                                  TextButton.icon(
                                    label: const Text("Rate this game"),
                                    icon: Icon(
                                      Icons.arrow_right,
                                      color: isDarkMode ? Colors.white54 : Colors.black54,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _expandRating = !_expandRating;
                                      });
                                    },
                                  ),
                                ]
                              : [
                                  Text("${encodeRating(_providedGame.userRating)}"),
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  IconButton(
                                    tooltip: "Rate again",
                                    icon: const Icon(
                                      Icons.arrow_right,
                                      color: Colors.black54,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _expandRating = !_expandRating;
                                      });
                                    },
                                  ),
                                ],
                        ),
                      )
                    else
                      FittedBox(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (_providedGame.userRating == null ||
                                    encodeRating(_providedGame.userRating)! > 1) {
                                  await _providedGame.updateRating(Rating.one);
                                  setState(() {});
                                } else if (_providedGame.userRating == Rating.one) {
                                  await _providedGame.updateRating(null);
                                  setState(() {});
                                }
                              },
                              child: Icon(
                                (_providedGame.userRating == null)
                                    ? Icons.star_border
                                    : (encodeRating(_providedGame.userRating)! >= 1)
                                        ? Icons.star
                                        : Icons.star_border,
                                color: Colors.amber,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (_providedGame.userRating == null ||
                                    encodeRating(_providedGame.userRating)! != 2) {
                                  await _providedGame.updateRating(Rating.two);
                                  setState(() {});
                                } else if (_providedGame.userRating == Rating.two) {
                                  await _providedGame.updateRating(null);
                                  setState(() {});
                                }
                              },
                              child: Icon(
                                (_providedGame.userRating == null)
                                    ? Icons.star_border
                                    : (encodeRating(_providedGame.userRating)! >= 2)
                                        ? Icons.star
                                        : Icons.star_border,
                                color: Colors.amber,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (_providedGame.userRating == null ||
                                    encodeRating(_providedGame.userRating)! != 3) {
                                  await _providedGame.updateRating(Rating.three);
                                  setState(() {});
                                } else if (_providedGame.userRating == Rating.three) {
                                  await _providedGame.updateRating(null);
                                  setState(() {});
                                }
                              },
                              child: Icon(
                                (_providedGame.userRating == null)
                                    ? Icons.star_border
                                    : (encodeRating(_providedGame.userRating)! >= 3)
                                        ? Icons.star
                                        : Icons.star_border,
                                color: Colors.amber,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (_providedGame.userRating == null ||
                                    encodeRating(_providedGame.userRating)! != 4) {
                                  await _providedGame.updateRating(Rating.four);
                                  setState(() {});
                                } else if (_providedGame.userRating == Rating.four) {
                                  await _providedGame.updateRating(null);
                                  setState(() {});
                                }
                              },
                              child: Icon(
                                (_providedGame.userRating == null)
                                    ? Icons.star_border
                                    : (encodeRating(_providedGame.userRating)! >= 4)
                                        ? Icons.star
                                        : Icons.star_border,
                                color: Colors.amber,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (_providedGame.userRating == null ||
                                    encodeRating(_providedGame.userRating)! != 5) {
                                  await _providedGame.updateRating(Rating.five);
                                  setState(() {});
                                } else if (_providedGame.userRating == Rating.five) {
                                  await _providedGame.updateRating(null);
                                  setState(() {});
                                }
                              },
                              child: Icon(
                                (_providedGame.userRating == null)
                                    ? Icons.star_border
                                    : (encodeRating(_providedGame.userRating)! >= 5)
                                        ? Icons.star
                                        : Icons.star_border,
                                color: Colors.amber,
                              ),
                            ),
                            IconButton(
                              tooltip: "Collapse",
                              icon: const Icon(
                                Icons.arrow_left,
                                color: Colors.black54,
                              ),
                              onPressed: () {
                                setState(() {
                                  _expandRating = !_expandRating;
                                });
                              },
                            )
                          ],
                        ),
                      ),
                  ],
                ),

                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: const Text(
                          "Purchase price:",
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    if (_purchasePriceEditMode == false)
                      Row(
                        children: [
                          Text(
                            (_providedGame.purchasePrice == null)
                                ? "N/A"
                                : ("\$${_providedGame.purchasePrice!.toStringAsFixed(2)}"),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: isDarkMode ? Colors.white54 : Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                _purchasePriceEditMode = !_purchasePriceEditMode;
                              });
                            },
                          ),
                        ],
                      )
                    else
                      Flexible(
                        child: Container(
                          decoration: BoxDecoration(
                            backgroundBlendMode: BlendMode.colorDodge,
                            color: const Color.fromARGB(255, 228, 228, 228),
                            border: Border.all(
                              color: Colors.black,
                              width: 0.5,
                            ),
                          ),
                          child: TextFormField(
                            controller: _purchasePriceController,
                            validator: (inputValue) {
                              if (inputValue == null) {
                                return null; //if don't type anything then still return true;
                              }
                              if (double.tryParse(inputValue) == null) {
                                return "Please enter a valid number";
                              }
                              if (double.parse(inputValue) < 0) {
                                return "Value must not be negative.";
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "Purchase Price"),
                            onFieldSubmitted: (inputValue) async {
                              if (_purchasePriceController.text.trim().isEmpty) {
                                setState(() {
                                  _purchasePriceEditMode = !_purchasePriceEditMode;
                                });
                              } else {
                                //final isValid = _formKey.currentState!.validate();
                                //if (isValid == false) {
                                final isValid = _formKey.currentState?.validate();
                                if (isValid != null && isValid == false) {
                                  return;
                                } else {
                                  _formKey.currentState?.save();
                                  await _providedGame
                                      .updatePurchasePrice(_purchasePriceController.text);
                                  setState(() {
                                    _purchasePriceEditMode = !_purchasePriceEditMode;
                                  });
                                }
                              }
                            },
                          ),
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    FittedBox(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: const Text(
                          "My thoughts:",
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (_userDescriptionEditMode == false)
                      FittedBox(
                        child: TextButton.icon(
                          icon: Icon(
                            Icons.edit_note,
                            color: isDarkMode ? Colors.blue.withOpacity(0.8) : Colors.black54,
                          ),
                          label: (_providedGame.userDescription == null ||
                                  _providedGame.userDescription!.isEmpty)
                              ? Text(
                                  "write something",
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white54 : Colors.black54,
                                  ),
                                )
                              : const Text("more thoughts"),
                          onPressed: () {
                            setState(() {
                              _userDescriptionEditMode = !_userDescriptionEditMode;
                            });
                          },
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        label: const Text("Finish editing"),
                        icon: const Icon(Icons.save),
                        onPressed: () async {
                          //update userDescription
                          _formKey.currentState!.save();
                          await _providedGame
                              .updateUserDescription(_userDescriptionController.text);
                          setState(() {
                            _userDescriptionEditMode = !_userDescriptionEditMode;
                          });
                        },
                      ),
                    if (_userDescriptionEditMode == true)
                      IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () {
                          setState(() {
                            _userDescriptionEditMode = !_userDescriptionEditMode;
                          });
                        },
                      )
                  ],
                ),

                if (_userDescriptionEditMode)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formKey,
                      onChanged: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.69,
                            color: Colors.blue.withOpacity(0.33),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          //style: TextStyle(color: isDarkMode ? Colors.black : null),
                          initialValue: _userDescriptionController.text,
                          keyboardType: TextInputType.multiline,
                          maxLines: 25,
                          decoration: InputDecoration(
                            labelText: "Thoughts on ${_providedGame.title}",
                          ),
                          onSaved: (inputValue) {
                            if (inputValue == null) {
                              return;
                            }
                            _userDescriptionController.text = inputValue;
                          },
                        ),
                      ),
                    ),
                  ),
                if (_userDescriptionEditMode)
                  ListTile(
                    trailing: OutlinedButton.icon(
                      label: const Text("Finish editing"),
                      icon: const Icon(Icons.save),
                      onPressed: () async {
                        //update userDescription
                        _formKey.currentState!.save();

                        await _providedGame.updateUserDescription(_userDescriptionController.text);
                        setState(() {
                          _userDescriptionEditMode = !_userDescriptionEditMode;
                        });
                      },
                    ),
                  ),
                if (_userDescriptionEditMode == false &&
                    _providedGame.userDescription != null &&
                    _providedGame.userDescription!.isNotEmpty)
                  Align(
                    //in case we want to move the icon to the left
                    //alignment: Alignment.bottomCenter,
                    child: IconButton(
                      tooltip: (_userDescriptionExpandMode) ? "Collapse" : "Expand",
                      onPressed: () {
                        setState(() {
                          _userDescriptionExpandMode = !_userDescriptionExpandMode;
                        });
                      },
                      icon: (!_userDescriptionExpandMode)
                          ? const Icon(Icons.arrow_drop_down)
                          : const Icon(Icons.arrow_drop_up),
                    ),
                  ),
                if (_userDescriptionEditMode == false &&
                    _providedGame.userDescription != null &&
                    _providedGame.userDescription!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      // alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 237, 237, 237),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.33),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SelectableText(
                        "\t\t${_providedGame.userDescription!}",
                        textAlign: TextAlign.start,
                        style: TextStyle(color: isDarkMode ? Colors.black : null),
                      ),
                    ),
                  ),

                const SizedBox(
                  height: 20,
                ),
                //the 2nd image should be at the bottom of the screen!!! Implement constraint for that
                if (_providedGame.userImageURLs != null && _providedGame.userImageURLs!.isNotEmpty)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double sidePadding = constraints.maxWidth / 20;
                      return Row(
                        children: [
                          Container(width: sidePadding),
                          Container(
                            width: constraints.maxWidth - 2 * sidePadding,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.black54
                                  : const Color.fromARGB(255, 237, 237, 237),
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              splashColor: Colors.amber.withOpacity(0.15),
                              onTap: () {
                                SwipeImageGallery(
                                  initialIndex: _currentImageIndex,
                                  hideStatusBar: false,
                                  backgroundColor: Colors.black54,
                                  context: context,
                                  children: _images,
                                  //heroProperties: _heroProperties,
                                ).show();
                              },
                              child: CarouselSlider(
                                options: CarouselOptions(
                                  initialPage: _currentImageIndex,
                                  aspectRatio: 16 / 9,
                                  enableInfiniteScroll:
                                      (_providedGame.imageURLs.length > 2) ? true : false,
                                  autoPlay: true,
                                  autoPlayInterval: const Duration(seconds: 4),
                                  autoPlayAnimationDuration: const Duration(milliseconds: 350),
                                  enlargeCenterPage: true,
                                  autoPlayCurve: Curves.fastOutSlowIn,
                                  scrollDirection: _scrollDirection,
                                  onPageChanged: (index, carouselPageChangedReason) {
                                    _currentImageIndex = index;
                                  },
                                ),
                                items: _images, //_imagesWrappedByHeroes,
                              ),
                            ),
                          ),
                          Container(width: sidePadding),
                        ],
                      );
                    },
                  ),
                const SizedBox(height: kToolbarHeight),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
