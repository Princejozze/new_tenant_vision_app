import 'package:flutter/material.dart';
import 'package:myapp/src/widgets/house_list.dart';
import 'package:myapp/src/widgets/add_property_dialog.dart';
import 'package:myapp/src/widgets/responsive_layout.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showAddPropertyDialog(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    if (isMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => const AddPropertyDialog(),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => const AddPropertyDialog(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
        ],
      ),
      body: const Expanded(child: HouseList()),
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
              ],
            ),
            const SizedBox(height: 16),
            const Expanded(child: HouseList()),
          ],
        ),
      ),
    );

    return ResponsiveLayout(
      mobileBody: mobileBody,
      desktopBody: desktopBody,
    );
  }
}
