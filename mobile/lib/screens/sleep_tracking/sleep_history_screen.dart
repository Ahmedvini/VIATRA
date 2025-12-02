import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/sleep_tracking/sleep_session.dart';
import '../../services/sleep_tracking_service.dart';
import '../../services/api_service.dart';
import 'sleep_details_screen.dart';

class SleepHistoryScreen extends StatefulWidget {
  const SleepHistoryScreen({Key? key}) : super(key: key);

  @override
  _SleepHistoryScreenState createState() => _SleepHistoryScreenState();
}

class _SleepHistoryScreenState extends State<SleepHistoryScreen> {
  late SleepTrackingService _sleepService;
  List<SleepSession> _sessions = [];
  bool _isLoading = true;
  String? _error;
  DateTime? _startDate;
  DateTime? _endDate;
  String _sortBy = 'date_desc';

  @override
  void initState() {
    super.initState();
    _sleepService = SleepTrackingService(context.read<ApiService>());
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sessions = await _sleepService.getSleepSessions(
        startDate: _startDate,
        endDate: _endDate,
      );

      if (!mounted) return;

      sessions.sort((a, b) {
        switch (_sortBy) {
          case 'date_asc':
            return a.startTime.compareTo(b.startTime);
          case 'duration':
            final aDuration = a.endTime?.difference(a.startTime).inMinutes ?? 0;
            final bDuration = b.endTime?.difference(b.startTime).inMinutes ?? 0;
            return bDuration.compareTo(aDuration);
          case 'quality':
            return (b.qualityRating ?? 0).compareTo(a.qualityRating ?? 0);
          case 'date_desc':
          default:
            return b.startTime.compareTo(a.startTime);
        }
      });

      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadHistory();
    }
  }

  void _clearDateRange() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _loadHistory();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  Color _getQualityColor(int? quality) {
    if (quality == null) return Colors.grey;
    if (quality >= 4) return Colors.green;
    if (quality >= 3) return Colors.orange;
    return Colors.red;
  }

  IconData _getQualityIcon(int? quality) {
    if (quality == null) return Icons.help_outline;
    if (quality >= 4) return Icons.sentiment_very_satisfied;
    if (quality >= 3) return Icons.sentiment_satisfied;
    return Icons.sentiment_dissatisfied;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep History'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _sortBy = value);
              _loadHistory();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'date_desc', child: Text('Newest First')),
              const PopupMenuItem(
                  value: 'date_asc', child: Text('Oldest First')),
              const PopupMenuItem(
                  value: 'duration', child: Text('Longest Duration')),
              const PopupMenuItem(
                  value: 'quality', child: Text('Best Quality')),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _startDate != null && _endDate != null
                          ? '${DateFormat.yMMMd().format(_startDate!)} - ${DateFormat.yMMMd().format(_endDate!)}'
                          : 'All Time',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (_startDate != null && _endDate != null)
                    IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearDateRange),
                  IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: _selectDateRange),
                ],
              ),
            ),
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadHistory, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bedtime_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No sleep sessions recorded',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Start tracking your sleep to see history here',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _sessions.length,
        itemBuilder: (context, index) {
          final session = _sessions[index];
          final duration = session.endTime != null
              ? session.endTime!.difference(session.startTime)
              : Duration.zero;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SleepDetailsScreen(sessionId: session.id),
                  ),
                ).then((_) => _loadHistory());
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat.yMMMd().format(session.startTime),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (session.qualityRating != null)
                          Row(
                            children: [
                              Icon(_getQualityIcon(session.qualityRating),
                                  color: _getQualityColor(session.qualityRating),
                                  size: 20),
                              const SizedBox(width: 4),
                              Text(
                                '${session.qualityRating!}/5',
                                style: TextStyle(
                                    color:
                                        _getQualityColor(session.qualityRating),
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${DateFormat.jm().format(session.startTime)} - ${session.endTime != null ? DateFormat.jm().format(session.endTime!) : 'In Progress'}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4)),
                          child: Row(
                            children: [
                              const Icon(Icons.timer,
                                  size: 14, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(_formatDuration(duration),
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (session.wakeUpCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(4)),
                            child: Row(
                              children: [
                                const Icon(Icons.notifications_active,
                                    size: 14, color: Colors.orange),
                                const SizedBox(width: 4),
                                Text(
                                  '${session.wakeUpCount} wake-ups',
                                  style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    if (session.notes != null && session.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        session.notes!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
