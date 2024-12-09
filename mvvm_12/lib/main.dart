import 'package:flutter/material.dart';
import 'home_page.dart'; // Import the HomePage
import 'package:provider/provider.dart';
import 'viewmodel/home_viewmodel.dart'; // Make sure to import HomeViewmodel

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => HomeViewmodel(), // Providing HomeViewmodel globally
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.deepPurple, // Main color
          secondary: Colors.purpleAccent, // Accent color
          background: Colors.black87, // Background color
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home:  HomePage(), // HomePage widget as the starting point
    );
  }
}
