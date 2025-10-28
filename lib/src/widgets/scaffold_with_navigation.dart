import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/src/screens/dashboard.dart';
import 'package:myapp/src/screens/upcoming_payments_screen.dart';
import 'package:myapp/src/screens/reminders_screen.dart';
import 'package:myapp/src/screens/overdue_payments_screen.dart';
import 'package:myapp/src/screens/tenant_history_screen.dart';

class ScaffoldWithNavigation extends StatefulWidget {
  const ScaffoldWithNavigation({super.key});

  @override
  State<ScaffoldWithNavigation> createState() => _ScaffoldWithNavigationState();
}

class _ScaffoldWithNavigationState extends State<ScaffoldWithNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    UpcomingPaymentsScreen(),
    RemindersScreen(),
    OverduePaymentsScreen(),
    TenantHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.history),
            label: 'History',
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
                icon: Icon(Icons.history),
                label: Text('History'),
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

class ScaffoldWithBottomNavBar extends StatefulWidget {
  final Widget child;

  const ScaffoldWithBottomNavBar({super.key, required this.child});

  @override
  State<ScaffoldWithBottomNavBar> createState() =>
      _ScaffoldWithBottomNavBarState();
}

class _ScaffoldWithBottomNavBarState extends State<ScaffoldWithBottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        // Home
        break;
      case 1:
        // Upcoming Payments
        break;
      case 2:
        // Reminders
        break;
      case 3:
        // Overdue
        break;
      case 4:
        // Tenant History
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
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
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}

class ScaffoldWithSideNavBar extends StatefulWidget {
  final Widget child;

  const ScaffoldWithSideNavBar({super.key, required this.child});

  @override
  State<ScaffoldWithSideNavBar> createState() => _ScaffoldWithSideNavBarState();
}

class _ScaffoldWithSideNavBarState extends State<ScaffoldWithSideNavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
              switch (index) {
                case 0:
                  context.go('/');
                  break;
                case 1:
                  // TODO: Implement other routes
                  break;
                case 2:
                  // TODO: Implement other routes
                  break;
              }
            },
            labelType: NavigationRailLabelType.all,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart),
                label: Text('Reports'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
