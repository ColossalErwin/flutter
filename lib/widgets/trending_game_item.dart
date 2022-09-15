import 'dart:math';
//packages
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
//helpers
import '../helpers/custom_route.dart';
//providers
import '../providers/game.dart';
import '../providers/games.dart';
//screens
import '../screens/trending_game_detail_screen.dart';

//have to convert this to a Stateful widget just for the sake of wishlist function
//it was fine using stateless since we have Consumer
//but for this particular case with wishlist algorithm (working with asynchronous function, not fetching but checking, so another step)
//we have to use stateful
class TrendingGameItem extends StatefulWidget {
  //final TrendingGamesGridOption option;
  const TrendingGameItem({
    Key? key,
    //this.option = TrendingGamesGridOption.one,
  }) : super(key: key);

  @override
  State<TrendingGameItem> createState() => _TrendingGameItemState();
}

class _TrendingGameItemState extends State<TrendingGameItem> {
  late DateTime? _releaseDate;
  late Game _providedTrendingGame;
  bool _isInWishlist = false;
  late bool _hasReleased;
  final List<Widget> _images = [];
  //must set here since initialization of _isInWishlist depends on asynchronous code
  //if we don't set it here then it would go through the asynchronous function without being initialized
  //at the very begininning, the favorite icon would be favorite_border, but then if returnValue is true
  //then setState is called to make the icon favorite (full)
  @override
  void didChangeDependencies() {
    _providedTrendingGame = Provider.of<Game>(context, listen: false);
    _isInWishlist =
        Provider.of<Games>(context, listen: false).isInWishlist(_providedTrendingGame.id);

    _releaseDate = (_providedTrendingGame.releaseDate == null)
        ? null
        : _providedTrendingGame.releaseDate!.toDate();
    _hasReleased = (_providedTrendingGame.releaseDate == null)
        ? false
        : _releaseDate!.isBefore(DateTime.now());
    int counter = 0;
    for (String url in _providedTrendingGame.imageURLs) {
      _images.add(
        Hero(
          tag: '$counter ${_providedTrendingGame.id} trending carousel',
          child: Image.network(
            url,
            errorBuilder: (context, error, stackTrace) {
              return const Image(
                image: AssetImage("assets/images/404_eye.png"),
              );
            },
          ),
        ),
      );
      counter++;
    }

    super.didChangeDependencies();
  }

