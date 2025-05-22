import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ml/UI_UX/splash_screen.dart';
import 'package:flutter_ml/widget/leftBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_ml/services/flask_service.dart';

bool isDarkMode = false;

// Global instance of FlaskService
final FlaskService flaskService = FlaskService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  isDarkMode = prefs.getBool('isDarkMode') ?? false;

  // Start both servers when app launches
  await Future.wait([
    flaskService.startClassificationServer(),
    flaskService.startRegressionServer(),
  ]);

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
  void dispose() {
    // Stop both servers when app closes
    flaskService.stopAllServers();
    super.dispose();
  }

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
