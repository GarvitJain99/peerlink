import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:peerlink/app/data/models/peer_device_model.dart';
import 'package:peerlink/app/data/services/p2p_service.dart';
import 'package:peerlink/app/presentation/discovery/providers/discovery_view_model.dart';
import 'package:peerlink/app/presentation/transfer/providers/transfer_view_model.dart';
import 'package:peerlink/app/presentation/transfer/widgets/transfer_list_item.dart';
import 'package:provider/provider.dart';

class TransferScreen extends StatelessWidget {
  final PeerDevice peer;
  const TransferScreen({super.key, required this.peer});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransferViewModel(
        context.read<P2pService>(),
        peer.id,
      ),
      child: Consumer<TransferViewModel>(
        builder: (context, viewModel, child) {
          return WillPopScope(
            onWillPop: () async {
              context.read<DiscoveryViewModel>().disconnectFromPeer(peer.id);
              return true;
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(peer.name, textAlign: TextAlign.center,),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: viewModel.transfers.isEmpty
                        ? const Center(child: Text('No transfers yet.'))
                        : ListView.builder(
                            itemCount: viewModel.transfers.length,
                            itemBuilder: (context, index) {
                              return TransferListItem(
                                transfer: viewModel.transfers[index],
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles();
                        if (result != null && result.files.single.path != null) {
                          viewModel.sendFile(result.files.single.path!);
                        }
                      },
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Send File'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}