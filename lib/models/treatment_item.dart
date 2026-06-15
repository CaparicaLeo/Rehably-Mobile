class TreatmentItem {
  final String id;
  final String treatmentId;
  final String exerciseId;
  final int? sets;
  final int? repetitions;
  final int? durationSeconds;
  final String? frequencyText;

  TreatmentItem({
    required this.id,
    required this.treatmentId,
    required this.exerciseId,
    this.sets,
    this.repetitions,
    this.durationSeconds,
    this.frequencyText,
  });

  factory TreatmentItem.fromJson(Map<String, dynamic> json) {
    return TreatmentItem(
      id: json['id'] as String,
      treatmentId: json['treatment_id'] as String,
      exerciseId: json['exercise_id'] as String,
      sets: json['sets'] as int?,
      repetitions: json['repetitions'] as int?,
      durationSeconds: json['duration_seconds'] as int?,
      frequencyText: json['frequency_text'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'exercise_id': exerciseId,
        'sets': sets,
        'repetitions': repetitions,
        'duration_seconds': durationSeconds,
        'frequency_text': frequencyText,
      };
}
