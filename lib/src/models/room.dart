enum RoomStatus { occupied, vacant, pending }

class Room {
  final String roomNumber;
  final String? tenantName;
  final double rentAmount;
  final String rentStatus;
  final DateTime startDate;
  final DateTime nextDueDate;
  final RoomStatus status;

  Room({
    required this.roomNumber,
    this.tenantName,
    required this.rentAmount,
    required this.rentStatus,
    required this.startDate,
    required this.nextDueDate,
    required this.status,
  });

  static List<Room> dummyData = [
    Room(
      roomNumber: '1',
      tenantName: 'Aisha Mwinyi',
      rentAmount: 1200,
      rentStatus: 'Overdue',
      startDate: DateTime(2023, 1, 15),
      nextDueDate: DateTime(2024, 7, 15),
      status: RoomStatus.occupied,
    ),
    Room(
      roomNumber: '2',
      tenantName: 'John Doe',
      rentAmount: 1200,
      rentStatus: 'Due Today',
      startDate: DateTime(2023, 2, 1),
      nextDueDate: DateTime.now(),
      status: RoomStatus.occupied,
    ),
    Room(
      roomNumber: '3',
      tenantName: 'Jane Smith',
      rentAmount: 1200,
      rentStatus: 'Paid',
      startDate: DateTime(2023, 3, 20),
      nextDueDate: DateTime(2024, 8, 20),
      status: RoomStatus.occupied,
    ),
    Room(
      roomNumber: '4',
      tenantName: null,
      rentAmount: 1200,
      rentStatus: 'Paid',
      startDate: DateTime(2023, 3, 20),
      nextDueDate: DateTime(2024, 8, 20),
      status: RoomStatus.vacant,
    ),
     Room(
      roomNumber: '5',
      tenantName: null,
      rentAmount: 1200,
      rentStatus: 'Paid',
      startDate: DateTime(2025, 10, 15),
      nextDueDate: DateTime(2025, 11, 15),
      status: RoomStatus.pending,
    ),
  ];
}
