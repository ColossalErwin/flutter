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

  @override
  void initState() {
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

    print("build filters screen");
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(child: Text("Filters")),
        actions: [
          IconButton(
            tooltip: "Save changes and exit",
            onPressed: () {
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
      //cannot use SingleChildScrollView here
      //use CustomScrollView
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
