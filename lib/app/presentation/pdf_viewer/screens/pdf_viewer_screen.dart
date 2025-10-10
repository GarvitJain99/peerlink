import 'dart:io';
import 'package:flutter/material.dart';
import 'package:peerlink/app/data/models/saved_file_model.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatefulWidget {
  final SavedFile savedFile;
  const PdfViewerScreen({super.key, required this.savedFile});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfViewerController _pdfViewerController;
  late TextEditingController _searchController;
  late PdfTextSearchResult _searchResult;

  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _searchController = TextEditingController();
    // Initialize with an empty result to prevent null issues.
    _searchResult = PdfTextSearchResult();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Toggles the visibility of the search bar.
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        // Clear results and text when exiting search mode.
        _searchResult.clear();
        _searchController.clear();
      }
    });
  }

  /// Performs search as the user types.
  void _performSearch(String text) async {
    if (text.isEmpty) {
      // If the search text is empty, clear the results.
      setState(() {
        _searchResult.clear();
      });
      return;
    }
    // Await the search and then update the state with the new results.
    final result = await _pdfViewerController.searchText(text);
    // **MODIFICATION**: Update state and reset the flag once search completes.
    setState(() {
      _searchResult = result;
    });
  }

  /// Builds the default app bar.
  AppBar _buildDefaultAppBar() {
    return AppBar(
      title: Text(widget.savedFile.fileName),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _toggleSearch,
        ),
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: _saveAnnotations,
        ),
      ],
    );
  }

  /// Builds the app bar used for searching.
  AppBar _buildSearchAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _toggleSearch,
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Search...',
          border: InputBorder.none,
        ),
        // Your original preferred search trigger is restored.
        onChanged: _performSearch,
      ),
      actions: [
        // **REMOVED**: Previous and Next buttons.
        // **FIXED**: Clear button now works correctly.
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            setState(() {
              _searchController.clear();
              _searchResult.clear(); // This removes the highlights from the viewer.
            });
          },
        ),
      ],
    );
  }

  /// Saves any annotations made to the PDF document.
  Future<void> _saveAnnotations() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saving annotations...')),
    );
    try {
      final updatedDocument = await _pdfViewerController.saveDocument();
      final file = File(widget.savedFile.filePath);
      await file.writeAsBytes(updatedDocument);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Annotations saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving annotations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSearching ? _buildSearchAppBar() : _buildDefaultAppBar(),
      body: Stack(
        children: [
          SfPdfViewer.file(
            File(widget.savedFile.filePath),
            controller: _pdfViewerController,
          ),
          // Displays the search result count (e.g., "5 results").
          if (_isSearching && _searchResult.hasResult)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  // Display total count instead of current/total
                  '${_searchResult.totalInstanceCount} results',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

