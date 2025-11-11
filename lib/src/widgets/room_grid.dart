import 'package:flutter/material.dart';
import 'package:myapp/src/models/room.dart';
import 'package:myapp/src/widgets/room_card.dart';

class RoomGrid extends StatelessWidget {
  const RoomGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Room> rooms = Room.dummyData;
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine the number of columns based on screen width
    int crossAxisCount;
    if (screenWidth >= 1200) {
      crossAxisCount = 3;
    } else if (screenWidth >= 800) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    // Adjust aspect ratio for better card proportions
    const double childAspectRatio = 0.7;

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        return RoomCard(
          room: rooms[index],
          onRoomUpdated: (updatedRoom) {
            print('Room updated: ${updatedRoom.roomNumber}');
          },
          // No house context here (dummy grid)
        );
      },
    );
  }
}
