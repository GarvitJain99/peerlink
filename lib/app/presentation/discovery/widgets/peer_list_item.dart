import 'package:flutter/material.dart';
import 'package:peerlink/app/data/models/peer_device_model.dart';

class PeerListItem extends StatelessWidget {
  final PeerDevice peer;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const PeerListItem({
    super.key,
    required this.peer,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: const Icon(Icons.phone_android_sharp),
        ),
        title: Text(peer.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: [
            Icon(_getStatusIcon(), color: _getStatusColor(), size: 16),
            const SizedBox(width: 4),
            Text(peer.status.toString().split('.').last),
          ],
        ),
        trailing: _buildTrailingWidget(),
      ),
    );
  }

  Color _getStatusColor() {
    switch (peer.status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
        return Colors.orange;
      case ConnectionStatus.failed:
        return Colors.red;
      case ConnectionStatus.busy:
        return Colors.grey;
      default: // found or disconnected
        return Colors.blue;
    }
  }

  IconData _getStatusIcon() {
    switch (peer.status) {
      case ConnectionStatus.connected:
        return Icons.check_circle;
      case ConnectionStatus.connecting:
        return Icons.sync;
      case ConnectionStatus.failed:
        return Icons.error;
      case ConnectionStatus.busy:
        return Icons.do_not_disturb_on;
      default:
        return Icons.tap_and_play;
    }
  }

  Widget? _buildTrailingWidget() {
    switch (peer.status) {
      case ConnectionStatus.found:
      case ConnectionStatus.disconnected:
      case ConnectionStatus.failed:
        return ElevatedButton(
          onPressed: onConnect,
          child: const Text('Connect'),
        );
      case ConnectionStatus.connecting:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 3),
        );
      case ConnectionStatus.busy:
        return const Chip(label: Text('Busy'), backgroundColor: Colors.grey);
      case ConnectionStatus.connected:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              tooltip: 'Disconnect',
              onPressed: onDisconnect,
            ),
          ],
        );
    }
  }
}