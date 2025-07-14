// services/firebase_service.dart
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Kontrol relay
  static Future<void> controlRelay(bool isOn) async {
    try {
      await _database.child('control/relay_control').set(isOn ? 'ON' : 'OFF');
      await _database.child('control/last_update').set(ServerValue.timestamp);
      await _database.child('control/device_online').set(true);
    } catch (e) {
      print('Error controlling relay: $e');
      rethrow;
    }
  }

  // Listen ke perubahan status relay
  static Stream<bool> getRelayStatus() {
    return _database.child('control/relay_control').onValue.map((event) {
      final value = event.snapshot.value?.toString() ?? 'OFF';
      return value == 'ON';
    });
  }

  // Listen ke data sensor
  static Stream<Map<String, dynamic>> getSensorData() {
    return _database.child('sensor').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      
      return {
        'voltage': (data['pzem']?['voltage'] as num?)?.toDouble() ?? 0.0,
        'current': (data['pzem']?['current'] as num?)?.toDouble() ?? 0.0,
        'power': (data['pzem']?['power'] as num?)?.toDouble() ?? 0.0,
        'energy': (data['pzem']?['energy'] as num?)?.toDouble() ?? 0.0,
        'timestamp': data['system']?['timestamp']?.toString() ?? '',
        'device_online': data['system']?['device_online'] ?? false,
      };
    });
  }

  // Get device online status
  static Stream<bool> getDeviceOnlineStatus() {
    return _database.child('control/device_online').onValue.map((event) {
      return event.snapshot.value as bool? ?? false;
    });
  }
}