
//dart
import 'dart:math';
//packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';
import 'package:carousel_slider/carousel_slider.dart';
//providers
import '../helpers/custom_route.dart';
import '../providers/games.dart';
import '../providers/game.dart';
//screens
import './edit_game_screen/edit_game_screen.dart';
import './game_experience_screen.dart';
import './edit_game_screen/add_detailed_description_screen.dart';

/*
enum GridOption {
  one,
  two,
}
*/

class GameDetailScreen extends StatefulWidget {
  final GridOption gridOption;
  const GameDetailScreen({
    Key? key,
    //this.gridOption = GridOption.two,
  }) : super(key: key);
  static const routeName = '/game-detail';

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  late List<Map<String, Object>> _pages;
  late String _gameID;
  //don't use final after late or else an error would occur (missing some dirty states) when we reload the page
  late Game _providedGame;
  final List<Image> _images = [];
  final List<Widget> _imagesWrappedByHeroes = [];
  final List<ImageGalleryHeroProperties> _heroProperties = [];

  late Axis _scrollDirection;

  late int _firstParagraphLastIndex;

  late int _counter;

  late MutableGame _copiedGame;

  @override
  void didChangeDependencies() {
    _scrollDirection = (Random().nextInt(100) > 50) ? Axis.vertical : Axis.horizontal;
    _gameID = ModalRoute.of(context)?.settings.arguments as String;

    _providedGame =
        Provider.of<Games>(context, listen: false).findByID(_gameID, GamesOption.userGames);
    _copiedGame = _providedGame.copyWithMutable(); //deep copy / return unmodified/modified Object
    //print(_copiedGame.longDescription);
    if (_providedGame.longDescription != null) {
      _firstParagraphLastIndex = _providedGame.longDescription!.indexOf('\n');
    } else {
      _firstParagraphLastIndex = -1;
    }
    _counter = 0;

    for (String url in _providedGame.imageURLs) {
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
      _imagesWrappedByHeroes.add(
        Hero(
          tag: url,
          child: _images[_counter],
        ),
      );
      _heroProperties.add(
        ImageGalleryHeroProperties(tag: url),
      );
      _counter++;
    }

    _pages = [
      {
        'page': const GameDetailScreen(),
        'title': _providedGame.title,
      },
      {
        'page': GameExperienceScreen(
          id: _gameID,
        ),
        'title': "Gaming Experience",
      },
    ];
    super.didChangeDependencies();
  }

  int _currentImageIndex = 0;
  int _selectedPageIndex = 0;
  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    print("build game detail screen");
    //final MediaQueryData mediaQueryData = MediaQuery.of(context);
    if (_providedGame.imageURLs.isNotEmpty) {
      _currentImageIndex = Random().nextInt(_providedGame.imageURLs.length);
    }

