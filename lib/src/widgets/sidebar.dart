import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final bool isCollapsed;
  const Sidebar({super.key, this.isCollapsed = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: isCollapsed ? 80 : 250,
      color: colorScheme.surface.withAlpha(150),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          isCollapsed
              ? const Icon(Icons.home_work_rounded, size: 30)
              : Text('Prop-Manage',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildMenuItem(context, Icons.grid_view_rounded, 'Current Houses', true),
                _buildMenuItem(context, Icons.calendar_today_rounded, 'Upcoming'),
                _buildMenuItem(context, Icons.notifications_rounded, 'Reminders'),
                _buildMenuItem(context, Icons.warning_rounded, 'Overdue'),
                _buildMenuItem(context, Icons.article_rounded, 'Leases'),
                _buildMenuItem(context, Icons.history_rounded, 'Tenant History'),
                _buildMenuItem(context, Icons.bar_chart_rounded, 'Financials'),
              ],
            ),
          ),
          _buildMenuItem(context, Icons.language_rounded, 'Language'),
          _buildMenuItem(context, Icons.help_outline_rounded, 'Help & Tutorial'),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title,
      [bool isActive = false]) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // When collapsed, return a simple, centered icon to avoid layout errors.
    if (isCollapsed) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.primary.withAlpha(25) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant),
      );
    }

    // When expanded, return the full ListTile.
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? colorScheme.primary.withAlpha(25) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant),
        title: Text(title,
            style: theme.textTheme.bodyLarge?.copyWith(
                color: isActive ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: FontWeight.w500)),
        onTap: () {},
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      ),
    );
  }
}
