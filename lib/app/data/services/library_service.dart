import 'dart:convert';

import 'package:peerlink/app/data/models/saved_file_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibraryService {
  final String? _userId;

  LibraryService(this._userId);

  // Private getter for the user-specific storage key
  String? get _storageKey {
    if (_userId == null) return null;
    return 'saved_files_library_$_userId';
  }

  /// Retrieves the list of all saved file records from local storage.
  Future<List<SavedFile>> getFiles() async {
    if (_storageKey == null) return [];

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey!);

    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => SavedFile.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  /// Adds a new file record to the list and saves it to local storage.
  Future<void> addFile(SavedFile file) async {
    if (_storageKey == null) return;

    final prefs = await SharedPreferences.getInstance();
    final files = await getFiles();
    files.add(file);
    final List<Map<String, dynamic>> jsonList =
        files.map((f) => f.toJson()).toList();
    await prefs.setString(_storageKey!, jsonEncode(jsonList));
  }

  // Deletes file from last and the local storage
  Future<void> deleteFile(String id) async {
    if (_storageKey == null) return;

    final prefs = await SharedPreferences.getInstance();
    final files = await getFiles();
    files.removeWhere((f) => f.id == id);
    final List<Map<String, dynamic>> jsonList =
        files.map((f) => f.toJson()).toList();
    await prefs.setString(_storageKey!, jsonEncode(jsonList));
  }

  // Updates file in list as well as the local storage
  Future<void> updateFile(SavedFile updatedFile) async {
    if (_storageKey == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final files = await getFiles();
    final index = files.indexWhere((f) => f.id == updatedFile.id);
    if (index != -1) {
      files[index] = updatedFile;
      final List<Map<String, dynamic>> jsonList =
          files.map((f) => f.toJson()).toList();
      await prefs.setString(_storageKey!, jsonEncode(jsonList));
    }
  }
}