// models/sensor_data.dart
class SensorData {
  final double voltage;
  final double current;
  final double power;
  final double energy;
  final double frequency;
  final double powerFactor;
  final DateTime lastUpdate;

  SensorData({
    required this.voltage,
    required this.current,
    required this.power,
    required this.energy,
    required this.frequency,
    required this.powerFactor,
    required this.lastUpdate,
  });

  factory SensorData.fromJson(Map<dynamic, dynamic> json) {
    return SensorData(
      voltage: (json['voltage'] ?? 0.0).toDouble(),
      current: (json['current'] ?? 0.0).toDouble(),
      power: (json['power'] ?? 0.0).toDouble(),
      energy: (json['energy'] ?? 0.0).toDouble(),
      frequency: (json['frequency'] ?? 0.0).toDouble(),
      powerFactor: (json['power_factor'] ?? 0.0).toDouble(),
      lastUpdate: DateTime.now(),
    );
  }
}
