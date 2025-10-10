import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:nearby_connections/nearby_connections.dart';

class P2pService {
  // Changed from P2P_STAR to P2P_POINT_TO_POINT
  final Strategy _strategy = Strategy.P2P_POINT_TO_POINT;
  final _nearby = Nearby();

  // Stream for broadcasting found devices
  final StreamController<Map<String, String>> _deviceStreamController =
      StreamController<Map<String, String>>.broadcast();
  Stream<Map<String, String>> get deviceStream =>
      _deviceStreamController.stream;

  // Stream for broadcasting when a device is no longer visible
  final StreamController<String> _endpointLostController =
      StreamController<String>.broadcast();
  Stream<String> get endpointLostStream => _endpointLostController.stream;

  // Stream for broadcasting incoming connection requests
  final StreamController<Map<String, dynamic>> _connectionRequestController =
      StreamController.broadcast();
  Stream<Map<String, dynamic>> get connectionRequestStream =>
      _connectionRequestController.stream;

  // Stream for broadcasting connection status updates (connected, failed, etc.)
  final StreamController<Map<String, String>> _connectionStatusController =
      StreamController.broadcast();
  Stream<Map<String, String>> get connectionStatusStream =>
      _connectionStatusController.stream;

  final StreamController<Map<String, dynamic>> _payloadController =
      StreamController.broadcast();
  Stream<Map<String, dynamic>> get payloadStream => _payloadController.stream;

  final StreamController<Map<String, dynamic>> _payloadTransferController =
      StreamController.broadcast();
  Stream<Map<String, dynamic>> get payloadTransferStream =>
      _payloadTransferController.stream;

  Future<void> startDiscovery(String ownUserName) async {
    try {
      await _nearby.startDiscovery(
        ownUserName,
        _strategy,
        onEndpointFound: (id, name, serviceId) {
          // Add the found device to our stream
          _deviceStreamController.add({id: name});
        },
        onEndpointLost: (id) {
          if (id != null) {
            _endpointLostController.add(id);
          }
        },
      );
      print('Discovery started');
    } catch (e) {
      print('Error starting discovery: $e');
    }
  }

  Future<void> stopDiscovery() async {
    await _nearby.stopDiscovery();
    print('Discovery stopped');
  }

  Future<void> startAdvertising(String ownUserName) async {
    try {
      await _nearby.startAdvertising(
        ownUserName,
        _strategy,
        onConnectionInitiated: (id, info) {
          _connectionRequestController.add({'id': id, 'info': info});
        },
        onConnectionResult: (id, status) {
          _connectionStatusController.add({
            'id': id,
            'status': status.toString(),
          });
        },
        onDisconnected: (id) {
          _connectionStatusController.add({'id': id, 'status': 'disconnected'});
        },
      );
      print('Advertising started');
    } catch (e) {
      print('Error starting advertising: $e');
    }
  }

  Future<void> stopAdvertising() async {
    await _nearby.stopAdvertising();
    print('Advertising stopped');
  }

  Future<void> requestConnection(String endpointId, String ownName) async {
    try {
      await _nearby.requestConnection(
        ownName,
        endpointId,
        onConnectionInitiated: (id, info) {
          _connectionRequestController.add({'id': id, 'info': info});
        },
        onConnectionResult: (id, status) {
          _connectionStatusController.add({
            'id': id,
            'status': status.toString(),
          });
        },
        onDisconnected: (id) {
          _connectionStatusController.add({'id': id, 'status': 'disconnected'});
        },
      );
    } catch (e) {
      print("requestConnection error: $e");
      rethrow;
    }
  }

  Future<void> handleConnectionRequest(String endpointId, bool accept) async {
    if (accept) {
      await _nearby.acceptConnection(
        endpointId,
        onPayLoadRecieved: (endpointId, payload) {
          _payloadController.add({'id': endpointId, 'payload': payload});
        },
        onPayloadTransferUpdate: (endpointId, payloadTransferUpdate) {
          _payloadTransferController.add({
            'id': endpointId,
            'update': payloadTransferUpdate,
          });
        },
      );
    } else {
      await _nearby.rejectConnection(endpointId);
    }
  }

  Future<void> disconnectFrom(String endpointId) async {
    await _nearby.disconnectFromEndpoint(endpointId);
  }

  Future<int> sendFile(String endpointId, String filePath) async {
    return await _nearby.sendFilePayload(endpointId, filePath);
  }

  Future<void> sendBytes(String endpointId, Map<String, dynamic> data) async {
    final byteData = Uint8List.fromList(jsonEncode(data).codeUnits);
    await _nearby.sendBytesPayload(endpointId, byteData);
  }

  Future<void> cancelTransfer(int payloadId) async {
    await _nearby.cancelPayload(payloadId);
  }
}
