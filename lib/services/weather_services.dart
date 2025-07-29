// lib/services/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class WeatherService {
  static const String _apiKey =
      'e7be5934d67f91b1fb6c37792a224c89'; // Ganti dengan API key Anda
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  static Map<String, dynamic> _defaultWeatherData = {
    'temperature': 28.0,
    'description': 'Cerah',
    'icon': '01d',
    'city': 'Batam',
    'country': 'ID',
  };

  // Cek permission lokasi
  static Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  // Dapatkan posisi saat ini
  static Future<Position?> getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Dapatkan data cuaca berdasarkan koordinat
  static Future<Map<String, dynamic>> getWeatherByCoordinates(
    double lat,
    double lon,
  ) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=id',
      );

      final response = await http.get(url).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'temperature': data['main']['temp'].toDouble(),
          'description': _getWeatherDescription(data['weather'][0]['main']),
          'icon': data['weather'][0]['icon'],
          'city': data['name'],
          'country': data['sys']['country'],
        };
      }
    } catch (e) {
      print('Error fetching weather by coordinates: $e');
    }
    return _defaultWeatherData;
  }

  // Dapatkan data cuaca berdasarkan nama kota
  static Future<Map<String, dynamic>> getWeatherByCity(String cityName) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric&lang=id',
      );

      final response = await http.get(url).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'temperature': data['main']['temp'].toDouble(),
          'description': _getWeatherDescription(data['weather'][0]['main']),
          'icon': data['weather'][0]['icon'],
          'city': data['name'],
          'country': data['sys']['country'],
        };
      }
    } catch (e) {
      print('Error fetching weather by city: $e');
    }
    return _defaultWeatherData;
  }

  // Konversi kode cuaca ke bahasa Indonesia
  static String _getWeatherDescription(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return 'Cerah';
      case 'clouds':
        return 'Berawan';
      case 'rain':
        return 'Hujan';
      case 'drizzle':
        return 'Gerimis';
      case 'thunderstorm':
        return 'Badai';
      case 'snow':
        return 'Salju';
      case 'mist':
      case 'fog':
        return 'Kabut';
      case 'haze':
        return 'Berkabut';
      default:
        return 'Cerah';
    }
  }
}
