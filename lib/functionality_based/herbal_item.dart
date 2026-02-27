import 'dart:convert';

class HerbalItem {
  final String name;
  final String scientificName;
  final String imageUrl;

  HerbalItem({
    required this.name,
    required this.scientificName,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'scientificName': scientificName,
    'imageUrl': imageUrl,
  };

  factory HerbalItem.fromJson(Map<String, dynamic> json) => HerbalItem(
    name: json['name']?.toString() ?? 'Unknown Plant',
    scientificName: json['scientificName']?.toString() ?? 'Unknown',
    imageUrl: json['imageUrl']?.toString() ?? '',
  );
}