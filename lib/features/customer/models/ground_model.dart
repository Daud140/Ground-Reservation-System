enum SportType {
  football,
  cricket,
  futsal,
  padel,
  tennis,
  basketball;

  String get displayName {
    switch (this) {
      case SportType.football:
        return 'Football';
      case SportType.cricket:
        return 'Cricket';
      case SportType.futsal:
        return 'Futsal';
      case SportType.padel:
        return 'Padel';
      case SportType.tennis:
        return 'Tennis';
      case SportType.basketball:
        return 'Basketball';
    }
  }

  String get iconName {
    switch (this) {
      case SportType.football:
        return 'sports_soccer';
      case SportType.cricket:
        return 'sports_cricket';
      case SportType.futsal:
        return 'sports_soccer';
      case SportType.padel:
        return 'sports_tennis';
      case SportType.tennis:
        return 'sports_tennis';
      case SportType.basketball:
        return 'sports_basketball';
    }
  }
}

/// Sports Ground entity in GroundZero
class GroundModel {
  final String id;
  final String ownerId;
  final String name;
  final SportType sportType;
  final String location;
  final String address;
  final double pricePerHour;
  final double rating;
  final int reviewsCount;
  final String openTime; // "08:00"
  final String closeTime; // "23:00"
  final List<String> facilities;
  final List<String> images;
  final String description;
  final bool isActive;

  const GroundModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.sportType,
    required this.location,
    required this.address,
    required this.pricePerHour,
    required this.rating,
    required this.reviewsCount,
    required this.openTime,
    required this.closeTime,
    required this.facilities,
    required this.images,
    required this.description,
    this.isActive = true,
  });

  String get primaryImage => images.isNotEmpty
      ? images.first
      : 'assets/images/ground_futsal_rawal.jpg';

  double get latitude {
    switch (id) {
      case 'ground_1':
        return 33.7215; // F-7 Markaz Islamabad
      case 'ground_2':
        return 33.7020; // E-11/4 Islamabad
      case 'ground_3':
        return 33.6938; // F-10 Padel Islamabad
      case 'ground_4':
        return 33.5760; // Ayub Park Rawalpindi
      case 'ground_5':
        return 33.7077; // Blue Area Islamabad
      case 'ground_6':
        return 33.7000; // Rawal Lake Islamabad
      case 'ground_7':
        return 33.5930; // Chaklala Rawalpindi
      case 'ground_8':
        return 33.5220; // Bahria Town Phase 7
      default:
        return 33.6844;
    }
  }

  double get longitude {
    switch (id) {
      case 'ground_1':
        return 73.0560;
      case 'ground_2':
        return 72.9780;
      case 'ground_3':
        return 73.0160;
      case 'ground_4':
        return 73.0720;
      case 'ground_5':
        return 73.0538;
      case 'ground_6':
        return 73.1200;
      case 'ground_7':
        return 73.0900;
      case 'ground_8':
        return 73.1100;
      default:
        return 73.0479;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'sportType': sportType.name,
      'location': location,
      'address': address,
      'pricePerHour': pricePerHour,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'openTime': openTime,
      'closeTime': closeTime,
      'facilities': facilities,
      'images': images,
      'description': description,
      'isActive': isActive,
    };
  }

  factory GroundModel.fromJson(Map<String, dynamic> json) {
    return GroundModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      sportType: SportType.values.firstWhere(
        (s) => s.name == json['sportType'],
        orElse: () => SportType.futsal,
      ),
      location: json['location'] as String,
      address: json['address'] as String,
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      reviewsCount: (json['reviewsCount'] as num).toInt(),
      openTime: json['openTime'] as String? ?? '08:00',
      closeTime: json['closeTime'] as String? ?? '23:00',
      facilities: List<String>.from(json['facilities'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      description: json['description'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  GroundModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    SportType? sportType,
    String? location,
    String? address,
    double? pricePerHour,
    double? rating,
    int? reviewsCount,
    String? openTime,
    String? closeTime,
    List<String>? facilities,
    List<String>? images,
    String? description,
    bool? isActive,
  }) {
    return GroundModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      sportType: sportType ?? this.sportType,
      location: location ?? this.location,
      address: address ?? this.address,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      facilities: facilities ?? this.facilities,
      images: images ?? this.images,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}
