import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/models/room.dart';
import 'package:myapp/src/models/tenant.dart';
import 'package:myapp/src/widgets/new_tenant_onboarding_dialog.dart';
import 'package:myapp/src/services/receipt_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:myapp/src/screens/tenant_history_screen.dart';

class RoomCard extends StatefulWidget {
  final Room room;
  final Function(Room) onRoomUpdated;
  final String? houseName;
  final String? houseAddress;

  const RoomCard({
    super.key, 
    required this.room,
    required this.onRoomUpdated,
    this.houseName,
    this.houseAddress,
  });

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  @override
  Widget build(BuildContext context) {
    final room = widget.room; // Get the current room data
    print('RoomCard rebuilding for Room ${room.roomNumber} - Status: ${room.status}, Tenant: ${room.tenantName}');
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
        statusIcon = Icons.person_add_alt_1;
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
        
        dropdownItems = [
          const PopupMenuItem<String>(
            value: 'add_tenant',
            child: Row(
              children: [
                Icon(Icons.person_add, size: 20),
                SizedBox(width: 8),
                Text('Add Tenant'),
              ],
            ),
          ),
        ];
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

        // Determine Due Date Bar properties based on payment status
        Color dueBarColor;
        String dueBarText;
        IconData dueBarIcon;

        // Check if no payment has been made
        if (room.tenant!.totalPaid == 0) {
          // Grey for "Add payment" reminder when no payment made yet
          dueBarColor = Colors.grey;
          dueBarText = room.paymentStatus;
          dueBarIcon = Icons.payment;
        } else if (room.isOverdue) {
          // Red for overdue
          dueBarColor = Colors.red;
          dueBarText = room.paymentStatus;
          dueBarIcon = Icons.calendar_today;
        } else {
          // Blue for payment on track
          dueBarColor = Colors.blue;
          dueBarText = room.paymentStatus;
          dueBarIcon = Icons.check_circle;
        }

        dueDateBar = Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          decoration: BoxDecoration(
            color: dueBarColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(dueBarIcon, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                dueBarText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
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
            child: Row(
              children: [
                Icon(Icons.edit, size: 20),
                SizedBox(width: 8),
                Text('Edit Tenant'),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'download_tenant_info',
            child: Row(
              children: [
                Icon(Icons.download, size: 20),
                SizedBox(width: 8),
                Text('Download tenant info (PDF)'),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'vacate_room',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('Vacate Room', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ];
        break;
    }

    return Card(
      margin: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
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
                    PopupMenuButton<String>(
                      onSelected: (value) {
                         if (value == 'add_tenant') {
                         _showAddTenantDialog(context);
                       } else if (value == 'edit_tenant') {
                         _showEditTenantDialog(context);
                       } else if (value == 'vacate_room') {
                         _showVacateRoomConfirmationDialog(context);
                       } else if (value == 'download_tenant_info') {
                         _downloadTenantInfo(context);
                       }
                      },
                      itemBuilder: (BuildContext context) => dropdownItems,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  room.tenantName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(room.currentRentAmount)} TZS / month',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                
                // Show dates for occupied rooms
                if (room.status == RoomStatus.occupied && room.tenant != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Start Date: ${DateFormat('MMM dd, yyyy').format(room.tenant!.startDate)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Next Due: ${DateFormat('MMM dd, yyyy').format(room.currentNextDueDate)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ],
                
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
      ),
    );
  }

  Future<void> _downloadTenantInfo(BuildContext context) async {
    final tenant = widget.room.tenant;
    if (tenant == null) return;

    final propertyName = widget.houseName ?? 'Property';
    final success = await ReceiptService.downloadTenantInfo(
      tenant: tenant,
      room: widget.room,
      propertyName: propertyName,
      propertyAddress: widget.houseAddress,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Tenant info PDF downloaded successfully.'
            : 'Failed to download tenant info PDF.'),
      ),
    );
  }

  // Dialog methods
  void _showAddTenantDialog(BuildContext context) {
    print('Opening add tenant dialog for room ${widget.room.roomNumber}');
    showDialog(
      context: context,
      builder: (context) => NewTenantOnboardingDialog(
        room: widget.room,
        onTenantCreated: (tenant) {
          print('Tenant created callback received: ${tenant.fullName}');
          final updatedRoom = widget.room.addTenant(tenant);
          print('Updated room status: ${updatedRoom.status}');
          print('Updated room tenant: ${updatedRoom.tenantName}');
          widget.onRoomUpdated(updatedRoom);
        },
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
    if (widget.room.tenant == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment History - ${widget.room.tenant!.fullName}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: widget.room.tenant!.payments.isEmpty
              ? const Center(
                  child: Text('No payments recorded yet'),
                )
              : ListView.builder(
                  itemCount: widget.room.tenant!.payments.length,
                  itemBuilder: (context, index) {
                    final payment = widget.room.tenant!.payments[index];
                    return ListTile(
                      leading: const Icon(Icons.payment),
                      title: Text('${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(payment.amount)} TZS'),
                      subtitle: Text(DateFormat('MMM dd, yyyy').format(payment.date)),
                      trailing: payment.notes != null 
                          ? IconButton(
                              icon: const Icon(Icons.info_outline),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(payment.notes!)),
                                );
                              },
                            )
                          : null,
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showAddPaymentDialog(context);
            },
            child: const Text('Add Payment'),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentDialog(BuildContext context) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (TZS)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                final payment = Payment(
                  id: 'payment-${DateTime.now().millisecondsSinceEpoch}',
                  amount: amount,
                  date: DateTime.now(),
                  notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                );
                
                final updatedRoom = widget.room.addPayment(payment);
                widget.onRoomUpdated(updatedRoom);
                Navigator.of(context).pop();
                
                // Show payment recorded message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Payment of ${NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0).format(amount)} recorded'),
                    backgroundColor: Colors.green,
                  ),
                );
                
                // Automatically download receipt
                if (widget.room.tenant != null) {
                  try {
                    final success = await ReceiptService.downloadReceipt(
                      payment: payment,
                      tenant: widget.room.tenant!,
                      room: widget.room,
                      propertyName: 'Property', // You might want to get this from context
                    );
                    
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Receipt automatically downloaded!'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    }
                  } catch (e) {
                    // Silent fail for automatic download
                    debugPrint('Auto receipt download failed: $e');
                  }
                }
              }
            },
            child: const Text('Record Payment'),
          ),
        ],
      ),
    );
  }

  void _showEditTenantDialog(BuildContext context) {
    if (widget.room.tenant == null) return;
    
    print('Opening edit tenant dialog for ${widget.room.tenant!.fullName}');
    showDialog(
      context: context,
      builder: (context) => NewTenantOnboardingDialog(
        room: widget.room,
        existingTenant: widget.room.tenant,
        isEditMode: true,
        onTenantCreated: (updatedTenant) {
          print('Tenant updated callback received: ${updatedTenant.fullName}');
          final updatedRoom = widget.room.updateTenant(updatedTenant);
          print('Updated room status: ${updatedRoom.status}');
          widget.onRoomUpdated(updatedRoom);
        },
      ),
    );
  }

  Future<void> _saveToHistory(Tenant tenant, String roomNumber, String houseName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('tenant_history');
      final List<PastTenant> history = historyJson != null
          ? (jsonDecode(historyJson) as List)
              .map((json) => PastTenant.fromJson(json))
              .toList()
          : [];
      
      // Add the vacated tenant to history
      history.add(PastTenant(
        id: 'history-${DateTime.now().millisecondsSinceEpoch}',
        fullName: tenant.fullName,
        property: houseName,
        roomNumber: roomNumber,
        moveInDate: tenant.startDate,
        moveOutDate: DateTime.now(),
        paymentHistory: tenant.payments.map((p) => HistoricalPayment(
          amount: p.amount,
          date: p.date,
        )).toList(),
        note: null,
      ));
      
      // Save back to SharedPreferences
      await prefs.setString('tenant_history', jsonEncode(history));
      print('Tenant saved to history: ${tenant.fullName}');
    } catch (e) {
      print('Error saving tenant to history: $e');
    }
  }

  void _showVacateRoomConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vacate Room'),
        content: Text('Are you sure you want to vacate Room ${widget.room.roomNumber}? This action will remove ${widget.room.tenant!.fullName} and change the room status to vacant.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Get house information before removing tenant
              // This is a bit of a workaround - we need house info
              final updatedRoom = widget.room.removeTenant();
              
              // Save to history (need to get house name somehow)
              // For now, we'll pass the room number and try to get house
              await _saveToHistory(
                widget.room.tenant!,
                widget.room.roomNumber,
                'Unknown House', // Will need to pass actual house name
              );
              
              widget.onRoomUpdated(updatedRoom);
              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Room ${widget.room.roomNumber} has been vacated'),
                  backgroundColor: Colors.orange,
                ),
              );
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
