import 'package:myapp/src/models/room.dart';

class House {
  final String id;
  final String name;
  final String location;
  final String price;
  final String imageUrl;
  final String address;
  final int totalRooms;
  final int occupiedRooms;
  final List<Room> rooms;

  House({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.address,
    required this.totalRooms,
    required this.occupiedRooms,
    required this.rooms,
  });

  static List<House> get dummyData => [
        House(
          id: 'house-1',
          name: 'Modern Glass House',
          location: 'New York, USA',
          price: '\$2,500,000',
          imageUrl: 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?q=80&w=2940&auto=format&fit=crop',
          address: '123 Luxury Ave, New York, NY',
          totalRooms: 5,
          occupiedRooms: 3,
          rooms: [
            Room(roomNumber: '1', tenantName: 'Aisha Mwinyi', rentAmount: 1200, rentStatus: 'Overdue', startDate: DateTime(2023, 1, 15), nextDueDate: DateTime(2024, 7, 15), status: RoomStatus.occupied),
            Room(roomNumber: '2', tenantName: 'John Doe', rentAmount: 1200, rentStatus: 'Due Today', startDate: DateTime(2023, 2, 1), nextDueDate: DateTime(2024, 8, 1), status: RoomStatus.occupied),
            Room(roomNumber: '3', tenantName: 'Jane Smith', rentAmount: 1200, rentStatus: 'On Track', startDate: DateTime(2023, 3, 20), nextDueDate: DateTime(2024, 9, 20), status: RoomStatus.occupied),
            Room(roomNumber: '4', rentAmount: 1200, rentStatus: 'Vacant', startDate: DateTime.now(), nextDueDate: DateTime.now(), status: RoomStatus.vacant),
            Room(roomNumber: '5', rentAmount: 1200, rentStatus: 'Pending', startDate: DateTime.now(), nextDueDate: DateTime.now(), status: RoomStatus.pending),
          ],
        ),
        House(
          id: 'house-2',
          name: 'Luxury Villa',
          location: 'Los Angeles, USA',
          price: '\$4,200,000',
          imageUrl: 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?q=80&w=2874&auto=format&fit=crop',
          address: '456 Grand View, Los Angeles, CA',
          totalRooms: 7,
          occupiedRooms: 6,
           rooms: [
            Room(roomNumber: '1', tenantName: 'Aisha Mwinyi', rentAmount: 1200, rentStatus: 'Overdue', startDate: DateTime(2023, 1, 15), nextDueDate: DateTime(2024, 7, 15), status: RoomStatus.occupied),
            Room(roomNumber: '2', tenantName: 'John Doe', rentAmount: 1200, rentStatus: 'Due Today', startDate: DateTime(2023, 2, 1), nextDueDate: DateTime(2024, 8, 1), status: RoomStatus.occupied),
            Room(roomNumber: '3', tenantName: 'Jane Smith', rentAmount: 1200, rentStatus: 'On Track', startDate: DateTime(2023, 3, 20), nextDueDate: DateTime(2024, 9, 20), status: RoomStatus.occupied),
            Room(roomNumber: '4', tenantName: 'Aisha Mwinyi', rentAmount: 1200, rentStatus: 'Overdue', startDate: DateTime(2023, 1, 15), nextDueDate: DateTime(2024, 7, 15), status: RoomStatus.occupied),
            Room(roomNumber: '5', tenantName: 'John Doe', rentAmount: 1200, rentStatus: 'Due Today', startDate: DateTime(2023, 2, 1), nextDueDate: DateTime(2024, 8, 1), status: RoomStatus.occupied),
            Room(roomNumber: '6', tenantName: 'Jane Smith', rentAmount: 1200, rentStatus: 'On Track', startDate: DateTime(2023, 3, 20), nextDueDate: DateTime(2024, 9, 20), status: RoomStatus.occupied),
            Room(roomNumber: '7', rentAmount: 1200, rentStatus: 'Vacant', startDate: DateTime.now(), nextDueDate: DateTime.now(), status: RoomStatus.vacant),
          ],
        ),
        // Add more houses with updated Room objects here...
      ];
}
