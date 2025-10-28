import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class TenantHistoryScreen extends StatelessWidget {
  const TenantHistoryScreen({super.key});

  Future<List<PastTenant>> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('tenant_history');
    if (historyJson != null) {
      return (json.decode(historyJson) as List)
          .map((json) => PastTenant.fromJson(json))
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant History'),
      ),
      body: FutureBuilder<List<PastTenant>>(
        future: _loadHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No tenant history yet',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final tenant = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    tenant.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Moved out on ${DateFormat('MMM dd, yyyy').format(tenant.moveOutDate)}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Property', tenant.property),
                          _buildInfoRow('Room', 'Room ${tenant.roomNumber}'),
                          _buildInfoRow('Move-in Date', DateFormat('MMM dd, yyyy').format(tenant.moveInDate)),
                          _buildInfoRow('Move-out Date', DateFormat('MMM dd, yyyy').format(tenant.moveOutDate)),
                          if (tenant.note != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      tenant.note!,
                                      style: TextStyle(color: Colors.orange[900]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const Divider(),
                          if (tenant.paymentHistory.isNotEmpty) ...[
                            const Text(
                              'Payment History',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...tenant.paymentHistory.map((payment) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat('MMM dd, yyyy').format(payment.date),
                                      ),
                                      Text(
                                        NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0).format(payment.amount),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                )),
                          ] else
                            const Text(
                              'No payment history available',
                              style: TextStyle(color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}

class PastTenant {
  final String id;
  final String fullName;
  final String property;
  final String roomNumber;
  final DateTime moveInDate;
  final DateTime moveOutDate;
  final List<HistoricalPayment> paymentHistory;
  final String? note;

  PastTenant({
    required this.id,
    required this.fullName,
    required this.property,
    required this.roomNumber,
    required this.moveInDate,
    required this.moveOutDate,
    required this.paymentHistory,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'property': property,
        'roomNumber': roomNumber,
        'moveInDate': moveInDate.toIso8601String(),
        'moveOutDate': moveOutDate.toIso8601String(),
        'paymentHistory': paymentHistory.map((p) => p.toJson()).toList(),
        'note': note,
      };

  factory PastTenant.fromJson(Map<String, dynamic> json) => PastTenant(
        id: json['id'],
        fullName: json['fullName'],
        property: json['property'],
        roomNumber: json['roomNumber'],
        moveInDate: DateTime.parse(json['moveInDate']),
        moveOutDate: DateTime.parse(json['moveOutDate']),
        paymentHistory: (json['paymentHistory'] as List?)
                ?.map((p) => HistoricalPayment.fromJson(p))
                .toList() ??
            [],
        note: json['note'],
      );
}

class HistoricalPayment {
  final double amount;
  final DateTime date;

  HistoricalPayment({required this.amount, required this.date});

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'date': date.toIso8601String(),
      };

  factory HistoricalPayment.fromJson(Map<String, dynamic> json) => HistoricalPayment(
        amount: json['amount'].toDouble(),
        date: DateTime.parse(json['date']),
      );
}

