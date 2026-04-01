import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RoadService {
  static const String _apiKey = 'AIzaSyDrMfyEysTvqNxP5ckaVB5Q7zOJPukl88A'; // Your actual key
  
  static Future<List<LatLng>> snapToRoads(List<LatLng> points) async {
    if (points.length < 2) return points;
    
    // Take only recent points to avoid API limits
    final recentPoints = points.length > 10 ? points.sublist(points.length - 10) : points;
    
    final path = recentPoints.map((p) => '${p.latitude},${p.longitude}').join('|');
    final url = 'https://roads.googleapis.com/v1/snapToRoads?path=$path&key=$_apiKey';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final snapped = data['snappedPoints'] as List?;
        
        if (snapped != null) {
          return snapped.map<LatLng>((point) {
            final loc = point['location'];
            return LatLng(loc['latitude'], loc['longitude']);
          }).toList();
        }
      }
    } catch (e) {
      print('Roads API error: $e');
    }
    
    return points; // Fallback to original
  }
}
