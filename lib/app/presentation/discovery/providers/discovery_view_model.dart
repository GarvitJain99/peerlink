import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:peerlink/app/data/models/peer_device_model.dart';
import 'package:peerlink/app/data/services/p2p_service.dart';

class DiscoveryViewModel extends ChangeNotifier {
  final P2pService _p2pService = P2pService();
  StreamSubscription? _deviceSubscription;

  Map<String, PeerDevice> _peers = {};
  bool _isScanning = false;

  List<PeerDevice> get peers => _peers.values.toList();
  bool get isScanning => _isScanning;

  @override
  void dispose() {
    _deviceSubscription?.cancel();
    super.dispose();
  }

  Future<void> startScanning(String ownUserName) async {
    if (_isScanning) return;

    _isScanning = true;
    _peers.clear();
    notifyListeners();

    // Start advertising and discovering simultaneously
    await _p2pService.startAdvertising(ownUserName);
    await _p2pService.startDiscovery(ownUserName);
    
    // Listen to the stream of found devices
    _deviceSubscription = _p2pService.deviceStream.listen((deviceMap) {
      final id = deviceMap.keys.first;
      final name = deviceMap.values.first;
      
      if (!_peers.containsKey(id)) {
        _peers[id] = PeerDevice(id: id, name: name);
        notifyListeners();
      }
    });
  }

  Future<void> stopScanning() async {
    if (!_isScanning) return;

    await _p2pService.stopAdvertising();
    await _p2pService.stopDiscovery();
    _deviceSubscription?.cancel();
    
    _isScanning = false;
    _peers.clear();
    notifyListeners();
  }
}