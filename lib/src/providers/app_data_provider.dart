
import 'package:flutter/material.dart';
import 'package:myapp/src/models/house.dart';
import 'package:myapp/src/services/storage_service.dart';

class AppDataProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<House> _houses = [];
  bool _isLoading = true;

  List<House> get houses => _houses;
  bool get isLoading => _isLoading;

  AppDataProvider() {
    loadHouses();
  }

  Future<void> loadHouses() async {
    _isLoading = true;
    notifyListeners();
    _houses = await _storageService.loadHouses();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addHouse(House house) async {
    _houses.add(house);
    await _storageService.saveHouses(_houses);
    notifyListeners();
  }

  House getHouseById(String id) {
    return _houses.firstWhere((house) => house.id == id);
  }
}
