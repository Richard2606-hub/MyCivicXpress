import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherApiService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  // Fetches current weather for a specific lat/long
  Future<Map<String, dynamic>> getCurrentWeather(double lat, double lng) async {
    final url = Uri.parse(
        '$_baseUrl?latitude=$lat&longitude=$lng&current=temperature_2m,relative_humidity_2m,is_day,precipitation,rain,showers,weather_code,cloud_cover,wind_speed_10m&timezone=auto');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _processWeatherData(data);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  Map<String, dynamic> _processWeatherData(Map<String, dynamic> rawData) {
    final current = rawData['current'];
    final weatherCode = current['weather_code'];
    
    return {
      'temperature': current['temperature_2m'],
      'humidity': current['relative_humidity_2m'],
      'windSpeed': current['wind_speed_10m'],
      'isDay': current['is_day'] == 1,
      'conditionText': _getWeatherConditionText(weatherCode),
      'iconPath': _getWeatherIcon(weatherCode, current['is_day'] == 1),
    };
  }

  // WMO Weather interpretation codes (Open-Meteo standard)
  String _getWeatherConditionText(int code) {
    switch (code) {
      case 0: return 'Clear sky';
      case 1: case 2: case 3: return 'Partly cloudy';
      case 45: case 48: return 'Fog';
      case 51: case 53: case 55: return 'Drizzle';
      case 61: case 63: case 65: return 'Rain';
      case 71: case 73: case 75: return 'Snow';
      case 80: case 81: case 82: return 'Rain showers';
      case 95: case 96: case 99: return 'Thunderstorm';
      default: return 'Unknown';
    }
  }

  // Map WMO codes to a general string that we can use for UI icons
  String _getWeatherIcon(int code, bool isDay) {
    if (code == 0) return isDay ? 'sunny' : 'clear_night';
    if (code <= 3) return isDay ? 'partly_cloudy' : 'cloudy_night';
    if (code == 45 || code == 48) return 'fog';
    if (code >= 51 && code <= 65) return 'rain';
    if (code >= 80 && code <= 82) return 'rain_showers';
    if (code >= 95 && code <= 99) return 'thunderstorm';
    return 'cloudy';
  }
}
