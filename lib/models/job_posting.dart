class JobPosting {
  final String id;
  final String employerId;
  final String title;
  final String description;
  final String barangay;
  final double salary;
  final String paymentFrequency;
  final List<String> requiredSkills;
  final String status; // 'active', 'paused', 'closed'
  final DateTime createdAt;
  final DateTime updatedAt;
  final int applicationsCount;

  JobPosting({
    required this.id,
    required this.employerId,
    required this.title,
    required this.description,
    required this.barangay,
    required this.salary,
    required this.paymentFrequency,
    required this.requiredSkills,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.applicationsCount = 0,
  });

  factory JobPosting.fromMap(Map<String, dynamic> map) {
    return JobPosting(
      id: map['id'] as String,
      employerId: map['employer_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      barangay: map['barangay'] as String,
      salary: (map['salary'] as num).toDouble(),
      paymentFrequency: map['payment_frequency'] as String,
      requiredSkills: List<String>.from(map['required_skills'] as List),
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      applicationsCount: map['applications_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employer_id': employerId,
      'title': title,
      'description': description,
      'barangay': barangay,
      'salary': salary,
      'payment_frequency': paymentFrequency,
      'required_skills': requiredSkills,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'employer_id': employerId,
      'title': title,
      'description': description,
      'barangay': barangay,
      'salary': salary,
      'payment_frequency': paymentFrequency,
      'required_skills': requiredSkills,
      'status': status,
    };
  }

  // Legacy property getters for backward compatibility
  String get location => barangay;
  String get salaryPeriod => paymentFrequency;
  DateTime get postedDate => createdAt;
}
