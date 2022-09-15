/*
════════ Exception caught by gesture ═══════════════════════════════════════════
setState() called after dispose(): _GamesOverviewScreenState#0bcc4(lifecycle state: defunct, not mounted)
════════════════════════════════════════════════════════════════════════════════

*/
//Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//helpers
import '../helpers/custom_search_delegate.dart';
//providers
import '../providers/user_preferences.dart';
import '../providers/games.dart';
//widgets
import '../widgets/user_info.dart';
import '../widgets/app_drawer.dart';
import '../widgets/games_grid.dart';
import '../widgets/floating_button/draggable_floating_action_button.dart';
//screens
import './edit_game_screen/edit_game_screen.dart';
import './game_category_screen.dart';
//temp data
import '../temp_data/user_info.dart' as user_info;
import '../temp_data/temp_data.dart' as temp_data;

class GamesOverviewScreen extends StatefulWidget {
  const GamesOverviewScreen({Key? key}) : super(key: key);
  static const routeName = "games-overview";

  @override
  State<GamesOverviewScreen> createState() => _GamesOverviewScreenState();
}

class _GamesOverviewScreenState extends State<GamesOverviewScreen> {
  String? _userImageURL;
  String? _userName = "";
  String? _userEmail = "";
  //bool isLoadingImage = false;

  late List<Map<String, Object>> _pages;

  //bool _isFetchingData = false;

  //remember to add this check (_isDidChangeDependencies) or we could go to an infinite loop
  //due to loading provider
  //also limit the use of using Provider.of<class with ChangeNotifier>(context) in build method
  //since it can potentially lead to an infinite loop too
  bool _isDidChangeDependencies = false;
  //this flag is super important to avoid infinite loop while using provider

  late Map<String, bool> _myCollectionFilters;
  late UserPreferences _myFilters;
  //bool _isLoading = false;

  //see how to use FutureBuilder instead of didChangeDependencies in TrendingGamesScreen

  //late final bool _isAndroid;

  @override
  void didChangeDependencies() {
    _myFilters = Provider.of<UserPreferences>(context);
    _myCollectionFilters = _myFilters.myCollectionFilters;
    if (_isDidChangeDependencies == false) {
      try {
        if (temp_data.isFetchUserGames == false) {
          Future.delayed(const Duration(
                  seconds: 1, milliseconds: 750)) //around 1.5 miliseconds to 2 seconds
              //else if filter is not empty, then data could be partially fetched, so we should wait a bit
              .then((_) async {
            await Provider.of<Games>(context, listen: false).fetchGames(GamesOption.userGames);
            print("Fetching User's Games successfully");
          });
          temp_data.isFetchUserGames = true;
        }
      } catch (error) {
        print(error);
      }

      _pages = [
        {
          'page': const GamesGrid(showFavoritesOnly: false),
          'title': "My Collection",
        },

        {
          'page': const GamesCategoryScreen(), //with of course favorite to true
          'title': "Genres",
        },
        //should have another one for wish list?
        {
          'page': const GamesGrid(showFavoritesOnly: true), //with of course favorite to true
          'title': "My Favorites",
        },
      ];
    }
    _isDidChangeDependencies = true;

    //the else case is kinda redundant since we already load user info at main (app launch)
    if (user_info.hasLoadedCredential) {
      print("case1");
      _userImageURL = user_info.userImageURL;
      _userName = user_info.username;
    } else {
      Future.delayed(const Duration(seconds: 2)).then(
        (_) async {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get()
              .then((document) {
            setState(() {
              try {
                _userName = document['username'];
                user_info.username = _userName;
                _userEmail = document['email'];
                user_info.userEmail = _userEmail;
                user_info.hasLoadedCredential = true;
                _userImageURL = document['image_url'];
                //image might not be there if we signing up
                //so better use try catch with at least 2 seconds
                user_info.userImageURL = _userImageURL;
              } catch (e) {
                print(e);
              }
            });
          });
        },
      );
    }

    super.didChangeDependencies();
  }

