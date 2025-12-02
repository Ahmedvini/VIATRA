import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sleep_tracking/sleep_session.dart';
import '../../services/sleep_tracking_service.dart';
import '../../services/api_service.dart';

class ActiveSleepScreen extends StatefulWidget {
  final SleepSession session;

  const ActiveSleepScreen({Key? key, required this.session}) : super(key: key);

  @override
  _ActiveSleepScreenState createState() => _ActiveSleepScreenState();
}

class _ActiveSleepScreenState extends State<ActiveSleepScreen> {
  late SleepTrackingService _sleepService;
  late SleepSession _session;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  DateTime? _pausedAt; // Track when session was paused
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sleepService = SleepTrackingService(context.read<ApiService>());
    _session = widget.session;
    _calculateElapsed();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateElapsed() {
    // Calculate elapsed time based on session status
    if (_session.status == 'active') {
      // For active sessions, calculate from start time to now
      _elapsed = DateTime.now().difference(_session.startTime);
    } else if (_session.status == 'paused') {
      // For paused sessions, freeze time at pause moment
      // Use totalDurationMinutes from backend if available
      if (_session.totalDurationMinutes != null && _session.totalDurationMinutes! > 0) {
        _elapsed = Duration(minutes: _session.totalDurationMinutes!);
      } else if (_pausedAt != null) {
        // Use local pause time
        _elapsed = _pausedAt!.difference(_session.startTime);
      } else {
        // Fallback: calculate from start to now
        _elapsed = DateTime.now().difference(_session.startTime);
        _pausedAt = DateTime.now(); // Store current time as pause time
      }
    } else if (_session.status == 'completed') {
      // For completed sessions, use totalDurationMinutes
      if (_session.totalDurationMinutes != null && _session.totalDurationMinutes! > 0) {
        _elapsed = Duration(minutes: _session.totalDurationMinutes!);
      } else if (_session.endTime != null) {
        _elapsed = _session.endTime!.difference(_session.startTime);
      } else {
        // Fallback
        _elapsed = DateTime.now().difference(_session.startTime);
      }
    }
    
    // Ensure elapsed time is never negative
    if (_elapsed.isNegative) {
      _elapsed = Duration.zero;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _session.status == 'active') {
        // Only update timer if session is active
        setState(() {
          _calculateElapsed();
        });
      }
    });
  }

  Future<void> _pauseSession() async {
    if (_session.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Session ID is missing')),
      );
      return;
    }

    final reasons = ['Bathroom', 'Noise', 'Discomfort', 'Thirst', 'Other'];
    
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Why did you wake up?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reasons.map((r) => ListTile(
            title: Text(r),
            onTap: () => Navigator.pop(context, r),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (reason == null) return;

    setState(() => _isLoading = true);

    try {
      // Store pause time before making API call
      _pausedAt = DateTime.now();
      
      final updatedSession = await _sleepService.pauseSleepSession(
        _session.id!,
        reason: reason.toLowerCase(),
      );

      if (mounted) {
        setState(() {
          _session = updatedSession;
          _calculateElapsed(); // Recalculate with new session data
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sleep paused. Tap Resume when ready to sleep again.')),
        );
      }
    } catch (e) {
      _pausedAt = null; // Clear pause time on error
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error pausing sleep: $e')),
        );
      }
    }
  }

  Future<void> _resumeSession() async {
    if (_session.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Session ID is missing')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedSession = await _sleepService.resumeSleepSession(_session.id!);

      if (mounted) {
        setState(() {
          _session = updatedSession;
          _pausedAt = null; // Clear pause time when resuming
          _calculateElapsed(); // Recalculate with new session data
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sleep resumed. Rest well!')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error resuming sleep: $e')),
        );
      }
    }
  }

  Future<void> _endSession() async {
    if (_session.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Session ID is missing')),
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _EndSleepDialog(),
    );

    if (result == null) return;

    setState(() => _isLoading = true);

    try {
      final updatedSession = await _sleepService.endSleepSession(
        _session.id!,
        qualityRating: result['rating'] as int?,
        notes: result['notes'] as String?,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sleep session completed!')),
        );
        Navigator.pop(context, updatedSession);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error ending sleep: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Leave Sleep Session?'),
            content: const Text('Your sleep session is still active. You can return to this screen anytime.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Leave'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_session.isPaused ? 'Sleep Paused' : 'Sleeping...'),
          backgroundColor: _session.isPaused ? Colors.orange : Colors.indigo,
        ),
        backgroundColor: _session.isPaused ? Colors.orange.shade50 : Colors.indigo.shade900,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status text
            Text(
              _session.isPaused ? 'You\'re Awake' : 'Sweet Dreams',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _session.isPaused ? Colors.orange.shade900 : Colors.white,
              ),
            ),
            const SizedBox(height: 48),

            // Timer
            _buildTimer(),
            const SizedBox(height: 48),

            // Info cards
            _buildInfoCards(),
            const SizedBox(height: 48),

            // Action buttons
            _buildActionButtons(),

            const Spacer(),

            // Tip text
            if (!_session.isPaused)
              Text(
                '💡 Tap Pause if you wake up during the night',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer() {
    final hours = _elapsed.inHours;
    final minutes = _elapsed.inMinutes % 60;
    final seconds = _elapsed.inSeconds % 60;

    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: _session.isPaused ? Colors.orange.shade700 : Colors.indigo.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Elapsed Time',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCards() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            'Started',
            _session.formattedStartTime,
            Icons.access_time,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
            'Wake-ups',
            '${_session.wakeUpCount}',
            Icons.notification_important,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.indigo, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_session.isPaused) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _resumeSession,
              icon: const Icon(Icons.play_arrow, size: 28),
              label: const Text('Resume Sleep', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _endSession,
              icon: const Icon(Icons.stop),
              label: const Text('End Sleep', style: TextStyle(fontSize: 18)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _pauseSession,
              icon: const Icon(Icons.pause, size: 28),
              label: const Text('Pause (Wake Up)', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _endSession,
              icon: const Icon(Icons.stop),
              label: const Text('End Sleep', style: TextStyle(fontSize: 18)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}

// End Sleep Dialog
class _EndSleepDialog extends StatefulWidget {
  @override
  _EndSleepDialogState createState() => _EndSleepDialogState();
}

class _EndSleepDialogState extends State<_EndSleepDialog> {
  int? _rating;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('How was your sleep?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rate your sleep quality:'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final rating = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _rating = rating),
                  child: Icon(
                    _rating != null && rating <= _rating!
                        ? Icons.star
                        : Icons.star_border,
                    size: 40,
                    color: Colors.amber,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'How did you sleep?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'rating': _rating,
              'notes': _notesController.text.isEmpty ? null : _notesController.text,
            });
          },
          child: const Text('Complete'),
        ),
      ],
    );
  }
}
