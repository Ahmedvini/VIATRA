import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/doctor/dashboard_stat_card.dart';
import '../../widgets/doctor/doctor_appointment_card.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppointmentProvider>(context, listen: false);
      provider.loadDoctorDashboardStats();
      provider.loadDoctorAppointments();
    });
  }

  Future<void> _handleRefresh() async {
    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    await Future.wait([
      provider.loadDoctorDashboardStats(refresh: true),
      provider.loadDoctorAppointments(refresh: true),
    ]);
  }

  List<dynamic> _getTodayAppointments(List appointments) {
    final today = DateTime.now();
    return appointments.where((apt) {
      final scheduledStart = apt.scheduledStart;
      return scheduledStart.year == today.year &&
          scheduledStart.month == today.month &&
          scheduledStart.day == today.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.appointments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage ?? 'An error occurred',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _handleRefresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final todayAppointments = _getTodayAppointments(provider.appointments);

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Cards Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: [
                      DashboardStatCard(
                        title: 'Today\'s Appointments',
                        count: provider.todayAppointmentsCount,
                        icon: Icons.today,
                        color: Colors.blue,
                        onTap: () => context.push('/doctor/appointments'),
                      ),
                      DashboardStatCard(
                        title: 'Upcoming',
                        count: provider.upcomingAppointmentsCount,
                        icon: Icons.event_available,
                        color: Colors.green,
                        onTap: () => context.push('/doctor/appointments'),
                      ),
                      DashboardStatCard(
                        title: 'Total Patients',
                        count: provider.totalPatientsCount,
                        icon: Icons.people,
                        color: Colors.orange,
                        onTap: () => context.push('/doctor/appointments'),
                      ),
                      DashboardStatCard(
                        title: 'Pending Requests',
                        count: provider.pendingRequestsCount,
                        icon: Icons.pending_actions,
                        color: Colors.red,
                        onTap: () => context.push('/doctor/appointments?status=scheduled'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Today's Schedule Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Today\'s Schedule',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/doctor/appointments'),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Today's Appointments List
                  if (todayAppointments.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No appointments today',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: todayAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = todayAppointments[index];
                        return DoctorAppointmentCard(
                          appointment: appointment,
                          onTap: () => context.push('/doctor/appointments/${appointment.id}'),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
