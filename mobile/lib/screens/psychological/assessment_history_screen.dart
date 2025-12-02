import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/psychological/psychological_assessment.dart';
import '../../services/psychological_assessment_service.dart';
import '../../services/api_service.dart';
import 'assessment_details_screen.dart';
import 'phq9_assessment_screen.dart';

class AssessmentHistoryScreen extends StatefulWidget {
  const AssessmentHistoryScreen({Key? key}) : super(key: key);

  @override
  State<AssessmentHistoryScreen> createState() => _AssessmentHistoryScreenState();
}

class _AssessmentHistoryScreenState extends State<AssessmentHistoryScreen> {
  late final PsychologicalAssessmentService _service;
  List<PsychologicalAssessment> _assessments = [];
  bool _isLoading = true;
  String? _error;
  String _filterType = 'all'; // all, week, month, year

  @override
  void initState() {
    super.initState();
    _service = PsychologicalAssessmentService(context.read<ApiService>());
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final assessments = await _service.getAssessmentHistory();
      setState(() {
        _assessments = _filterAssessments(assessments);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<PsychologicalAssessment> _filterAssessments(List<PsychologicalAssessment> assessments) {
    final now = DateTime.now();
    switch (_filterType) {
      case 'week':
        return assessments.where((a) => 
          a.assessmentDate.isAfter(now.subtract(const Duration(days: 7)))
        ).toList();
      case 'month':
        return assessments.where((a) => 
          a.assessmentDate.isAfter(now.subtract(const Duration(days: 30)))
        ).toList();
      case 'year':
        return assessments.where((a) => 
          a.assessmentDate.isAfter(now.subtract(const Duration(days: 365)))
        ).toList();
      default:
        return assessments;
    }
  }

  Color _getSeverityColor(String? severity) {
    if (severity == null) return Colors.grey;
    switch (severity.toLowerCase()) {
      case 'minimal':
        return Colors.green;
      case 'mild':
        return Colors.lightGreen;
      case 'moderate':
        return Colors.orange;
      case 'moderately_severe':
        return Colors.deepOrange;
      case 'severe':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final isArabic = locale == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'سجل التقييمات' : 'Assessment History'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterType = value;
                _assessments = _filterAssessments(_assessments);
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Text(isArabic ? 'الكل' : 'All'),
              ),
              PopupMenuItem(
                value: 'week',
                child: Text(isArabic ? 'هذا الأسبوع' : 'This Week'),
              ),
              PopupMenuItem(
                value: 'month',
                child: Text(isArabic ? 'هذا الشهر' : 'This Month'),
              ),
              PopupMenuItem(
                value: 'year',
                child: Text(isArabic ? 'هذا العام' : 'This Year'),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(isArabic),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PHQ9AssessmentScreen(),
            ),
          );
          if (result == true) {
            _loadHistory();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(isArabic ? 'تقييم جديد' : 'New Assessment'),
      ),
    );
  }

  Widget _buildBody(bool isArabic) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'حدث خطأ' : 'Error occurred',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHistory,
              child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
            ),
          ],
        ),
      );
    }

    if (_assessments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'لا توجد تقييمات بعد' : 'No assessments yet',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic 
                ? 'ابدأ أول تقييم لك الآن' 
                : 'Start your first assessment now',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_assessments.length > 1) _buildTrendChart(isArabic),
        Expanded(child: _buildList(isArabic)),
      ],
    );
  }

  Widget _buildTrendChart(bool isArabic) {
    final sortedAssessments = List<PsychologicalAssessment>.from(_assessments)
      ..sort((a, b) => a.assessmentDate.compareTo(b.assessmentDate));

    return Container(
      height: 120,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'اتجاه الدرجات' : 'Score Trend',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: List.generate(
                sortedAssessments.length,
                (index) {
                  final assessment = sortedAssessments[index];
                  final height = (assessment.totalScore / 27) * 50;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: height,
                            decoration: BoxDecoration(
                              color: _getSeverityColor(assessment.severityLevel),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(bool isArabic) {
    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _assessments.length,
        itemBuilder: (context, index) {
          final assessment = _assessments[index];
          return _buildAssessmentCard(assessment, isArabic);
        },
      ),
    );
  }

  Widget _buildAssessmentCard(PsychologicalAssessment assessment, bool isArabic) {
    final dateFormat = DateFormat('MMM dd, yyyy', isArabic ? 'ar' : 'en');
    final timeFormat = DateFormat('h:mm a', isArabic ? 'ar' : 'en');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AssessmentDetailsScreen(
                assessment: assessment,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getSeverityColor(assessment.severityLevel).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${assessment.totalScore}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getSeverityColor(assessment.severityLevel),
                      ),
                    ),
                    Text(
                      '/27',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? assessment.severityDisplayAr : assessment.severityDisplay,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(assessment.assessmentDate),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      timeFormat.format(assessment.assessmentDate),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
