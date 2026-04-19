import 'package:flutter/foundation.dart';

@immutable
class CitizenProfile {
  final String fullName;
  final String icNumber;
  final String dob;
  final String gender;
  final String location;
  final String address;
  final int impactScore;
  final bool isVerified;

  const CitizenProfile({
    required this.fullName,
    required this.icNumber,
    required this.dob,
    required this.gender,
    required this.location,
    required this.address,
    this.impactScore = 0,
    this.isVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'icNumber': icNumber,
      'dob': dob,
      'gender': gender,
      'location': location,
      'address': address,
      'impactScore': impactScore,
      'isVerified': isVerified,
    };
  }

  factory CitizenProfile.fromMap(Map<String, dynamic> map) {
    return CitizenProfile(
      fullName: map['fullName'] ?? '',
      icNumber: map['icNumber'] ?? '',
      dob: map['dob'] ?? '',
      gender: map['gender'] ?? '',
      location: map['location'] ?? '',
      address: map['address'] ?? '',
      impactScore: map['impactScore'] ?? 0,
      isVerified: map['isVerified'] ?? false,
    );
  }

  CitizenProfile copyWith({
    String? fullName,
    String? icNumber,
    String? dob,
    String? gender,
    String? location,
    String? address,
    int? impactScore,
    bool? isVerified,
  }) {
    return CitizenProfile(
      fullName: fullName ?? this.fullName,
      icNumber: icNumber ?? this.icNumber,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      address: address ?? this.address,
      impactScore: impactScore ?? this.impactScore,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
