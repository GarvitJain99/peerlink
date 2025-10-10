import 'package:flutter/material.dart';
import 'package:peerlink/app/presentation/library/providers/library_view_model.dart';
import 'package:peerlink/app/presentation/library/widgets/saved_file_list_item.dart';
import 'package:provider/provider.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<LibraryViewModel>();
    _searchController.addListener(() {
      viewModel.search(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        actions: [
          // Sort Menu Button
          Consumer<LibraryViewModel>(
            builder: (context, viewModel, child) {
              return PopupMenuButton<SortOption>(
                icon: const Icon(Icons.sort),
                tooltip: 'Sort by',
                onSelected: (option) {
                  viewModel.changeSort(option);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: SortOption.dateDesc,
                    child: Text('Newest First'),
                  ),
                  const PopupMenuItem(
                    value: SortOption.dateAsc,
                    child: Text('Oldest First'),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: SortOption.nameAsc,
                    child: Text('Name (A-Z)'),
                  ),
                  const PopupMenuItem(
                    value: SortOption.nameDesc,
                    child: Text('Name (Z-A)'),
                  ),
                  const PopupMenuDivider(),
                   const PopupMenuItem(
                    value: SortOption.sizeDesc,
                    child: Text('Size (Largest First)'),
                  ),
                  const PopupMenuItem(
                    value: SortOption.sizeAsc,
                    child: Text('Size (Smallest First)'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<LibraryViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search files...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              viewModel.search('');
                            },
                          )
                        : null,
                  ),
                ),
              ),

              // Filter Chips
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: viewModel.currentFilter == FilterType.all,
                      onSelected: (_) => viewModel.changeFilter(FilterType.all),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('PDFs'),
                      selected: viewModel.currentFilter == FilterType.pdf,
                      onSelected: (_) => viewModel.changeFilter(FilterType.pdf),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Images'),
                      selected: viewModel.currentFilter == FilterType.image,
                      onSelected: (_) => viewModel.changeFilter(FilterType.image),
                    ),
                     const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Videos'),
                      selected: viewModel.currentFilter == FilterType.video,
                      onSelected: (_) => viewModel.changeFilter(FilterType.video),
                    ),
                     const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Documents'),
                      selected: viewModel.currentFilter == FilterType.doc,
                      onSelected: (_) => viewModel.changeFilter(FilterType.doc),
                    ),
                  ],
                ),
              ),

              // File List
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (viewModel.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (viewModel.displayedFiles.isEmpty) {
                      return const Center(
                        child: Text(
                          'No files match your criteria.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: viewModel.displayedFiles.length,
                      itemBuilder: (context, index) {
                        final file = viewModel.displayedFiles[index];
                        return SavedFileListItem(file: file);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}