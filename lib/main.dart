import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/src/navigation/router.dart';
import 'package:myapp/src/services/house_service.dart';
import 'package:myapp/src/services/theme_service.dart';
import 'package:myapp/src/services/auth_service.dart';
import 'package:myapp/src/services/expense_service.dart';
import 'package:myapp/src/services/language_service.dart';
import 'package:provider/provider.dart';


import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HouseService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ExpenseService()),
        ChangeNotifierProvider(create: (_) => LanguageService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          final darkColorScheme = ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark);
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
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: darkColorScheme,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            themeMode: themeService.mode,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
