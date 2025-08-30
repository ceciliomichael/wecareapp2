class JobPosting {
  final String id;
  final String title;
  final String description;
  final String location;
  final double salary;
  final String salaryPeriod; // 'hourly', 'daily', 'weekly', 'monthly'
  final DateTime postedDate;
  final String status; // 'active', 'paused', 'closed'
  final int applicationsCount;

  JobPosting({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.salary,
    required this.salaryPeriod,
    required this.postedDate,
    required this.status,
    this.applicationsCount = 0,
  });


}
