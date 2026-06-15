class Treatment {
  final String id;
  final String patientId;
  final String doctorId;
  final String title;
  final String status;
  final String startDate;
  final String? endDate;
  final String? createdAt;
  final String? updatedAt;

  Treatment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.title,
    required this.status,
    required this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      doctorId: json['doctor_id'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'patient_id': patientId,
        'doctor_id': doctorId,
        'title': title,
        'status': status,
        'start_date': startDate,
        'end_date': endDate,
      };
}
