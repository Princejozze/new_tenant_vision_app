import 'package:myapp/src/models/tenant.dart';

enum RoomStatus { occupied, vacant, pending }

class Room {
  final String roomNumber;
  final Tenant? tenant;
  final double rentAmount;
  final String rentStatus;
  final DateTime startDate;
  final DateTime nextDueDate;
  final RoomStatus status;

  Room({
    required this.roomNumber,
    this.tenant,
    required this.rentAmount,
    required this.rentStatus,
    required this.startDate,
    required this.nextDueDate,
    required this.status,
  });

  // Get tenant name or default text
  String get tenantName => tenant?.fullName ?? 'No tenant assigned';

  // Get current rent amount (from tenant or default)
  double get currentRentAmount => tenant?.monthlyRent ?? rentAmount;

  // Get payment status
  String get paymentStatus => tenant?.paymentStatus ?? 'No tenant assigned';

  // Check if overdue
  bool get isOverdue => tenant?.isOverdue ?? false;

  // Get next due date
  DateTime get currentNextDueDate => tenant?.nextDueDate ?? nextDueDate;

  // Add tenant to room
  Room addTenant(Tenant newTenant) {
    return Room(
      roomNumber: roomNumber,
      tenant: newTenant,
      rentAmount: newTenant.monthlyRent,
      rentStatus: 'Occupied',
      startDate: newTenant.startDate,
      nextDueDate: newTenant.nextDueDate,
      status: RoomStatus.occupied,
    );
  }

  // Remove tenant from room
  Room removeTenant() {
    return Room(
      roomNumber: roomNumber,
      tenant: null,
      rentAmount: rentAmount,
      rentStatus: 'Vacant',
      startDate: DateTime.now(),
      nextDueDate: DateTime.now(),
      status: RoomStatus.vacant,
    );
  }

  // Update tenant information
  Room updateTenant(Tenant updatedTenant) {
    return Room(
      roomNumber: roomNumber,
      tenant: updatedTenant,
      rentAmount: updatedTenant.monthlyRent,
      rentStatus: 'Occupied',
      startDate: updatedTenant.startDate,
      nextDueDate: updatedTenant.nextDueDate,
      status: RoomStatus.occupied,
    );
  }

  // Add payment to tenant
  Room addPayment(Payment payment) {
    if (tenant == null) return this;
    final updatedTenant = tenant!.addPayment(payment);
    return updateTenant(updatedTenant);
  }

  Map<String, dynamic> toJson() {
    return {
      'roomNumber': roomNumber,
      'tenant': tenant?.toJson(),
      'rentAmount': rentAmount,
      'rentStatus': rentStatus,
      'startDate': startDate.toIso8601String(),
      'nextDueDate': nextDueDate.toIso8601String(),
      'status': status.toString().split('.').last,
    };
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomNumber: json['roomNumber'],
      tenant: json['tenant'] != null ? Tenant.fromJson(json['tenant']) : null,
      rentAmount: json['rentAmount'].toDouble(),
      rentStatus: json['rentStatus'],
      startDate: DateTime.parse(json['startDate']),
      nextDueDate: DateTime.parse(json['nextDueDate']),
      status: RoomStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => RoomStatus.vacant,
      ),
    );
  }

  static List<Room> dummyData = [];
}
