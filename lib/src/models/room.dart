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

  static List<Room> dummyData = [];
}
