import 'package:flutter/material.dart';
import 'package:myapp/src/models/house.dart';
import 'package:myapp/src/models/room.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HouseService extends ChangeNotifier {
  List<House> _houses = [];
  static const String _housesKey = 'houses_data';

  List<House> get houses => _houses;

  HouseService() {
    _loadHouses();
  }

  Future<void> _loadHouses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final housesJson = prefs.getString(_housesKey);
      if (housesJson != null) {
        final List<dynamic> housesList = json.decode(housesJson);
        _houses = housesList.map((json) => _houseFromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading houses: $e');
    }
  }

  Future<void> _saveHouses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final housesJson = json.encode(_houses.map((house) => _houseToJson(house)).toList());
      await prefs.setString(_housesKey, housesJson);
    } catch (e) {
      print('Error saving houses: $e');
    }
  }

  void addHouse({
    required String name,
    required String address,
    required int numberOfRooms,
  }) {
    final newHouse = House(
      id: 'house-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      location: _extractLocationFromAddress(address),
      price: '\$${_generateRandomPrice()}',
      imageUrl: _getRandomHouseImage(),
      address: address,
      totalRooms: numberOfRooms,
      occupiedRooms: 0, // New houses start with no occupied rooms
      rooms: _generateRooms(numberOfRooms),
    );

    _houses = [..._houses, newHouse];
    notifyListeners();
    _saveHouses(); // Save to local storage
  }

  String _extractLocationFromAddress(String address) {
    // Extract city and state from address
    final parts = address.split(',');
    if (parts.length >= 2) {
      return parts[1].trim();
    }
    return 'Unknown Location';
  }

  String _generateRandomPrice() {
    // Generate a random price between 1.5M and 5M
    final random = DateTime.now().millisecondsSinceEpoch % 3500000;
    return (1500000 + random).toString();
  }

  String _getRandomHouseImage() {
    // Return a random house image from Unsplash
    final images = [
      'https://images.unsplash.com/photo-1613490493576-7fde63acd811?q=80&w=2940&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?q=80&w=2874&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?q=80&w=2853&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1605146769289-440113cc3d00?q=80&w=2870&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1600607687644-c7171b42498b?q=80&w=2940&auto=format&fit=crop',
    ];
    final randomIndex = DateTime.now().millisecondsSinceEpoch % images.length;
    return images[randomIndex];
  }

  List<Room> _generateRooms(int numberOfRooms) {
    final rooms = <Room>[];
    for (int i = 1; i <= numberOfRooms; i++) {
      rooms.add(Room(
        roomNumber: i.toString(),
        rentAmount: 1200.0,
        rentStatus: 'Vacant',
        startDate: DateTime.now(),
        nextDueDate: DateTime.now(),
        status: RoomStatus.vacant,
      ));
    }
    return rooms;
  }

  // JSON serialization methods
  Map<String, dynamic> _houseToJson(House house) {
    return {
      'id': house.id,
      'name': house.name,
      'location': house.location,
      'price': house.price,
      'imageUrl': house.imageUrl,
      'address': house.address,
      'totalRooms': house.totalRooms,
      'occupiedRooms': house.occupiedRooms,
      'rooms': house.rooms.map((room) => _roomToJson(room)).toList(),
    };
  }

  House _houseFromJson(Map<String, dynamic> json) {
    return House(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      price: json['price'],
      imageUrl: json['imageUrl'],
      address: json['address'],
      totalRooms: json['totalRooms'],
      occupiedRooms: json['occupiedRooms'],
      rooms: (json['rooms'] as List).map((roomJson) => _roomFromJson(roomJson)).toList(),
    );
  }

  Map<String, dynamic> _roomToJson(Room room) {
    return {
      'roomNumber': room.roomNumber,
      'tenantName': room.tenantName,
      'rentAmount': room.rentAmount,
      'rentStatus': room.rentStatus,
      'startDate': room.startDate.toIso8601String(),
      'nextDueDate': room.nextDueDate.toIso8601String(),
      'status': room.status.toString().split('.').last,
    };
  }

  Room _roomFromJson(Map<String, dynamic> json) {
    return Room(
      roomNumber: json['roomNumber'],
      tenantName: json['tenantName'],
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
}
