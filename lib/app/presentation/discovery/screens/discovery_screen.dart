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
    _requestPermissionsAndStartScanning();
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
       context.read<DiscoveryViewModel>().startScanning("MyDeviceName");
    }
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
          )
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
                // Use our new, beautiful widget!
                return PeerListItem(
                  peer: peer,
                  onConnect: () {
                    // We will implement connection logic here in the next step
                    print('Connecting to ${peer.name}...');
                  },
                );
              },
            ),
      // Add a FloatingActionButton to start/stop scanning
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (discoveryViewModel.isScanning) {
            discoveryViewModel.stopScanning();
          } else {
            // We use the same name for now
            discoveryViewModel.startScanning("MyDeviceName");
          }
        },
        label: Text(discoveryViewModel.isScanning ? 'Stop' : 'Scan'),
        icon: Icon(discoveryViewModel.isScanning ? Icons.stop : Icons.search),
      ),
    );
  }
}