// import 'dart:developer';
// import 'package:flutter_health_connect/flutter_health_connect.dart';
// // If 'HealthConnect' is not defined, try importing as below or check the package documentation
// // import 'package:flutter_health_connect/flutter_health_connect.dart' as health_connect;

// class HealthConnectService {
//   static final HealthConnectService _instance = HealthConnectService._internal();
//   factory HealthConnectService() => _instance;
//   HealthConnectService._internal();

//   // Health Connect permissions we need
//   static const List<HealthConnectDataType> _requiredPermissions = [
//     HealthConnectDataType.Steps,
//     HealthConnectDataType.Distance,
//     HealthConnectDataType.ActiveCaloriesBurned,
//     HealthConnectDataType.Speed,
//     HealthConnectDataType.Power,
//     HealthConnectDataType.HeartRate,
//     HealthConnectDataType.ElevationGained,
//   ];

//   /// Check if Health Connect is available
//   Future<bool> isHealthConnectAvailable() async {
//     try {
//       return await HealthConnect.isHealthConnectAvailable();
//     } catch (e) {
//       log('Error checking Health Connect availability: $e');
//       return false;
//     }
//   }

//   /// Install Health Connect
//   Future<void> installHealthConnect() async {
//     try {
//       await HealthConnect.installHealthConnect();
//     } catch (e) {
//       log('Error installing Health Connect: $e');
//     }
//   }

//   /// Request permissions for Health Connect
//   Future<bool> requestPermissions() async {
//     try {
//       final isAvailable = await isHealthConnectAvailable();
//       if (!isAvailable) {
//         log('Health Connect is not available');
//         return false;
//       }

//       // Request permissions
//       final bool granted = await HealthConnect.requestPermissions(
//         permissions: _requiredPermissions,
//         readOnly: true,
//       );

//       if (granted) {
//         log('Health Connect permissions granted');
//         return true;
//       } else {
//         log('Health Connect permissions denied');
//         return false;
//       }
//     } catch (e) {
//       log('Error requesting Health Connect permissions: $e');
//       return false;
//     }
//   }

//   /// Check if permissions are granted
//   Future<bool> hasPermissions() async {
//     try {
//       return await HealthConnect.hasPermissions(
//         permissions: _requiredPermissions,
//       );
//     } catch (e) {
//       log('Error checking Health Connect permissions: $e');
//       return false;
//     }
//   }

//   /// Get activity data from Health Connect
//   Future<Map<String, dynamic>> getActivityData({
//     required DateTime startTime,
//     required DateTime endTime,
//     required String activityType,
//   }) async {
//     try {
//       // Initialize result map
//       Map<String, dynamic> result = {
//         'distance': 0.0,
//         'calories': 0.0,
//         'steps': 0,
//         'avgPace': 0.0,
//         'elevationGain': 0.0,
//         'avgSpeed': 0.0,
//       };

//       // Check permissions first
//       final hasPerms = await hasPermissions();
//       if (!hasPerms) {
//         log('No Health Connect permissions');
//         return result;
//       }

//       // Get distance data
//       final distanceRecords = await HealthConnect.getHealthRecords(
//         type: HealthConnectDataType.Distance,
//         startTime: startTime,
//         endTime: endTime,
//       );

//       double totalDistance = 0.0;
//       for (var record in distanceRecords) {
//         if (record.value != null) {
//           totalDistance += record.value as double;
//         }
//       }
//       result['distance'] = totalDistance / 1000.0; // Convert meters to km

//       // Get calories data
//       final caloriesRecords = await HealthConnect.getHealthRecords(
//         type: HealthConnectDataType.ActiveCaloriesBurned,
//         startTime: startTime,
//         endTime: endTime,
//       );

//       double totalCalories = 0.0;
//       for (var record in caloriesRecords) {
//         if (record.value != null) {
//           totalCalories += record.value as double;
//         }
//       }
//       result['calories'] = totalCalories;

//       // Get steps data
//       final stepsRecords = await HealthConnect.getHealthRecords(
//         type: HealthConnectDataType.Steps,
//         startTime: startTime,
//         endTime: endTime,
//       );

//       int totalSteps = 0;
//       for (var record in stepsRecords) {
//         if (record.value != null) {
//           totalSteps += (record.value as num).toInt();
//         }
//       }
//       result['steps'] = totalSteps;

//       // Get speed data for average pace calculation
//       final speedRecords = await HealthConnect.getHealthRecords(
//         type: HealthConnectDataType.Speed,
//         startTime: startTime,
//         endTime: endTime,
//       );

