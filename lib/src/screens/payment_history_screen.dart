import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/services/house_service.dart';
import 'package:myapp/src/models/room.dart';
import 'package:myapp/src/models/tenant.dart';
import 'package:myapp/src/widgets/payment_row_widget.dart';
import 'package:intl/intl.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final houseService = Provider.of<HouseService>(context);
    
    // Group all payments by tenant so each tenant appears once
    final Map<String, Map<String, dynamic>> tenantIdToGroup = {};
    int totalPaymentsCount = 0;

    for (var house in houseService.houses) {
      for (var room in house.rooms) {
        if (room.status == RoomStatus.occupied && room.tenant != null) {
          final tenant = room.tenant!;
          final key = tenant.id;

          tenantIdToGroup.putIfAbsent(key, () => {
            'tenant': tenant,
            'room': room,
            'house': house.name,
            'payments': <Payment>[],
          });

          for (var payment in tenant.payments) {
            (tenantIdToGroup[key]!['payments'] as List<Payment>).add(payment);
            totalPaymentsCount++;
          }
        }
      }
    }

    // Sort each tenant's payments by newest first and then sort tenants by latest payment
    final groupedPayments = tenantIdToGroup.values.toList();
    for (final g in groupedPayments) {
      final list = g['payments'] as List<Payment>;
      list.sort((a, b) => b.date.compareTo(a.date));
    }
    groupedPayments.sort((a, b) {
      final ap = (a['payments'] as List<Payment>);
      final bp = (b['payments'] as List<Payment>);
      final aLatest = ap.isNotEmpty ? ap.first.date : DateTime.fromMillisecondsSinceEpoch(0);
      final bLatest = bp.isNotEmpty ? bp.first.date : DateTime.fromMillisecondsSinceEpoch(0);
      return bLatest.compareTo(aLatest);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Add export all receipts functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export all receipts feature coming soon!'),
                ),
              );
            },
            icon: const Icon(Icons.download),
            tooltip: 'Export All Receipts',
          ),
        ],
      ),
      body: groupedPayments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Payments Yet',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Payment history will appear here once tenants start making payments',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Summary card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.payments,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Payments',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '$totalPaymentsCount payments',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0).format(
                          groupedPayments.fold(0.0, (sum, group) {
                            final payments = group['payments'] as List<Payment>;
                            return sum + payments.fold<double>(0.0, (s, p) => s + p.amount);
                          }),
                        ),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Payments grouped by tenant (collapsible)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: groupedPayments.length,
                    itemBuilder: (context, index) {
                      final data = groupedPayments[index];
                      final tenant = data['tenant'] as Tenant;
                      final room = data['room'] as Room;
                      final houseName = data['house'] as String;
                      final payments = data['payments'] as List<Payment>;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          title: Text(
                            tenant.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            '$houseName • Room ${room.roomNumber}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          trailing: Text(
                            NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0).format(
                              payments.fold<double>(0.0, (s, p) => s + p.amount),
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                          children: [
                            ...payments.map((payment) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: PaymentRowWidget(
                                    payment: payment,
                                    tenant: tenant,
                                    room: room,
                                    propertyName: houseName,
                                  ),
                                )),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
