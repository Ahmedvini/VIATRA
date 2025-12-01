import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/appointments/appointment_card.dart';
import 'appointment_detail_screen.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  _AppointmentListScreenState createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all';
  bool _isLoadingMore = false;

  final List<Map<String, dynamic>> _statusFilters = [
    {'value': 'all', 'label': 'All'},
    {'value': 'scheduled', 'label': 'Scheduled'},
    {'value': 'completed', 'label': 'Completed'},
    {'value': 'cancelled', 'label': 'Cancelled'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMore();
    }
  }

  Future<void> _loadAppointments() async {
    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    try {
      await provider.fetchAppointments(
        status: _selectedFilter == 'all' ? null : _selectedFilter,
        forceRefresh: true,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading appointments: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    if (!provider.hasMoreAppointments) return;

    setState(() => _isLoadingMore = true);
    try {
      await provider.fetchAppointments(
        status: _selectedFilter == 'all' ? null : _selectedFilter,
        loadMore: true,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading more: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  Future<void> _refreshAppointments() async {
    await _loadAppointments();
  }

  void _onFilterChanged(String? value) {
    if (value != null && value != _selectedFilter) {
      setState(() => _selectedFilter = value);
      _loadAppointments();
    }
  }

  List<Appointment> _getFilteredAppointments(List<Appointment> appointments) {
    final now = DateTime.now();
    if (_tabController.index == 0) {
      // Upcoming tab
      return appointments
          .where((apt) =>
              apt.scheduledStart.isAfter(now) &&
              (apt.status == 'scheduled' || apt.status == 'confirmed'))
          .toList();
    } else {
      // Past tab
      return appointments
          .where((apt) =>
              apt.scheduledStart.isBefore(now) ||
              apt.status == 'completed' ||
              apt.status == 'cancelled' ||
              apt.status == 'no_show')
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) => setState(() {}),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statusFilters.map((filter) {
                  final isSelected = _selectedFilter == filter['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter['label'] as String),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          _onFilterChanged(filter['value'] as String);
                        }
                      },
                      selectedColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Appointment List
          Expanded(
            child: Consumer<AppointmentProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.appointments.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.appointments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading appointments',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadAppointments,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredAppointments = _getFilteredAppointments(provider.appointments);

                if (filteredAppointments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _tabController.index == 0
                              ? 'No upcoming appointments'
                              : 'No past appointments',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _tabController.index == 0
                              ? 'Book an appointment with a doctor'
                              : 'Your appointment history will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshAppointments,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredAppointments.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filteredAppointments.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final appointment = filteredAppointments[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppointmentCard(
                          appointment: appointment,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AppointmentDetailScreen(
                                  appointmentId: appointment.id,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to doctor search/list
          Navigator.pushNamed(context, '/doctors');
        },
        icon: const Icon(Icons.add),
        label: const Text('Book Appointment'),
      ),
    );
}
