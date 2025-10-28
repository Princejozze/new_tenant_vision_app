import 'package:flutter/material.dart';
import 'package:myapp/src/widgets/add_property_dialog.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home, size: 64, color: colorScheme.onSurface.withAlpha(102)),
          const SizedBox(height: 20),
          Text(
            'No houses yet',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Get started by adding your first rental house.',
            style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showAddPropertyDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add New House'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
