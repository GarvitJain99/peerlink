import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:peerlink/app/data/models/saved_file_model.dart';
import 'package:peerlink/app/data/services/library_service.dart';

// Enums to manage UI state for sorting and filtering
enum SortOption { dateDesc, dateAsc, nameAsc, nameDesc, sizeDesc, sizeAsc }
enum FilterType { all, pdf, image, video, doc }

class LibraryViewModel extends ChangeNotifier {
  final LibraryService _libraryService;

  LibraryViewModel(this._libraryService) {
    loadFiles();
  }

  // State variables
  bool _isLoading = true;
  List<SavedFile> _allFiles = [];
  List<SavedFile> _displayedFiles = [];
  String _searchQuery = '';
  SortOption _currentSort = SortOption.dateDesc; // Default: Newest first
  FilterType _currentFilter = FilterType.all;   // Default: Show all

  // Getters for the UI
  bool get isLoading => _isLoading;
  List<SavedFile> get displayedFiles => _displayedFiles;
  SortOption get currentSort => _currentSort;
  FilterType get currentFilter => _currentFilter;

  Future<void> loadFiles() async {
    _isLoading = true;
    notifyListeners();
    _allFiles = await _libraryService.getFiles();
    _applyFiltersAndSort(); // Apply default sort/filter
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteFile(String id) async {
    await _libraryService.deleteFile(id);
    await loadFiles(); // Reload all files and re-apply filters
  }

  // ADDED: Complete implementation for renaming a file.
  Future<void> renameFile(SavedFile file, String newName) async {
    final extension = p.extension(file.fileName);
    final newFileNameWithExt = '$newName$extension';

    // Physically rename the file on the device's storage
    final originalFileOnDisk = File(file.filePath);
    if (await originalFileOnDisk.exists()) {
      try {
        final directory = p.dirname(file.filePath);
        final newPath = p.join(directory, newFileNameWithExt);
        await originalFileOnDisk.rename(newPath);

        // Create an updated SavedFile object with the new name and path
        final updatedFile = SavedFile(
          id: file.id,
          fileName: newFileNameWithExt,
          filePath: newPath, // Update the path as well
          fileSize: file.fileSize,
          dateSaved: file.dateSaved,
          senderName: file.senderName,
        );

        await _libraryService.updateFile(updatedFile);
        await loadFiles(); // Reload to reflect changes in the UI
      } catch (e) {
        print("Error renaming file on disk: $e");
        // Optionally, show an error message to the user
      }
    }
  }

  // --- New methods for UI interaction ---

  void changeSort(SortOption option) {
    _currentSort = option;
    _applyFiltersAndSort();
  }

  void changeFilter(FilterType type) {
    _currentFilter = type;
    _applyFiltersAndSort();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
  }

  // --- Core private method to process the file list ---

  void _applyFiltersAndSort() {
    List<SavedFile> result = List.from(_allFiles);

    // 1. Apply Filter
    if (_currentFilter != FilterType.all) {
      result = result.where((file) {
        final extension = file.fileName.split('.').last.toLowerCase();
        switch (_currentFilter) {
          case FilterType.pdf:
            return extension == 'pdf';
          case FilterType.image:
            return ['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(extension);
          case FilterType.video:
            return ['mp4', 'mov', 'avi', 'mkv'].contains(extension);
          case FilterType.doc:
            return ['doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'txt']
                .contains(extension);
          default:
            return true;
        }
      }).toList();
    }

    // 2. Apply Search Query
    if (_searchQuery.isNotEmpty) {
      result = result.where((file) {
        return file.fileName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // 3. Apply Sort
    switch (_currentSort) {
      case SortOption.dateDesc:
        result.sort((a, b) => b.dateSaved.compareTo(a.dateSaved));
        break;
      case SortOption.dateAsc:
        result.sort((a, b) => a.dateSaved.compareTo(b.dateSaved));
        break;
      case SortOption.nameAsc:
        result.sort((a, b) =>
            a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase()));
        break;
      case SortOption.nameDesc:
        result.sort((a, b) =>
            b.fileName.toLowerCase().compareTo(a.fileName.toLowerCase()));
        break;
      case SortOption.sizeDesc:
        result.sort((a, b) => b.fileSize.compareTo(a.fileSize));
        break;
      case SortOption.sizeAsc:
        result.sort((a, b) => a.fileSize.compareTo(b.fileSize));
        break;
    }

    _displayedFiles = result;
    notifyListeners();
  }
}