//       if (speedRecords.isNotEmpty) {
//         double totalSpeed = 0.0;
//         int speedCount = 0;
        
//         for (var record in speedRecords) {
//           if (record.value != null) {
//             totalSpeed += record.value as double;
//             speedCount++;
//           }
//         }
        
//         if (speedCount > 0) {
//           double avgSpeedMs = totalSpeed / speedCount;
//           result['avgSpeed'] = avgSpeedMs * 3.6; // Convert m/s to km/h
          
//           // Calculate pace (minutes per km)
//           if (avgSpeedMs > 0) {
//             double paceMinPerKm = (1000.0 / avgSpeedMs) / 60.0;
//             result['avgPace'] = paceMinPerKm;
//           }
//         }
//       }

//       // Get elevation gain data
//       final elevationRecords = await HealthConnect.getHealthRecords(
//         type: HealthConnectDataType.ElevationGained,
//         startTime: startTime,
//         endTime: endTime,
//       );

//       double totalElevation = 0.0;
//       for (var record in elevationRecords) {
//         if (record.value != null) {
//           totalElevation += record.value as double;
//         }
//       }
//       result['elevationGain'] = totalElevation;

//       log('Health Connect data retrieved: $result');
//       return result;

//     } catch (e) {
//       log('Error getting Health Connect data: $e');
//       return {
//         'distance': 0.0,
//         'calories': 0.0,
//         'steps': 0,
//         'avgPace': 0.0,
//         'elevationGain': 0.0,
//         'avgSpeed': 0.0,
//       };
//     }
//   }

//   /// Write activity session to Health Connect
//   Future<bool> writeActivitySession({
//     required DateTime startTime,
//     required DateTime endTime,
//     required String activityType,
//     required double distanceKm,
//     required double caloriesBurned,
//     required int steps,
//     required double elevationGainMeters,
//   }) async {
//     try {
//       // Check permissions first
//       final hasPerms = await hasPermissions();
//       if (!hasPerms) {
//         log('No Health Connect write permissions');
//         return false;
//       }

//       // Write distance record
//       await HealthConnect.writeHealthRecord(
//         type: HealthConnectDataType.Distance,
//         startTime: startTime,
//         endTime: endTime,
//         value: distanceKm * 1000, // Convert km to meters
//       );

//       // Write calories record
//       await HealthConnect.writeHealthRecord(
//         type: HealthConnectDataType.ActiveCaloriesBurned,
//         startTime: startTime,
//         endTime: endTime,
//         value: caloriesBurned,
//       );

//       // Write steps record
//       await HealthConnect.writeHealthRecord(
//         type: HealthConnectDataType.Steps,
//         startTime: startTime,
//         endTime: endTime,
//         value: steps,
//       );

//       // Write elevation gain record
//       await HealthConnect.writeHealthRecord(
//         type: HealthConnectDataType.ElevationGained,
//         startTime: startTime,
//         endTime: endTime,
//         value: elevationGainMeters,
//       );

//       log('Activity session written to Health Connect successfully');
//       return true;

//     } catch (e) {
//       log('Error writing to Health Connect: $e');
//       return false;
//     }
//   }

//   /// Calculate MET-based calories as fallback
//   double calculateMETCalories({
//     required String activityType,
//     required double durationHours,
//     required double weightKg,
//   }) {
//     double met = 0.0;
    
//     switch (activityType.toLowerCase()) {
//       case 'walking':
//         met = 3.5;
//         break;
//       case 'running':
//         met = 9.8;
//         break;
//       case 'cycling':
//         met = 7.5;
//         break;
//       default:
//         met = 3.5;
//     }
    
//     return met * weightKg * durationHours;
//   }

//   /// Estimate steps from distance
//   int estimateStepsFromDistance({
//     required double distanceKm,
//     required String activityType,
//   }) {
//     double stepsPerKm = 0.0;
    
//     switch (activityType.toLowerCase()) {
//       case 'walking':
//         stepsPerKm = 1400.0; // Average steps per km for walking
//         break;
//       case 'running':
//         stepsPerKm = 1200.0; // Average steps per km for running
//         break;
//       case 'cycling':
//         stepsPerKm = 0.0; // No steps for cycling
//         break;
//       default:
//         stepsPerKm = 1400.0;
//     }
    
//     return (distanceKm * stepsPerKm).round();
//   }
// }