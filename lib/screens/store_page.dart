import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taskmanagement/data/database.dart';
import 'package:taskmanagement/model/theme_model.dart';
import 'package:taskmanagement/themes/theme_provider.dart';
import 'package:taskmanagement/widgets/store_item_card.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  Currency db = Currency();
  final _box2 = Hive.box("box2"); // for currency
  final _box3 = Hive.box("box3"); // for theme data persistence

  @override
  void initState() {
    super.initState();

    // Load saved current theme and apply
    String savedTheme = _box3.get("CURRENT_THEME", defaultValue: "Blue");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeModel = Provider.of<ThemeModel>(context, listen: false);
      themeModel.currentThemeName = savedTheme;

      // Load bought themes list from box3
      List<dynamic>? savedBought = _box3.get("BOUGHT_THEMES");
      if (savedBought != null) {
        themeModel.boughtThemes = Set<String>.from(savedBought);
      } else {
        themeModel.boughtThemes = {'Blue'}; // default bought theme
      }

      // Apply saved theme
      _applyThemeByName(savedTheme);

      themeModel.notifyListeners();
    });
  }

  void _applyThemeByName(String themeName) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    switch (themeName) {
      case 'Blue':
        themeProvider.toggleLightTheme();
        break;
      case 'Dark':
        themeProvider.toggleDarkTheme();
        break;
      case 'Purple':
        themeProvider.togglePurpleTheme();
        break;
      case 'Green':
        themeProvider.toggleGreenTheme();
        break;
      case 'Red':
        Provider.of<ThemeProvider>(context, listen: false).toggleRedTheme();
        break;
      case 'Pink':
        Provider.of<ThemeProvider>(context, listen: false).togglePinkTheme();
        break;
      default:
        themeProvider.toggleLightTheme(); // fallback if something went wrong
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add a gradient background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.secondary.withOpacity(0.12),
              Theme.of(context).colorScheme.primary.withOpacity(0.07),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(),
            Padding(
              padding: const EdgeInsets.only(top: 18.0, left: 18, right: 18, bottom: 8),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.palette_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Theme Shop",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.shade200,
                          Colors.amber.shade100,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.18),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.attach_money_rounded, color: Color.fromARGB(255, 230, 174, 4)),
                        const SizedBox(width: 2),
                        ValueListenableBuilder(
                          valueListenable: _box2.listenable(),
                          builder: (context, box, _) {
                            final amount = box.get("CURRENCY", defaultValue: 0);
                            return Text(
                              amount.toString(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown[800],
                                shadows: [
                                  Shadow(
                                    color: Colors.amber.withOpacity(0.3),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(thickness: 1.2, color: Colors.grey.shade300, indent: 18, endIndent: 18),
            const SizedBox(height: 10),
            Expanded(
              child: Consumer<ThemeModel>(
                builder: (context, value, child) {
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 22,
                      crossAxisSpacing: 22,
                      childAspectRatio: 0.80,
                    ),
                    itemCount: value.themeItems.length,
                    itemBuilder: (context, index) {
                      final theme = value.themeItems[index];
                      final themeName = theme[0];
                      final themePrice = int.tryParse(theme[1]) ?? 0;
                      final imagePath = theme[2];
                      final isBought = value.isThemeBought(themeName);
                      final isSelected = value.currentThemeName == themeName;

                      // Fade-in animation for each card
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 400 + index * 80),
                        builder: (context, opacity, child) {
                          return Opacity(
                            opacity: opacity,
                            child: child,
                          );
                        },
                        child: StoreItemCard(
                          themeName: themeName,
                          themePrice: themePrice.toString(),
                          imagePath: imagePath,
                          isBought: isBought,
                          isSelected: isSelected,
                          onBuy: () {
                            final currentCurrency = _box2.get("CURRENCY", defaultValue: 0);
                            if (currentCurrency >= themePrice) {
                              setState(() {
                                value.buyTheme(themeName);
                                _box2.put("CURRENCY", currentCurrency - themePrice);

                                // Save bought themes set as List<String> to Hive
                                _box3.put("BOUGHT_THEMES", value.boughtThemes.toList());

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: const [
                                        Icon(Icons.check_circle, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          "Purchase successful!",
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.lightGreen,
                                  ),
                                );
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: const [
                                      Icon(Icons.warning_amber_rounded, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text("Not enough currency!"),
                                    ],
                                  ),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          },
                          onUse: () {
                            setState(() {
                              value.selectTheme(themeName);

                              // Save current theme in Hive
                              _box3.put("CURRENT_THEME", themeName);

                              // Apply the selected theme
                              _applyThemeByName(themeName);
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Make the app bar a widget (not a real AppBar) for more flexibility
  Widget _buildAppBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 26, color: Theme.of(context).colorScheme.primary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}