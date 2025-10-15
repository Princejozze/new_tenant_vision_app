import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavigation extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavigation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 600) {
        return ScaffoldWithBottomNavBar(child: child);
      } else {
        return ScaffoldWithSideNavBar(child: child);
      }
    });
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
        context.go('/');
        break;
      case 1:
        // TODO: Implement other routes
        break;
      case 2:
        // TODO: Implement other routes
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
