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
      commonName: json['commonName']?.toString() ?? 'N/A',
      scientificName: json['scientificName']?.toString() ?? 'N/A',
      about: json['about']?.toString() ?? 'No description available.',
      imageUrl: json['imageUrl']?.toString() ?? '',
      quickInfo: QuickInfo.fromJson(json['quickInfo'] as Map<String, dynamic>? ?? {}),
      uses: Uses.fromJson(json['uses'] as Map<String, dynamic>? ?? {}),
      growthGuide: GrowthGuide.fromJson(json['growthGuide'] as Map<String, dynamic>? ?? {}),
      extras: Extras.fromJson(json['extras'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'commonName': commonName,
    'scientificName': scientificName,
    'about': about,
    'imageUrl': imageUrl,
    'quickInfo': quickInfo.toJson(),
    'uses': uses.toJson(),
    'growthGuide': growthGuide.toJson(),
    'extras': extras.toJson(),
  };
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
      sunlight: json['sunlight']?.toString() ?? 'N/A',
      watering: json['watering']?.toString() ?? 'N/A',
      petSafety: json['petSafety']?.toString() ?? 'N/A',
      growthEase: json['growthEase']?.toString() ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() => {
    'sunlight': sunlight,
    'watering': watering,
    'petSafety': petSafety,
    'growthEase': growthEase,
  };
}

class Uses {
  final List<String> medicinal;
  final List<String> culinary;

  Uses({required this.medicinal, required this.culinary});

  factory Uses.fromJson(Map<String, dynamic> json) {
    return Uses(
      medicinal: (json['medicinal'] as List?)?.map((e) => e.toString()).toList() ?? [],
      culinary: (json['culinary'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'medicinal': medicinal,
    'culinary': culinary,
  };
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
      climate: json['climate']?.toString() ?? 'N/A',
      soil: json['soil']?.toString() ?? 'N/A',
      wateringSchedule: json['wateringSchedule']?.toString() ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() => {
    'climate': climate,
    'soil': soil,
    'wateringSchedule': wateringSchedule,
  };
}

class Extras {
  final String warnings;
  final String funFact;

  Extras({required this.warnings, required this.funFact});

  factory Extras.fromJson(Map<String, dynamic> json) {
    return Extras(
      warnings: json['warnings']?.toString() ?? 'None',
      funFact: json['funFact']?.toString() ?? 'No fun fact available.',
    );
  }

  Map<String, dynamic> toJson() => {
    'warnings': warnings,
    'funFact': funFact,
  };
}