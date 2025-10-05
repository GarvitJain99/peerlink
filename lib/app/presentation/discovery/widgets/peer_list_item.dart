import 'package:flutter/material.dart';
import 'package:peerlink/app/data/models/peer_device_model.dart';

class PeerListItem extends StatelessWidget {
  final PeerDevice peer;
  final VoidCallback onConnect;

  const PeerListItem({
    super.key,
    required this.peer,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    // Determine icon and color based on connection status
    IconData statusIcon;
    Color statusColor;
    String statusText = peer.status.toString().split('.').last;

    switch (peer.status) {
      case ConnectionStatus.connected:
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        break;
      case ConnectionStatus.connecting:
        statusIcon = Icons.sync;
        statusColor = Colors.orange;
        break;
      case ConnectionStatus.failed:
        statusIcon = Icons.error;
        statusColor = Colors.red;
        break;
      default: // found or disconnected
        statusIcon = Icons.tap_and_play;
        statusColor = Colors.blue;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: const Icon(Icons.phone_android),
        ),
        title: Text(peer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 16),
            const SizedBox(width: 4),
            Text(statusText),
          ],
        ),
        trailing: peer.status == ConnectionStatus.found
            ? ElevatedButton(
                onPressed: onConnect,
                child: const Text('Connect'),
              )
            : null, // Hide button if not in 'found' state
      ),
    );
  }
}