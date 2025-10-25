
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/src/models/house.dart';

class StorageService {
  static const _housesKey = 'houses';

  Future<void> saveHouses(List<House> houses) async {
    final prefs = await SharedPreferences.getInstance();
    final housesJson = houses.map((house) => house.toJson()).toList();
    await prefs.setString(_housesKey, json.encode(housesJson));
  }

  Future<List<House>> loadHouses() async {
    final prefs = await SharedPreferences.getInstance();
    final housesString = prefs.getString(_housesKey);
    if (housesString == null) {
      return [];
    }
    final List<dynamic> housesJson = json.decode(housesString);
    return housesJson.map((json) => House.fromJson(json as Map<String, dynamic>)).toList();
  }
}
