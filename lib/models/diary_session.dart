class DiarySession {
  final String id;
  final String patientId;
  final String? treatmentItemId;
  final String sessionDate;
  final bool completed;
  final int? painLevel;
  final int? fatigueLevel;
  final int? difficultyLevel;
  final TreatmentItemSummary? treatmentItem;

  DiarySession({
    required this.id,
    required this.patientId,
    this.treatmentItemId,
    required this.sessionDate,
    required this.completed,
    this.painLevel,
    this.fatigueLevel,
    this.difficultyLevel,
    this.treatmentItem,
  });

  factory DiarySession.fromJson(Map<String, dynamic> json) {
    return DiarySession(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      treatmentItemId: json['treatment_item_id'] as String?,
      sessionDate: json['session_date'] as String,
      completed: json['completed'] as bool? ?? false,
      painLevel: json['pain_level'] as int?,
      fatigueLevel: json['fatigue_level'] as int?,
      difficultyLevel: json['difficulty_level'] as int?,
      treatmentItem: json['treatment_item'] != null
          ? TreatmentItemSummary.fromJson(json['treatment_item'] as Map<String, dynamic>)
          : null,
    );
  }
}

class TreatmentItemSummary {
  final String id;
  final String? exerciseId;
  final int? sets;
  final int? repetitions;
  final int? durationSeconds;
  final String? frequencyText;
  final ExerciseSummary? exercise;

  TreatmentItemSummary({
    required this.id,
    this.exerciseId,
    this.sets,
    this.repetitions,
    this.durationSeconds,
    this.frequencyText,
    this.exercise,
  });

  factory TreatmentItemSummary.fromJson(Map<String, dynamic> json) {
    return TreatmentItemSummary(
      id: json['id'] as String,
      exerciseId: json['exercise_id'] as String?,
      sets: json['sets'] as int?,
      repetitions: json['repetitions'] as int?,
      durationSeconds: json['duration_seconds'] as int?,
      frequencyText: json['frequency_text'] as String?,
      exercise: json['exercise'] != null
          ? ExerciseSummary.fromJson(json['exercise'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ExerciseSummary {
  final String id;
  final String title;
  final String? category;

  ExerciseSummary({
    required this.id,
    required this.title,
    this.category,
  });

  factory ExerciseSummary.fromJson(Map<String, dynamic> json) {
    return ExerciseSummary(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String?,
    );
  }
}
