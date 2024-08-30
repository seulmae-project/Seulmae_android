import 'package:flutter/material.dart';
import 'notification_detail_screen.dart';
class NotificationItem extends StatelessWidget {
  final String id;
  final String title;
  final String content;
  final String regDate;
  final Future<void> Function() onRefresh;

  NotificationItem({
    required this.id,
    required this.title,
    required this.content,
    required this.regDate,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationDetailScreen(id: id),
          ),
        ).then((result) {
          print("NotificationItem: Result from detail screen: $result");
          if (result == true) {
            print("NotificationItem: Calling onRefresh callback");
            onRefresh(); // 데이터 새로 고침
          }
        });
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.notifications, color: Colors.white),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(regDate),
      ),
    );
  }
}

class AlertItem extends StatelessWidget {
  final String id;
  final String title;
  final String message;
  final String regDateNotification;

  AlertItem({
    required this.id,
    required this.title,
    required this.message,
    required this.regDateNotification,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.warning, color: Colors.white),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('$message\nDate: $regDateNotification'),
    );
  }
}
