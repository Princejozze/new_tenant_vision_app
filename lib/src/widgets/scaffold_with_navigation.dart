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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
    RemindersScreen(),           // 2 - Reminders (with Upcoming and Overdue tabs)
    PaymentHistoryScreen(),      // 3 - Payments
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
  void _openSubscription(BuildContext context) => context.go('/subscription');
  void _openSupport(BuildContext context) => context.go('/support');
  final VoidCallback onSignOut;
  final String displayName;
  final int selectedIndex;
  final Function(int) onIndexChanged;
  final Widget child;

  Future<Map<String, dynamic>?> _getLandlordInfo(AuthService auth) async {
    final user = auth.user;
    if (user == null) return null;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('landlords')
          .doc(user.uid)
          .get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  String? _getProfileImageUrl(Map<String, dynamic>? landlordData, User? user) {
    // First check Firebase Auth for photo URL (for Google sign-in users)
    if (user?.photoURL != null && user!.photoURL!.isNotEmpty) {
      return user.photoURL;
    }
    // Fallback to Firestore
    return landlordData?['photoUrl'] as String?;
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

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
            FutureBuilder<Map<String, dynamic>?>(
              future: _getLandlordInfo(context.watch<AuthService>()),
              builder: (context, snapshot) {
                final auth = context.watch<AuthService>();
                final landlordData = snapshot.data;
                final joinDate = landlordData?['createdAt'] as Timestamp?;
                final planType = landlordData?['planType'] as String? ?? 'Free Plan';
                final profileImageUrl = _getProfileImageUrl(landlordData, auth.user);
                
                String joinDateText = 'Joined recently';
                if (joinDate != null) {
                  final date = joinDate.toDate();
                  final day = date.day;
                  final month = DateFormat('MMMM').format(date);
                  final year = date.year;
                  final suffix = _getDaySuffix(day);
                  joinDateText = 'Joined ${day}$suffix $month $year';
                }
                
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Profile Image Circle
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          backgroundImage: profileImageUrl != null
                              ? NetworkImage(profileImageUrl)
                              : null,
                          child: profileImageUrl == null
                              ? Text(
                                  (displayName.isNotEmpty ? displayName[0] : 'U').toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                displayName.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                joinDateText,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                planType,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Reminders'),
              onTap: () { Navigator.pop(context); onIndexChanged(2); },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Payment History'),
              onTap: () { Navigator.pop(context); onIndexChanged(3); },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Financial Analytics'),
              onTap: () { Navigator.pop(context); _openFinancial(context); },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () { Navigator.pop(context); _openSettings(context); },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Support'),
              onTap: () { Navigator.pop(context); _openSupport(context); },
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
            icon: Icon(Icons.notifications_outlined),
            label: 'Reminders',
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
  void _openSubscription(BuildContext context) => context.go('/subscription');
  void _openSupport(BuildContext context) => context.go('/support');
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
                icon: Icon(Icons.notifications_outlined),
                label: Text('Reminders'),
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
