import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taskmanagement/model/theme_model.dart';
import 'package:taskmanagement/screens/auth_page.dart';
import 'package:taskmanagement/services/noti_service.dart';
import 'package:taskmanagement/services/tts_provider.dart';
import 'package:taskmanagement/themes/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Notis
  NotiService().initNotification();

  // initialize Hive database
  await Hive.initFlutter();
  await Hive.openBox('box1');
  await Hive.openBox('box2');
  await Hive.openBox('box3');
  await Hive.openBox('box4');

  // Run app 
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),  // Provide your theme here once
        ChangeNotifierProvider(create: (_) => ThemeModel()),
        ChangeNotifierProvider(create: (_) => TtsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Transparent status bar colors
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    // Consumer to rebuild when theme changes
    return Consumer<ThemeProvider>(
      // Consumer to listen to theme changes -> Rebuilds the MaterialApp on theme change
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Tasks',
          home: const AuthePage(),
          theme: themeProvider.themeData,
        );
      },
    );
  }
}
