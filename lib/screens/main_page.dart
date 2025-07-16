import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskmanagement/data/database.dart';
import 'package:taskmanagement/screens/calendar_page.dart';
import 'package:taskmanagement/screens/overview_page.dart';
import 'package:taskmanagement/screens/profile_page.dart';
import 'package:taskmanagement/screens/reminders_page.dart';
import 'package:taskmanagement/screens/settings_page.dart';
import 'package:taskmanagement/screens/store_page.dart';
import 'package:taskmanagement/screens/task_page.dart';
import 'package:taskmanagement/screens/timer_page.dart';
import 'package:taskmanagement/services/auth_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final user = FirebaseAuth.instance.currentUser!;

  // Sign user out
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  int currentPage = 0;
  
  Currency db = Currency();
  final _box2 = Hive.box("box2");

  late final List<Widget> pages = [
    //OverviewPage(),
    TaskPage(),
    const CalendarPage(),
    const TimerPage(),
    const ProfilePage(),
  ];

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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary, 
      appBar: _buildAppBar(),
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Custom Drawer Header
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).colorScheme.onPrimary,
                        child: ClipOval(
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: AuthService().getProfileImage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      // Nickname and Exit
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              user.displayName ?? "User",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.logout, color: Colors.white),
                              onPressed: signUserOut,
                              tooltip: "Sign Out",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Email under the row
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, top: 2.0),
                    child: Text(
                      user.email ?? "",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Drawer Items
            ListTile(
              leading: const Icon(Icons.storefront_rounded),
              trailing: const Icon(Icons.arrow_forward_ios, size: 20),
              title: const Text("Theme Store"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StorePage()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text("Reminders"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RemindersPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            const Divider(indent: 16, endIndent: 16, thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Welcome to Task Management!",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
      body: pages[currentPage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        onTap: (value) {
          setState(() {
            currentPage = value;
          });
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Theme.of(context).colorScheme.inversePrimary,
        unselectedItemColor: Theme.of(context).colorScheme.onSecondary,
        items: const [
          /*BottomNavigationBarItem(
            icon: Icon(Icons.abc),
            label: 'Overview',
          ),*/
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Timer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
  return AppBar(
    backgroundColor: Theme.of(context).colorScheme.surface,
    elevation: 0,
    iconTheme: IconThemeData(size: 30),
    actions: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Icon(Icons.attach_money_rounded, color: const Color.fromARGB(255, 230, 174, 4)),
            //updating value in real time
            ValueListenableBuilder(
              valueListenable: _box2.listenable(),
              builder: (context, box, _) {
                final amount = box.get("CURRENCY", defaultValue: 0);
                return Text(
                  amount.toString(),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                );
              },
            ),
          ],
        ),
      )
    ],
  );
}
}
