import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/src/screens/dashboard.dart';
import 'package:myapp/src/screens/properties_screen.dart';
import 'package:myapp/src/screens/upcoming_payments_screen.dart';
import 'package:myapp/src/screens/reminders_screen.dart';
import 'package:myapp/src/screens/overdue_payments_screen.dart';
import 'package:myapp/src/screens/payment_history_screen.dart';

class ScaffoldWithNavigation extends StatefulWidget {
  const ScaffoldWithNavigation({super.key});

  @override
  State<ScaffoldWithNavigation> createState() => _ScaffoldWithNavigationState();
}

class _ScaffoldWithNavigationState extends State<ScaffoldWithNavigation> {
  int _selectedIndex = 0; // Dashboard is at index 0

  final List<Widget> _screens = const [
    DashboardScreen(),           // 0 - Home
    PropertiesScreen(),          // 1 - Properties
    UpcomingPaymentsScreen(),    // 2 - Upcoming  
    RemindersScreen(),           // 3 - Reminders
    OverduePaymentsScreen(),     // 4 - Overdue
    PaymentHistoryScreen(),      // 5 - Payments
  ];

  @override
  Widget build(BuildContext context) {
    // Set the navigation callback for dashboard
    DashboardScreen.onNavigateToTab = (index) => setState(() => _selectedIndex = index);
    
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 600) {
        return _MobileScaffold(
          selectedIndex: _selectedIndex,
          onIndexChanged: (index) => setState(() => _selectedIndex = index),
          child: _screens[_selectedIndex],
        );
      } else {
        return _DesktopScaffold(
          selectedIndex: _selectedIndex,
          onIndexChanged: (index) => setState(() => _selectedIndex = index),
          child: _screens[_selectedIndex],
        );
      }
    });
  }
}

class _MobileScaffold extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;
  final Widget child;

  const _MobileScaffold({
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onIndexChanged,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.apartment),
            label: 'Properties',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: 'Upcoming',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            label: 'Reminders',
          ),
          NavigationDestination(
            icon: Icon(Icons.warning_outlined),
            label: 'Overdue',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Payments',
          ),
        ],
      ),
    );
  }
}

class _DesktopScaffold extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;
  final Widget child;

  const _DesktopScaffold({
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onIndexChanged,
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.apartment),
                label: Text('Properties'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today),
                label: Text('Upcoming'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications_outlined),
                label: Text('Reminders'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.warning_outlined),
                label: Text('Overdue'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt_long),
                label: Text('Payments'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
