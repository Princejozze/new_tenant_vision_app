import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/models/room.dart';

class RoomCard extends StatelessWidget {
  final Room room;

  const RoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Determine status badge properties
    Color statusColor;
    IconData statusIcon;
    String statusText;
    Widget primaryActionButton;
    Widget? dueDateBar;
    List<PopupMenuEntry<String>> dropdownItems = [];

    switch (room.status) {
      case RoomStatus.vacant:
        statusColor = Colors.orange;
        statusIcon = Icons.person_off_outlined;
        statusText = 'Vacant';
        primaryActionButton = ElevatedButton.icon(
          onPressed: () {
            _showAddTenantDialog(context);
          },
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Add Tenant'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        break;
      case RoomStatus.pending:
        statusColor = Colors.blue;
        statusIcon = Icons.description_outlined;
        statusText = 'Pending Agreement';
        primaryActionButton = ElevatedButton.icon(
          onPressed: () {
            _showManageLeaseAgreementDialog(context);
          },
          icon: const Icon(Icons.assignment_outlined),
          label: const Text('Manage Lease Agreement'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        break;
      case RoomStatus.occupied:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        statusText = 'Occupied';

        // Determine Due Date Bar properties
        Color dueBarColor;
        String dueBarText;
        final now = DateTime.now();
        final difference = room.nextDueDate.difference(now).inDays;

        if (room.rentStatus == 'Overdue') {
          dueBarColor = Colors.red;
          dueBarText = 'Overdue';
        } else if (difference <= 7 && difference >= 0) {
          dueBarColor = Colors.grey;
          dueBarText = 'Due in $difference days';
        } else {
          dueBarColor = Colors.green;
          dueBarText = 'Payment is on track';
        }

        dueDateBar = Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          decoration: BoxDecoration(
            color: dueBarColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Text(
            dueBarText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        );

        primaryActionButton = OutlinedButton.icon(
          onPressed: () {
            _showPaymentHistoryDialog(context);
          },
          icon: const Icon(Icons.history),
          label: const Text('Payment History'),
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.primary,
            side: BorderSide(color: colorScheme.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        dropdownItems = [
          const PopupMenuItem<String>(
            value: 'edit_tenant',
            child: Text('Edit Tenant'),
          ),
          const PopupMenuItem<String>(
            value: 'vacate_room',
            child: Text('Vacate Room'),
          ),
        ];
        break;
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dueDateBar != null) dueDateBar,
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Room ${room.roomNumber}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(statusIcon, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                statusText,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (dropdownItems.isNotEmpty)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit_tenant') {
                            _showEditTenantDialog(context);
                          } else if (value == 'vacate_room') {
                            _showVacateRoomConfirmationDialog(context);
                          }
                        },
                        itemBuilder: (BuildContext context) => dropdownItems,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  room.tenantName ?? 'No tenant assigned',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(room.rentAmount)} TZS / month',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: primaryActionButton,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dialog methods
  void _showAddTenantDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tenant'),
        content: const Text('This will be the multi-step onboarding wizard for adding a new tenant.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement tenant creation logic
            },
            child: const Text('Start Wizard'),
          ),
        ],
      ),
    );
  }

  void _showManageLeaseAgreementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Lease Agreement'),
        content: const Text('This dialog will handle lease document management, including downloading and uploading signed copies.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement lease agreement management
            },
            child: const Text('Manage'),
          ),
        ],
      ),
    );
  }

  void _showPaymentHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment History'),
        content: const Text('This dialog will list all past payments for this tenant.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditTenantDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Tenant'),
        content: const Text('This dialog will allow editing tenant details.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement tenant editing logic
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showVacateRoomConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vacate Room'),
        content: const Text('Are you sure you want to vacate this room? This action will remove the tenant and change the room status to vacant.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement room vacation logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Vacate Room'),
          ),
        ],
      ),
    );
  }
}
