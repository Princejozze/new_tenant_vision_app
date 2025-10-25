
import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/src/models/room.dart';

part 'house.g.dart';

@JsonSerializable(explicitToJson: true)
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

  factory House.fromJson(Map<String, dynamic> json) => _$HouseFromJson(json);

  Map<String, dynamic> toJson() => _$HouseToJson(this);
}
