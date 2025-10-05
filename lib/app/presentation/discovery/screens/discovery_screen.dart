import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peerlink/app/presentation/auth/providers/auth_view_model.dart';
import 'package:peerlink/app/presentation/discovery/providers/discovery_view_model.dart';
import 'package:permission_handler/permission_handler.dart'; // Import the package

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
  
  // NEW METHOD to handle permissions
  Future<void> _requestPermissionsAndStartScanning() async {
    // Request multiple permissions at once
    await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.nearbyWifiDevices, // For Android 13 and above
    ].request();
    
    // After permissions are handled, start scanning
    // We pass a placeholder name for now. Later, this will be the user's actual name/ID.
    if (mounted) {
       context.read<DiscoveryViewModel>().startScanning("MyDeviceName");
    }
  }

  @override
  void dispose() {
    // Stop scanning when the screen is disposed to save battery
    // Using context in dispose is tricky, so we find the provider without it.
    Provider.of<DiscoveryViewModel>(context, listen: false).stopScanning();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... the rest of your build method remains exactly the same
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
      body: discoveryViewModel.peers.isEmpty
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
                return ListTile(
                  leading: const Icon(Icons.phone_android),
                  title: Text(peer.name),
                  subtitle: Text(peer.status.toString().split('.').last),
                );
              },
            ),
    );
  }
}