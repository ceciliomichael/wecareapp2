class Helper {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String skill;
  final String experience;
  final String barangay;
  final String? barangayClearanceBase64;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Helper({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.skill,
    required this.experience,
    required this.barangay,
    this.barangayClearanceBase64,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Helper.fromMap(Map<String, dynamic> map) {
    return Helper(
      id: map['id'] as String,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      skill: map['skill'] as String,
      experience: map['experience'] as String,
      barangay: map['barangay'] as String,
      barangayClearanceBase64: map['barangay_clearance_base64'] as String?,
      isVerified: map['is_verified'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'skill': skill,
      'experience': experience,
      'barangay': barangay,
      'barangay_clearance_base64': barangayClearanceBase64,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';
}
