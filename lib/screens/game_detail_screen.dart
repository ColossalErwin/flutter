//fix an issue where when we are from mange games screen and click on add a game
//it shows late initialization issue, _gameID has not been initialized

//Trending games should have filters to show upcoming games only

/*//This error related to the default tab controller that we uses for game detail screen and my experience screen
//in order to fix it change late final String _gameID to late String _gameID and late final Game provideGame to just late Game _providedGame;

════════ Exception caught by widgets library ═══════════════════════════════════
The following LateError was thrown while rebuilding dirty elements:
LateInitializationError: Field 'gameID' has already been initialized.

The relevant error-causing widget was
GameDetailScreen
lib/main.dart:423
When the exception was thrown, this was the stack
#0      LateError._throwFieldAlreadyInitialized (dart:_internal-patch/internal_patch.dart:194:5)
#1      _GameDetailScreenState._gameID=
../screens/game_detail_screen.dart:39
#2      _GameDetailScreenState.didChangeDependencies
../screens/game_detail_screen.dart:50
#3      StatefulElement.performRebuild
package:flutter/…/widgets/framework.dart:4974
#4      Element.rebuild
package:flutter/…/widgets/framework.dart:4529
#5      BuildOwner.buildScope
package:flutter/…/widgets/framework.dart:2659
#6      WidgetsBinding.drawFrame
package:flutter/…/widgets/binding.dart:891
#7      RendererBinding._handlePersistentFrameCallback
package:flutter/…/rendering/binding.dart:370
#8      SchedulerBinding._invokeFrameCallback
package:flutter/…/scheduler/binding.dart:1146
#9      SchedulerBinding.handleDrawFrame
package:flutter/…/scheduler/binding.dart:1083
#10     SchedulerBinding._handleDrawFrame
package:flutter/…/scheduler/binding.dart:997
#14     _invoke (dart:ui/hooks.dart:151:10)
#15     PlatformDispatcher._drawFrame (dart:ui/platform_dispatcher.dart:308:5)
#16     _drawFrame (dart:ui/hooks.dart:115:31)
(elided 3 frames from dart:async)
The element being rebuilt at the time was index 4 of 58: GameDetailScreen
    dirty
    dependencies: [_LocalizationsScope-[GlobalKey#c8630], _ModalScopeStatus, _InheritedTheme]
    state: _GameDetailScreenState#e6140
════════════════════════════════════════════════════════════════════════════════

════════ Exception caught by scheduler library ═════════════════════════════════
buildScope missed some dirty elements.
The list of dirty elements at the end of the buildScope call was
    GamesOverviewScreen
        dependencies: [_LocalizationsScope-[GlobalKey#c8630], MediaQuery, _InheritedTheme, _InheritedProviderScope<Filters?>]
*/

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
import 'edit_game_screen/add_detailed_description_screen.dart';

enum GridOption {
  one,
  two,
}

class GameDetailScreen extends StatefulWidget {
  final GridOption gridOption;
  const GameDetailScreen({
    Key? key,
    this.gridOption = GridOption.two,
  }) : super(key: key);
  static const routeName = '/game-detail';

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  late List<Map<String, Object>> _pages;
  late String _gameID;
  //don't use final here or else an error would occur (missing some dirty states) when we reload the page
  late Game _providedGame;
  //don't use final here or else an error would occur when we reload the page
  final List<Image> _images = [];
  final List<Widget> _imagesWrappedByHeroes = [];
  final List<ImageGalleryHeroProperties> _heroProperties = [];

  late Axis _scrollDirection;

  late int _firstParagraphLastIndex;

  late int _counter;

  late MutableGame _copiedGame;

