import 'package:flutter/material.dart';
import 'package:myapp/src/widgets/house_list.dart';
import 'package:myapp/src/widgets/add_property_dialog.dart';
import 'package:myapp/src/widgets/responsive_layout.dart';
import 'package:myapp/src/widgets/tenant_search_dialog.dart';

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

  void _showTenantSearchDialog(BuildContext context) {
    print('Search button pressed - opening dialog');
    showDialog(
      context: context,
      builder: (context) => const TenantSearchDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mobileBody = Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showTenantSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPropertyDialog(context),
          ),
        ],
      ),
      body: const HouseList(),
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
                  child: InkWell(
                    onTap: () => _showTenantSearchDialog(context),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.outline),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(width: 12),
                          Text(
                            'Find Tenant & Add Payment',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
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
