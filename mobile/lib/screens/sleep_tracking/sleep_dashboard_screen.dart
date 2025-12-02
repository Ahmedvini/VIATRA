import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sleep_tracking/sleep_session.dart';
import '../../models/sleep_tracking/sleep_analytics.dart';
import '../../services/sleep_tracking_service.dart';
import '../../services/api_service.dart';
import 'active_sleep_screen.dart';
import 'sleep_history_screen.dart';
import 'sleep_details_screen.dart';

class SleepDashboardScreen extends StatefulWidget {
  const SleepDashboardScreen({Key? key}) : super(key: key);

  @override
  _SleepDashboardScreenState createState() => _SleepDashboardScreenState();
}

class _SleepDashboardScreenState extends State<SleepDashboardScreen> {
  late SleepTrackingService _sleepService;
  bool _isLoading = true;
  String? _error;
  SleepAnalytics? _analytics;
  SleepSession? _activeSession;
  List<SleepSession> _recentSessions = [];
  int _selectedDays = 7;

  @override
  void initState() {
    super.initState();
    _sleepService = SleepTrackingService(context.read<ApiService>());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load analytics and recent sessions in parallel
      final results = await Future.wait([
        _sleepService.getSleepAnalytics(days: _selectedDays),
        _sleepService.getRecentSessions(limit: 5),
        _sleepService.getActiveSession(),
      ]);

      setState(() {
        _analytics = results[0] as SleepAnalytics;
        _recentSessions = results[1] as List<SleepSession>;
        _activeSession = results[2] as SleepSession?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _startSleepSession() async {
    try {
      final session = await _sleepService.startSleepSession(
        notes: 'Started from dashboard',
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActiveSleepScreen(session: session),
          ),
        ).then((_) => _loadData()); // Reload when returning
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting sleep: $e')),
        );
      }
    }
  }

  void _changeDaysFilter(int days) {
    setState(() {
      _selectedDays = days;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SleepHistoryScreen(),
                ),
              ).then((_) => _loadData());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildErrorView()
                : _buildDashboard(),
      ),
      floatingActionButton: _activeSession != null
          ? null // Don't show if there's an active session
          : FloatingActionButton.extended(
              onPressed: _startSleepSession,
              icon: const Icon(Icons.bedtime),
              label: const Text('Start Sleep'),
            ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(_error ?? 'An error occurred'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active session banner (if any)
          if (_activeSession != null) _buildActiveSessionBanner(),

          // Time period selector
          _buildTimePeriodSelector(),
          const SizedBox(height: 20),

          // Analytics summary cards
          if (_analytics != null) _buildAnalyticsCards(),
          const SizedBox(height: 24),

          // Chart placeholder (you can add fl_chart later)
          if (_analytics != null) _buildSleepChart(),
          const SizedBox(height: 24),

          // Recent sessions
          _buildRecentSessions(),
        ],
      ),
    );
  }

  Widget _buildActiveSessionBanner() {
    return Card(
      color: Colors.blue.shade50,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(
          _activeSession!.isPaused ? Icons.pause_circle : Icons.bedtime,
          color: Colors.blue,
          size: 36,
        ),
        title: Text(
          _activeSession!.isPaused ? 'Sleep Paused' : 'Sleep in Progress',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Started: ${_activeSession!.formattedStartTime}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActiveSleepScreen(session: _activeSession!),
            ),
          ).then((_) => _loadData());
        },
      ),
    );
  }

  Widget _buildTimePeriodSelector() {
    return Row(
      children: [
        const Text(
          'Show last',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 7, label: Text('7 days')),
              ButtonSegment(value: 30, label: Text('30 days')),
            ],
            selected: {_selectedDays},
            onSelectionChanged: (Set<int> newSelection) {
              _changeDaysFilter(newSelection.first);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Avg Duration',
                _analytics!.formattedAverageDuration,
                Icons.schedule,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Avg Quality',
                _analytics!.formattedAverageQuality,
                Icons.star,
                _getColor(_analytics!.qualityColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Efficiency',
                _analytics!.formattedSleepEfficiency,
                Icons.trending_up,
                _getColor(_analytics!.efficiencyColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Avg Wake-ups',
                _analytics!.formattedAverageWakeUps,
                Icons.notification_important,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepChart() {
    // Placeholder for chart - you can implement with fl_chart package
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sleep Duration Trend',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              color: Colors.grey[100],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.show_chart, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Chart coming soon',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Install fl_chart package for visualization',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Sleep Sessions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SleepHistoryScreen(),
                  ),
                ).then((_) => _loadData());
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_recentSessions.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.bedtime_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No sleep sessions yet',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the button below to start tracking your sleep',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ..._recentSessions.map((session) => _buildSessionCard(session)),
      ],
    );
  }

  Widget _buildSessionCard(SleepSession session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getColor(session.qualityColor),
          child: Text(
            session.qualityRating?.toString() ?? '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(session.dateString),
        subtitle: Text(
          '${session.formattedDuration} • ${session.wakeUpCount} wake-ups',
        ),
        trailing: Text(
          session.qualityStars,
          style: const TextStyle(fontSize: 16),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SleepDetailsScreen(sessionId: session.id),
            ),
          );
        },
      ),
    );
  }

  Color _getColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }
}
