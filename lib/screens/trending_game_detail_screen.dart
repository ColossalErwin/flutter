//for some reason we cannot pass arguments through routes since we already did that for game-detail
//if we pass then game detail would also find the arguments instead, causing all kinds of problems

//dart
import 'dart:math';
//packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';
import 'package:carousel_slider/carousel_slider.dart';
//screen
import './buying_trending_game_screen.dart';
//providers
import '../providers/games.dart';
import '../providers/game.dart';

/*
enum GridOption {
  one,
  two,
}
*/

class TrendingGameDetailScreen extends StatefulWidget {
  final String trendingGameID;
  final int imageIndex;
  //final GridOption gridOption;
  const TrendingGameDetailScreen({
    Key? key,
    // this.gridOption = GridOption.two,
    required this.trendingGameID,
    this.imageIndex = 0,
  }) : super(key: key);
  static const routeName = '/game-detail';

  @override
  State<TrendingGameDetailScreen> createState() => _TrendingGameDetailScreenState();
}

class _TrendingGameDetailScreenState extends State<TrendingGameDetailScreen> {
  late List<Map<String, Object>> _pages;
  //late GameDetailArguments args;

  //don't use final here or else an error would occur (missing some dirty states) when we reload the page
  late Game _providedTrendingGame;
  //don't use final here or else an error would occur when we reload the page
  final List<Image> _images = [];
  final List<Widget> _carouselImages = [];
  late int _currentImageIndex;

  late Axis scrollDirection;
  late int _firstParagraphLastIndex;
  late String? detailedDescription;
  late int counter;

  @override
  void didChangeDependencies() {
    _currentImageIndex = widget.imageIndex;
    //put scrollDirection here so that when we click the floating action button
    //the carousel won't change its scroll direction
    scrollDirection = (Random().nextInt(100) > 50) ? Axis.vertical : Axis.horizontal;
    //args = ModalRoute.of(context)?.settings.arguments as GameDetailArguments;

    _providedTrendingGame = Provider.of<Games>(context, listen: false)
        .findByID(widget.trendingGameID, GamesOption.trendingGames);

    if (_providedTrendingGame.longDescription != null) {
      detailedDescription = _providedTrendingGame.longDescription!.replaceAll('~', '\n');
      _firstParagraphLastIndex = detailedDescription!.indexOf('\n');
    } else {
      _firstParagraphLastIndex = -1;
    }
    counter = 0;
    for (String url in _providedTrendingGame.imageURLs) {
      _images.add(
        Image.network(url),
      );
      _carouselImages.add(
        Hero(
          tag: "$counter ${_providedTrendingGame.id} trending carousel",
          child: _images[counter],
        ),
      );
      counter++;
    }

    _pages = [
      {
        'page': TrendingGameDetailScreen(
          trendingGameID: widget.trendingGameID,
          imageIndex: _currentImageIndex,
        ),
        'title': "_providedTrendingGame.title",
      },
      {
        'page': BuyingTrendingGameScreen(
          trendingGameID: widget.trendingGameID,
        ),
        'title': _providedTrendingGame.title,
      },
    ];

    super.didChangeDependencies();
  }

