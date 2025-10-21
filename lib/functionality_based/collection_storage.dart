import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'herbal_item.dart';

class CollectionStorage {
  static const _key = 'savedPlants';

  static Future<List<HerbalItem>> getSavedPlants() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_key) ?? [];
    return jsonList
        .map((jsonString) => HerbalItem.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  static Future<void> _savePlantList(List<HerbalItem> plants) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList =
    plants.map((plant) => jsonEncode(plant.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  static Future<void> savePlant(HerbalItem plant) async {
    List<HerbalItem> plants = await getSavedPlants();
    if (!plants.any((p) => p.scientificName == plant.scientificName)) {
      plants.add(plant);
      await _savePlantList(plants);
    }
  }

  static Future<void> removePlant(String scientificName) async {
    List<HerbalItem> plants = await getSavedPlants();
    plants.removeWhere((p) => p.scientificName == scientificName);
    await _savePlantList(plants);
  }

  static Future<bool> isPlantSaved(String scientificName) async {
    List<HerbalItem> plants = await getSavedPlants();
    return plants.any((p) => p.scientificName == scientificName);
  }
}