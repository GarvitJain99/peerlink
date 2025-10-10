import 'package:flutter/material.dart';
import 'package:peerlink/app/presentation/library/providers/library_view_model.dart';
import 'package:peerlink/app/presentation/library/widgets/saved_file_list_item.dart';
import 'package:provider/provider.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
      ),
      body: Consumer<LibraryViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.savedFiles.isEmpty) {
            return const Center(
              child: Text(
                'No saved files yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: viewModel.savedFiles.length,
            itemBuilder: (context, index) {
              final file = viewModel.savedFiles[index];
              return SavedFileListItem(file: file);
            },
          );
        },
      ),
    );
  }
}