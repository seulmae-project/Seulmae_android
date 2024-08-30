class NotificationItemData {
  final String id;
  final String title;
  final String content;
  final String regDate;

  NotificationItemData({
    required this.id,
    required this.title,
    required this.content,
    required this.regDate,
  });

  factory NotificationItemData.fromJson(Map<String, dynamic> json) {
    return NotificationItemData(
      id: json['announcementId'].toString(),
      title: json['title'],
      content: json['content'],
      regDate: json['regDate'],
    );
  }
}

class AlertItemData {
  final String id;
  final String title;
  final String message;
  final String regDateNotification;

  AlertItemData({
    required this.id,
    required this.title,
    required this.message,
    required this.regDateNotification,
  });

  factory AlertItemData.fromJson(Map<String, dynamic> json) {
    return AlertItemData(
      id: json['notificationId'].toString(),
      title: json['title'],
      message: json['message'],
      regDateNotification: json['regDateNotification'],
    );
  }
}
