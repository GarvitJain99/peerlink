import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peerlink/app/data/models/peer_device_model.dart';
import 'package:peerlink/app/presentation/discovery/providers/discovery_view_model.dart';

class ChatScreen extends StatefulWidget {
  final PeerDevice peer;
  const ChatScreen({super.key, required this.peer});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // When the back button is pressed, initiate the disconnect.
        context.read<DiscoveryViewModel>().disconnectFromPeer(widget.peer.id);
        return true; // Allow the screen to be popped.
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.peer.name),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Connected to ${widget.peer.name}'),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement file picking
                },
                icon: const Icon(Icons.attach_file),
                label: const Text('Send File'),
              )
            ],
          ),
        ),
      ),
    );
  }
}