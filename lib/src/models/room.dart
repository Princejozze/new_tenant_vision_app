
import 'package:json_annotation/json_annotation.dart';

part 'room.g.dart';

enum RoomStatus { occupied, vacant, pending }

@JsonSerializable()
class Room {
  final String roomNumber;
  final String? tenantName;
  final double rentAmount;
  final String rentStatus;
  final DateTime startDate;
  final DateTime nextDueDate;
  @JsonKey(defaultValue: RoomStatus.vacant)
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

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  Map<String, dynamic> toJson() => _$RoomToJson(this);
}
