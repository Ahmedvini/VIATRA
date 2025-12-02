import 'package:flutter/material.dart';
import '../../models/psychological/psychological_assessment.dart';
import 'assessment_history_screen.dart';

class AssessmentResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const AssessmentResultScreen({
    Key? key,
    required this.result,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final assessment =
        PsychologicalAssessment.fromJson(result['assessment'] as Map<String, dynamic>);
    final recommendations = result['recommendations'] as Map<String, dynamic>;
    final severityDisplay = result['severity_display'] as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Results'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getSeverityColor(assessment.severityLevel),
                      _getSeverityColor(assessment.severityLevel).withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'PHQ-9 Score',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${assessment.totalScore}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'out of 27',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            severityDisplay['en'] as String,
                            style: TextStyle(
                              color: _getSeverityColor(assessment.severityLevel),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            severityDisplay['ar'] as String,
                            style: TextStyle(
                              color: _getSeverityColor(assessment.severityLevel),
                              fontSize: 14,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Score interpretation
            _buildInfoCard(
              context,
              icon: Icons.info_outline,
              title: 'What does this mean?',
              titleAr: 'ماذا يعني هذا؟',
              content: _getScoreInterpretation(assessment.totalScore),
              contentAr: _getScoreInterpretationAr(assessment.totalScore),
            ),
            const SizedBox(height: 16),

            // Recommendations
            _buildInfoCard(
              context,
              icon: Icons.lightbulb_outline,
              title: 'Recommendations',
              titleAr: 'التوصيات',
              content: recommendations['en'] as String,
              contentAr: recommendations['ar'] as String,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),

            // Warning if high self-harm score
            if (assessment.q9SelfHarm >= 2)
              _buildWarningCard(context),
            
            const SizedBox(height: 24),

            // Action buttons
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AssessmentHistoryScreen(),
                  ),
                  (route) => route.isFirst,
                );
              },
              icon: const Icon(Icons.history),
              label: const Text('View History'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: const Icon(Icons.home),
              label: const Text('Go to Home'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Important Notice',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[900],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'The PHQ-9 is a screening tool, not a diagnosis. A high score suggests depressive symptoms, but only a qualified clinician can interpret results and decide on treatment.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String titleAr,
    required String content,
    required String contentAr,
    Color? color,
  }) {
    final cardColor = color ?? Colors.green;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: cardColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cardColor,
                            ),
                      ),
                      Text(
                        titleAr,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              contentAr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.red[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red[300]!, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.emergency, color: Colors.red[700], size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Crisis Support',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[900],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'You indicated thoughts of self-harm. Please reach out for immediate support:',
              style: TextStyle(color: Colors.red[900]),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement crisis hotline call
              },
              icon: const Icon(Icons.phone),
              label: const Text('Call Crisis Hotline'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String? severity) {
    switch (severity) {
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

  String _getScoreInterpretation(int score) {
    if (score <= 4) {
      return 'Your score suggests minimal or no depression. Continue to monitor your mood and practice self-care.';
    } else if (score <= 9) {
      return 'Your score suggests mild depression. Consider speaking with a healthcare provider about your symptoms.';
    } else if (score <= 14) {
      return 'Your score suggests moderate depression. It\'s recommended to consult with a mental health professional for evaluation and potential treatment.';
    } else if (score <= 19) {
      return 'Your score suggests moderately severe depression. Please seek evaluation and treatment from a mental health professional soon.';
    } else {
      return 'Your score suggests severe depression. Immediate evaluation and treatment by a mental health professional is strongly recommended.';
    }
  }

  String _getScoreInterpretationAr(int score) {
    if (score <= 4) {
      return 'نتيجتك تشير إلى اكتئاب خفيف جداً أو معدوم. استمر في مراقبة مزاجك وممارسة الرعاية الذاتية.';
    } else if (score <= 9) {
      return 'نتيجتك تشير إلى اكتئاب خفيف. فكر في التحدث مع مقدم الرعاية الصحية حول أعراضك.';
    } else if (score <= 14) {
      return 'نتيجتك تشير إلى اكتئاب متوسط. يُنصح بالتشاور مع أخصائي صحة نفسية للتقييم والعلاج المحتمل.';
    } else if (score <= 19) {
      return 'نتيجتك تشير إلى اكتئاب متوسط إلى شديد. يرجى طلب التقييم والعلاج من أخصائي صحة نفسية قريباً.';
    } else {
      return 'نتيجتك تشير إلى اكتئاب شديد. يُوصى بشدة بالتقييم والعلاج الفوري من قبل أخصائي صحة نفسية.';
    }
  }
}
