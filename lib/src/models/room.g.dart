// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map<String, dynamic> json) => Room(
      roomNumber: json['roomNumber'] as String,
      tenantName: json['tenantName'] as String?,
      rentAmount: (json['rentAmount'] as num).toDouble(),
      rentStatus: json['rentStatus'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      nextDueDate: DateTime.parse(json['nextDueDate'] as String),
      status: $enumDecodeNullable(_$RoomStatusEnumMap, json['status']) ??
          RoomStatus.vacant,
    );

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
      'roomNumber': instance.roomNumber,
      'tenantName': instance.tenantName,
      'rentAmount': instance.rentAmount,
      'rentStatus': instance.rentStatus,
      'startDate': instance.startDate.toIso8601String(),
      'nextDueDate': instance.nextDueDate.toIso8601String(),
      'status': _$RoomStatusEnumMap[instance.status]!,
    };

const _$RoomStatusEnumMap = {
  RoomStatus.occupied: 'occupied',
  RoomStatus.vacant: 'vacant',
  RoomStatus.pending: 'pending',
};
