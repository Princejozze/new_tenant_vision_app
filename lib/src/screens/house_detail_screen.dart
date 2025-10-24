
import 'package:flutter/material.dart';
import 'package:myapp/src/models/house.dart';
import 'package:myapp/src/widgets/room_card.dart';

class HouseDetailPage extends StatelessWidget {
  final House house;

  const HouseDetailPage({super.key, required this.house});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            leading: TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Dashboard'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            leadingWidth: 200, // Adjust as needed
            title: Text(house.name, style: Theme.of(context).textTheme.headlineMedium),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  house.address,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey),
                ),
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
                : SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400.0,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: 1.2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        if (index < house.rooms.length) {
                          return RoomCard(room: house.rooms[index]);
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
  }
}
