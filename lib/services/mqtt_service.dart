import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';

class MQTTService {
  late MqttServerClient client;
  final String server = 'broker.hivemq.com';
  final int port = 1883;
  String clientId = 'flutter_client_';

  Function(String)? onStatusUpdate;
  Function(Map<String, dynamic>)? onPZEMData;

  Future<void> connect() async {
    clientId += DateTime.now().millisecondsSinceEpoch.toString();
    client = MqttServerClient(server, clientId);
    client.port = port;
    client.keepAlivePeriod = 60;
    client.onDisconnected = _onDisconnected;
    client.logging(on: false);

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .keepAliveFor(60);
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
      return;
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      print('MQTT connected');

      client.subscribe('smart_switch/state_update', MqttQos.atLeastOnce);

      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final recMess = c[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );

        try {
          final data = jsonDecode(payload);
          if (data is Map<String, dynamic>) {
            if (onPZEMData != null) {
              onPZEMData!(data);
            }
          }
        } catch (e) {
          print('Error parsing MQTT message: $e');
        }
      });
    } else {
      print('MQTT connection failed');
    }
  }

  void _onDisconnected() {
    print('MQTT disconnected');
    Future.delayed(const Duration(seconds: 5), () => connect());
  }

  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void disconnect() {
    client.disconnect();
  }
}
