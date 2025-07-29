// models/device_control.dart
class DeviceControl {
  final bool deviceOnline;
  final String relayControl;
  final String lastUpdate;

  DeviceControl({
    required this.deviceOnline,
    required this.relayControl,
    required this.lastUpdate,
  });

  factory DeviceControl.fromJson(Map<dynamic, dynamic> json) {
    return DeviceControl(
      deviceOnline: json['device_online'] ?? false,
      relayControl: json['relay_control'] ?? 'OFF',
      lastUpdate: json['last_update'] ?? '',
    );
  }
}
