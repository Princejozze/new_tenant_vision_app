import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/services/house_service.dart';
import 'package:myapp/src/models/room.dart';
import 'package:myapp/src/models/tenant.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/services/sms_service.dart';
import 'package:url_launcher/url_launcher.dart';

class UpcomingPaymentsScreen extends StatelessWidget {
  const UpcomingPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final houseService = Provider.of<HouseService>(context);
    
    // Get all upcoming payments (due in next 30 days)
    final upcomingTenants = <Map<String, dynamic>>[];
    
    for (var house in houseService.houses) {
      for (var room in house.rooms) {
        if (room.status == RoomStatus.occupied && room.tenant != null) {
          final tenant = room.tenant!;
          final now = DateTime.now();
          
          // Calculate based on coverage date (when their paid rent runs out)
          final coverageUntil = tenant.coverageUntilDate;
          final daysUntilDue = coverageUntil.difference(now).inDays;
          
          // Show upcoming payments: due within 30 days (whether they've paid or not)
          // This shows when their current payment runs out
          if (daysUntilDue >= 0 && daysUntilDue <= 30) {
            upcomingTenants.add({
              'tenant': tenant,
              'room': room,
              'house': house,
              'daysUntilDue': daysUntilDue,
            });
          }
        }
      }
    }
    
    // Sort by closest due date first
    upcomingTenants.sort((a, b) => 
      (a['daysUntilDue'] as int).compareTo(b['daysUntilDue'] as int)
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Payments'),
        actions: [
          IconButton(
            tooltip: 'Notify all upcoming by SMS',
            icon: const Icon(Icons.sms),
            onPressed: () async {
              final numbers = upcomingTenants
                  .map((e) => (e['tenant'] as Tenant).phone)
                  .whereType<String>()
                  .where((p) => p.trim().isNotEmpty)
                  .toList();
              if (numbers.isEmpty) return;
              final message = 'Reminder: Your rent is due soon. Please ensure payment before the due date to avoid penalties.';
              await SmsService.sendGroupSms(phoneNumbers: numbers, message: message);
            },
          ),
        ],
      ),
      body: upcomingTenants.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'All Caught Up!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No payments are due in the next 30 days',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: upcomingTenants.length,
              itemBuilder: (context, index) {
                final data = upcomingTenants[index];
                final tenant = data['tenant'] as Tenant;
                final room = data['room'] as Room;
                final house = data['house'];
                final daysUntilDue = data['daysUntilDue'] as int;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(
                      tenant.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('$house • Room ${room.roomNumber}'),
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(
                            daysUntilDue == 0 
                                ? 'Due today' 
                                : 'Due in $daysUntilDue ${daysUntilDue == 1 ? 'day' : 'days'}',
                          ),
                          backgroundColor: Colors.grey[200],
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      tooltip: 'Actions',
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'record',
                          child: Text('Record Payment'),
                        ),
                        if (tenant.email != null && tenant.email!.isNotEmpty)
                          const PopupMenuItem(
                            value: 'email',
                            child: Text('Notify by Email'),
                          ),
                        if (tenant.phone != null && tenant.phone!.isNotEmpty)
                          const PopupMenuItem(
                            value: 'sms',
                            child: Text('Notify by SMS'),
                          ),
                      ],
                      onSelected: (value) async {
                        switch (value) {
                          case 'record':
                            _showPaymentDialog(context, tenant, room, house);
                            break;
                          case 'email':
                            // Open mail client
                            final subject = 'Rent due reminder';
                            final body = daysUntilDue == 0
                                ? 'Reminder: Your rent is due today. Please make payment to avoid penalties.'
                                : 'Reminder: Your rent is due in $daysUntilDue days. Please ensure payment before the due date.';
                            final uri = Uri(
                              scheme: 'mailto',
                              path: tenant.email,
                              queryParameters: {'subject': subject, 'body': body},
                            );
                            await launchUrl(uri);
                            break;
                          case 'sms':
                            final phone = tenant.phone;
                            if (phone == null || phone.trim().isEmpty) return;
                            final msg = daysUntilDue == 0
                                ? 'Reminder: Your rent is due today. Please make payment to avoid penalties.'
                                : 'Reminder: Your rent is due in $daysUntilDue days. Please ensure payment before the due date.';
                            await SmsService.sendSms(phoneNumber: phone, message: msg);
                            break;
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showPaymentDialog(BuildContext context, Tenant tenant, Room room, dynamic house) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Record Payment - ${tenant.fullName}'),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                final payment = Payment(
                  id: 'payment-${DateTime.now().millisecondsSinceEpoch}',
                  amount: amount,
                  date: DateTime.now(),
                  notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                );
                final houseService = Provider.of<HouseService>(context, listen: false);
                houseService.recordPayment(
                  houseId: house.id,
                  roomNumber: room.roomNumber,
                  payment: payment,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Record Payment'),
          ),
        ],
      ),
    );
  }
}


