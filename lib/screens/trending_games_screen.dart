//trending games screen should have refresh feature since the developer updates info on this side

//Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//helpers
import '../helpers/custom_search_delegate_for_trending_games.dart';
//providers
import '../providers/games.dart';
//widgets
import '../widgets/app_drawer.dart';
import '../widgets/trending_games_grid.dart';
import '../widgets/user_info.dart';
//temp data
import '../temp_data/user_info.dart' as user_info;
/*
enum SelectedTrendingPage {
  all,
  wishlist,
}
*/

class TrendingGamesScreen extends StatefulWidget {
  //final SelectedTrendingPage? selectedTrendingPage;
  const TrendingGamesScreen({Key? key}) : super(key: key);
  static const routeName = '/trending-games';
  @override
  State<TrendingGamesScreen> createState() => _TrendingGamesScreenState();
}

class _TrendingGamesScreenState extends State<TrendingGamesScreen> {
  String? _userImageURL;
  String? _userName = "";
  //bool isLoadingImage = false;

  late List<Map<String, Object>> _pages;

  //bool _isFetchingData = false;

//remember to add this check didChangeDependencies (_isDidChangeDependencies) or we could go to an infinite loop
//due to loading provider
//also limit the use of using Provider.of<class with ChangeNotifier>(context) in build method
//since it can potentially lead to an infinite loop too
  bool _didChangeDependencies = false;

  int _selectedPageIndex = 0; //0 is All Trending Games page, 1 is Wishlist page
  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  void didChangeDependencies() {
    if (_didChangeDependencies == false) {
      final modalRoute = ModalRoute.of(context);
      if (modalRoute != null) {
        final args = modalRoute.settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          _selectedPageIndex = args['selectedPageIndex'];
        }
      }
      //since we use FutureBuilder there's no need to fetch data again

      Future.delayed(const Duration(seconds: 0)).then((_) async {
        //Provider.of<Games>(context, listen: false).reset();
        //maybe fetch both trending games and wishlist games is better
        //so that we can check if a game is in _wishlist locally
        /*
        await Provider.of<Games>(context, listen: false).fetchGames(
            (_selectedPageIndex == 0) ? GamesOption.trendingGames : GamesOption.wishlistGames);*/
        await Provider.of<Games>(context, listen: false).fetchGames((GamesOption.trendingGames));
        if (!mounted) return;
        await Provider.of<Games>(context, listen: false).fetchGames((GamesOption.wishlistGames));
      });
      if (user_info.userImageURL != null) {
        _userImageURL = user_info.userImageURL;
        _userName = user_info.username;
      } else {
        Future.delayed(const Duration(seconds: 1)).then(
          (_) async {
            await FirebaseFirestore.instance
                .collection("users")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get()
                .then((document) {
              setState(() {
                _userImageURL = document['image_url'];
                user_info.userImageURL = _userImageURL;
                _userName = document['username'];
                user_info.username = _userName;
              });
            });
          },
        );
      }

      _pages = [
        {
          'page': const TrendingGamesGrid(showWishlistOnly: false),
          'title': "Trending Games",
        },
        {
          'page': const TrendingGamesGrid(showWishlistOnly: true), //with of course favorite to true
          'title': "My Wishlist",
        },
      ];
    }

    _didChangeDependencies = true;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    print("build trending games screen");
    //remember to add this check didChangeDependencies (_isDidChangeDependencies) or we could go to an infinite loop
    //due to loading provider
    //also limit the use of using Provider.of<class with ChangeNotifier>(context) in build method
    //since it can potentially lead to an infinite loop too

    //bool backlogFilter = false;
    //There are two approaches to the fetchAndSetGames function
    //in this case we don't use it in initState/didChangeDependencies
    //but rather in a FutureBuilder
    //since fetchAndSetGames is a future
    //by using FutureBuilder we don't have to use delayed in didChangeDependencies since we can simply use an async function

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: FittedBox(child: Text(_pages[_selectedPageIndex]['title'] as String)),
          actions: [
            /*
            IconButton(
              tooltip: "Filters",
              icon: const Icon(Icons.filter_list_outlined),
              onPressed: () {
                //_recursiveShowMenuIndex0();
              },
            ),
            */
            IconButton(
              tooltip: "Search",
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegateForTrendingGames(
                    games: Provider.of<Games>(context, listen: false).trendingGames,
                  ),
                );
              },
            ),
            UserInformation(
              _userName,
              _userImageURL,
              returnPageRouteName: TrendingGamesScreen.routeName,
            ),
          ],
        ),
        body: _pages[_selectedPageIndex]['page'] as Widget,
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
              icon: const Icon(Icons.home),
              label: "Trending Games",
              tooltip: "All Trending Games",
            ),
            BottomNavigationBarItem(
              backgroundColor: Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.favorite_border_outlined),
              label: "Wishlist",
              tooltip: "My Wishlist Games",
            ),
          ],
        ),
      ),
    );
  }
}
