import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peerlink/app/data/services/p2p_service.dart';
import 'package:peerlink/app/presentation/auth/providers/auth_view_model.dart';
import 'package:peerlink/app/presentation/discovery/providers/discovery_view_model.dart';
import 'package:peerlink/app/presentation/discovery/widgets/peer_list_item.dart';
import 'package:permission_handler/permission_handler.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  StreamSubscription? _connectionRequestSubscription;
  String _ownDeviceName = 'My Device';
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final discoveryViewModel = context.read<DiscoveryViewModel>();
      // Feature: Listen for connection requests to show the dialog
      _connectionRequestSubscription = discoveryViewModel
          .uiConnectionRequestStream
          .listen((event) {
            _showConnectionRequestDialog(
              context,
              event['id'],
              event['info'].endpointName,
            );
          });
      _requestPermissionsAndStartScanning();
    });
  }

  @override
  void dispose() {
    _connectionRequestSubscription?.cancel();
    Provider.of<DiscoveryViewModel>(context, listen: false).stopScanning();
    super.dispose();
  }

  void _showConnectionRequestDialog(
    BuildContext context,
    String id,
    String name,
  ) {
    if (_isDialogShowing) return;

    setState(() {
      _isDialogShowing = true;
    });

    final discoveryViewModel = context.read<DiscoveryViewModel>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Connection Request'),
        content: Text('Do you want to connect with $name?'),
        actions: [
          TextButton(
            onPressed: () {
              discoveryViewModel.acceptConnection(id, false);
              Navigator.of(context).pop();
            },
            child: const Text('REJECT'),
          ),
          ElevatedButton(
            onPressed: () {
              discoveryViewModel.acceptConnection(id, true);
              Navigator.of(context).pop();
            },
            child: const Text('ACCEPT'),
          ),
        ],
      ),
    ).then((_) {
      setState(() {
        _isDialogShowing = false;
      });
    });
  }

  String _formatDeviceName(String email) {
    if (email.isEmpty || !email.contains('@')) return 'PeerLink User';
    final parts = email.split('@').first.split('.');
    if (parts.length >= 2) {
      final firstName = parts[0];
      final regNo = parts[1];
      final capitalizedFirstName =
          firstName[0].toUpperCase() + firstName.substring(1);
      return '$capitalizedFirstName ($regNo)';
    }
    return email.split('@').first;
  }

  void _startScan() {
    final authViewModel = context.read<AuthViewModel>();
    final currentUser = authViewModel.currentUser;
    String deviceName = 'PeerLink User';

    if (currentUser != null && currentUser.email.isNotEmpty) {
      deviceName = _formatDeviceName(currentUser.email);
    }

    setState(() {
      _ownDeviceName = deviceName;
    });

    context.read<DiscoveryViewModel>().startScanning(deviceName);
  }

  Future<void> _requestPermissionsAndStartScanning() async {
    await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.nearbyWifiDevices,
    ].request();

    if (mounted) {
      _startScan();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();
    final discoveryViewModel = context.watch<DiscoveryViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Peers'),
        actions: [
          if (discoveryViewModel.connectedPeers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, right: 8.0),
              child: Badge(
                label: Text(discoveryViewModel.connectedPeers.length.toString()),
                child: IconButton(
                  icon: const Icon(Icons.group),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ConnectedPeersScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<DiscoveryViewModel>().stopScanning();
              authViewModel.signOut();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: const EdgeInsets.all(16.0),
            elevation: 4,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.person),
              ),
              title: Text(
                _ownDeviceName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('You'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'NEARBY PEERS',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          const Divider(indent: 16, endIndent: 16),
          Expanded(
            child: discoveryViewModel.isScanning &&
                    discoveryViewModel.peers.isEmpty
                ? const SearchingAnimation()
                : ListView.builder(
                    itemCount: discoveryViewModel.peers.length,
                    itemBuilder: (context, index) {
                      final peer = discoveryViewModel.peers[index];
                      return PeerListItem(
                        peer: peer,
                        onConnect: () {
                          discoveryViewModel.connectToPeer(
                            peer,
                            _ownDeviceName,
                          );
                        },
                        onDisconnect: () {
                          discoveryViewModel.disconnectFromPeer(peer.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (discoveryViewModel.isScanning) {
            discoveryViewModel.stopScanning();
          } else {
            _startScan();
          }
        },
        label: Text(discoveryViewModel.isScanning ? 'Stop' : 'Scan'),
        icon: Icon(discoveryViewModel.isScanning ? Icons.stop : Icons.search),
      ),
    );
  }
}