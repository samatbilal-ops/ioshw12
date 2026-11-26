import 'package:flutter/material.dart';

import 'screens/photo_diary_screen.dart';

/// Standalone LW13 app: `flutter run -t lib/main_lw13.dart`.
class Lw13App extends StatelessWidget {
  const Lw13App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Narxoz Photo Journal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepOrange),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepOrange,
        brightness: Brightness.dark,
      ),
      home: const PhotoDiaryScreen(),
    );
  }
}
