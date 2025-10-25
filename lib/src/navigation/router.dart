
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/providers/app_data_provider.dart';
import 'package:myapp/src/screens/dashboard.dart';
import 'package:myapp/src/screens/house_detail_screen.dart';
import 'package:myapp/src/widgets/scaffold_with_navigation.dart';

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
            final appDataProvider = Provider.of<AppDataProvider>(context, listen: false);
            final house = appDataProvider.getHouseById(houseId);

            return ScaffoldWithNavigation(child: HouseDetailPage(house: house));
          },
        ),
      ],
    ),
  ],
);
