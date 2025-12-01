import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/doctor_search_provider.dart';

import '../../widgets/doctor/doctor_card.dart';
import '../../utils/constants.dart';
import 'doctor_search_filter_sheet.dart';

class DoctorSearchScreen extends StatefulWidget {
  const DoctorSearchScreen({super.key});

  @override
  State<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(DoctorSearchConstants.searchDebounce, () {
      final provider = context.read<DoctorSearchProvider>();
      final newFilter = provider.filter.copyWith(searchQuery: query);
      provider.updateFilter(newFilter);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - DoctorSearchConstants.loadMoreThreshold) {
      final provider = context.read<DoctorSearchProvider>();
      if (provider.hasMore && !provider.isLoadingMore) {
        provider.loadMoreDoctors();
      }
    }
  }

  Future<void> _onRefresh() async {
    await context.read<DoctorSearchProvider>().refreshSearch();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DoctorSearchFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search doctors...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : const Icon(Icons.search),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: _onSearchChanged,
        ),
        actions: [
          Consumer<DoctorSearchProvider>(
            builder: (context, provider, _) {
              final filterCount = provider.filter.activeFilterCount;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: _showFilterSheet,
                  ),
                  if (filterCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          filterCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<DoctorSearchProvider>(
        builder: (context, provider, _) {
          if (provider.state == DoctorSearchState.initial) {
            return _buildInitialState(theme);
          }

          if (provider.state == DoctorSearchState.loading && !provider.hasResults) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.state == DoctorSearchState.error && !provider.hasResults) {
            return _buildErrorState(theme, provider.errorMessage);
          }

          if (!provider.hasResults) {
            return _buildEmptyState(theme);
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.doctors.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= provider.doctors.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final doctor = provider.doctors[index];
                return DoctorCard(
                  doctor: doctor,
                  onTap: () => context.push('/doctors/${doctor.id}'),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterSheet,
        child: const Icon(Icons.tune),
      ),
    );
  }

  Widget _buildInitialState(ThemeData theme) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 100,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Search for Doctors',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Use the search bar or filters\nto find healthcare professionals',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

  Widget _buildEmptyState(ThemeData theme) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 100,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No Doctors Found',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search\nor filters',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              context.read<DoctorSearchProvider>().clearSearch();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Clear Search'),
          ),
        ],
      ),
    );

  Widget _buildErrorState(ThemeData theme, String? errorMessage) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 100,
            color: theme.colorScheme.error.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Something Went Wrong',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'Failed to load doctors',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.read<DoctorSearchProvider>().searchDoctors(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
}
