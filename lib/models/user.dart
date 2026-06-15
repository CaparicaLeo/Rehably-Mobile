class User {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String role;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;
  final DoctorProfile? doctor;
  final PatientProfile? patient;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.role,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.doctor,
    this.patient,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctor'] != null
        ? DoctorProfile.fromJson(json['doctor'] as Map<String, dynamic>)
        : null;
    final patient = json['patient'] != null
        ? PatientProfile.fromJson(json['patient'] as Map<String, dynamic>)
        : null;
    final role = json['role'] as String? ?? (doctor != null ? 'doctor' : 'patient');
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      role: role,
      emailVerifiedAt: json['email_verified_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      doctor: doctor,
      patient: patient,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'role': role,
        'email_verified_at': emailVerifiedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'doctor': doctor?.toJson(),
        'patient': patient?.toJson(),
      };
}

class DoctorProfile {
  final String id;
  final String crefito;
  final String specialty;
  final String userId;

  DoctorProfile({
    required this.id,
    required this.crefito,
    required this.specialty,
    required this.userId,
  });

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      id: json['id'] as String,
      crefito: json['crefito'] as String,
      specialty: json['specialty'] as String,
      userId: json['user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'crefito': crefito,
        'specialty': specialty,
        'user_id': userId,
      };
}

class PatientProfile {
  final String id;
  final String userId;
  final String? doctorId;
  final String birthDate;
  final String? clinicalCondition;

  PatientProfile({
    required this.id,
    required this.userId,
    this.doctorId,
    required this.birthDate,
    this.clinicalCondition,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      doctorId: json['doctor_id'] as String?,
      birthDate: json['birth_date'] as String,
      clinicalCondition: json['clinical_condition'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'doctor_id': doctorId,
        'birth_date': birthDate,
        'clinical_condition': clinicalCondition,
      };
}
