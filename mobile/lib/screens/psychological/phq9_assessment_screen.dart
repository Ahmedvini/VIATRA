import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/psychological/psychological_assessment.dart';
import '../../services/psychological_assessment_service.dart';
import '../../services/api_service.dart';
import 'assessment_result_screen.dart';

class PHQ9AssessmentScreen extends StatefulWidget {
  const PHQ9AssessmentScreen({Key? key}) : super(key: key);

  @override
  _PHQ9AssessmentScreenState createState() => _PHQ9AssessmentScreenState();
}

class _PHQ9AssessmentScreenState extends State<PHQ9AssessmentScreen> {
  late PsychologicalAssessmentService _service;
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

  // Store answers (default to -1 = not answered)
  final List<int> _answers = List.filled(9, -1);

  @override
  void initState() {
    super.initState();
    _service = PsychologicalAssessmentService(context.read<ApiService>());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _answers.every((answer) => answer >= 0);

  int get _totalScore => _answers.fold(0, (sum, answer) => sum + (answer >= 0 ? answer : 0));

  Future<void> _submitAssessment() async {
    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await _service.submitAssessment(
        q1Interest: _answers[0],
        q2FeelingDown: _answers[1],
        q3Sleep: _answers[2],
        q4Energy: _answers[3],
        q5Appetite: _answers[4],
        q6SelfWorth: _answers[5],
        q7Concentration: _answers[6],
        q8Movement: _answers[7],
        q9SelfHarm: _answers[8],
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AssessmentResultScreen(result: result),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = PHQ9Questions.questions;
    final scoreLabels = PHQ9Questions.scoreLabels;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PHQ-9 Assessment'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${_currentPage + 1}/${questions.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentPage + 1) / questions.length,
            backgroundColor: Colors.grey[200],
          ),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    PHQ9Questions.getInstructions('en'),
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Questions PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question number
                      Text(
                        'Question ${index + 1}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Question text (English)
                      Text(
                        question.en,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),

                      // Question text (Arabic)
                      Text(
                        question.ar,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 32),

                      // Scrollable slider with labels
                      _buildScoreSelector(index, scoreLabels),
                    ],
                  ),
                );
              },
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 16),
                Expanded(
                  flex: _currentPage == 0 ? 1 : 1,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            if (_currentPage < questions.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              _submitAssessment();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _currentPage == questions.length - 1
                          ? Colors.green
                          : null,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_currentPage == questions.length - 1 ? 'Submit' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSelector(int questionIndex, List<ScoreLabel> scoreLabels) {
    final currentValue = _answers[questionIndex];

    return Column(
      children: [
        // Score indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            final isSelected = currentValue == index;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    Text(
                      index.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),

        // Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            activeTrackColor: Theme.of(context).primaryColor,
            inactiveTrackColor: Colors.grey[300],
            thumbColor: Theme.of(context).primaryColor,
            overlayColor: Theme.of(context).primaryColor.withOpacity(0.2),
          ),
          child: Slider(
            value: currentValue < 0 ? 0 : currentValue.toDouble(),
            min: 0,
            max: 3,
            divisions: 3,
            onChanged: (value) {
              setState(() {
                _answers[questionIndex] = value.toInt();
              });
            },
          ),
        ),
        const SizedBox(height: 24),

        // Score labels
        ...scoreLabels.map((label) {
          final isSelected = currentValue == label.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _answers[questionIndex] = label.value;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.grey[100],
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          label.value.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label.en,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                            ),
                          ),
                          Text(
                            label.ar,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).primaryColor,
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
