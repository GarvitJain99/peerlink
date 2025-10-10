import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:peerlink/app/data/models/saved_file_model.dart';
import 'package:peerlink/app/presentation/library/providers/library_view_model.dart';
import 'package:peerlink/app/presentation/pdf_viewer/screens/pdf_viewer_screen.dart';
import 'package:provider/provider.dart';

class SavedFileListItem extends StatelessWidget {
  final SavedFile file;
  const SavedFileListItem({super.key, required this.file});

  // Helper to format file size
  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<LibraryViewModel>();
    final isPdf = file.fileName.toLowerCase().endsWith('.pdf');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        // The default tap action is now to open externally
        onTap: () => OpenFile.open(file.filePath),
        leading: const Icon(Icons.insert_drive_file, size: 40),
        title: Text(
          file.fileName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Received from: ${file.senderName}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'open':
                OpenFile.open(file.filePath);
                break;
              case 'open_in_app':
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PdfViewerScreen(savedFile: file),
                  ),
                );
                break;
              case 'details':
                _showDetailsDialog(context);
                break;
              case 'rename':
                _showRenameDialog(context, viewModel);
                break;
              case 'delete':
                _showDeleteConfirmationDialog(context, viewModel);
                break;
            }
          },
          itemBuilder: (context) {
            // Build the menu items based on file type
            List<PopupMenuEntry<String>> menuItems = [];

            // Add the 'Open In-App' option only if it's a PDF
            if (isPdf) {
              menuItems.add(
                const PopupMenuItem(
                  value: 'open_in_app',
                  child: Text('Open In-App'),
                ),
              );
              menuItems.add(
                const PopupMenuItem(
                  value: 'open',
                  child: Text('Open Externally'),
                ),
              );
            }

            // Add the rest of the options
            menuItems.addAll([
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'details', child: Text('Details')),
              const PopupMenuItem(value: 'rename', child: Text('Rename')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ]);

            return menuItems;
          },
        ),
      ),
    );
  }

  // Dialog to show file details
  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(file.fileName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Size: ${_formatBytes(file.fileSize)}'),
            const SizedBox(height: 8),
            Text(
              'Received on: ${DateFormat.yMMMd().add_jm().format(file.dateSaved)}',
            ),
            const SizedBox(height: 8),
            Text('From: ${file.senderName}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Dialog to confirm deletion
  void _showDeleteConfirmationDialog(
    BuildContext context,
    LibraryViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text(
          'Are you sure you want to delete "${file.fileName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              viewModel.deleteFile(file.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Dialog for renaming the file
  void _showRenameDialog(BuildContext context, LibraryViewModel viewModel) {
    final controller = TextEditingController(
      text: file.fileName.split('.').first,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename File'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter new name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                viewModel.renameFile(file, newName);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }
}
