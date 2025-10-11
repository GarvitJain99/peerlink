import 'dart:convert';
import 'dart:io';

import 'package:peerlink/app/data/models/saved_file_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibraryService {
  // REMOVE the static const key
  // static const _storageKey = 'saved_files_library';

  // ADD a final property to hold the current user's ID
  final String? _userId;

  // ADD a constructor that accepts the user ID
  LibraryService(this._userId);

  // ADD a private getter for the user-specific storage key
  String? get _storageKey {
    // If no user is logged in, there is no storage key.
    if (_userId == null) return null;
    return 'saved_files_library_$_userId';
  }

  /// Retrieves the list of all saved file records from local storage.
  Future<List<SavedFile>> getFiles() async {
    // ADD a check to ensure a user is logged in.
    if (_storageKey == null) return [];

    final prefs = await SharedPreferences.getInstance();
    // Use the user-specific key
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
    // ADD a check to ensure a user is logged in.
    if (_storageKey == null) return;

    final prefs = await SharedPreferences.getInstance();
    final files = await getFiles();
    files.add(file);
    final List<Map<String, dynamic>> jsonList =
        files.map((f) => f.toJson()).toList();
    // Use the user-specific key
    await prefs.setString(_storageKey!, jsonEncode(jsonList));
  }

  // ... (Repeat the pattern for deleteFile and updateFile)

  Future<void> deleteFile(String id) async {
    // ADD a check to ensure a user is logged in.
    if (_storageKey == null) return;

    final prefs = await SharedPreferences.getInstance();
    final files = await getFiles();
    // ... (rest of the method is the same)
    files.removeWhere((f) => f.id == id);
    final List<Map<String, dynamic>> jsonList =
        files.map((f) => f.toJson()).toList();
    // Use the user-specific key
    await prefs.setString(_storageKey!, jsonEncode(jsonList));
  }

  Future<void> updateFile(SavedFile updatedFile) async {
    // ADD a check to ensure a user is logged in.
    if (_storageKey == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final files = await getFiles();
    // ... (rest of the method is the same)
    final index = files.indexWhere((f) => f.id == updatedFile.id);
    if (index != -1) {
      files[index] = updatedFile;
      final List<Map<String, dynamic>> jsonList =
          files.map((f) => f.toJson()).toList();
      // Use the user-specific key
      await prefs.setString(_storageKey!, jsonEncode(jsonList));
    }
  }
}