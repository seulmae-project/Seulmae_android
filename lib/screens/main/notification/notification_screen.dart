import 'package:flutter/material.dart';
import 'add_notification_screen.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(() {
      setState(() {}); // To update the UI when the tab changes
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

class NotificationList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text('12월 3일', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        NotificationItem(date: '12월 3일', content: '새로운 공지가 추가되었습니다.'),
        SizedBox(height: 10),
        Text('12월 4일', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        NotificationItem(date: '12월 4일', content: '새로운 공지가 추가되었습니다.'),
        NotificationItem(date: '12월 4일', content: '새로운 공지가 추가되었습니다.'),
      ],
    );
  }
}

class AlertList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text('12월 3일', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        AlertItem(date: '12월 3일', content: '중요 알림이 있습니다.'),
        SizedBox(height: 10),
        Text('12월 4일', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        AlertItem(date: '12월 4일', content: '중요 알림이 있습니다.'),
      ],
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String date;
  final String content;

  NotificationItem({required this.date, required this.content});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.notifications, color: Colors.white),
      ),
      title: Text(
        '공지',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(content),
    );
  }
}

class AlertItem extends StatelessWidget {
  final String date;
  final String content;

  AlertItem({required this.date, required this.content});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.warning, color: Colors.white),
      ),
      title: Text(
        '알림',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(content),
    );
  }
}
