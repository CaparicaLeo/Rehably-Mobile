import 'user.dart';

class Patient {
  final String id;
  final String userId;
  final String doctorId;
  final String birthDate;
  final String? clinicalCondition;
  final String? email;
  final String? phoneNumber;
  final User? user;

  Patient({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.birthDate,
    this.clinicalCondition,
    this.email,
    this.phoneNumber,
    this.user,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      doctorId: json['doctor_id'] as String,
      birthDate: json['birth_date'] as String,
      clinicalCondition: json['clinical_condition'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': user?.name,
        'email': user?.email,
        'password': null,
        'password_confirmation': null,
        'phone_number': user?.phoneNumber,
        'birth_date': birthDate,
        'clinical_condition': clinicalCondition,
      };
}
