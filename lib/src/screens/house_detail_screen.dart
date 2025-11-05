
import 'package:flutter/material.dart';
import 'package:myapp/src/models/house.dart';
import 'package:myapp/src/models/room.dart';
import 'package:myapp/src/widgets/room_card.dart';
import 'package:myapp/src/services/house_service.dart';
import 'package:provider/provider.dart';

class HouseDetailPage extends StatelessWidget {
  final String houseId;

  const HouseDetailPage({
    super.key, 
    required this.houseId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HouseService>(
      builder: (context, houseService, child) {
        print('=== HouseDetailPage Consumer rebuilding for houseId: $houseId ===');
        print('Total houses in service: ${houseService.houses.length}');
        final house = houseService.getHouseById(houseId);
        print('Found house: ${house?.name} with ${house?.rooms.length} rooms');
        print('House rooms statuses: ${house?.rooms.map((r) => '${r.roomNumber}:${r.status}').join(', ')}');
        
        if (house == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('House not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back to Dashboard'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                leading: TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                leadingWidth: 200,
                title: Text(house.name, style: Theme.of(context).textTheme.headlineMedium),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      house.address,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      print('Test button pressed - forcing notifyListeners');
                      houseService.notifyListeners();
                    },
                    icon: Icon(Icons.refresh),
                    tooltip: 'Test Rebuild',
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: house.rooms.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.room_outlined,
                                size: 64,
                                color: Theme.of(context).colorScheme.onSurface.withAlpha(102),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Rooms Yet',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'This house has no rooms configured yet.',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            if (index < house.rooms.length) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: RoomCard(
                                  key: ValueKey('${house.rooms[index].roomNumber}-${house.rooms[index].tenant?.id ?? 'vacant'}'),
                                  room: house.rooms[index],
                                  onRoomUpdated: (updatedRoom) {
                                    print('Room updated callback triggered for room ${updatedRoom.roomNumber}');
                                    houseService.updateRoomInHouse(houseId, updatedRoom, index);
                                  },
                                ),
                              );
                            }
                            return null;
                          },
                          childCount: house.rooms.length,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
