import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peerlink/app/presentation/auth/providers/auth_view_model.dart';
import 'package:peerlink/app/presentation/discovery/providers/discovery_view_model.dart';
import 'package:peerlink/app/presentation/discovery/widgets/peer_list_item.dart'; // Import new widget
import 'package:permission_handler/permission_handler.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _requestPermissionsAndStartScanning());
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
    if (email.isEmpty || !email.contains('@')) {
      return 'PeerLink User';
    }
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
    String deviceName = 'PeerLink User'; // Default name

    if (currentUser != null && currentUser.email.isNotEmpty) {
      deviceName = _formatDeviceName(currentUser.email);
    }

    context.read<DiscoveryViewModel>().startScanning(deviceName);
  }

  @override
  void dispose() {
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
              authViewModel.signOut();
            },
          ),
        ],
      ),
      body: discoveryViewModel.isScanning && discoveryViewModel.peers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Looking for nearby peers...'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: discoveryViewModel.peers.length,
              itemBuilder: (context, index) {
                final peer = discoveryViewModel.peers[index];
                return PeerListItem(
                  peer: peer,
                  onConnect: () {
                    print('Connecting to ${peer.name}...');
                  },
                );
              },
            ),
      // FloatingActionButton to start/stop scanning
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
