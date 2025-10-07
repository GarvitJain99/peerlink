import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:peerlink/app/data/models/peer_device_model.dart';
import 'package:peerlink/app/data/services/p2p_service.dart';

class DiscoveryViewModel extends ChangeNotifier {
  final P2pService _p2pService = P2pService();
  StreamSubscription? _deviceSubscription;
  StreamSubscription? _connectionResultSubscription;
  final Map<String, Timer> _lostPeerTimers = {};

  Stream<ConnectionRequest> get connectionRequestStream =>
      _p2pService.connectionRequestStream;

  Map<String, PeerDevice> _peers = {};
  bool _isScanning = false;

  List<PeerDevice> get peers => _peers.values.toList();
  bool get isScanning => _isScanning;

  List<PeerDevice> get connectedPeers {
    return _peers.values
        .where((peer) => peer.status == ConnectionStatus.connected)
        .toList();
  }

  DiscoveryViewModel() {
    _connectionResultSubscription =
        _p2pService.connectionResultStream.listen((result) {
      final id = result.keys.first;
      final status = result.values.first;

      if (_peers.containsKey(id)) {
        _lostPeerTimers[id]?.cancel();
        _lostPeerTimers.remove(id);

        ConnectionStatus newStatus;
        switch (status) {
          case Status.CONNECTED:
            newStatus = ConnectionStatus.connected;
            break;
          case Status.REJECTED:
            newStatus = ConnectionStatus.found;
            break;
          case Status.ERROR:
            newStatus = ConnectionStatus.failed;
            break;
          default:
            newStatus = _peers[id]!.status;
        }
        _peers[id] = _peers[id]!.copyWith(status: newStatus);
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _deviceSubscription?.cancel();
    _connectionResultSubscription?.cancel();
    _lostPeerTimers.forEach((_, timer) => timer.cancel());
    super.dispose();
  }

  Future<void> startScanning(String ownUserName) async {
    if (_isScanning) return;

    _isScanning = true;
    _peers.clear();
    notifyListeners();

    await _p2pService.startAdvertising(ownUserName);
    await _p2pService.startDiscovery(ownUserName);

    _deviceSubscription = _p2pService.deviceStream.listen((device) {
      if (device.status == DeviceStatus.found) {
        if (_lostPeerTimers.containsKey(device.id)) {
          _lostPeerTimers[device.id]?.cancel();
          _lostPeerTimers.remove(device.id);
        }
        if (!_peers.containsKey(device.id)) {
          _peers[device.id] = PeerDevice(id: device.id, name: device.name);
        }
      } else if (device.status == DeviceStatus.lost) {
        _lostPeerTimers[device.id] = Timer(const Duration(seconds: 5), () {
          _peers.remove(device.id);
          _lostPeerTimers.remove(device.id);
          notifyListeners();
        });
      }
      notifyListeners();
    });
  }

  Future<void> stopScanning() async {
    if (!_isScanning) return;

    _lostPeerTimers.forEach((_, timer) => timer.cancel());
    _lostPeerTimers.clear();

    await _p2pService.stopAdvertising();
    await _p2pService.stopDiscovery();
    _deviceSubscription?.cancel();
    _deviceSubscription = null;

    _isScanning = false;
    notifyListeners();
  }

  Future<void> connectToPeer(String peerId, String ownUserName) async {
    if (_peers.containsKey(peerId)) {
      _peers[peerId] = _peers[peerId]!.copyWith(status: ConnectionStatus.connecting);
      notifyListeners();
    }
    await _p2pService.requestConnection(peerId, ownUserName);
  }

  Future<void> acceptConnection(String peerId) async {
    await _p2pService.acceptConnection(peerId);
  }

  Future<void> rejectConnection(String peerId) async {
    await _p2pService.rejectConnection(peerId);
  }

  Future<void> disconnectFromPeer(String peerId) async {
    await _p2pService.disconnectFromPeer(peerId);
    if (_peers.containsKey(peerId)) {
      _peers.remove(peerId);
      notifyListeners();
    }
  }
}