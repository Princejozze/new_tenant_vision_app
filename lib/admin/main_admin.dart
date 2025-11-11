import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'router_admin.dart';
import '../firebase_options.dart';
import 'services/admin_auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Global error handler to catch google_sign_in initialization errors
  FlutterError.onError = (FlutterErrorDetails details) {
    // Ignore google_sign_in related errors on web
    if (kIsWeb && details.exception.toString().contains('google')) {
      debugPrint('Ignoring google_sign_in error: ${details.exception}');
      return;
    }
    FlutterError.presentError(details);
  };
  
  // Handle async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kIsWeb && error.toString().contains('google')) {
      debugPrint('Ignoring google_sign_in async error: $error');
      return true; // Error handled
    }
    return false; // Let Flutter handle it
  };
  
  FirebaseApp? app;
  try {
    app = await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint('Firebase initialized successfully: ${app.name}');
  } catch (e) {
    // Firebase might already be initialized, try to get existing app
    try {
      app = Firebase.app();
      debugPrint('Using existing Firebase app: ${app.name}');
    } catch (e2) {
      debugPrint('Firebase initialization error: $e');
      debugPrint('Could not get existing app: $e2');
      // Continue anyway - some features might not work
    }
  }
  
  runApp(const AdminApp());
}

class AdminApp extends StatefulWidget {
  const AdminApp({super.key});

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  AdminAuthService? _authService;
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    // Wait a bit for Firebase to be ready before initializing services
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        try {
          setState(() {
            _authService = AdminAuthService();
            _router = createAdminRouter(_authService);
          });
        } catch (e, stack) {
          debugPrint('Error initializing AdminApp: $e\n$stack');
          // Create anyway to show error
          setState(() {
            _authService = AdminAuthService();
            _router = createAdminRouter(_authService);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_router == null || _authService == null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MultiProvider(
      providers: [
        Provider<FirebaseAuth>(create: (_) => FirebaseAuth.instance),
        Provider<FirebaseFirestore>(create: (_) => FirebaseFirestore.instance),
        ChangeNotifierProvider.value(value: _authService!),
      ],
      child: Builder(
        builder: (context) {
          try {
            return MaterialApp.router(
              title: 'Admin Console',
              theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
              routerConfig: _router!,
            );
          } catch (e, stack) {
            debugPrint('Error building MaterialApp.router: $e\n$stack');
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error loading app: $e'),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
