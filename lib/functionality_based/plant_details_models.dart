class PlantDetails {
  final String commonName;
  final String scientificName;
  final String about;
  final QuickInfo quickInfo;
  final Uses uses;
  final String imageUrl;
  final GrowthGuide growthGuide;
  final Extras extras;

  PlantDetails({
    required this.commonName,
    required this.scientificName,
    required this.about,
    required this.quickInfo,
    required this.imageUrl,
    required this.uses,
    required this.growthGuide,
    required this.extras,
  });

  factory PlantDetails.fromJson(Map<String, dynamic> json) {
    return PlantDetails(
      commonName: json['commonName'] ?? 'N/A',
      scientificName: json['scientificName'] ?? 'N/A',
      about: json['about'] ?? 'No description available.',
      imageUrl: (json['imageUrl'] as String? ?? '').startsWith('http') ? json['imageUrl'] : '',
      quickInfo: QuickInfo.fromJson(json['quickInfo'] ?? {}),
      uses: Uses.fromJson(json['uses'] ?? {}),
      growthGuide: GrowthGuide.fromJson(json['growthGuide'] ?? {}),
      extras: Extras.fromJson(json['extras'] ?? {}),
    );
  }
}

class QuickInfo {
  final String sunlight;
  final String watering;
  final String petSafety;
  final String growthEase;

  QuickInfo({
    required this.sunlight,
    required this.watering,
    required this.petSafety,
    required this.growthEase,
  });

  factory QuickInfo.fromJson(Map<String, dynamic> json) {
    return QuickInfo(
      sunlight: json['sunlight'] ?? 'N/A',
      watering: json['watering'] ?? 'N/A',
      petSafety: json['petSafety'] ?? 'N/A',
      growthEase: json['growthEase'] ?? 'N/A',
    );
  }
}

class Uses {
  final List<String> medicinal;
  final List<String> culinary;

  Uses({required this.medicinal, required this.culinary});

  factory Uses.fromJson(Map<String, dynamic> json) {
    return Uses(
      medicinal: List<String>.from(json['medicinal'] ?? []),
      culinary: List<String>.from(json['culinary'] ?? []),
    );
  }
}

class GrowthGuide {
  final String climate;
  final String soil;
  final String wateringSchedule;

  GrowthGuide({
    required this.climate,
    required this.soil,
    required this.wateringSchedule,
  });

  factory GrowthGuide.fromJson(Map<String, dynamic> json) {
    return GrowthGuide(
      climate: json['climate'] ?? 'N/A',
      soil: json['soil'] ?? 'N/A',
      wateringSchedule: json['wateringSchedule'] ?? 'N/A',
    );
  }
}

class Extras {
  final String warnings;
  final String funFact;

  Extras({required this.warnings, required this.funFact});

  factory Extras.fromJson(Map<String, dynamic> json) {
    return Extras(
      warnings: json['warnings'] ?? 'None',
      funFact: json['funFact'] ?? 'No fun fact available.',
    );
  }
}