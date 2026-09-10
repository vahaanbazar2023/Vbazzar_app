class AppNotification {
  final int id;
  final String userId;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.data,
    required this.createdAt,
    required this.isRead,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) {
    return AppNotification(
      id: (j['id'] as num?)?.toInt() ?? 0,
      userId: j['user_id']?.toString() ?? '',
      title: j['title']?.toString() ?? '',
      body: j['body']?.toString() ?? '',
      data: (j['data'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.tryParse(j['created_at']?.toString() ?? '') ??
          DateTime.now(),
      isRead: j['is_read'] == 1 || j['is_read'] == '1' || j['is_read'] == true,
    );
  }

  /// The onclick route key from the notification payload.
  String? get onClickRoute => data['onclick']?.toString();
}
