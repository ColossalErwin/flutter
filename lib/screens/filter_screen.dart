//packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//providers
import '../providers/user_preferences.dart';
//helpers
import '../helpers/custom_route.dart';
//widgets
import '../widgets/app_drawer.dart';
//screens
import './games_overview_screen.dart';

class FilterScreen extends StatefulWidget {
  /*  static const routeName = '/meal-item';*/
  static const routeName = "/filter";
  //final Function saveFilters;
  //final Map<String, bool> filters;
  const FilterScreen({
    Key? key,
    /*required this.filters, required this.saveFilters*/
  }) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  //variables with logics related to each other will be grouped

/*
  bool _showThisYearBacklogOnly = false;
  bool _showLastYearBacklogOnly = false;

  bool _showDislikeds = false;

  bool _removeAfter30Days = true;
  bool _showTips = true;
  */
  @override
  void initState() {
    /*
    _showBacklogOnly = widget.filters['isGlutenFree'] as bool;
    _showHaveNotFinishedOnly = widget.filters['isLactoseFree'] as bool;
    _showFavoritesOnly = widget.filters['isVegetarian'] as bool;
    _showThisYearBacklog = widget.filters['isVegan'] as bool;
    _showLastYearBacklogOnly = widget.filters['hideDisliked'] as bool;
    */
    super.initState();
  }

  SwitchListTile _switchListTileBuilder({
    Color? color,
    required String title,
    required String subtitle,
    required bool value,
    required Function updateValueFunction,
  }) {
    return SwitchListTile.adaptive(
      activeColor: (color == null) ? Colors.green : color,
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: updateValueFunction as void Function(bool)?,
    );
  }

  @override
  Widget build(BuildContext context) {
    var userPreferences = Provider.of<UserPreferences>(context, listen: false);
    var filters = userPreferences.myCollectionFilters;
    /*
    if (filters.isEmpty) {
      Future.delayed(const Duration(seconds: 1)).then((_) async {
        await Provider.of<UserPreferences>(context, listen: false).fetchFilters();
      });
    }
    if (filters.isEmpty) {
      filters = Provider.of<UserPreferences>(context, listen: false).myCollectionFilters;
    }
    */

    print("build filters screen");
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(child: Text("Filters")),
        actions: [
          IconButton(
            tooltip: "Save changes and exit",
            onPressed: () {
              /*
              final Map<String, bool> userSelectedfilters = {
                'isGlutenFree': _showBacklogOnly,
                'isLactoseFree': _showHaveNotFinishedOnly,
                'isVegetarian': _showFavoritesOnly,
                'isVegan': _showThisYearBacklog,
                'hideDisliked': _showLastYearBacklogOnly,
              };
              */
              //widget.saveFilters(userSelectedfilters);
              while (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              Navigator.of(context).push(
                CustomRoute(
                  builder: (context) => const GamesOverviewScreen(),
                ),
              );
            },
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      //for some reason cannot use SingleChildScrollView
      //so use CustomScrollView
      //see: https://stackoverflow.com/questions/56326005/how-to-use-expanded-in-singlechildscrollview
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: true, //this is the default value, just pass here so we know
            //if false then nothing would be seen
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: const Text(
                    "Adjust your filtering preference",
                    style: TextStyle(fontSize: 17),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _switchListTileBuilder(
                        title: "Backlog Only",
                        subtitle: "Showing games that you have not played.",
                        value: filters['showBacklog']!,
                        updateValueFunction: (boolValue) {
                          setState(() {
                            userPreferences.toggleShowBacklog();
                          });
                        },
                      ),
                      _switchListTileBuilder(
                        title: "Another Chance",
                        subtitle: "Showing games that you have played but have not finished.",
                        value: filters['showHaveNotFinished']!,
                        updateValueFunction: (boolValue) {
                          setState(() {
                            userPreferences.toggleShowHaveNotFinished();
                          });
                        },
                      ),
                      _switchListTileBuilder(
                        title: "I am amazing",
                        subtitle: "Showing games that you have played but have not finished.",
                        value: filters['showFinished']!,
                        updateValueFunction: (boolValue) {
                          setState(() {
                            userPreferences.toggleShowFinished();
                          });
                        },
                      ),
                      _switchListTileBuilder(
                        color: Colors.blue,
                        title: "My Collection",
                        subtitle:
                            "Showing all games, but will not show disliked games if \"Hide-Dislikeds\" mode is activated. If show all is switched off from showing-all-games mode, then instead of not displaying anything, the default mode will be shown which feature your backlog as well as games you have not finished.",
                        value: filters['showAll']!,
                        updateValueFunction: (boolValue) {
                          setState(() {
                            userPreferences.toggleShowAll();
                          });
                        },
                      ),
                      const Divider(),
                      _switchListTileBuilder(
                        color: Colors.orange,
                        title: "Hide Dislikeds",
                        subtitle:
                            "Not showing games that are marked as disliked.", //only available for trending games
                        value: filters['hideDislikeds']!,
                        updateValueFunction: (boolValue) {
                          setState(() {
                            userPreferences.toggleHideDislikeds();
                          });
                        },
                      ),
                      //const Divider(),
                      /*
                      _switchListTileBuilder(
                        "This Year",
                        "Showing games that you have ",
                        _showThisYearBacklogOnly,
                        (boolValue) {
                          setState(() {
                            _showThisYearBacklogOnly = boolValue;
                          });
                        },
                      ),
                      _switchListTileBuilder(
                        "Last Year",
                        "Only show games that you have added last year.",
                        _showLastYearBacklogOnly,
                        (boolValue) {
                          setState(() {
                            _showLastYearBacklogOnly = boolValue;
                          });
                        },
                      ),
                      _switchListTileBuilder(
                        "Remove after 30 days",
                        "Your games in the trash folder will be removed after 30 days.",
                        _removeAfter30Days,
                        (boolValue) {
                          setState(() {
                            _removeAfter30Days = boolValue;
                          });
                        },
                      ),
                      _switchListTileBuilder(
                        "Unfamilliar?",
                        "Show tips and hints to provide user a good experience.",
                        _showTips,
                        (boolValue) {
                          setState(() {
                            _showTips = boolValue;
                          });
                        },
                      ),
                      */
                      /*
                      ListTile(
                        leading: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.grey[700],
                          ),
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              CustomRoute(
                                builder: (context) => const GamesOverviewScreen(),
                              ),
                              (route) => route.isFirst,
                            );
                          },
                          child: const Text("Cancel"),
                        ),
                        trailing: ElevatedButton.icon(
                          icon: const Icon(Icons.save_sharp),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.grey[700],
                          ),
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              CustomRoute(
                                builder: (context) => const GamesOverviewScreen(),
                              ),
                              (route) => route.isFirst,
                            );
                          },
                          label: const Text("Apply"),
                        ),
                      ),
                      */
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