  int _currentImageIndex = 0;
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    _currentImageIndex = Random().nextInt(_providedTrendingGame.imageURLs.length);
    print("build trending game item");


    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              backgroundBlendMode: BlendMode.colorDodge,
              //color: const Color.fromARGB(255, 228, 228, 228),
              color: Colors.black,
              border: Border.all(
                color: Colors.black,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            width: double.infinity,
            height: constraints.maxHeight * 0.95,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      CustomRoute(
                        builder: (context) => TrendingGameDetailScreen(
                          trendingGameID: _providedTrendingGame.id,
                          imageIndex: _currentImageIndex,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      //color: Color.fromARGB(255, 132, 166, 217),
                      color:
                          (isDarkMode) ? Colors.black26 : const Color.fromARGB(255, 186, 200, 232),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.black,
                        width: 0.5,
                      ),
                    ),
                    //Colors.black38,
                    width: double.infinity,
                    child: Text(
                      _providedTrendingGame.title,
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600,
                        //color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                if (isPortrait)
                  Flexible(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: double.infinity,
                        height: constraints.maxWidth / 2,
                        decoration: BoxDecoration(
                          color: (isDarkMode)
                              ? Colors.black87
                              : const Color.fromARGB(255, 228, 228, 228),
                          border: Border.all(
                            color: Colors.black,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          splashColor: Colors.amber.withOpacity(0.15),
                          onTap: () {
                            Navigator.of(context).push(
                              CustomRoute(
                                builder: (context) => TrendingGameDetailScreen(
                                  trendingGameID: _providedTrendingGame.id,
                                  imageIndex: _currentImageIndex,
                                ),
                              ),
                            );
                          },
                          child: CarouselSlider(
                            options: CarouselOptions(
                              initialPage: _currentImageIndex,
                              //Random().nextInt(_providedGame.imageURLs.length),
                              //random number from 0 up to length - 1
                              aspectRatio: 16 / 9,
                              enableInfiniteScroll:
                                  (_providedTrendingGame.imageURLs.length > 2) ? true : false,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 4),
                              autoPlayAnimationDuration: const Duration(milliseconds: 350),
                              enlargeCenterPage: true,
                              autoPlayCurve: Curves.fastOutSlowIn,
                              //scrollDirection: Axis.horizontal,
                              //height: ,

                              onPageChanged: (index, carouselPageChangedReason) {
                                _currentImageIndex = index;
                              },
                              //onScrolled: ,
                              //clipBehavior: Clip.none,
                            ),
                            items: _images,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: LayoutBuilder(builder: (ctx, constraints) {
                      return Flexible(
                        child: Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: Container(),
                            ),
                            Flexible(
                              flex: 10,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: double.infinity,
                                  height: constraints.maxWidth / 2,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 228, 228, 228),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 0.77,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: InkWell(
                                    splashColor: Colors.amber.withOpacity(0.15),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        CustomRoute(
                                          builder: (context) => TrendingGameDetailScreen(
                                            trendingGameID: _providedTrendingGame.id,
                                            imageIndex: _currentImageIndex,
                                          ),
                                        ),
                                      );
                                    },
                                    child: CarouselSlider(
                                      options: CarouselOptions(
                                        initialPage: _currentImageIndex,
                                        //Random().nextInt(_providedGame.imageURLs.length),
                                        //random number from 0 up to length - 1
                                        aspectRatio: 16 / 9,
                                        enableInfiniteScroll:
                                            (_providedTrendingGame.imageURLs.length > 2)
                                                ? true
                                                : false,
                                        autoPlay: true,
                                        autoPlayInterval: const Duration(seconds: 4),
                                        autoPlayAnimationDuration:
                                            const Duration(milliseconds: 350),
                                        enlargeCenterPage: true,
                                        autoPlayCurve: Curves.fastOutSlowIn,
                                        //scrollDirection: Axis.horizontal,

                                        onPageChanged: (index, carouselPageChangedReason) {
                                          _currentImageIndex = index;
                                        },
                                        //onScrolled: ,
                                        //clipBehavior: Clip.none,
                                      ),
                                      items: _images,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Container(),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                Container(
                  color: !isDarkMode ? Colors.white : null,
                  height: constraints.maxHeight / 4.5,
                  child: Consumer<Game>(
                    builder: (context, providedTrendingGame, child) {
                      return SelectableText(
                        providedTrendingGame.description,
                        //softWrap: true,
                        //overflow: TextOverflow.fade,
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    //backgroundBlendMode: BlendMode.colorDodge,
                    //color: Color.fromARGB(255, 146, 223, 226),
                    color: const Color.fromARGB(202, 0, 0, 0),
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (!_hasReleased)
                        const Flexible(
                          //flex: 1,
                          child: Icon(
                            Icons.calendar_month,
                            color: Colors.white,
                          ),
                        )
                      else
                        Flexible(
                          //flex: 1,
                          child: GestureDetector(
                            //must set here since initialization of _isInWishlist depends on asynchronous code
                            //if we don't set it here then it would go through the asynchronous function without being initialized
                            //at the very begininning, the favorite icon would be a border, but then if returnValue is true (different from isInWishList)
                            //then setState is called to make it right
                            onTap: () async {
                              Provider.of<Games>(context, listen: false).toggleWishlist(
                                  _providedTrendingGame,
                                  toggleOption: (_isInWishlist == false) ? true : false);
                              setState(() {
                                _isInWishlist = !_isInWishlist;
                                _providedTrendingGame.isFavorite =
                                    !_providedTrendingGame.isFavorite;
                              });
                            },
                            child: Icon(
                              _isInWishlist ? Icons.favorite : Icons.favorite_border,
                              color: Colors.red.withOpacity(0.8),
                            ),
                          ),
                        ),
                      if (_releaseDate != null && !_hasReleased)
                        Flexible(
                          //flex: 2,
                          child: Container(
                            alignment: Alignment.center,
                            //Colors.black38,
                            width: double.infinity,
                            child: FittedBox(
                              child: SelectableText(
                                DateFormat.yMMMMd().format(_releaseDate!), //(),
                                //softWrap: true,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                      else if (_releaseDate != null && _hasReleased)
                        Flexible(
                          //flex: 2,
                          child: Container(
                            alignment: Alignment.center,
                            //Colors.black38,
                            width: double.infinity,
                            child: FittedBox(
                              child: SelectableText(
                                "Released in ${DateFormat.y().format(_releaseDate!)}", //(),
                                //softWrap: true,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                      else
                        Flexible(
                          //flex: 2,
                          child: Container(
                            alignment: Alignment.center,
                            //Colors.black38,
                            width: double.infinity,
                            child: const FittedBox(
                              child: SelectableText(
                                "Release Date: TBA", //(),
                                //softWrap: true,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      if (!_hasReleased)
                        Flexible(
                          //flex: 1,
                          child: GestureDetector(
                            onTap: () async {
                              Provider.of<Games>(context, listen: false).toggleWishlist(
                                  _providedTrendingGame,
                                  toggleOption: (_isInWishlist == false) ? true : false);

                              setState(() {
                                _isInWishlist = !_isInWishlist;
                                _providedTrendingGame.isFavorite =
                                    !_providedTrendingGame.isFavorite;
                              });
                            },
                            child: Icon(
                              _isInWishlist ? Icons.favorite : Icons.favorite_border,
                              color: Colors.red.withOpacity(0.8),
                            ),
                          ),
                        )
                      else
                        Flexible(
                          child: GestureDetector(
                            onTap: () async {
                              //check if id is already in trending_game_ids
                              //add if it is not => show scaffold message
                              //if already is => show scaffold message saying: "This game is already in your backlog"
                              final bool hasAdded = await Provider.of<Games>(context, listen: false)
                                  .addTrendingGameToCollection(_providedTrendingGame, context);
                              if (!mounted) return;
                              if (hasAdded) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        "Successfully added ${_providedTrendingGame.title} to your collection.")));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        "${_providedTrendingGame.title} was not added to your collection.")));
                              }
                            },
                            child: const Icon(
                              Icons.playlist_add, //add_box or add_circle
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
