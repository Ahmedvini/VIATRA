import 'package:json_annotation/json_annotation.dart';

part 'psychological_assessment.g.dart';

@JsonSerializable()
class PsychologicalAssessment {
  final String? id;
  @JsonKey(name: 'patient_id')
  final String? patientId;
  @JsonKey(name: 'assessment_type')
  final String assessmentType;
  @JsonKey(name: 'assessment_date')
  final DateTime assessmentDate;
  
  // PHQ-9 Questions (0-3 each)
  @JsonKey(name: 'q1_interest')
  final int q1Interest;
  @JsonKey(name: 'q2_feeling_down')
  final int q2FeelingDown;
  @JsonKey(name: 'q3_sleep')
  final int q3Sleep;
  @JsonKey(name: 'q4_energy')
  final int q4Energy;
  @JsonKey(name: 'q5_appetite')
  final int q5Appetite;
  @JsonKey(name: 'q6_self_worth')
  final int q6SelfWorth;
  @JsonKey(name: 'q7_concentration')
  final int q7Concentration;
  @JsonKey(name: 'q8_movement')
  final int q8Movement;
  @JsonKey(name: 'q9_self_harm')
  final int q9SelfHarm;
  
  // Calculated fields
  @JsonKey(name: 'total_score')
  final int totalScore;
  @JsonKey(name: 'severity_level')
  final String? severityLevel;
  
  final String? notes;
  @JsonKey(name: 'difficulty_level')
  final String? difficultyLevel;
  
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  PsychologicalAssessment({
    this.id,
    this.patientId,
    this.assessmentType = 'PHQ9',
    required this.assessmentDate,
    required this.q1Interest,
    required this.q2FeelingDown,
    required this.q3Sleep,
    required this.q4Energy,
    required this.q5Appetite,
    required this.q6SelfWorth,
    required this.q7Concentration,
    required this.q8Movement,
    required this.q9SelfHarm,
    required this.totalScore,
    this.severityLevel,
    this.notes,
    this.difficultyLevel,
    this.createdAt,
    this.updatedAt,
  });

  factory PsychologicalAssessment.fromJson(Map<String, dynamic> json) =>
      _$PsychologicalAssessmentFromJson(json);

  Map<String, dynamic> toJson() => _$PsychologicalAssessmentToJson(this);

  String get severityDisplay {
    switch (severityLevel) {
      case 'minimal':
        return 'Minimal Depression';
      case 'mild':
        return 'Mild Depression';
      case 'moderate':
        return 'Moderate Depression';
      case 'moderately_severe':
        return 'Moderately Severe';
      case 'severe':
        return 'Severe Depression';
      default:
        return 'Unknown';
    }
  }

  String get severityDisplayAr {
    switch (severityLevel) {
      case 'minimal':
        return 'اكتئاب خفيف جداً';
      case 'mild':
        return 'اكتئاب خفيف';
      case 'moderate':
        return 'اكتئاب متوسط';
      case 'moderately_severe':
        return 'اكتئاب متوسط إلى شديد';
      case 'severe':
        return 'اكتئاب شديد';
      default:
        return 'غير معروف';
    }
  }
}

@JsonSerializable()
class PHQ9Question {
  final String id;
  final String en;
  final String ar;

  PHQ9Question({
    required this.id,
    required this.en,
    required this.ar,
  });

  factory PHQ9Question.fromJson(Map<String, dynamic> json) =>
      _$PHQ9QuestionFromJson(json);

  Map<String, dynamic> toJson() => _$PHQ9QuestionToJson(this);
}

@JsonSerializable()
class ScoreLabel {
  final int value;
  final String en;
  final String ar;

  ScoreLabel({
    required this.value,
    required this.en,
    required this.ar,
  });

  factory ScoreLabel.fromJson(Map<String, dynamic> json) =>
      _$ScoreLabelFromJson(json);

  Map<String, dynamic> toJson() => _$ScoreLabelToJson(this);
}

class PHQ9Questions {
  static final List<PHQ9Question> questions = [
    PHQ9Question(
      id: 'q1',
      en: 'Little interest or pleasure in doing things',
      ar: 'قلة الاهتمام أو المتعة في فعل الأشياء',
    ),
    PHQ9Question(
      id: 'q2',
      en: 'Feeling down, depressed, or hopeless',
      ar: 'الشعور بالإحباط أو الاكتئاب أو اليأس',
    ),
    PHQ9Question(
      id: 'q3',
      en: 'Trouble falling or staying asleep, or sleeping too much',
      ar: 'صعوبة في النوم أو البقاء نائماً، أو النوم أكثر من اللازم',
    ),
    PHQ9Question(
      id: 'q4',
      en: 'Feeling tired or having little energy',
      ar: 'الشعور بالتعب أو قلة الطاقة',
    ),
    PHQ9Question(
      id: 'q5',
      en: 'Poor appetite or overeating',
      ar: 'ضعف الشهية أو الإفراط في الأكل',
    ),
    PHQ9Question(
      id: 'q6',
      en: 'Feeling bad about yourself — or that you are a failure or have let yourself or your family down',
      ar: 'الشعور بالسوء تجاه نفسك — أو أنك فاشل أو خذلت نفسك أو عائلتك',
    ),
    PHQ9Question(
      id: 'q7',
      en: 'Trouble concentrating on things, such as reading the newspaper or watching television',
      ar: 'صعوبة في التركيز على الأشياء، مثل قراءة الصحف أو مشاهدة التلفزيون',
    ),
    PHQ9Question(
      id: 'q8',
      en: 'Moving or speaking so slowly that other people could have noticed, or the opposite — being so fidgety or restless that you have been moving around a lot more than usual',
      ar: 'التحرك أو التحدث ببطء شديد بحيث يلاحظ الآخرون، أو العكس — أن تكون متوتراً أو قلقاً لدرجة أنك تتحرك أكثر من المعتاد',
    ),
    PHQ9Question(
      id: 'q9',
      en: 'Thoughts that you would be better off dead, or of hurting yourself in some way',
      ar: 'أفكار بأنك ستكون أفضل حالاً ميتاً، أو إيذاء نفسك بطريقة ما',
    ),
  ];

  static final List<ScoreLabel> scoreLabels = [
    ScoreLabel(value: 0, en: 'Not at all', ar: 'على الإطلاق'),
    ScoreLabel(value: 1, en: 'Several days', ar: 'عدة أيام'),
    ScoreLabel(value: 2, en: 'More than half the days', ar: 'أكثر من نصف الأيام'),
    ScoreLabel(value: 3, en: 'Nearly every day', ar: 'كل يوم تقريباً'),
  ];

  static String getInstructions(String locale) {
    return locale == 'ar'
        ? 'خلال الأسبوعين الماضيين، كم مرة أزعجتك المشاكل التالية؟'
        : 'Over the past two weeks, how often have you been bothered by the following problems?';
  }
}
