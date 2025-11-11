import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/services/auth_service.dart';
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
      final auth = context.watch<AuthService>();
      if (constraints.maxWidth < 600) {
        return _MobileScaffold(
          selectedIndex: _selectedIndex,
          onIndexChanged: (index) => setState(() => _selectedIndex = index),
          child: _screens[_selectedIndex],
          onSignOut: () => context.read<AuthService>().signOut(),
          displayName: auth.displayName ?? 'Landlord',
        );
      } else {
        return _DesktopScaffold(
          selectedIndex: _selectedIndex,
          onIndexChanged: (index) => setState(() => _selectedIndex = index),
          child: _screens[_selectedIndex],
          onSignOut: () => context.read<AuthService>().signOut(),
          displayName: auth.displayName ?? 'Landlord',
        );
      }
    });
  }
}

class _MobileScaffold extends StatelessWidget {
  void _openProfile(BuildContext context) => context.go('/profile');
  void _openSettings(BuildContext context) => context.go('/settings');
  void _openFinancial(BuildContext context) => context.go('/financial');
  void _openAnalytics(BuildContext context) => context.go('/analytics');
  final VoidCallback onSignOut;
  final String displayName;
  final int selectedIndex;
  final Function(int) onIndexChanged;
  final Widget child;

  const _MobileScaffold({
    required this.onSignOut,
    required this.displayName,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Profile',
          icon: const Icon(Icons.account_circle),
          onPressed: () => _openProfile(context),
        ),
        title: const SizedBox.shrink(),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              tooltip: 'Menu',
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.account_circle, size: 48, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Dashboard'),
              onTap: () { Navigator.pop(context); onIndexChanged(0); },
            ),
            ListTile(
              leading: const Icon(Icons.apartment),
              title: const Text('Properties'),
              onTap: () { Navigator.pop(context); onIndexChanged(1); },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Upcoming Payments'),
              onTap: () { Navigator.pop(context); onIndexChanged(2); },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Reminders'),
              onTap: () { Navigator.pop(context); onIndexChanged(3); },
            ),
            ListTile(
              leading: const Icon(Icons.warning_outlined),
              title: const Text('Overdue Payments'),
              onTap: () { Navigator.pop(context); onIndexChanged(4); },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Payment History'),
              onTap: () { Navigator.pop(context); onIndexChanged(5); },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Change Profile'),
              onTap: () { Navigator.pop(context); _openProfile(context); },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Financial'),
              onTap: () { Navigator.pop(context); _openFinancial(context); },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Analytics'),
              onTap: () { Navigator.pop(context); _openAnalytics(context); },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () { Navigator.pop(context); _openSettings(context); },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () { Navigator.pop(context); onSignOut(); },
            ),
          ],
        ),
      ),
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
  void _openProfile(BuildContext context) => context.go('/profile');
  void _openSettings(BuildContext context) => context.go('/settings');
  void _openFinancial(BuildContext context) => context.go('/financial');
  void _openAnalytics(BuildContext context) => context.go('/analytics');
  final VoidCallback onSignOut;
  final String displayName;
  final int selectedIndex;
  final Function(int) onIndexChanged;
  final Widget child;

  const _DesktopScaffold({
    required this.onSignOut,
    required this.displayName,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Profile',
          icon: const Icon(Icons.account_circle),
          onPressed: () => _openProfile(context),
        ),
        title: const SizedBox.shrink(),
        actions: const [],
      ),
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