  int _selectedPageIndex = 0;
  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    print("build games overview screen");
    //appBarWidget should be built here, not in didChangeDependencies since it wouldn't load the user avatar there
    final PreferredSizeWidget appBarWidget = appBarBuilder();
    //final MediaQueryData mediaQueryData = MediaQuery.of(context);
    //final bool isPortrait = mediaQueryData.orientation == Orientation.portrait;
    /*
      print(mediaQueryData.size.height -
      mediaQueryData.padding.top -
      mediaQueryData.padding.bottom -
      appBarWidget.preferredSize.height -
      kBottomNavigationBarHeight);
    */

    //kBottomNavigationBarHeight is the default height of bottom navigation bar

    //remember to add this check didChangeDependencies (_isDidChangeDependencies) or we could go to an infinite loop
    //due to loading provider
    //also limit the use of using Provider.of<class with ChangeNotifier>(context) in build method
    //since it can potentially lead to an infinite loop too

    final GlobalKey parentKey = GlobalKey();
    //print("build from GamesOverViewScreen");
    /*
    setState(() {
      _userImageURLFuture!.then((val) {
        _userImageURL = val;
      });
    });
    */
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Stack(
          key: parentKey,
          children: [
            Scaffold(
              appBar: appBarWidget,
              drawer: const AppDrawer(),
              body: SafeArea(
                child: _pages[_selectedPageIndex]['page'] as Widget,
              ),
              bottomNavigationBar: BottomNavigationBar(
                onTap: _selectPage,
                //backgroundColor: //Theme.of(context).colorScheme.primary,
                backgroundColor:
                    (isDarkMode) ? Colors.black : Theme.of(context).colorScheme.primary,
                selectedItemColor: (isDarkMode) ? Colors.white : Colors.black,
                unselectedItemColor: (isDarkMode) ? Colors.white38 : Colors.white,
                currentIndex: _selectedPageIndex,
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    icon: const Icon(Icons.home),
                    label: "My Games",
                    tooltip: "My Games Collection",
                  ),
                  BottomNavigationBarItem(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    icon: const Icon(Icons.category),
                    label: "Genres",
                    tooltip: "Filter By Genres",
                  ),
                  BottomNavigationBarItem(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    icon: const Icon(Icons.star_border_outlined),
                    label: "My Favorites",
                    tooltip: "My Favorites",
                  ),
                ],
              ),
            ),
            //if (isPortrait)
            draggableFloatingActionButtonBuilder(
              context: context,
              parentKey: parentKey,
              tooltip: "Add a game to your backlog",
              icon: const Icon(Icons.playlist_add),
              handler: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  EditGameScreen.routeName,
                  arguments: {
                    'returnRouteName': GamesOverviewScreen.routeName,
                  },
                  (route) => route.isFirst,
                );
              },
              iconColor: Colors.black,
              backgroundColor: Colors.blue.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }

  void _recursiveShowFiltersMenu() {
    //show menu for selectedPageIndex = 0, which is the overview screen
    //the favorite screen should only have show finished and show have not finished
    //since we only have good experience with games that we have played
    //also should create another map for this
    //maybe we should create an array in the database for filters
    //data type is
    //array of Map<String, bool>, sounds like a good idea? maybe not
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1, 0, 0, 0),
      items: [
        PopupMenuItem<int>(
          value: 0,
          child: SwitchListTile.adaptive(
            activeColor: Colors.green,
            title: const FittedBox(child: Text("My Backlog ¯\\_(ツ)_/¯")),
            //backlog also includes played but not finished and have not played
            subtitle: const Text("Show games that you haven't played"),
            value: _myCollectionFilters['showBacklog']!,
            onChanged: (boolValue) async {
              await _myFilters.toggleShowBacklog();
              //could use consumer instead of setState since setState would rebuild the whole widget
              //consumer only rebuild what is needed since it listen to change notifier

              //no need to use backlogFilter setState for show menu, but we might need it to update the whole widget
              setState(() {
                //_isLoading = true;
                temp_data.isFetchUserGames = false;
                _isDidChangeDependencies = false;
              });
              if (!mounted) return;
              //don't forget to pop the menu or else these menus would stack upon each other
              Navigator.of(context).pop();
              _recursiveShowFiltersMenu();

              /*
              The reason we use a recursive function in this case is because showMenu wouldn't update to a new Menu
              so even if we click on the switch, it wouldn't show
              by using a recursive function, another Menu would appear to replace this one
              The recursive call only happen when there is change to the boolValue
              it could be on a nonterminated while loop, but that while loop is 'on hold'
              don't forget to pop the menu or else these menus would stack upon each other
              */
            },
          ),
        ),
        PopupMenuItem<int>(
          value: 1,
          child: SwitchListTile.adaptive(
            activeColor: Colors.green,
            title: const Text("Another Chance?"),
            subtitle: const Text("Show games that you have played but have not finished."),
            value: _myCollectionFilters['showHaveNotFinished']!,
            onChanged: (boolValue) async {
              await _myFilters.toggleShowHaveNotFinished();
              setState(() {
                //_isLoading = true;
                temp_data.isFetchUserGames = false;
                _isDidChangeDependencies = false;
              });
              if (!mounted) return;
              Navigator.of(context).pop();
              _recursiveShowFiltersMenu();
            },
          ),
        ),
        PopupMenuItem<int>(
          value: 2,
          child: SwitchListTile.adaptive(
            activeColor: Colors.green,
            title: const Text("I'm amazing"),
            subtitle: const Text("Show games that you have finished."),
            value: _myCollectionFilters['showFinished']!,
            onChanged: (boolValue) async {
              await _myFilters.toggleShowFinished();
              setState(() {
                // _isLoading = true;
                temp_data.isFetchUserGames = false;
                _isDidChangeDependencies = false;
              });
              if (!mounted) return;
              Navigator.of(context).pop();
              _recursiveShowFiltersMenu();
            },
          ),
        ),
        PopupMenuItem<int>(
          value: 3,
          child: SwitchListTile.adaptive(
            activeColor: Colors.blue,
            title: const Text("My Collection"),
            subtitle: const Text(
                "Show all games except disliked games if \"Hide-Dislikeds\" mode is on."),
            value: _myCollectionFilters['showAll']!,
            onChanged: (boolValue) async {
              await _myFilters.toggleShowAll();
              setState(() {
                // _isLoading = true;
                temp_data.isFetchUserGames = false;
                _isDidChangeDependencies = false;
              });
              if (!mounted) return;
              Navigator.of(context).pop();
              _recursiveShowFiltersMenu();
            },
          ),
        ),
        if (_selectedPageIndex == 0)
          PopupMenuItem<int>(
            value: 4,
            child: SwitchListTile.adaptive(
              activeColor: Colors.amber,
              title: const Text("Hide Dislikeds"),
              subtitle: const Text("Hide games that are marked as dislikeds."),
              value: _myCollectionFilters['hideDislikeds']!,
              onChanged: (boolValue) async {
                await _myFilters.toggleHideDislikeds();
                setState(() {
                  // _isLoading = true;
                  temp_data.isFetchUserGames = false;
                  _isDidChangeDependencies = false;
                });
                if (!mounted) return;
                Navigator.of(context).pop();
                _recursiveShowFiltersMenu();
              },
            ),
          ),
      ],
    );
  }

  PreferredSizeWidget appBarBuilder() {
    return AppBar(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black87 : null,
      title: FittedBox(child: Text(_pages[_selectedPageIndex]['title'] as String)),
      actions: [
        if (_selectedPageIndex == 0 || _selectedPageIndex == 2)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(
                    games: (_selectedPageIndex == 0)
                        ? Provider.of<Games>(context, listen: false).games
                        : Provider.of<Games>(context, listen: false).favoriteGames),
              );
            },
          ),
        if (_selectedPageIndex == 0 || _selectedPageIndex == 2)
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(1, 0, 0, 0),
                items: [
                  PopupMenuItem<int>(
                    value: 0,
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        icon: const Icon(Icons.filter_alt_outlined),
                        label: const Text("Filters"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _recursiveShowFiltersMenu();
                        },
                      ),
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_month),
                        label: const Text("Release year"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        UserInformation(
          _userName,
          _userImageURL,
          //isFromHomePage: true,
          returnPageRouteName: GamesOverviewScreen.routeName,
        ),
      ],
    );
  }
}
