import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/services/house_service.dart';
import 'package:myapp/src/models/room.dart';
import 'package:myapp/src/models/tenant.dart';
import 'package:intl/intl.dart';

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
                  ),
                );
              },
            ),
    );
  }
}


