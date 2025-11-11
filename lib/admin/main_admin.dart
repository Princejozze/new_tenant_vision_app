import 'package:flutter/material.dart';
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
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    // Firebase might already be initialized
    debugPrint('Firebase initialization: $e');
  }
  runApp(const AdminApp());
}

class AdminApp extends StatefulWidget {
  const AdminApp({super.key});

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  late final AdminAuthService _authService;
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    try {
      _authService = AdminAuthService();
      // Create router after a microtask to ensure everything is ready
      Future.microtask(() {
        if (mounted) {
          setState(() {
            _router = createAdminRouter(_authService);
          });
        }
      });
    } catch (e) {
      debugPrint('Error initializing AdminApp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_router == null) {
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
        ChangeNotifierProvider.value(value: _authService),
      ],
      child: MaterialApp.router(
        title: 'Admin Console',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        routerConfig: _router!,
      ),
    );
  }
}