  int _selectedPageIndex = 0;
  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    print("build trending game detail");

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
              icon: const Icon(Icons.gamepad),
              label: _providedTrendingGame.title,
            ),
            BottomNavigationBarItem(
              backgroundColor: Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.shopping_bag_outlined),
              label: "Buying Options",
              tooltip: "Direct to buying pages",
            ),
          ],
        ),
        floatingActionButton: (_selectedPageIndex == 1)
            ? null
            : ((_providedTrendingGame.releaseDate != null &&
                        _providedTrendingGame.releaseDate!.toDate().isAfter(
                              DateTime.now(),
                            )) ||
                    _providedTrendingGame.releaseDate == null)
                ? FloatingActionButton(
                    backgroundColor: Colors.red.withOpacity(0.85),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    //tooltip: _providedTrendingGame.isFavorite ? "Unfavorite" : "Favorite",
                    child: Icon(
                      _providedTrendingGame.isFavorite ? Icons.favorite : Icons.favorite_border,
                    ),
                    onPressed: () async {
                      /*
                      //we have to use async since this takes time to communicate with the server
                      await _providedTrendingGame.toggleWishlist();
                      setState(() {});
                      */
                    },
                  )
                : FloatingActionButton(
                    backgroundColor: Colors.blue.withOpacity(0.85),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    tooltip: "Add this game to your collection",
                    child: const Icon(Icons.add),
                    onPressed: () async {
                      //check if id is already in trending_game_ids
                      //add if it is not => show scaffold message
                      //if already is => show scaffold message saying: "This game is already in your backlog"
                      final bool hasAdded = await Provider.of<Games>(context, listen: false)
                          .addTrendingGameToCollection(_providedTrendingGame, context);
                      if (hasAdded) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Successfully added ${_providedTrendingGame.title} to your collection."),
                          ),
                        );
                      }
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
                    actions: const [
                      /*
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_checkout),
                        color: Colors.black87,
                        onPressed: () {},
                      )
                      */
                    ],
                    expandedHeight: 300,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: FittedBox(
                        child: Stack(
                          children: [
                            // Implement the stroke
                            Text(
                              _providedTrendingGame.title,
                              style: TextStyle(
                                fontSize: 30,
                                letterSpacing: 2,
                                //fontWeight: FontWeight.bold,
                                //cascade style: make a sequence of operation on the same object
                                //see: https://stackoverflow.com/questions/49447736/list-use-of-double-dot-in-dart
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 7.5
                                  ..color = Colors.black,
                              ),
                            ),
                            // The text inside
                            Text(
                              _providedTrendingGame.title,
                              style: const TextStyle(
                                fontSize: 30,
                                letterSpacing: 2,
                                //fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ), //Text(_providedTrendingGame.title),
                      ),
                      background: /*Hero(
                        tag: "trending game title image ${_providedTrendingGame.id}",
                        child:*/
                          FadeInImage(
                        placeholderErrorBuilder: (context, error, stackTrace) {
                          return Image.asset("assets/images/ps5-placeholder.jpeg");
                        },
                        imageErrorBuilder: (context, error, stackTrace) {
                          return const Image(
                            image: AssetImage("assets/images/404_eye.png"),
                          );
                        },
                        placeholder: const AssetImage("assets/images/ps5-placeholder.jpeg"),
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          _providedTrendingGame.titleImageURL,
                        ),
                      ),
                    ),
                    // ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          width: double.infinity,
                          child: SelectableText(
                            _providedTrendingGame.description,
                            textAlign: TextAlign.center,
                            //softWrap: true,
                            style: TextStyle(fontSize: (isDarkMode) ? 15 : 16.5),
                            //softWrap parameter of Text -> true: wrap to newLine if there's no more page
                          ),
                        ),
                        //modify constraints of this!!!
                        const SizedBox(
                          height: 10,
                        ),
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
                                      ? Colors.black87
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
                                      hideStatusBar: false,
                                      backgroundColor: Colors.black54,
                                      context: context,
                                      children: _images,
                                      initialIndex: _currentImageIndex,
                                      onSwipe: (index) {
                                        setState(() {
                                          _currentImageIndex = index;
                                        });
                                      },
                                    ).show();
                                  },
                                  child: CarouselSlider(
                                    options: CarouselOptions(
                                      initialPage: _currentImageIndex,
                                      aspectRatio: 16 / 9,
                                      enableInfiniteScroll:
                                          (_providedTrendingGame.imageURLs.length > 2)
                                              ? true
                                              : false,
                                      autoPlay: true,
                                      autoPlayInterval: const Duration(seconds: 4),
                                      autoPlayAnimationDuration: const Duration(milliseconds: 350),
                                      enlargeCenterPage: true,
                                      autoPlayCurve: Curves.fastOutSlowIn,
                                      scrollDirection: scrollDirection,
                                      onPageChanged: (index, carouselPageChangedReason) {
                                        _currentImageIndex = index;
                                      },
                                    ),
                                    items: _carouselImages,
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
                        if (_providedTrendingGame.longDescription != null)
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 0, 0, 20),
                            //padding: const EdgeInsets.fromLTRB(20, 0, 0, 20),
                            width: double.infinity,
                            child: (_firstParagraphLastIndex == -1) //doesn't have a newline
                                ? SelectableText(
                                    _providedTrendingGame.longDescription!,
                                    textAlign: (_providedTrendingGame.longDescription!.length < 100)
                                        ? TextAlign.center
                                        : TextAlign.start,
                                  )
                                : SelectableText(
                                    detailedDescription!.substring(
                                      0,
                                      _firstParagraphLastIndex,
                                    ),
                                    textAlign: (_providedTrendingGame.longDescription!.length < 100)
                                        ? TextAlign.center
                                        : TextAlign.start,
                                    style: TextStyle(
                                        fontSize: (isDarkMode) ? 21 : 23,
                                        fontWeight: (isDarkMode) ? null : FontWeight.bold,
                                        fontStyle: FontStyle.italic),
                                  ),
                          ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (_providedTrendingGame.longDescription != null)
                          Container(
                            //padding: const EdgeInsets.fromLTRB(20, 0, 0, 20),
                            margin: const EdgeInsets.fromLTRB(20, 0, 0, 20),
                            width: double.infinity,
                            child: (_firstParagraphLastIndex == -1)
                                ? null
                                : SelectableText(
                                    detailedDescription!.substring(_firstParagraphLastIndex),
                                    style: TextStyle(fontSize: (isDarkMode) ? 15 : 17),
                                    textAlign: (_providedTrendingGame.longDescription!.length < 100)
                                        ? TextAlign.center
                                        : TextAlign.start,
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
}
