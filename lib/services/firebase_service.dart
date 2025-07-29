// services/firebase_service.dart
import 'package:firebase_database/firebase_database.dart';
import '../models/sensor_data.dart';
import '../models/device_control.dart';

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Stream untuk data sensor
  Stream<SensorData> getSensorDataStream() {
    return _database.child('sensor_data').onValue.map((event) {
      if (event.snapshot.exists) {
        return SensorData.fromJson(
          Map<String, dynamic>.from(event.snapshot.value as Map),
        );
      }
      return SensorData(
        voltage: 0.0,
        current: 0.0,
        power: 0.0,
        energy: 0.0,
        frequency: 0.0,
        powerFactor: 0.0,
        lastUpdate: DateTime.now(),
      );
    });
  }

  // Stream untuk kontrol device
  Stream<DeviceControl> getDeviceControlStream() {
    return _database.child('control').onValue.map((event) {
      if (event.snapshot.exists) {
        return DeviceControl.fromJson(
          Map<String, dynamic>.from(event.snapshot.value as Map),
        );
      }
      return DeviceControl(
        deviceOnline: false,
        relayControl: 'OFF',
        lastUpdate: '',
      );
    });
  }

  // Fungsi untuk mengontrol relay di multiple nodes
  Future<void> updateRelayControl(String status) async {
    final timestamp = DateTime.now().toString();

    // Buat update multi-path
    Map<String, dynamic> updates = {
      'control/relay_control': status,
      'control/last_update': timestamp,
      'powerData/relayStatus': status,
      'relay/status': status,
    };

    try {
      await _database.update(updates);
      print('Successfully updated relay status in all nodes');
    } catch (e) {
      print('Error updating relay status: $e');
      throw e;
    }
  }

  // Fungsi untuk mendapatkan data user
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final snapshot = await _database.child('users').child(uid).get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null;
  }
}
