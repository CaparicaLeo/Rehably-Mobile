class Address {
  final String id;
  final String userId;
  final String postalCode;
  final String street;
  final String number;
  final String neighborhood;
  final String city;
  final String state;
  final String? complement;
  final String? createdAt;
  final String? updatedAt;

  Address({
    required this.id,
    required this.userId,
    required this.postalCode,
    required this.street,
    required this.number,
    required this.neighborhood,
    required this.city,
    required this.state,
    this.complement,
    this.createdAt,
    this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      postalCode: json['postal_code'] as String,
      street: json['street'] as String,
      number: json['number'] as String,
      neighborhood: json['neighborhood'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      complement: json['complement'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'postal_code': postalCode,
        'street': street,
        'number': number,
        'neighborhood': neighborhood,
        'city': city,
        'state': state,
        'complement': complement,
      };
}
