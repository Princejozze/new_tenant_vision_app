import 'package:flutter/material.dart';
import 'package:myapp/src/navigation/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);

    return MaterialApp.router(
      title: 'Rental Property Manager',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.outline.withAlpha(128), width: 1),
          ),
        ),
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
