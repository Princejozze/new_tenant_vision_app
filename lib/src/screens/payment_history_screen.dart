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
    
    // Collect all payments from all tenants
    final allPayments = <Map<String, dynamic>>[];
    
    for (var house in houseService.houses) {
      for (var room in house.rooms) {
        if (room.status == RoomStatus.occupied && room.tenant != null) {
          final tenant = room.tenant!;
          for (var payment in tenant.payments) {
            allPayments.add({
              'payment': payment,
              'tenant': tenant,
              'room': room,
              'house': house.name,
            });
          }
        }
      }
    }
    
    // Sort by payment date (newest first)
    allPayments.sort((a, b) => 
      (b['payment'] as Payment).date.compareTo((a['payment'] as Payment).date)
    );

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
      body: allPayments.isEmpty
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
                              '${allPayments.length} payments',
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
                          allPayments.fold(0.0, (sum, item) => 
                            sum + (item['payment'] as Payment).amount
                          ),
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
                
                // Payments list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: allPayments.length,
                    itemBuilder: (context, index) {
                      final data = allPayments[index];
                      final payment = data['payment'] as Payment;
                      final tenant = data['tenant'] as Tenant;
                      final room = data['room'] as Room;
                      final houseName = data['house'] as String;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with tenant info
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                    child: Icon(
                                      Icons.person,
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tenant.fullName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          '$houseName • Room ${room.roomNumber}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0).format(payment.amount),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Payment details with download button
                              PaymentRowWidget(
                                payment: payment,
                                tenant: tenant,
                                room: room,
                                propertyName: houseName,
                              ),
                            ],
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
}
