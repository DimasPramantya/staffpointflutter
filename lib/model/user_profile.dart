class UserProfile {
  final String name;
  final String email;
  final String address;
  final String phone;
  final String npk;
  final int salary;
  final String companyName;
  final String roleName;
  final String jobName;
  final String? pfp;

  UserProfile({
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
    required this.npk,
    required this.salary,
    required this.companyName,
    required this.roleName,
    required this.jobName,
    this.pfp
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      email: json['email'],
      address: json['address'],
      phone: json['phone'],
      npk: json['npk'],
      salary: json['salary'],
      companyName: json['company_name'],
      roleName: json['role_name'],
      jobName: json['job_name'],
      pfp: json['pfp']
    );
  }
}