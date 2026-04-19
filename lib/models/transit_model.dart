import 'package:flutter/material.dart';

enum TransitType { lrt, mrt, monorail, bus, ktm, ferry, drt }

class TransitLine {
  final String id;
  final String name;
  final TransitType type;
  final Color color;
  final List<String> availableStates; // Which states this service operates in
  final String? externalUrl; // For On-Demand services

  TransitLine({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.availableStates,
    this.externalUrl,
  });

  static List<TransitLine> getMockLines() {
    return [
      TransitLine(id: 'lrt_kj', name: 'LRT Kelana Jaya', type: TransitType.lrt, color: const Color(0xFFE91E63), availableStates: ['Kuala Lumpur', 'Selangor']),
      TransitLine(id: 'lrt_sp', name: 'LRT Sri Petaling', type: TransitType.lrt, color: const Color(0xFF8BC34A), availableStates: ['Kuala Lumpur', 'Selangor']),
      TransitLine(id: 'mrt_kg', name: 'MRT Kajang', type: TransitType.mrt, color: const Color(0xFF009688), availableStates: ['Kuala Lumpur', 'Selangor']),
      TransitLine(id: 'mrt_py', name: 'MRT Putrajaya', type: TransitType.mrt, color: const Color(0xFFFF9800), availableStates: ['Kuala Lumpur', 'Selangor', 'Putrajaya']),
      TransitLine(id: 'monorail', name: 'Monorail', type: TransitType.monorail, color: const Color(0xFF673AB7), availableStates: ['Kuala Lumpur']),
      
      // KTM Komuter
      TransitLine(id: 'ktm_seremban', name: 'KTM Seremban Line', type: TransitType.ktm, color: const Color(0xFF3F51B5), availableStates: ['Kuala Lumpur', 'Selangor', 'Negeri Sembilan']),
      TransitLine(id: 'ktm_utara', name: 'KTM Komuter Utara', type: TransitType.ktm, color: const Color(0xFF1E3A8A), availableStates: ['Kedah', 'Penang', 'Perak', 'Perlis']),
      TransitLine(id: 'ktm_selatan', name: 'KTM Komuter Selatan', type: TransitType.ktm, color: const Color(0xFF1E3A8A), availableStates: ['Johor', 'Melaka']),
      
      // Rapid On-Demand (DRT)
      TransitLine(
        id: 'rapid_drt', 
        name: 'Rapid On-Demand Van', 
        type: TransitType.drt, 
        color: const Color(0xFFFFC107), 
        availableStates: ['Kuala Lumpur', 'Selangor', 'Penang'],
        externalUrl: 'https://www.myrapid.com.my/bus-services/rapid-drt-kumpool/',
      ),
      
      // Buses & Ferry
      TransitLine(id: 'bus_rapid', name: 'Rapid KL Bus', type: TransitType.bus, color: const Color(0xFF2196F3), availableStates: ['Kuala Lumpur', 'Selangor', 'Putrajaya']),
      TransitLine(id: 'bus_penang', name: 'Rapid Penang', type: TransitType.bus, color: const Color(0xFF2196F3), availableStates: ['Penang']),
      TransitLine(id: 'bus_kuantan', name: 'Rapid Kuantan', type: TransitType.bus, color: const Color(0xFF2196F3), availableStates: ['Pahang']),
      TransitLine(id: 'ferry_penang', name: 'Penang Ferry', type: TransitType.ferry, color: const Color(0xFF00BCD4), availableStates: ['Penang']),
    ];
  }
}

class TransitStation {
  final String id;
  final String name;
  final List<String> lineIds;
  final String state; // For filtering

  TransitStation({
    required this.id,
    required this.name,
    required this.lineIds,
    required this.state,
  });

  static List<TransitStation> getMockStations() {
    return [
      // Central (KL/Selangor)
      TransitStation(id: 'kj14', name: 'KL Sentral', lineIds: ['lrt_kj', 'monorail', 'ktm_seremban', 'bus_rapid'], state: 'Kuala Lumpur'),
      TransitStation(id: 'kj15', name: 'Bangsar', lineIds: ['lrt_kj'], state: 'Kuala Lumpur'),
      TransitStation(id: 'kj24', name: 'Kelana Jaya', lineIds: ['lrt_kj', 'bus_rapid', 'rapid_drt'], state: 'Selangor'),
      TransitStation(id: 'py24', name: 'Putrajaya Sentral', lineIds: ['mrt_py', 'bus_rapid'], state: 'Putrajaya'),
      TransitStation(id: 'ktm_ser', name: 'Seremban Station', lineIds: ['ktm_seremban'], state: 'Negeri Sembilan'),

      // Northern (Kedah/Penang)
      TransitStation(id: 'ktm_as', name: 'Alor Setar', lineIds: ['ktm_utara'], state: 'Kedah'),
      TransitStation(id: 'ktm_sp', name: 'Sungai Petani', lineIds: ['ktm_utara'], state: 'Kedah'),
      TransitStation(id: 'ktm_gur', name: 'Gurun', lineIds: ['ktm_utara'], state: 'Kedah'),
      TransitStation(id: 'ktm_bm', name: 'Bukit Mertajam', lineIds: ['ktm_utara', 'bus_penang', 'rapid_drt'], state: 'Penang'),
      TransitStation(id: 'ferry_pg', name: 'Pangkalan Raja Tun Uda', lineIds: ['ferry_penang', 'bus_penang'], state: 'Penang'),
      TransitStation(id: 'bus_komtar', name: 'KOMTAR Bus Terminal', lineIds: ['bus_penang', 'rapid_drt'], state: 'Penang'),

      // Southern (Johor)
      TransitStation(id: 'ktm_jb', name: 'JB Sentral', lineIds: ['ktm_selatan'], state: 'Johor'),
      TransitStation(id: 'ktm_kempas', name: 'Kempas Baru', lineIds: ['ktm_selatan'], state: 'Johor'),
      TransitStation(id: 'ktm_segamat', name: 'Segamat', lineIds: ['ktm_selatan'], state: 'Johor'),
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
