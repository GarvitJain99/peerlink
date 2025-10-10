import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:peerlink/app/data/models/saved_file_model.dart';
import 'package:peerlink/app/data/services/library_service.dart';

class LibraryViewModel extends ChangeNotifier {
  final LibraryService _libraryService;

  LibraryViewModel(this._libraryService) {
    loadFiles();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<SavedFile> _savedFiles = [];
  List<SavedFile> get savedFiles => _savedFiles;

  /// Loads the list of saved files
  Future<void> loadFiles() async {
    _isLoading = true;
    notifyListeners();
    _savedFiles = await _libraryService.getFiles();
    // Sort by newest to oldest
    _savedFiles.sort((a, b) => b.dateSaved.compareTo(a.dateSaved));
    _isLoading = false;
    notifyListeners();
  }

  /// Deletes a file record
  Future<void> deleteFile(String id) async {
    await _libraryService.deleteFile(id);
    await loadFiles();
  }

  /// Renames a file
  Future<void> renameFile(SavedFile file, String newName) async {
    final directory = File(file.filePath).parent.path;
    final extension = file.fileName.split('.').last;
    final newFilePath = '$directory/$newName.$extension';
    
    try {
      final oldFile = File(file.filePath);
      if (await oldFile.exists()) {
        await oldFile.rename(newFilePath);
      }
    } catch (e) {
      print("Error renaming file on disk: $e");
      return;
    }
    
    // New Saved File object with new name
    final updatedFile = SavedFile(
      id: file.id,
      fileName: '$newName.$extension',
      filePath: newFilePath,
      fileSize: file.fileSize,
      dateSaved: file.dateSaved,
      senderName: file.senderName,
    );
    
    // Update the record
    await _libraryService.updateFile(updatedFile);
    
    // Reload the list to show the updated name.
    await loadFiles();
  }
}