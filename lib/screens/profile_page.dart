import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskmanagement/screens/store_page.dart';
import 'package:taskmanagement/services/auth_service.dart';
import 'package:taskmanagement/themes/theme_provider.dart';
import 'package:taskmanagement/widgets/statistics_tile.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskmanagement/data/database.dart';
import 'package:provider/provider.dart';
import 'package:taskmanagement/model/theme_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Currency db = Currency();
  final _box2 = Hive.box("box2");

  // Initialize tasks completed hive box
  final TasksCompleted tasksCompleted = TasksCompleted();
  final _box3 = Hive.box("box3");

  // Initialize user stats hive box
  final UserStats userStats = UserStats();
  final _box4 = Hive.box("box4");

  @override
  void initState() {

    //first time opening app -> create default data
    if (_box2.get("CURRENCY") == null) { //means this is the first time opening the app (no data stored)
      db.createInitialData();
    }
    else {
      //data already exists
      db.loadCurrency();
    }

    if (_box4.get("XP") == null || _box4.get("LEVEL") == null) {
      userStats.createInitialData();
    }
    else {
      userStats.loadStats();
    }

    super.initState();
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
    final Color accentBarColor = Theme.of(context).colorScheme.primary;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Accent bar
                    Container(
                      width: 7,
                      decoration: BoxDecoration(
                        color: accentBarColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(18),
                            bottomRight: Radius.circular(18),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Profile picture
                              AuthService().getProfileImage(),
                              const SizedBox(height: 10),
                              // Email
                              Text(
                                FirebaseAuth.instance.currentUser?.displayName ?? "No Name",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                              // Level and XP
                              ValueListenableBuilder(
                                valueListenable: Hive.box('box4').listenable(),
                                builder: (context, Box box, _) {
                                  final int xp = box.get("XP", defaultValue: 0);
                                  final int level = box.get("LEVEL", defaultValue: 1);
                                  const int xpToLevelUp = 100;
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Text(
                                          "LEVEL $level",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).colorScheme.onSecondary,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                                        child: LinearProgressIndicator(
                                          value: xp / xpToLevelUp,
                                          backgroundColor: Colors.grey[300],
                                          color: Theme.of(context).colorScheme.primary,
                                          minHeight: 14,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      Text(
                                        "$xp / $xpToLevelUp XP",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Theme.of(context).colorScheme.onSecondary,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Statistics Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Statistics",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Statistics Tiles
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: StatisticsTile(
                                  label: "Tasks Completed",
                                  value: "${_box3.get("TASKS_COMPLETED", defaultValue: 0)}",
                                  icon: Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              Expanded(
                                child: StatisticsTile(
                                  label: "Currency",
                                  value: "${_box2.get("CURRENCY", defaultValue: 0)}",
                                  icon: Icons.monetization_on,
                                  imagePath: "assets/images/coin.png",
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: StatisticsTile(
                                  label: "Days Streak",
                                  value: "${_box3.get("STREAK", defaultValue: 0)}",
                                  icon: Icons.fireplace_rounded,
                                  imagePath: "assets/images/streak.png",
                                  color: Colors.red.shade400,
                                ),
                              ),
                              Expanded(
                                child: StatisticsTile(
                                  label: "Longest Streak",
                                  value: "${_box3.get("LONGEST_STREAK", defaultValue: 0)}",
                                  icon: Icons.emoji_events,
                                  imagePath: "assets/images/trophy.png",
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Owned Themes Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Consumer<ThemeModel>(
                builder: (context, themeModel, child) {
                  final ownedThemes = themeModel.themeItems
                      .where((item) => themeModel.isThemeBought(item[0]))
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Owned Themes",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_forward_ios, size: 20),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => StorePage()),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ownedThemes.map((theme) {
                            final themeName = theme[0];
                            final themeImage = theme[2];
                            final isCurrent = themeModel.currentThemeName == themeName;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                              child: Container(
                                width: 120,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 16),
                                    Image.asset(themeImage, height: 40),
                                    const SizedBox(height: 8),
                                    Text(
                                      themeName,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: isCurrent
                                          ? null
                                          : () {
                                              themeModel.selectTheme(themeName);
                                              Hive.box("box3").put("CURRENT_THEME", themeName);
                                              _applyThemeByName(themeName);
                                              setState(() {});
                                            },
                                      child: Text(isCurrent ? "In Use" : "Use"),
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(70, 32),
                                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                        elevation: 0,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}