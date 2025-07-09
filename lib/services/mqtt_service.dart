import 'dart:convert';
import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  late MqttServerClient client;
  final String server = 'broker.hivemq.com';
  final int port = 1883;
  final String clientId = 'flutter_client_';
  final String statusTopic = 'smart_switch/status';
  final String controlTopic = 'smart_switch/control';
  final String pzemTopic = 'smart_switch/pzem';

  StreamController<bool>? _statusController;
  StreamController<Map<String, dynamic>>? _pzemController;

  MQTTService() {
    client = MqttServerClient(
      server,
      clientId + DateTime.now().millisecondsSinceEpoch.toString(),
    );
    client.logging(on: false);
    client.keepAlivePeriod = 30;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
  }

  Stream<bool> get statusStream => _statusController!.stream;
  Stream<Map<String, dynamic>> get pzemStream => _pzemController!.stream;

  Future<void> connect() async {
    _statusController = StreamController<bool>();
    _pzemController = StreamController<Map<String, dynamic>>();

    try {
      await client.connect();
      client.subscribe(statusTopic, MqttQos.atLeastOnce);
      client.subscribe(pzemTopic, MqttQos.atLeastOnce);
      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        final MqttPublishMessage message =
            messages[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          message.payload.message,
        );

        if (messages[0].topic == statusTopic) {
          _statusController!.add(payload == 'ON');
        } else if (messages[0].topic == pzemTopic) {
          try {
            final data = Map<String, dynamic>.from(json.decode(payload));
            _pzemController!.add(data);
          } catch (e) {
            print('Error parsing PZEM data: $e');
          }
        }
      });
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }
  }

  void _onConnected() {
    print('MQTT Connected');
  }

  void _onSubscribed(String topic) {
    print('Subscribed to $topic');
  }

  void _onDisconnected() {
    print('MQTT Disconnected');
  }

  void controlSwitch(bool state) {
    final message = state ? 'ON' : 'OFF';
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(controlTopic, MqttQos.atLeastOnce, builder.payload!);
  }

  Future<void> disconnect() async {
    client.disconnect();
    _statusController?.close();
    _pzemController?.close();
  }
}
