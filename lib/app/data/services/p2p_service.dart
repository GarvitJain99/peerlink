import 'dart:async';
// **💡 THIS IS THE LINE THAT WAS MISSING 💡**
import 'package:nearby_connections/nearby_connections.dart';

class P2pService {
  final Strategy _strategy = Strategy.P2P_STAR;
  final _nearby = Nearby();

  // A stream controller to broadcast found devices
  final StreamController<Map<String, String>> _deviceStreamController =
      StreamController<Map<String, String>>.broadcast();

  Stream<Map<String, String>> get deviceStream => _deviceStreamController.stream;

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
          // Handle lost endpoint if necessary
          print('Endpoint lost: $id');
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
          // Handle incoming connection requests here
        },
        onConnectionResult: (id, status) {
          // Handle connection results here
        },
        onDisconnected: (id) {
          // Handle disconnections here
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
}