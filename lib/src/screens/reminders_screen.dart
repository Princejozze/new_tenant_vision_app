import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/services/house_service.dart';
import 'package:myapp/src/models/room.dart';
import 'package:myapp/src/models/tenant.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/services/sms_service.dart';
import 'package:myapp/src/services/receipt_service.dart';
import 'package:url_launcher/url_launcher.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.teal,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'UPCOMING'),
            Tab(text: 'OVERDUE'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _UpcomingTab(),
          _OverdueTab(),
        ],
      ),
    );
  }
}

class _UpcomingTab extends StatelessWidget {
  const _UpcomingTab();

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
      floatingActionButton: upcomingTenants.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async {
                final numbers = upcomingTenants
                    .map((e) => (e['tenant'] as Tenant).phone)
                    .whereType<String>()
                    .where((p) => p.trim().isNotEmpty)
                    .toList();
                if (numbers.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No phone numbers available')),
                  );
                  return;
                }
                final message = 'Reminder: Your rent is due soon. Please ensure payment before the due date to avoid penalties.';
                await SmsService.sendGroupSms(phoneNumbers: numbers, message: message);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('SMS notifications sent')),
                  );
                }
              },
              tooltip: 'Notify all upcoming by SMS',
              child: const Icon(Icons.sms),
            )
          : null,
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

class _OverdueTab extends StatefulWidget {
  const _OverdueTab();

  @override
  State<_OverdueTab> createState() => _OverdueTabState();
}

class _OverdueTabState extends State<_OverdueTab> {
  List<Map<String, dynamic>> _overdueTenants = [];

  @override
  void initState() {
    super.initState();
    _loadOverdueTenants();
  }

  void _loadOverdueTenants() {
    final houseService = Provider.of<HouseService>(context, listen: false);
    final overdue = <Map<String, dynamic>>[];
    
    for (var house in houseService.houses) {
      for (var room in house.rooms) {
        if (room.status == RoomStatus.occupied && room.tenant != null) {
          final tenant = room.tenant!;
          if (tenant.isOverdue) {
            final monthsOverdue = (tenant.balance / tenant.monthlyRent).ceil();
            overdue.add({
              'tenant': tenant,
              'room': room,
              'house': house,
              'amountOwed': tenant.balance,
              'monthsOverdue': monthsOverdue,
            });
          }
        }
      }
    }
    
    // Sort by highest amount owed
    overdue.sort((a, b) => 
      (b['amountOwed'] as double).compareTo(a['amountOwed'] as double)
    );
    
    setState(() {
      _overdueTenants = overdue;
    });
  }

  void _notifyByEmail(Tenant tenant, Room room) {
    if (tenant.email == null || tenant.email!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This tenant has no email address')),
      );
      return;
    }
    // TODO: Implement email notification
  }

  void _notifyBySMS(Tenant tenant, Room room) async {
    if (tenant.phone == null || tenant.phone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This tenant has no phone number')),
      );
      return;
    }
    final msg = 'Notice: Your rent is overdue. Please pay immediately to avoid further penalties.';
    await SmsService.sendSms(phoneNumber: tenant.phone!, message: msg);
  }

  void _recordPayment(Tenant tenant, Room room) {
    showDialog(
      context: context,
      builder: (context) => _PaymentDialog(
        tenant: tenant,
        room: room,
        onPaymentRecorded: () {
          _loadOverdueTenants();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: _overdueTenants.isEmpty
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
                    'No tenants have overdue payments',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                if (_hasContacts)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _hasEmails ? _notifyAllByEmail : null,
                            icon: const Icon(Icons.email),
                            label: const Text('Notify All by Email'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _hasPhones ? _notifyAllBySMS : null,
                            icon: const Icon(Icons.sms),
                            label: const Text('Notify All by SMS'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _overdueTenants.length,
                    itemBuilder: (context, index) {
                      final data = _overdueTenants[index];
                      final tenant = data['tenant'] as Tenant;
                      final room = data['room'] as Room;
                      final house = data['house'];
                      final amountOwed = data['amountOwed'] as double;
                      final monthsOverdue = data['monthsOverdue'] as int;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
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
                              Row(
                                children: [
                                  Chip(
                                    label: Text(
                                      '$monthsOverdue ${monthsOverdue == 1 ? 'month' : 'months'} overdue',
                                    ),
                                    backgroundColor: Colors.red,
                                    labelStyle: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Amount: ${NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0).format(amountOwed)}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
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
                            onSelected: (value) {
                              switch (value) {
                                case 'record':
                                  _recordPayment(tenant, room);
                                  break;
                                case 'email':
                                  _notifyByEmail(tenant, room);
                                  break;
                                case 'sms':
                                  _notifyBySMS(tenant, room);
                                  break;
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  bool get _hasContacts => _hasEmails || _hasPhones;
  bool get _hasEmails => _overdueTenants.any(
    (item) => (item['tenant'] as Tenant).email != null,
  );
  bool get _hasPhones => _overdueTenants.any(
    (item) => (item['tenant'] as Tenant).phone != null,
  );

  void _notifyAllByEmail() {}
  void _notifyAllBySMS() async {
    final numbers = _overdueTenants
        .map((e) => (e['tenant'] as Tenant).phone)
        .whereType<String>()
        .where((p) => p.trim().isNotEmpty)
        .toList();
    if (numbers.isEmpty) return;
    final message = 'Notice: Your rent is overdue. Please pay immediately to avoid further penalties.';
    await SmsService.sendGroupSms(phoneNumbers: numbers, message: message);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SMS notifications sent')),
      );
    }
  }
}

class _PaymentDialog extends StatelessWidget {
  final Tenant tenant;
  final Room room;
  final Function onPaymentRecorded;

  const _PaymentDialog({
    required this.tenant,
    required this.room,
    required this.onPaymentRecorded,
  });

  @override
  Widget build(BuildContext context) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    return AlertDialog(
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
          onPressed: () async {
            final amount = double.tryParse(amountController.text);
            if (amount != null && amount > 0) {
              final payment = Payment(
                id: 'payment-${DateTime.now().millisecondsSinceEpoch}',
                amount: amount,
                date: DateTime.now(),
                notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
              );
              
              // Persist payment via service
              final houseService = Provider.of<HouseService>(context, listen: false);
              // Find this room's house id
              final house = houseService.houses.firstWhere((h) => h.rooms.contains(room));
              houseService.recordPayment(
                houseId: house.id,
                roomNumber: room.roomNumber,
                payment: payment,
              );

              Navigator.pop(context);
              onPaymentRecorded();
              
              // Automatically download receipt
              try {
                final success = await ReceiptService.downloadReceipt(
                  payment: payment,
                  tenant: tenant,
                  room: room,
                  propertyName: house.name,
                );
                
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment recorded and receipt downloaded!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment recorded, but receipt download failed'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment recorded, but receipt download failed'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            }
          },
          child: const Text('Record Payment'),
        ),
      ],
    );
  }
}
