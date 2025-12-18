import 'package:flutter/material.dart';
import 'package:myapp/src/models/house.dart';
import 'package:myapp/src/models/room.dart';
import 'package:myapp/src/models/tenant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HouseService extends ChangeNotifier {
  List<House> _houses = [];
  static const String _housesKey = 'houses_data';

  List<House> get houses => _houses;

  House? getHouseById(String id) {
    try {
      return _houses.firstWhere((h) => h.id == id);
    } catch (e) {
      print('House not found with ID: $id');
      return null;
    }
  }

  HouseService() {
    _loadHouses();
  }

  Future<void> _loadHouses() async {
    try {
      print('Loading houses from local storage...');
      final prefs = await SharedPreferences.getInstance();
      final housesJson = prefs.getString(_housesKey);
      if (housesJson != null) {
        print('Found saved houses data, parsing...');
        final List<dynamic> housesList = json.decode(housesJson);
        _houses = housesList.map((json) => _houseFromJson(json)).toList();
        print('Loaded ${_houses.length} houses from storage');
        for (var house in _houses) {
          print('House: ${house.name} (ID: ${house.id}) with ${house.rooms.length} rooms');
        }
        notifyListeners();
      } else {
        print('No saved houses data found - starting with empty list');
        _houses = [];
        notifyListeners();
      }
    } catch (e) {
      print('Error loading houses: $e');
      _houses = [];
      notifyListeners();
    }
  }

  Future<void> _saveHouses() async {
    try {
      print('Saving ${_houses.length} houses to local storage...');
      final prefs = await SharedPreferences.getInstance();
      final housesJson = json.encode(_houses.map((house) => _houseToJson(house)).toList());
      await prefs.setString(_housesKey, housesJson);
      print('Successfully saved houses to local storage');
    } catch (e) {
      print('Error saving houses: $e');
    }
  }

  void addHouse({
    required String name,
    required String address,
    required int numberOfRooms,
    String? imageUrl, // Optional image URL, if null will use random image
  }) {
    final rooms = _generateRooms(numberOfRooms);
    print('Generated ${rooms.length} rooms for house: $name');
    
    final newHouse = House(
      id: 'house-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      location: _extractLocationFromAddress(address),
      price: '\$${_generateRandomPrice()}',
      imageUrl: imageUrl ?? _getRandomHouseImage(), // Use provided image or fallback to random
      address: address,
      totalRooms: numberOfRooms,
      occupiedRooms: 0, // New houses start with no occupied rooms
      rooms: rooms,
    );

    print('Created house with ID: ${newHouse.id} and ${newHouse.rooms.length} rooms');
    _houses = [..._houses, newHouse];
    notifyListeners();
    _saveHouses(); // Save to local storage
  }

  void updateRoomInHouse(String houseId, Room updatedRoom, int roomIndex) {
    final houseIndex = _houses.indexWhere((h) => h.id == houseId);
    if (houseIndex != -1) {
      final house = _houses[houseIndex];
      final updatedRooms = List<Room>.from(house.rooms);
      
      if (roomIndex < updatedRooms.length) {
        updatedRooms[roomIndex] = updatedRoom;
        
        // Update occupied rooms count
        final occupiedCount = updatedRooms.where((room) => room.status == RoomStatus.occupied).length;
        
        final updatedHouse = House(
          id: house.id,
          name: house.name,
          location: house.location,
          price: house.price,
          imageUrl: house.imageUrl,
          address: house.address,
          totalRooms: house.totalRooms,
          occupiedRooms: occupiedCount,
          rooms: updatedRooms,
        );
        
        _houses[houseIndex] = updatedHouse;
        print('About to notify listeners for room update');
        notifyListeners();
        print('Listeners notified - room ${updatedRoom.roomNumber} status: ${updatedRoom.status}');
        _saveHouses();
        
        print('Updated room ${updatedRoom.roomNumber} in house ${house.name}');
      }
    }
  }

  // Record a payment for a specific room's tenant and persist
  void recordPayment({
    required String houseId,
    required String roomNumber,
    required Payment payment,
  }) {
    final houseIndex = _houses.indexWhere((h) => h.id == houseId);
    if (houseIndex == -1) return;
    final house = _houses[houseIndex];
    final roomIndex = house.rooms.indexWhere((r) => r.roomNumber == roomNumber);
    if (roomIndex == -1) return;
    final room = house.rooms[roomIndex];
    if (room.tenant == null) return;

    final updatedTenant = room.tenant!.addPayment(payment);
    final updatedRoom = Room(
      roomNumber: room.roomNumber,
      tenant: updatedTenant,
      rentAmount: room.rentAmount,
      rentStatus: room.rentStatus,
      startDate: room.startDate,
      nextDueDate: room.nextDueDate,
      status: room.status,
    );

    updateRoomInHouse(houseId, updatedRoom, roomIndex);
    _saveHouses();
  }

  void updateHouse({
    required String houseId,
    required String name,
    required String address,
    String? imageUrl, // Optional image URL, if null keeps existing image
  }) {
    final houseIndex = _houses.indexWhere((h) => h.id == houseId);
    if (houseIndex != -1) {
      final house = _houses[houseIndex];
      
      final updatedHouse = House(
        id: house.id,
        name: name,
        location: _extractLocationFromAddress(address),
        price: house.price,
        imageUrl: imageUrl ?? house.imageUrl, // Use provided image or keep existing
        address: address,
        totalRooms: house.totalRooms,
        occupiedRooms: house.occupiedRooms,
        rooms: house.rooms,
      );
      
      _houses[houseIndex] = updatedHouse;
      notifyListeners();
      _saveHouses();
      
      print('Updated house ${updatedHouse.name}');
    }
  }

  void deleteHouse(String houseId) {
    _houses.removeWhere((house) => house.id == houseId);
    notifyListeners();
    _saveHouses();
    print('Deleted house with ID: $houseId');
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
    // Return a random house image from Unsplash with more reliable URLs
    final images = [
      'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&h=600&fit=crop&crop=center',
      'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&h=600&fit=crop&crop=center',
      'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800&h=600&fit=crop&crop=center',
      'https://images.unsplash.com/photo-1605146769289-440113cc3d00?w=800&h=600&fit=crop&crop=center',
      'https://images.unsplash.com/photo-1600607687644-c7171b42498b?w=800&h=600&fit=crop&crop=center',
      'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800&h=600&fit=crop&crop=center',
      'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800&h=600&fit=crop&crop=center',
      'https://images.unsplash.com/photo-1605276374104-dee2a0ed3cd6?w=800&h=600&fit=crop&crop=center',
    ];
    final randomIndex = DateTime.now().millisecondsSinceEpoch % images.length;
    return images[randomIndex];
  }

  List<Room> _generateRooms(int numberOfRooms) {
    print('Generating $numberOfRooms rooms...');
    final rooms = <Room>[];
    for (int i = 1; i <= numberOfRooms; i++) {
      final room = Room(
        roomNumber: i.toString(),
        rentAmount: 0.0, // Vacant rooms start with $0 rent
        rentStatus: 'Vacant',
        startDate: DateTime.now(),
        nextDueDate: DateTime.now(),
        status: RoomStatus.vacant,
      );
      rooms.add(room);
      print('Created room ${room.roomNumber} with status ${room.status} and rent ${room.rentAmount}');
    }
    print('Generated ${rooms.length} rooms successfully');
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
      'tenant': room.tenant?.toJson(),
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
}
