import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:peerlink/app/data/models/transfer_update_model.dart';
import 'package:peerlink/app/presentation/transfer/providers/transfer_view_model.dart';
import 'package:provider/provider.dart';

class TransferListItem extends StatelessWidget {
  final TransferUpdate transfer;
  const TransferListItem({super.key, required this.transfer});

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transfer.fileName, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatBytes(transfer.fileSize)),
                Text(
                  transfer.status.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (transfer.status == TransferStatus.receiving ||
                transfer.status == TransferStatus.sending)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: LinearProgressIndicator(
                  value: transfer.progress,
                  minHeight: 6,
                ),
              ),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (transfer.status) {
      case TransferStatus.sending:
      case TransferStatus.receiving:
        return Colors.blue;
      case TransferStatus.success:
      case TransferStatus.saved:
        return Colors.green;
      case TransferStatus.failed:
      case TransferStatus.canceled:
        return Colors.red;
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    final viewModel = context.read<TransferViewModel>();
    switch (transfer.status) {
      case TransferStatus.receiving:
      case TransferStatus.sending:
        return TextButton.icon(
          label: const Text('Cancel'),
          icon: const Icon(Icons.cancel, color: Colors.red),
          onPressed: () => viewModel.cancelTransfer(transfer.payloadId),
        );
      case TransferStatus.success:
        if (transfer.isSender) {
          // The sender sees a confirmation message
          return Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              label: const Text('Sent'),
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: null, 
            ),
          );
        } else {
          return Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              label: const Text('Save to Device'),
              icon: const Icon(Icons.download, color: Colors.green),
              onPressed: () => viewModel.saveFile(transfer.payloadId),
            ),
          );
        }
      case TransferStatus.saved:
        return TextButton.icon(
          label: const Text('Open File'),
          icon: const Icon(Icons.open_in_new),
          onPressed: () {
            if (transfer.finalFilePath != null) {
              OpenFile.open(transfer.finalFilePath);
            }
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}