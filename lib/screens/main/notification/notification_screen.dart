import 'package:flutter/material.dart';
import 'add_notification_screen.dart';
import 'alert_list.dart';
import 'join_request_list.dart';
import 'notification_list.dart';

class NotificationScreen extends StatefulWidget {
  final bool isManager;

  NotificationScreen({required this.isManager});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ValueNotifier<bool> _shouldRefresh = ValueNotifier(false);
  final GlobalKey<NotificationListState> _notificationListKey = GlobalKey<NotificationListState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.isManager ? 3 : 2,
      vsync: this,
    );
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _shouldRefresh.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging && _tabController.index == 0) {
      _shouldRefresh.value = !_shouldRefresh.value; // 공지 탭으로 이동 시 새로고침
    }
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
            if (widget.isManager) Tab(text: '입장요청'),
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
          ValueListenableBuilder<bool>(
            valueListenable: _shouldRefresh,
            builder: (context, shouldRefresh, child) {
              return NotificationList(
                key: _notificationListKey,
                onRefresh: () {
                  setState(() {
                    _shouldRefresh.value = !_shouldRefresh.value; // 새로고침 트리거
                  });
                },
              );
            },
          ),
          AlertList(),
          if (widget.isManager) JoinRequestList(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNotificationScreen(),
            ),
          );

          if (result == true) {
            _notificationListKey.currentState?.triggerLoadInitialNotifications();
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      )
          : null,
    );
  }
}
