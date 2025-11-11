import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'router_admin.dart';
import '../firebase_options.dart';
import 'services/admin_auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuth>(create: (_) => FirebaseAuth.instance),
        Provider<FirebaseFirestore>(create: (_) => FirebaseFirestore.instance),
        ChangeNotifierProvider(create: (ctx) => AdminAuthService()),
      ],
      child: MaterialApp.router(
        title: 'Admin Console',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        routerConfig: createAdminRouter(
          // Safe to read with listen:true here to rebuild router when auth changes
          context.watch<AdminAuthService>(),
        ),
      ),
    );
  }
}
