
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/main.dart';
import 'package:myapp/src/models/house.dart';
import 'package:myapp/src/providers/app_data_provider.dart';
import 'package:myapp/src/widgets/house_list.dart';
import 'package:myapp/src/widgets/add_property_dialog.dart';
import 'package:myapp/src/widgets/responsive_layout.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showAddPropertyDialog(BuildContext context) {
    final appDataProvider = Provider.of<AppDataProvider>(context, listen: false);
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => AddPropertyDialog(onSave: (House house) {
          appDataProvider.addHouse(house);
        }),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AddPropertyDialog(onSave: (House house) {
          appDataProvider.addHouse(house);
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataProvider>(
      builder: (context, appDataProvider, child) {
        final themeProvider = Provider.of<ThemeProvider>(context);

        final themeToggleButton = IconButton(
          icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
          onPressed: () => themeProvider.toggleTheme(),
          tooltip: 'Toggle Theme',
        );

        final Widget bodyContent;
        if (appDataProvider.isLoading) {
          bodyContent = const Center(child: CircularProgressIndicator());
        } else if (appDataProvider.houses.isEmpty) {
          bodyContent = const Center(
            child: Text(
              'No properties added yet. Tap the \'+\' to get started!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          );
        } else {
          bodyContent = HouseList(houses: appDataProvider.houses);
        }

        final mobileBody = Scaffold(
          appBar: AppBar(
            title: const Text('Properties'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // TODO: Implement search functionality
                },
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddPropertyDialog(context),
              ),
              themeToggleButton,
            ],
          ),
          body: bodyContent,
        );

        final desktopBody = Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Find Tenant & Add Payment',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAddPropertyDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add New House'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    themeToggleButton,
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(child: bodyContent),
              ],
            ),
          ),
        );

        return ResponsiveLayout(
          mobileBody: mobileBody,
          desktopBody: desktopBody,
        );
      },
    );
  }
}
