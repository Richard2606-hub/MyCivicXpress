import 'dart:async';
import 'dart:math';
import '../models/transit_model.dart';

class TransitApiService {
  final List<TransitLine> _lines = TransitLine.getMockLines();
  final List<TransitStation> _stations = TransitStation.getMockStations();

  Future<List<TransitLine>> getLines() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _lines;
  }

  Future<List<TransitStation>> getStationsByLine(String lineId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (lineId == 'all') return _stations;
    return _stations.where((s) => s.lineIds.contains(lineId)).toList();
  }

  Future<List<TransitStation>> getNearbyStations(String userCity) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Simple filter by city
    final nearby = _stations.where((s) => s.city.toLowerCase() == userCity.toLowerCase()).toList();
    if (nearby.isEmpty) {
      // Fallback to top stations if no city match
      return _stations.take(3).toList();
    }
    return nearby;
  }

  Future<List<StationArrival>> getArrivals(String stationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final random = Random();
    
    // Generate some random arrivals
    return [
      StationArrival(
        stationId: stationId,
        destination: 'Gombak',
        minutes: random.nextInt(10) + 1,
        platform: 'Platform 1',
      ),
      StationArrival(
        stationId: stationId,
        destination: 'Putra Heights',
        minutes: random.nextInt(15) + 5,
        platform: 'Platform 2',
      ),
    ];
  }
}
