import 'dart:convert';
import 'dart:io';

import 'package:peerlink/app/data/models/saved_file_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibraryService {
  static const _storageKey = 'saved_files_library';

  /// Retrieves the list of all saved file records from local storage.
  Future<List<SavedFile>> getFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString != null) {
      // Decode the JSON string back into a list of maps.
      final List<dynamic> jsonList = jsonDecode(jsonString);
      // Convert each map back into a SavedFile object.
      return jsonList.map((json) => SavedFile.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  /// Adds a new file record to the list and saves it to local storage.
  Future<void> addFile(SavedFile file) async {
    final prefs = await SharedPreferences.getInstance();
    final files = await getFiles();
    files.add(file);
    final List<Map<String, dynamic>> jsonList =
        files.map((f) => f.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  Future<void> deleteFile(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final files = await getFiles();

    SavedFile? fileToDelete;
    try {
      fileToDelete = files.firstWhere((f) => f.id == id);
    } catch (e) {
      print("File record not found for deletion.");
      return; 
    }

    try {
      final fileOnDisk = File(fileToDelete.filePath);
      if (await fileOnDisk.exists()) {
        await fileOnDisk.delete();
      }
    } catch (e) {
      print("Error deleting file from disk: $e");
    }

    files.removeWhere((f) => f.id == id);

    final List<Map<String, dynamic>> jsonList =
        files.map((f) => f.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  /// Updates a file record for renaming.
  Future<void> updateFile(SavedFile updatedFile) async {
    final prefs = await SharedPreferences.getInstance();
    final files = await getFiles();

    final index = files.indexWhere((f) => f.id == updatedFile.id);

    if (index != -1) {
      files[index] = updatedFile;
      final List<Map<String, dynamic>> jsonList =
          files.map((f) => f.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    }
  }
}