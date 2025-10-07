import 'dart:async';
import 'package:nearby_connections/nearby_connections.dart';

// Helper class to make stream data clearer
enum DeviceStatus { found, lost }

class DiscoveredDevice {
  final String id;
  final String name;
  final DeviceStatus status;

  DiscoveredDevice({required this.id, required this.name, required this.status});
}

// Model to hold info about an incoming connection request
class ConnectionRequest {
  final String deviceId;
  final String deviceName;
  final String endpointName;

  ConnectionRequest({
    required this.deviceId,
    required this.deviceName,
    required this.endpointName,
  });
}

class P2pService {
  // **OPTIMIZATION: Changed strategy for faster discovery**
  final Strategy _strategy = Strategy.P2P_POINT_TO_POINT;
  final _nearby = Nearby();

  final StreamController<DiscoveredDevice> _deviceStreamController =
      StreamController<DiscoveredDevice>.broadcast();

  final StreamController<ConnectionRequest> _connectionRequestController =
      StreamController<ConnectionRequest>.broadcast();

  final StreamController<Map<String, Status>> _connectionResultController =
      StreamController<Map<String, Status>>.broadcast();

  Stream<DiscoveredDevice> get deviceStream => _deviceStreamController.stream;
  Stream<ConnectionRequest> get connectionRequestStream =>
      _connectionRequestController.stream;
  Stream<Map<String, Status>> get connectionResultStream =>
      _connectionResultController.stream;

  Future<void> startDiscovery(String ownUserName) async {
    try {
      await _nearby.startDiscovery(
        ownUserName,
        _strategy,
        onEndpointFound: (id, name, serviceId) {
          _deviceStreamController.add(
            DiscoveredDevice(id: id, name: name, status: DeviceStatus.found),
          );
        },
        onEndpointLost: (id) {
          if (id != null) {
            print('Endpoint lost: $id');
            _deviceStreamController.add(
              DiscoveredDevice(id: id, name: '', status: DeviceStatus.lost),
            );
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
          print('Connection initiated: $id, ${info.endpointName}');
          _connectionRequestController.add(ConnectionRequest(
            deviceId: id,
            deviceName: info.endpointName,
            endpointName: info.endpointName,
          ));
        },
        onConnectionResult: (id, status) {
          print('Connection result: $id, $status');
          _connectionResultController.add({id: status});
        },
        onDisconnected: (id) {
          print('Disconnected: $id');
          _connectionResultController.add({id: Status.ERROR});
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

  Future<void> requestConnection(String peerId, String ownUserName) async {
    try {
      await _nearby.requestConnection(
        ownUserName,
        peerId,
        onConnectionInitiated: (id, info) {
          _nearby.acceptConnection(id, onPayLoadRecieved: (endpointId, payload) {});
        },
        onConnectionResult: (id, status) {
          _connectionResultController.add({id: status});
        },
        onDisconnected: (id) {
          _connectionResultController.add({id: Status.ERROR});
        },
      );
    } catch (e) {
      print('Error requesting connection: $e');
    }
  }

  Future<void> acceptConnection(String peerId) async {
    await _nearby.acceptConnection(peerId, onPayLoadRecieved: (endpointId, payload) {});
  }

  Future<void> rejectConnection(String peerId) async {
    await _nearby.rejectConnection(peerId);
  }
}