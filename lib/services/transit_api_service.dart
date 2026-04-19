import 'dart:async';
import 'dart:math';
import '../models/transit_model.dart';

class TransitApiService {
  final List<TransitLine> _lines = TransitLine.getMockLines();
  final List<TransitStation> _stations = TransitStation.getMockStations();

  Future<List<TransitLine>> getLinesForState(String state) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Return lines that operate in the user's registered state
    return _lines.where((l) => l.availableStates.contains(state)).toList();
  }

  Future<List<TransitStation>> getStationsByLine(String lineId, String state) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (lineId == 'all') {
      return _stations.where((s) => s.state == state).toList();
    }
    return _stations.where((s) => s.lineIds.contains(lineId) && s.state == state).toList();
  }

  Future<List<TransitStation>> getNearbyStations(String userState) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Filter stations by the user's registered state
    final nearby = _stations.where((s) => s.state.toLowerCase() == userState.toLowerCase()).toList();
    
    if (nearby.isEmpty) {
      // Fallback to KL if no state data found (e.g. for less populated states in mock)
      return _stations.where((s) => s.state == 'Kuala Lumpur').take(3).toList();
    }
    return nearby;
  }

  Future<List<StationArrival>> getArrivals(String stationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final random = Random();
    
    final station = _stations.firstWhere((s) => s.id == stationId, orElse: () => _stations.first);
    
    String dest1 = 'Gombak';
    String dest2 = 'Putra Heights';
    
    if (station.lineIds.contains('ktm_utara')) {
      dest1 = 'Butterworth';
      dest2 = 'Padang Besar';
    } else if (station.lineIds.contains('ktm_selatan')) {
      dest1 = 'JB Sentral';
      dest2 = 'Gemas';
    } else if (station.lineIds.contains('bus_penang') || station.lineIds.contains('ferry_penang')) {
      dest1 = 'Georgetown';
      dest2 = 'Butterworth';
    }

    return [
      StationArrival(
        stationId: stationId,
        destination: dest1,
        minutes: random.nextInt(10) + 1,
        platform: 'Platform 1',
      ),
      StationArrival(
        stationId: stationId,
        destination: dest2,
        minutes: random.nextInt(15) + 5,
        platform: 'Platform 2',
      ),
    ];
  }
}
