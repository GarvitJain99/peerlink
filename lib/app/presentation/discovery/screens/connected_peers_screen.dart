import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peerlink/app/presentation/discovery/providers/discovery_view_model.dart';

class ConnectedPeersScreen extends StatelessWidget {
  const ConnectedPeersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DiscoveryViewModel>();
    final connectedPeers = viewModel.connectedPeers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connected Group'),
      ),
      body: Column(
        children: [
          Expanded(
            child: connectedPeers.isEmpty
                ? const Center(
                    child: Text('No peers connected.'),
                  )
                : ListView.builder(
                    itemCount: connectedPeers.length,
                    itemBuilder: (context, index) {
                      final peer = connectedPeers[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(
                          peer.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'Connected',
                          style: TextStyle(color: Colors.green),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.link_off, color: Colors.red),
                          onPressed: () {
                            viewModel.disconnectFromPeer(peer.id);
                          },
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                // File sharing logic will go here
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Share Files with Group'),
            ),
          )
        ],
      ),
    );
  }
}