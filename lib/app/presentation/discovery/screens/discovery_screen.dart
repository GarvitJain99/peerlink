import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peerlink/app/data/services/p2p_service.dart';
import 'package:peerlink/app/presentation/auth/providers/auth_view_model.dart';
import 'package:peerlink/app/presentation/discovery/providers/discovery_view_model.dart';
import 'package:peerlink/app/presentation/discovery/widgets/peer_list_item.dart';
import 'package:peerlink/app/presentation/discovery/widgets/searching_animation.dart';
import 'package:permission_handler/permission_handler.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  StreamSubscription? _connectionRequestSubscription;
  String _ownDeviceName = 'My Device';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToConnectionRequests();
      _requestPermissionsAndStartScanning();
    });
  }

  void _listenToConnectionRequests() {
    final viewModel = context.read<DiscoveryViewModel>();
    _connectionRequestSubscription =
        viewModel.connectionRequestStream.listen((request) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Connection Request'),
          content: Text('Do you want to connect with ${request.deviceName}?'),
          actions: [
            TextButton(
              onPressed: () {
                viewModel.rejectConnection(request.deviceId);
                Navigator.of(context).pop();
              },
              child: const Text('Decline'),
            ),
            TextButton(
              onPressed: () {
                viewModel.acceptConnection(request.deviceId);
                Navigator.of(context).pop();
              },
              child: const Text('Accept'),
            ),
          ],
        ),
      );
    });
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

  @override
  void dispose() {
    _connectionRequestSubscription?.cancel();
    Provider.of<DiscoveryViewModel>(context, listen: false).stopScanning();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();
    final discoveryViewModel = context.watch<DiscoveryViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Peers'),
        actions: [
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
                          final ownUserName = _ownDeviceName;
                          discoveryViewModel.connectToPeer(peer.id, ownUserName);
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