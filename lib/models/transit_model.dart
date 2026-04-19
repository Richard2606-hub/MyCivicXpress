import 'package:flutter/material.dart';

enum TransitType { lrt, mrt, monorail, bus }

class TransitLine {
  final String id;
  final String name;
  final TransitType type;
  final Color color;

  TransitLine({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
  });

  static List<TransitLine> getMockLines() {
    return [
      TransitLine(id: 'lrt_kj', name: 'LRT Kelana Jaya', type: TransitType.lrt, color: const Color(0xFFE91E63)),
      TransitLine(id: 'mrt_kg', name: 'MRT Kajang', type: TransitType.mrt, color: const Color(0xFF009688)),
      TransitLine(id: 'mrt_py', name: 'MRT Putrajaya', type: TransitType.mrt, color: const Color(0xFFFF9800)),
      TransitLine(id: 'monorail', name: 'Monorail', type: TransitType.monorail, color: const Color(0xFF673AB7)),
      TransitLine(id: 'bus_rapid', name: 'Rapid Bus', type: TransitType.bus, color: const Color(0xFF2196F3)),
    ];
  }
}

class TransitStation {
  final String id;
  final String name;
  final List<String> lineIds;
  final String city; // For nearby detection

  TransitStation({
    required this.id,
    required this.name,
    required this.lineIds,
    required this.city,
  });

  static List<TransitStation> getMockStations() {
    return [
      // LRT Kelana Jaya
      TransitStation(id: 'kj14', name: 'KL Sentral', lineIds: ['lrt_kj', 'monorail', 'bus_rapid'], city: 'Kuala Lumpur'),
      TransitStation(id: 'kj15', name: 'Bangsar', lineIds: ['lrt_kj'], city: 'Kuala Lumpur'),
      TransitStation(id: 'kj24', name: 'Kelana Jaya', lineIds: ['lrt_kj', 'bus_rapid'], city: 'Petaling Jaya'),
      TransitStation(id: 'kj20', name: 'Taman Jaya', lineIds: ['lrt_kj'], city: 'Petaling Jaya'),
      
      // MRT Kajang
      TransitStation(id: 'kg16', name: 'Pasar Seni', lineIds: ['mrt_kg', 'lrt_kj'], city: 'Kuala Lumpur'),
      TransitStation(id: 'kg18', name: 'Bukit Bintang', lineIds: ['mrt_kg', 'monorail'], city: 'Kuala Lumpur'),
      TransitStation(id: 'kg12', name: 'Bandar Utama', lineIds: ['mrt_kg', 'bus_rapid'], city: 'Petaling Jaya'),
      TransitStation(id: 'kg13', name: 'TTDI', lineIds: ['mrt_kg'], city: 'Kuala Lumpur'),

      // MRT Putrajaya
      TransitStation(id: 'py17', name: 'KLCC East', lineIds: ['mrt_py'], city: 'Kuala Lumpur'),
      TransitStation(id: 'py24', name: 'Putrajaya Sentral', lineIds: ['mrt_py', 'bus_rapid'], city: 'Putrajaya'),

      // Bus
      TransitStation(id: 'b1', name: 'Sunway Pyramid', lineIds: ['bus_rapid'], city: 'Subang Jaya'),
      TransitStation(id: 'b2', name: 'Mid Valley', lineIds: ['bus_rapid'], city: 'Kuala Lumpur'),
    ];
  }
}

class StationArrival {
  final String stationId;
  final String destination;
  final int minutes;
  final String platform;

  StationArrival({
    required this.stationId,
    required this.destination,
    required this.minutes,
    required this.platform,
  });
}
