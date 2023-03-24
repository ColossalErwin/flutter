//packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//helpers
import '../helpers/custom_route.dart';
//providers
import '../providers/user_preferences.dart';
import '../providers/games.dart';
//screens
import './games_overview_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  static const routeName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isInit = false;
  late bool _isDarkMode;
  late int _timeBeforeEmptyTrash;
  @override
  void didChangeDependencies() {
    if (_isInit == false) {
      _timeBeforeEmptyTrash = 30;
      _isDarkMode = Theme.of(context).brightness == Brightness.dark;
    }
    _isInit = true;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        actions: [
          IconButton(
            tooltip: "Save changes and exit",
            onPressed: () {
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
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Appearance:"),
                      ListTile(
                        //title: const FittedBox(child: Text("Appearance")),
                        leading: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: (_isDarkMode) ? null : const BorderSide(width: 2.5),
                          ),
                          icon: const Icon(
                            Icons.light_mode,
                            color: Colors.amber,
                          ),
                          label: const Text(
                            "Light Mode",
                            style: TextStyle(
                              color: Colors.amber,
                            ),
                          ),
                          onPressed: () async {
                            await Provider.of<UserPreferences>(context, listen: false)
                                .setThemeMode(Brightness.light, context);
                            /*
                            await Provider.of<UserPreferences>(context, listen: false)
                                .chooseBrightnessMode(Brightness.light);
                                */
                            setState(() {
                              _isDarkMode = false;
                            });
                          },
                        ),
                        trailing: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: (_isDarkMode)
                                ? const BorderSide(
                                    width: 2.5,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          icon: const Icon(
                            Icons.dark_mode,
                            color: Color.fromARGB(255, 62, 137, 174),
                          ),
                          label: const Text(
                            "Dark Mode",
                            style: TextStyle(
                              color: Color.fromARGB(255, 62, 137, 174),
                            ),
                          ),
                          onPressed: () async {
                            await Provider.of<UserPreferences>(context, listen: false)
                                .setThemeMode(Brightness.dark, context);
                            /*
                            await Provider.of<UserPreferences>(context, listen: false)
                                .chooseBrightnessMode(Brightness.dark);
                                */
                            setState(() {
                              _isDarkMode = true;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Time before emptying trash:"),
                      RadioListTile(
                        activeColor: Theme.of(context).colorScheme.primary,
                        title: const Text('30 days'),
                        value: 30,
                        groupValue: _timeBeforeEmptyTrash,
                        onChanged: (value) async {
                          setState(() {
                            _timeBeforeEmptyTrash = value as int;
                          });
                          await Provider.of<Games>(context, listen: false)
                              .setTimeBeforeEmptyTrash(_timeBeforeEmptyTrash, context);
                        },
                      ),
                      RadioListTile(
                        activeColor: Theme.of(context).colorScheme.primary,
                        title: const Text('3 months'),
                        value: 90,
                        groupValue: _timeBeforeEmptyTrash,
                        onChanged: (value) async {
                          setState(() {
                            _timeBeforeEmptyTrash = value as int;
                          });
                          await Provider.of<Games>(context, listen: false)
                              .setTimeBeforeEmptyTrash(_timeBeforeEmptyTrash, context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
