import 'dart:convert';

class CitizenProfile {
  final String id;
  final String name; // Full name as per IC
  final String icNumber; // Malaysian IC
  final String dateOfBirth;
  final String gender;
  final String location; // State/City
  final String address;
  final List<String> interests;
  final Map<String, dynamic> preferences;
  final bool isVerified;

  CitizenProfile({
    required this.id,
    required this.name,
    required this.icNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.location,
    required this.address,
    required this.interests,
    this.preferences = const {},
    this.isVerified = false,
  });

  factory CitizenProfile.defaultProfile() {
    return CitizenProfile(
      id: 'guest',
      name: 'Malaysian Citizen',
      icNumber: '000000-00-0000',
      dateOfBirth: '2000-01-01',
      gender: 'Other',
      location: 'Kuala Lumpur',
      address: 'Jalan Sultan Ismail, 50250 Kuala Lumpur',
      interests: ['Public Transport', 'Health', 'Welfare'],
    );
  }

  CitizenProfile copyWith({
    String? name,
    String? icNumber,
    String? dateOfBirth,
    String? gender,
    String? location,
    String? address,
    List<String>? interests,
    Map<String, dynamic>? preferences,
    bool? isVerified,
  }) {
    return CitizenProfile(
      id: id,
      name: name ?? this.name,
      icNumber: icNumber ?? this.icNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      address: address ?? this.address,
      interests: interests ?? this.interests,
      preferences: preferences ?? this.preferences,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  // Firebase-compatible serialization
  Map<String, dynamic> toMap() => toJson();
  factory CitizenProfile.fromMap(Map<String, dynamic> map) => CitizenProfile.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icNumber': icNumber,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'location': location,
      'address': address,
      'interests': interests,
      'preferences': preferences,
      'isVerified': isVerified,
    };
  }

  factory CitizenProfile.fromJson(Map<String, dynamic> json) {
    return CitizenProfile(
      id: json['id'] ?? 'guest',
      name: json['name'] ?? json['fullName'] ?? 'Malaysian Citizen',
      icNumber: json['icNumber'] ?? '000000-00-0000',
      dateOfBirth: json['dateOfBirth'] ?? json['dob'] ?? '2000-01-01',
      gender: json['gender'] ?? 'Other',
      location: json['location'] ?? 'Kuala Lumpur',
      address: json['address'] ?? '',
      interests: List<String>.from(json['interests'] ?? ['Public Transport', 'Health', 'Welfare']),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      isVerified: json['isVerified'] ?? false,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory CitizenProfile.fromJsonString(String jsonStr) {
    return CitizenProfile.fromJson(jsonDecode(jsonStr));
  }
}
