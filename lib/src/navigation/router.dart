import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/src/models/house.dart';
import 'package:myapp/src/screens/dashboard.dart';
import 'package:myapp/src/screens/house_detail_screen.dart';
import 'package:myapp/src/widgets/scaffold_with_navigation.dart';
import 'package:myapp/src/services/house_service.dart';
import 'package:provider/provider.dart';

import 'package:myapp/src/services/auth_service.dart';
import 'package:myapp/src/screens/auth/login_screen.dart';
import 'package:myapp/src/screens/auth/register_screen.dart';
import 'package:provider/provider.dart';

final GoRouter router = GoRouter(
  initialLocation: '/register',
  redirect: (context, state) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final isLoggingIn = state.subloc == '/login' || state.subloc == '/register';
    if (!auth.isAuthenticated && !isLoggingIn) return '/login';
    if (auth.isAuthenticated && isLoggingIn) return '/dashboard';
    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (BuildContext context, GoRouterState state) {
        return const ScaffoldWithNavigation();
      },
    ),
    GoRoute(
      path: '/house/:houseId',
      builder: (BuildContext context, GoRouterState state) {
        final houseId = state.pathParameters['houseId']!;
        final houseService = Provider.of<HouseService>(context, listen: false);
        
        print('Looking for house with ID: $houseId');
        print('Available houses: ${houseService.houses.map((h) => h.id).toList()}');
        
        // Wait a moment for houses to load if they're not available yet
        if (houseService.houses.isEmpty) {
          print('No houses found, waiting for initialization...');
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading houses...'),
                ],
              ),
            ),
          );
        }
        
        final house = houseService.getHouseById(houseId);
        if (house != null) {
          print('Found house: ${house.name} with ${house.rooms.length} rooms');
          return HouseDetailPage(houseId: houseId);
        } else {
          print('House not found with ID: $houseId');
          // If house is not found, show error page
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'House Not Found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The house with ID "$houseId" could not be found.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/dashboard'),
                    child: const Text('Back to Dashboard'),
                  ),
                ],
              ),
            ),
          );
        }
      },
    ),
    GoRoute(
      path: '/',
      redirect: (context, state) => '/dashboard',
    ),
  ],
);
