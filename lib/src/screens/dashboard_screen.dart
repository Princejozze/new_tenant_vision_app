import 'package:flutter/material.dart';
import 'package:myapp/src/widgets/responsive_layout.dart';
import 'package:myapp/src/widgets/sidebar.dart';
import 'package:myapp/src/widgets/bottom_navbar.dart';
import 'package:myapp/src/widgets/header.dart';
import 'package:myapp/src/widgets/house_list.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileBody: MobileDashboard(),
      desktopBody: DesktopDashboard(),
    );
  }
}

class DesktopDashboard extends StatelessWidget {
  const DesktopDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isCollapsed = screenWidth < 1390;

    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isCollapsed ? 80 : 250,
            child: Sidebar(isCollapsed: isCollapsed),
          ),
          VerticalDivider(width: 1, thickness: 1, color: Colors.grey[300]),
          const Expanded(
            child: Column(
              children: [
                Header(),
                Expanded(
                  child: HouseList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MobileDashboard extends StatelessWidget {
  const MobileDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prop-Manage', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        elevation: 1,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: const Column(
        children: [
          Header(),
          Expanded(
            child: HouseList(),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavbar(),
      drawer: const Drawer(child: Sidebar()),
    );
  }
}
