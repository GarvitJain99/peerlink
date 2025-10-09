import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:peerlink/app/data/models/peer_device_model.dart';
import 'package:peerlink/app/data/services/p2p_service.dart';

class DiscoveryViewModel extends ChangeNotifier {
  final P2pService _p2pService = P2pService();
  StreamSubscription? _deviceSubscription;
  StreamSubscription? _endpointLostSubscription;
  StreamSubscription? _connectionRequestSubscription;
  StreamSubscription? _connectionStatusSubscription;

  final StreamController<Map<String, dynamic>> _uiConnectionRequestController =
      StreamController.broadcast();
  Stream<Map<String, dynamic>> get uiConnectionRequestStream =>
      _uiConnectionRequestController.stream;

  Map<String, PeerDevice> _peers = {};
  bool _isScanning = false;

  List<PeerDevice> get peers => _peers.values.toList();
  bool get isScanning => _isScanning;

  DiscoveryViewModel() {
    _deviceSubscription = _p2pService.deviceStream.listen((deviceMap) {
      final id = deviceMap.keys.first;
      final name = deviceMap.values.first;
      if (!_peers.containsKey(id)) {
        _peers[id] = PeerDevice(id: id, name: name);
        notifyListeners();
      }
    });

    _endpointLostSubscription = _p2pService.endpointLostStream.listen(
      (endpointId) {
        if (_peers.containsKey(endpointId)) {
          _peers.remove(endpointId);
          notifyListeners();
        }
      },
    );

    _connectionRequestSubscription = _p2pService.connectionRequestStream.listen(
      (event) {
        _uiConnectionRequestController.add(event);
      },
    );

    _connectionStatusSubscription = _p2pService.connectionStatusStream.listen(
      (event) {
        final id = event['id']!;
        final status = event['status']!;

        if (_peers.containsKey(id)) {
          if (status == 'Status.CONNECTED') {
            _peers[id] = _peers[id]!.copyWith(status: ConnectionStatus.connected);
          } else if (status == 'Status.REJECTED') {
            _peers[id] = _peers[id]!.copyWith(status: ConnectionStatus.found);
          } else { // Handles 'disconnected' and 'Status.ERROR'
            _peers[id] = _peers[id]!.copyWith(status: ConnectionStatus.found);
          }
          notifyListeners();
        }
      },
    );
  }

  @override
  void dispose() {
    _deviceSubscription?.cancel();
    _endpointLostSubscription?.cancel();
    _connectionRequestSubscription?.cancel();
    _connectionStatusSubscription?.cancel();
    _uiConnectionRequestController.close();
    super.dispose();
  }

  Future<void> startScanning(String ownUserName) async {
    if (_isScanning) return;
    _isScanning = true;
    _peers.clear();
    notifyListeners();
    await _p2pService.startAdvertising(ownUserName);
    await _p2pService.startDiscovery(ownUserName);
  }

  // **MODIFIED: This now disconnects everyone and clears the UI**
  Future<void> stopScanning() async {
    if (!_isScanning) return;
    await _disconnectFromAllPeers();
    await _p2pService.stopAdvertising();
    await _p2pService.stopDiscovery();
    _isScanning = false;
    _peers.clear();
    notifyListeners();
  }

  // Helper method for stopScanning
  Future<void> _disconnectFromAllPeers() async {
    final connectedPeers =
        _peers.values.where((p) => p.status == ConnectionStatus.connected).toList();
    for (final peer in connectedPeers) {
      await _p2pService.disconnectFrom(peer.id);
    }
  }

  Future<void> connectToPeer(PeerDevice peer, String ownName) async {
    if (peer.status == ConnectionStatus.found) {
      _peers[peer.id] = peer.copyWith(status: ConnectionStatus.connecting);
      notifyListeners();
      try {
        await _p2pService.requestConnection(peer.id, ownName);
      } on PlatformException catch (e) {
        if (e.code == '8003') { // STATUS_ALREADY_CONNECTED_TO_ENDPOINT
          _peers[peer.id] = peer.copyWith(status: ConnectionStatus.connected);
          notifyListeners();
        } else {
          _peers[peer.id] = peer.copyWith(status: ConnectionStatus.failed);
          notifyListeners();
        }
      }
    }
  }

  Future<void> acceptConnection(String endpointId, bool accept) async {
    await _p2pService.handleConnectionRequest(endpointId, accept);
  }

  // **MODIFIED: This now ONLY changes the status, it does not remove the peer**
  Future<void> disconnectFromPeer(String endpointId) async {
    await _p2pService.disconnectFrom(endpointId);
    if (_peers.containsKey(endpointId)) {
      _peers[endpointId] =
          _peers[endpointId]!.copyWith(status: ConnectionStatus.found);
      notifyListeners();
    }
  }
}