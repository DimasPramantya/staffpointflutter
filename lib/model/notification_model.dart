class NotificationData {
  final int id;
  final String wording;
  final int? userId;
  final int? companyId;
  final DateTime createdAt;
  final String title; // hardcoded field

  NotificationData({
    required this.id,
    required this.wording,
    this.userId,
    this.companyId,
    required this.createdAt,
    required this.title,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json, {String? title}) {
    return NotificationData(
      id: json['id'],
      wording: json['wording'],
      userId: json['user_id'],
      companyId: json['company_id'],
      createdAt: DateTime.parse(json['created_at']),
      title: title ?? 'Pegawai Baru',
    );
  }
}