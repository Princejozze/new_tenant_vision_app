import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/services/house_service.dart';
import 'package:myapp/src/models/tenant.dart';
import 'package:myapp/src/models/room.dart';

class TenantSearchDialog extends StatefulWidget {
  const TenantSearchDialog({super.key});

  @override
  State<TenantSearchDialog> createState() => _TenantSearchDialogState();
}

class _TenantSearchDialogState extends State<TenantSearchDialog> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    // Load all tenants when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllTenants();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadAllTenants() {
    final houseService = Provider.of<HouseService>(context, listen: false);
    final results = <Map<String, dynamic>>[];

    // Get all tenants from all houses in order
    for (var house in houseService.houses) {
      for (var room in house.rooms) {
        if (room.tenant != null) {
          results.add({
            'tenant': room.tenant!,
            'room': room,
            'house': house,
          });
        }
      }
    }

    setState(() {
      _searchResults = results;
    });
  }

  void _searchTenants(String query) {
    print('Searching for: $query');
    if (query.isEmpty) {
      // When search is empty, show all tenants
      _loadAllTenants();
      return;
    }

    final houseService = Provider.of<HouseService>(context, listen: false);
    final results = <Map<String, dynamic>>[];

    print('Total houses: ${houseService.houses.length}');
    // Search through all houses and rooms
    for (var house in houseService.houses) {
      print('House: ${house.name}, Rooms: ${house.rooms.length}');
      for (var room in house.rooms) {
        if (room.tenant != null) {
          final tenant = room.tenant!;
          final searchText = query.toLowerCase();
          
          print('Checking tenant: ${tenant.fullName}');
          // Check if query matches tenant name
          if (tenant.fullName.toLowerCase().contains(searchText) ||
              tenant.firstName.toLowerCase().contains(searchText) ||
              tenant.lastName.toLowerCase().contains(searchText)) {
            print('Match found: ${tenant.fullName}');
            results.add({
              'tenant': tenant,
              'room': room,
              'house': house,
            });
          }
        }
      }
    }

    print('Search results: ${results.length}');
    setState(() {
      _searchResults = results;
    });
  }

  void _openPaymentDialog(Tenant tenant, Room room, BuildContext context) {
    Navigator.of(context).pop(); // Close search dialog
    _showAddPaymentDialog(context, tenant, room);
  }

  void _showAddPaymentDialog(BuildContext context, Tenant tenant, Room room) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Payment - ${tenant.fullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Room ${room.roomNumber}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
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
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                final houseService = Provider.of<HouseService>(context, listen: false);
                final updatedRoom = room.addPayment(
                  Payment(
                    id: 'payment-${DateTime.now().millisecondsSinceEpoch}',
                    amount: amount,
                    date: DateTime.now(),
                    notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                  ),
                );
                
                // Update the house with the updated room
                final updatedRooms = houseService.houses
                    .firstWhere((h) => h.rooms.contains(room))
                    .rooms
                    .map((r) => r.roomNumber == room.roomNumber ? updatedRoom : r)
                    .toList();
                
                houseService.notifyListeners();
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Payment of ${NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0).format(amount)} recorded for ${tenant.fullName}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Record Payment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('TenantSearchDialog build called');
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Find Tenant & Add Payment',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Search field
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by tenant name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _searchTenants,
            ),
            const SizedBox(height: 16),
            
            // Results
            Expanded(
              child: _searchResults.isEmpty && _searchController.text.isNotEmpty
                  ? Center(
                      child: Text(
                        'No tenants found',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : _searchResults.isEmpty
                      ? Center(
                          child: Text(
                            'No tenants available',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final result = _searchResults[index];
                            final tenant = result['tenant'] as Tenant;
                            final room = result['room'] as Room;
                            final house = result['house'];
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: colorScheme.primary,
                                  child: Text(
                                    tenant.fullName.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  tenant.fullName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${house.name} - Room ${room.roomNumber}'),
                                    Text('Balance: ${NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0).format(tenant.balance)}'),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.payment),
                                  onPressed: () => _openPaymentDialog(tenant, room, context),
                                ),
                                onTap: () => _openPaymentDialog(tenant, room, context),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