  @override
  void didChangeDependencies() {
    //put _scrollDirection here so that when we click the floating action button
    //the carousel won't change its scroll direction
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
        /*
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  await _providedGame.toggleFavorite();
                  setState(() {});
                },
                tooltip: (_providedGame.isFavorite) ? "Unfavorite" : "Favorite",
                child: (_providedGame.isFavorite)
                    ? const Icon(Icons.favorite)
                    : const Icon(Icons.favorite_border_outlined),
              ),
              */

        //we only want the floating button gets updated and not the whole page whenever we toggleFavorite
        //we still need this to be a Stateful widget to setState for the icon (full or border)
        //an option is use Consumer
        //We can only use one Provider route at a time
        //so we cannot use Consumer<Game> since we already use Provider.of<Games>
        //thus we have to use Consumer<Games>
        //this would return a Games object instead
        //so we have to use the Games gameList findByID to find that Game object
        //or we can simply not use gamesList at all and use _providedGame

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
                      background: Hero(
                        tag: _providedGame.titleImageURL,
                        child: Image.network(
                          /*
                          loadingBuilder: (context, error, stackTrace) {
                            return Image.asset("assets/images/ps5-placeholder.jpeg");
                          },
                          */
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
                        /*
                  Text(
                    "\$${_providedGame.msrp} --- ${platformToString(_providedGame.platform)}",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  */
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
                                      /*
                                      If we want the to click on the first image and direct to the right one without using setState
                                      we should specify initialPage for CarouselSlider to be 0
                                      if we choose random
                                      then when click on the first image after loading the page the first time
                                      it might not direct to the correct one
                                      otherwise should set _currentIndex to Random and use initialPage the same as currentIndex
                        
                                      //however if we swipe from the image gallery and want to go back and see the carousel displaying the same image
                                      //that would be another story
                                      //the carousel usually won't rebuild
                                      //try to use onSwipe for storing the index
                                      //then if only SwipeImageGallery has some function when we dismiss it
                                      */
                                      SwipeImageGallery(
                                        initialIndex: _currentImageIndex,
                                        // transitionDuration: 400,
                                        hideStatusBar: false,
                                        backgroundColor: Colors.black54,

                                        //use current Image Index found in CarouselSllider to jump to the right image here
                                        context: context,
                                        children: _images,
                                        /*
                                      initialIndex: _currentImageIndex,
                                      onSwipe: (index) {
                                        setState(() {
                                          _currentImageIndex = index;
                                        });
                                      },
                                      */
                                        heroProperties: _heroProperties,
                                      ).show();
                                    },
                                    child: CarouselSlider(
                                      options: CarouselOptions(
                                        initialPage: _currentImageIndex,
                                        //Random().nextInt(_providedGame.imageURLs.length),
                                        //random number from 0 up to length - 1
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
                                          /*
                                          print("current image index");
                                          print(_currentImageIndex);
                                          print("index");
                                          print(index);
                                          print(carouselPageChangedReason);
                                          */
                                          //carouselPageChangedReason could be manual (user swipe)
                                          //or timed (animation change)
                                        },

                                        //onScrolled: ,
                                        //clipBehavior: Clip.none,
                                      ),
                                      items: _imagesWrappedByHeroes,
                                    ),
                                  ),
                                ),
                                Container(width: sidePadding),
                              ],
                            );
                          }),
                        /*
                  //example for CarouselSlider
                  CarouselSlider(
                    items: items,
                    options: CarouselOptions(
                        height: 400,
                        aspectRatio: 16/9,
                        viewportFraction: 0.8,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        reverse: false,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 3),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enlargeCenterPage: true,
                        onPageChanged: callbackFunction,
                        _scrollDirection: Axis.horizontal,
                    )
                  ),
                   */
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
                                  /*
                                  Why do we use await and async for push here
                                  Because we go to a new page (Add Detailed Description Screen)
                                  We have to write a detailed description which takes time
                                  if we don't use await then the code after that would execute synchronously
                                  meaning _copiedGame.longDescription is still with its initial values
                                  */
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

  /*
  Widget _recursiveImageSwiping(Game _providedGame, int startingIndex) {
    if (startingIndex == _providedGame.imageURLs.length) {
      return Container(); //base case
    }
    return Dismissible(
      key: ValueKey(_providedGame.id),
      background: _recursiveImageSwiping(_providedGame, startingIndex + 1),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: double.infinity,
        child: (widget.gridOption == GridOption.two)
            ? Image.network(_providedGame.imageURLs[startingIndex])
            : FadeInImage(
                placeholder: const AssetImage("assets/images/ps5-placeholder.jpeg"),
                image: NetworkImage(_providedGame.imageURLs[startingIndex]),
                fit: BoxFit.cover,
              ),
      ),
    );
  }
  */
  /*
                  SizedBox(
                    width: double.infinity,
                    height: 250,
                    child: InkWell(
                      splashColor: Colors.blue,
                      onTap: () => SwipeImageGallery(
                        context: context,
                        images: images,
                      ).show(),
                      child: Image.network(_providedGame.imageURLs[0]),
                    ),
                  ),
                  */

  /*
                  Dismissible(
                    key: ValueKey(_providedGame.id),
                    background: _recursiveImageSwiping(_providedGame, 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      width: double.infinity,
                      child: Hero(
                        tag: "2nd image${_providedGame.id}",
                        child: (widget.gridOption == GridOption.two)
                            ? Image.network(_providedGame.imageURLs[0])
                            : FadeInImage(
                                placeholder: const AssetImage("assets/images/ps5-placeholder.jpeg"),
                                image: NetworkImage(_providedGame.imageURLs[0]),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  */
}
