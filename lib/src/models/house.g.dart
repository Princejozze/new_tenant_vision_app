// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'house.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

House _$HouseFromJson(Map<String, dynamic> json) => House(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      price: json['price'] as String,
      imageUrl: json['imageUrl'] as String,
      address: json['address'] as String,
      totalRooms: (json['totalRooms'] as num).toInt(),
      occupiedRooms: (json['occupiedRooms'] as num).toInt(),
      rooms: (json['rooms'] as List<dynamic>)
          .map((e) => Room.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HouseToJson(House instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'location': instance.location,
      'price': instance.price,
      'imageUrl': instance.imageUrl,
      'address': instance.address,
      'totalRooms': instance.totalRooms,
      'occupiedRooms': instance.occupiedRooms,
      'rooms': instance.rooms.map((e) => e.toJson()).toList(),
    };
