import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:project_model_ai/UI_UX/splash_screen.dart';
import 'package:project_model_ai/widget/leftBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isDarkMode = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(const MyApp());

  doWhenWindowReady(() {
    const initialSize = Size(1200, 700);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = 'Project Model AI';
    appWindow.show();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Project Model AI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(darkMode: isDarkMode),
      routes: {'/home': (context) => const Leftbar()},
    );
  }
}
