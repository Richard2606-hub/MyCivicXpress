import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/weather_api_service.dart';

final weatherApiProvider = Provider((ref) => WeatherApiService());

class WeatherMapView extends ConsumerStatefulWidget {
  const WeatherMapView({super.key});

  @override
  ConsumerState<WeatherMapView> createState() => _WeatherMapViewState();
}

class _WeatherMapViewState extends ConsumerState<WeatherMapView> {
  final MapController _mapController = MapController();
  
  // Malaysia Center coordinates
  final LatLng _initialCenter = const LatLng(4.2105, 101.9758);
  
  LatLng? _selectedLocation;
  String _locationName = 'Select a location';
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;

  void _onMapTap(TapPosition tapPosition, LatLng point) async {
    setState(() {
      _selectedLocation = point;
      _isLoading = true;
      _locationName = 'Loading...';
      _weatherData = null;
    });

    try {
      // 1. Get placename from geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(point.latitude, point.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Construct a nice name like "Kuala Lumpur, Malaysia" or "Petaling Jaya, Selangor"
        final locality = place.locality?.isNotEmpty == true ? place.locality : place.subAdministrativeArea;
        final state = place.administrativeArea;
        if (locality != null && state != null) {
           _locationName = '$locality, $state';
        } else if (state != null) {
           _locationName = state;
        } else {
           _locationName = place.country ?? 'Unknown Location';
        }
      } else {
        _locationName = 'Unknown Location';
      }

      // 2. Get Weather Data
      final api = ref.read(weatherApiProvider);
      final weather = await api.getCurrentWeather(point.latitude, point.longitude);
      
      if (mounted) {
        setState(() {
          _weatherData = weather;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationName = 'Location not found';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not fetch weather data. Try another location.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const SizedBox(),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.8),
                Colors.transparent,
              ],
            ),
          ),
        ),
        title: Row(
          children: [
            const Icon(LucideIcons.cloudSun, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Weather Map',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // The Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 6.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                // CartoDB Dark Matter for a sleek premium look
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.civiceaseai.app',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 80,
                      height: 80,
                      child: const Icon(
                        LucideIcons.mapPin,
                        color: Color(0xFF6366F1),
                        size: 40,
                      ).animate()
                       .slideY(begin: -0.5, end: 0, duration: 400.ms, curve: Curves.bounceOut),
                    ),
                  ],
                ),
            ],
          ),
          
          // Weather Information Card overlay
          if (_selectedLocation != null || _isLoading)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: _buildWeatherCard(),
            ),
            
          // Instruction Overlay if nothing selected
          if (_selectedLocation == null && !_isLoading)
            Positioned(
              top: 120,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.mousePointerClick, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Tap anywhere on the map to check weather',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.2, end: 0),
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120.0), // Above the card
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF1E293B),
          onPressed: () {
            _mapController.move(_initialCenter, 6.0);
          },
          child: const Icon(LucideIcons.crosshair, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _locationName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: Color(0xFF6366F1)),
              ),
            )
          else if (_weatherData != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _getWeatherIconWidget(_weatherData!['iconPath']),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_weatherData!['temperature']}°C',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _weatherData!['conditionText'],
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(LucideIcons.droplets, '${_weatherData!['humidity']}%', 'Humidity'),
                _buildWeatherDetail(LucideIcons.wind, '${_weatherData!['windSpeed']} km/h', 'Wind'),
              ],
            ),
          ]
        ],
      ),
    ).animate(key: ValueKey(_locationName)).fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildWeatherDetail(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF6366F1), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
        ),
      ],
    );
  }

  Widget _getWeatherIconWidget(String iconPath) {
    IconData icon;
    Color color;

    switch (iconPath) {
      case 'sunny':
        icon = LucideIcons.sun;
        color = Colors.orange;
        break;
      case 'clear_night':
        icon = LucideIcons.moon;
        color = Colors.blueGrey;
        break;
      case 'partly_cloudy':
        icon = LucideIcons.cloudSun;
        color = Colors.yellow;
        break;
      case 'cloudy_night':
        icon = LucideIcons.cloudMoon;
        color = Colors.blueGrey;
        break;
      case 'fog':
        icon = LucideIcons.cloudFog;
        color = Colors.grey;
        break;
      case 'rain':
      case 'rain_showers':
        icon = LucideIcons.cloudRain;
        color = Colors.lightBlue;
        break;
      case 'thunderstorm':
        icon = LucideIcons.cloudLightning;
        color = Colors.deepPurpleAccent;
        break;
      case 'cloudy':
      default:
        icon = LucideIcons.cloud;
        color = Colors.white70;
    }

    return Icon(icon, color: color, size: 48);
  }
}
