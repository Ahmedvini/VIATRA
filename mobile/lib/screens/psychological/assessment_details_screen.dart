import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/psychological/psychological_assessment.dart';

class AssessmentDetailsScreen extends StatelessWidget {
  final PsychologicalAssessment assessment;

  const AssessmentDetailsScreen({
    Key? key,
    required this.assessment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final isArabic = locale == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'تفاصيل التقييم' : 'Assessment Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score Summary Card
            _buildScoreSummaryCard(isArabic),
            const SizedBox(height: 16),

            // Assessment Date
            _buildInfoCard(
              isArabic ? 'تاريخ التقييم' : 'Assessment Date',
              DateFormat.yMMMd().format(assessment.assessmentDate),
              Icons.calendar_today,
            ),
            const SizedBox(height: 16),

            // Individual Questions and Answers
            _buildQuestionsSection(isArabic),
            const SizedBox(height: 16),

            // Difficulty Level (if provided)
            if (assessment.difficultyLevel != null)
              _buildDifficultyCard(isArabic),
            const SizedBox(height: 16),

            // Notes (if provided)
            if (assessment.notes != null && assessment.notes!.isNotEmpty)
              _buildNotesCard(isArabic),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSummaryCard(bool isArabic) {
    final Color severityColor = _getSeverityColor();

    return Card(
      elevation: 4,
      color: severityColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              isArabic ? 'النتيجة الإجمالية' : 'Total Score',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${assessment.totalScore}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: severityColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? assessment.severityDisplayAr
                  : assessment.severityDisplay,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: severityColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic ? 'من 27 درجة' : 'out of 27',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionsSection(bool isArabic) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isArabic ? 'تفاصيل الإجابات' : 'Answer Details',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuestionRow(0, assessment.q1Interest, isArabic),
            _buildDivider(),
            _buildQuestionRow(1, assessment.q2FeelingDown, isArabic),
            _buildDivider(),
            _buildQuestionRow(2, assessment.q3Sleep, isArabic),
            _buildDivider(),
            _buildQuestionRow(3, assessment.q4Energy, isArabic),
            _buildDivider(),
            _buildQuestionRow(4, assessment.q5Appetite, isArabic),
            _buildDivider(),
            _buildQuestionRow(5, assessment.q6SelfWorth, isArabic),
            _buildDivider(),
            _buildQuestionRow(6, assessment.q7Concentration, isArabic),
            _buildDivider(),
            _buildQuestionRow(7, assessment.q8Movement, isArabic),
            _buildDivider(),
            _buildQuestionRow(8, assessment.q9SelfHarm, isArabic),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionRow(int index, int score, bool isArabic) {
    final question = PHQ9Questions.questions[index];
    final scoreLabel = PHQ9Questions.scoreLabels.firstWhere(
      (label) => label.value == score,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${index + 1}. ${isArabic ? question.ar : question.en}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isArabic ? scoreLabel.ar : scoreLabel.en,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getScoreColor(score),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey[300], height: 1);
  }

  Widget _buildDifficultyCard(bool isArabic) {
    final Map<String, String> difficultyLabels = {
      'not_difficult': isArabic ? 'ليس صعباً على الإطلاق' : 'Not difficult at all',
      'somewhat_difficult': isArabic ? 'صعب إلى حد ما' : 'Somewhat difficult',
      'very_difficult': isArabic ? 'صعب جداً' : 'Very difficult',
      'extremely_difficult': isArabic ? 'صعب للغاية' : 'Extremely difficult',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic
                  ? 'مدى صعوبة هذه المشاكل في حياتك'
                  : 'How difficult have these problems made things',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              difficultyLabels[assessment.difficultyLevel] ??
                  assessment.difficultyLevel!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(bool isArabic) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'ملاحظات' : 'Notes',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              assessment.notes!,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor() {
    switch (assessment.severityLevel) {
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

  Color _getScoreColor(int score) {
    switch (score) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.lightGreen;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
