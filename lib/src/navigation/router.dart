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
        return const ScaffoldWithNavigation(child: DashboardScreen());
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'house/:houseId',
          builder: (BuildContext context, GoRouterState state) {
            final houseId = state.pathParameters['houseId']!;
            final houseService = Provider.of<HouseService>(context, listen: false);
            final house = houseService.houses.firstWhere((h) => h.id == houseId);
            return ScaffoldWithNavigation(child: HouseDetailPage(house: house));
          },
        ),
      ],
    ),
  ],
);
