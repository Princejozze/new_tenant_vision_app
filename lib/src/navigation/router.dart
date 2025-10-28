import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/src/models/house.dart';
import 'package:myapp/src/screens/dashboard.dart';
import 'package:myapp/src/screens/house_detail_screen.dart';
import 'package:myapp/src/widgets/scaffold_with_navigation.dart';
import 'package:myapp/src/services/house_service.dart';
import 'package:provider/provider.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return ScaffoldWithNavigation();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'house/:houseId',
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
                        onPressed: () => context.go('/'),
                        child: const Text('Back to Dashboard'),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ],
    ),
  ],
);