    /*
    final _gameID = ModalRoute.of(context)?.settings.arguments as String;
    final _providedGame =
        Provider.of<Games>(context, listen: false).findByID(_gameID, GamesOption.userGames);
        */
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          onTap: _selectPage,
          backgroundColor: (isDarkMode) ? Colors.black : Theme.of(context).colorScheme.primary,
          selectedItemColor: (isDarkMode) ? Colors.white : Colors.black,
          unselectedItemColor: (isDarkMode) ? Colors.white38 : Colors.white,
          currentIndex: _selectedPageIndex,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              backgroundColor: Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.games_outlined),
              label: _providedGame.title,
            ),
            BottomNavigationBarItem(
              backgroundColor: Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.star_border_outlined),
              label: "My Experience",
              tooltip: "My Thoughts",
            ),
          ],
        ),

        floatingActionButton: (_selectedPageIndex == 1)
            ? null
            : FloatingActionButton(
                backgroundColor: Colors.red.withOpacity(0.9),
                foregroundColor: Colors.white,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                tooltip: _providedGame.isFavorite ? "Unfavorite" : "Favorite",
                child: Icon(
                  _providedGame.isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
                onPressed: () async {
                  //we have to use async since this takes time to communicate with the server
                  await _providedGame.toggleFavorite();
                  setState(() {});
                },
              ),

        body: (_selectedPageIndex > 0)
            ? _pages[_selectedPageIndex]['page'] as Widget
            : CustomScrollView(
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
                              EditGameScreen.routeName,
                              arguments: {
                                'id': _gameID,
                                'returnRouteName': GameDetailScreen.routeName,
                              },
                            );
                          },
                        ),
                      ),
                    ],
                    expandedHeight: 300,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      //adding a border for the game's title (strut style)
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
                      background: Hero(
                        tag: _providedGame.titleImageURL,
                        child: Image.network(
                          errorBuilder: (context, error, stackTrace) {
                            return const Image(
                              image: AssetImage("assets/images/404_eye.png"),
                            );
                          },
                          _providedGame.titleImageURL,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          width: double.infinity,
                          child: SelectableText(
                            _providedGame.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16.5),
                            //softWrap: true,
                            //softWrap parameter of Text -> true: wrap to newLine if there's no more page
                          ),
                        ),
                        //modify constraints of this!!!
                        const SizedBox(
                          height: 20,
                        ),
                        if (_providedGame.imageURLs.isNotEmpty)
                          //the 2nd image should be at the bottom of the screen!!! Implement constraint for that
                          LayoutBuilder(builder: (context, constraints) {
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
                                        // transitionDuration: 400,
                                        hideStatusBar: false,
                                        backgroundColor: Colors.black54,

                                        //use current Image Index found in CarouselSllider to jump to the right image here
                                        context: context,
                                        children: _images,
                                        heroProperties: _heroProperties,
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
                                        autoPlayAnimationDuration:
                                            const Duration(milliseconds: 350),
                                        enlargeCenterPage: true,
                                        autoPlayCurve: Curves.fastOutSlowIn,
                                        scrollDirection: _scrollDirection,

                                        onPageChanged: (index, carouselPageChangedReason) {
                                          _currentImageIndex = index;
                                          //carouselPageChangedReason could be manual (user swiping)
                                          //or timed (auto changing from animation)
                                        },
                                      ),
                                      items: _imagesWrappedByHeroes,
                                    ),
                                  ),
                                ),
                                Container(width: sidePadding),
                              ],
                            );
                          }),
                        const SizedBox(
                          height: 40,
                        ),
                        if (_copiedGame.longDescription != null)
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 0, 0, 20),
                            width: double.infinity,
                            child: (_firstParagraphLastIndex == -1) //doesn't have a newline
                                ? SelectableText(
                                    _copiedGame.longDescription!,
                                    textAlign: (_copiedGame.longDescription!.length < 100)
                                        ? TextAlign.center
                                        : TextAlign.start,
                                  )
                                : SelectableText(
                                    _copiedGame.longDescription!.substring(
                                      0,
                                      _firstParagraphLastIndex,
                                    ),

                                    style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: (_copiedGame.longDescription!.length < 100)
                                        ? TextAlign.center
                                        : TextAlign.start,
                                    //softWrap: true,
                                    //softWrap parameter of Text -> true: wrap to newLine if there's no more page
                                  ),
                          ),
                        if (_copiedGame.longDescription == null ||
                            _copiedGame.longDescription!.isEmpty)
                          Column(
                            children: [
                              Text(
                                "${_providedGame.title} doesn't have a detailed description yet.",
                              ),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  await Navigator.of(context).push(CustomRoute(
                                    builder: (context) => AddDetailedDescriptionScreen(
                                      addDetailedDescription: _addDetailedDescription,
                                      title: _providedGame.title,
                                      detailedDescription: _copiedGame.longDescription,
                                    ),
                                  ));
                                  setState(() {});
                                  if (!mounted) return;
                                  Provider.of<Games>(context, listen: false).updateGame(
                                    id: _gameID,
                                    initialGame: _providedGame,
                                    editedGame: _providedGame.copyWith(
                                        longDescription: _copiedGame.longDescription),
                                    gamesOption: GamesOption.userGames,
                                  );
                                },
                                label: const Text("Add a detailed description"),
                              )
                            ],
                          ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (_copiedGame.longDescription != null)
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 0, 0, 20),
                            width: double.infinity,
                            child: (_firstParagraphLastIndex == -1)
                                ? null
                                : SelectableText(
                                    _copiedGame.longDescription!
                                        .substring(_firstParagraphLastIndex),
                                    style: const TextStyle(fontSize: 17),
                                    textAlign: (_copiedGame.longDescription!.length < 100)
                                        ? TextAlign.center
                                        : TextAlign.start,
                                    //softWrap: true,
                                  ),
                          ),
                        const SizedBox(height: kToolbarHeight),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _addDetailedDescription(String? detailedDescription) {
    _copiedGame.longDescription = detailedDescription;
    print("copied game long description is");
    print(_copiedGame.longDescription);
  }
}
