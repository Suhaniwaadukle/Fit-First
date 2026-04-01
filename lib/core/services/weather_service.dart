import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherService {
  static const String _apiKey = 'df37c7003c93f8382ded451e7e9c8bee'; // Get from openweathermap.org
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  String? currentLocation;

  Future<double?> getCurrentTemperature() async {
    try {
      // Get current location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      // Fetch weather data
      final response = await http.get(
        Uri.parse(
          '$_baseUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric'
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final double temperature = data['main']['temp'].toDouble();
        
        print('Current temperature: ${temperature}°C');
        print('Location: ${data['name']}, ${data['sys']['country']}');
        currentLocation = "${data['name']}, ${data['sys']['country']}";
        
        return temperature;
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weather: $e');
      return null;
    }
  }

  static double adjustWaterIntakeForTemperature(double baseIntake, double temperature) {
    double addition = 0.0;
    
    if (temperature < 15) {
      addition = 0.0; // Cold: No additional water needed
    } else if (temperature >= 15 && temperature < 25) {
      addition = 0.2; // Mild: +0.2L
    } else if (temperature >= 25 && temperature < 35) {
      addition = 0.5; // Warm: +0.5L
    } else if (temperature >= 35) {
      addition = 1.0; // Hot: +1.0L
    }
    
    return baseIntake + addition;
  }

  // Get temperature category for display
  static String getTemperatureCategory(double temperature) {
    if (temperature < 15) {
      return 'Cold';
    } else if (temperature < 25) {
      return 'Mild';
    } else if (temperature < 35) {
      return 'Warm';
    } else {
      return 'Hot';
    }
  }

  // Get additional water intake amount
  static double getAdditionalWaterIntake(double temperature) {
    if (temperature < 15) {
      return 0.0;
    } else if (temperature < 25) {
      return 0.2;
    } else if (temperature < 35) {
      return 0.5;
    } else {
      return 1.0;
    }
  }
}

class AirQualityService {
  static const String _apiKey = 'df37c7003c93f8382ded451e7e9c8bee';

  Future<int?> getCurrentAQI(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['list'][0]['main']['aqi'];
      } else {
        throw Exception("AQI fetch failed");
      }
    } catch (e) {
      print("AQI Error: $e");
      return null;
    }
  }

  static String getAQIStatus(int aqi) {
    switch (aqi) {
      case 1:
        return "Good";
      case 2:
        return "Fair";
      case 3:
        return "Moderate";
      case 4:
        return "Poor";
      case 5:
        return "Very Poor";
      default:
        return "Unknown";
    }
  }
}