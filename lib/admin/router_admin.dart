import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'services/admin_auth_service.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard_screen.dart';

GoRouter createAdminRouter(AdminAuthService auth) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: auth,
    redirect: (context, state) {
      final bool loggingIn = state.uri.path == '/login';
      if (!auth.isAuthenticated && !loggingIn) return '/login';
      if (auth.isAuthenticated && loggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
}
