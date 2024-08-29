import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../config.dart';
import '../../../providers/auth_provider.dart';
import 'add_notification_screen.dart';
import 'join_request_list.dart';
import 'notification_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  final bool isManager;  // Add a parameter to determine if the user is a manager

  NotificationScreen({required this.isManager});  // Constructor to receive the parameter

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.isManager ? 3 : 2,  // Show 3 tabs if the user is a manager, otherwise 2
      vsync: this,
    );
    _tabController!.addListener(() {
      setState(() {});  // To update the UI when the tab changes
    });
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '공지'),
            Tab(text: '알림'),
            if (widget.isManager) Tab(text: '입장요청'),  // Conditionally add the tab for managers only
          ],
          indicatorColor: Colors.blueAccent,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.grey,
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          NotificationList(),
          AlertList(),
          if (widget.isManager) JoinRequestList(),  // Conditionally add the content for managers only
        ],
      ),
      floatingActionButton: _tabController!.index == 0
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNotificationScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      )
          : null,
    );
  }
}


class NotificationList extends StatefulWidget {
    @override
    _NotificationListState createState() => _NotificationListState();
  }

  class _NotificationListState extends State<NotificationList> {
    late Future<List<NotificationItemData>> _notifications;

    @override
    void initState() {
      super.initState();
      _notifications = fetchNotifications();
    }

    Future<List<NotificationItemData>> fetchNotifications() async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final selectedWorkplaceId = authProvider.selectedWorkplaceId;

      if (authProvider.isTokenExpired()) {
        bool refreshed = await authProvider.refreshAccessToken();
        if (!refreshed) {
          throw Exception('Failed to refresh token');
        }
      }

      final accessToken = authProvider.accessToken;
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/announcement/v1/list?workplaceId=$selectedWorkplaceId&page=0&size=5'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      print(response.body); // For debugging purposes
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> notificationsJson = data['data']['data'];
        return notificationsJson.map((json) => NotificationItemData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notifications');
      }
    }

    @override
    Widget build(BuildContext context) {
      return FutureBuilder<List<NotificationItemData>>(
        future: _notifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No notifications available.'));
          } else {
            final notifications = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: notifications.map((notification) {
                return NotificationItem(
                  id: notification.id,
                  title: notification.title,
                  content: notification.content,
                  regDate: notification.regDate,
                );
              }).toList(),
            );
          }
        },
      );
    }
  }

  class AlertList extends StatefulWidget {
    @override
    _AlertListState createState() => _AlertListState();
  }

  class _AlertListState extends State<AlertList> {
    late Future<List<AlertItemData>> _alerts;

    @override
    void initState() {
      super.initState();
      _alerts = fetchAlerts();
    }

    Future<List<AlertItemData>> fetchAlerts() async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final selectedWorkplaceId = authProvider.selectedWorkplaceId;

      if (authProvider.isTokenExpired()) {
        bool refreshed = await authProvider.refreshAccessToken();
        if (!refreshed) {
          throw Exception('Failed to refresh token');
        }
      }

      final accessToken = authProvider.accessToken;
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/notification/v1/list?userWorkplaceId=$selectedWorkplaceId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> alertsJson = data['data'];
        return alertsJson.map((json) => AlertItemData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load alerts');
      }
    }

    @override
    Widget build(BuildContext context) {
      return FutureBuilder<List<AlertItemData>>(
        future: _alerts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No alerts available.'));
          } else {
            final alerts = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: alerts.map((alert) {
                return AlertItem(
                  id: alert.id,
                  title: alert.title,
                  message: alert.message,
                  regDateNotification: alert.regDateNotification,
                );
              }).toList(),
            );
          }
        },
      );
    }
  }

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

  class NotificationItem extends StatelessWidget {
    final String id;
    final String title;
    final String content;
    final String regDate;

    NotificationItem({
      required this.id,
      required this.title,
      required this.content,
      required this.regDate,
    });

    @override
    Widget build(BuildContext context) {
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationDetailScreen(
                id: id
              ),
            ),
          );
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
