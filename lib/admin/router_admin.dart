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
      try {
        final bool loggingIn = state.uri.path == '/login';
        if (!auth.ready) return null; // Wait for auth to be ready
        if (!auth.isAuthenticated && !loggingIn) return '/login';
        if (auth.isAuthenticated && loggingIn) return '/';
        return null;
      } catch (e) {
        // If there's any error, default to login
        return '/login';
      }
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
