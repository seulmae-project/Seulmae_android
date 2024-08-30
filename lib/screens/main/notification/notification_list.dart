import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../config.dart';
import '../../../providers/auth_provider.dart';
import 'notification_models.dart';
import 'notification_widgets.dart';

class NotificationList extends StatefulWidget {
  final Function onRefresh;

  NotificationList({Key? key, required this.onRefresh}) : super(key: key);

  @override
  NotificationListState createState() => NotificationListState();
}

class NotificationListState extends State<NotificationList> {
  List<NotificationItemData> _notificationList = [];
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  final int _initialPageSize = 20;
  final int _pageSize = 5;

  @override
  void initState() {
    super.initState();
    _loadInitialNotifications();
  }

  void _loadInitialNotifications() {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
      fetchNotifications(_initialPageSize, _currentPage).then((notifications) {
        setState(() {
          _notificationList = notifications;
          _currentPage = 1; // 페이지를 1로 초기화
          _hasMore = notifications.length == _initialPageSize;
          _isLoading = false;
        });
      }).catchError((error) {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  void triggerLoadInitialNotifications() {
    _refreshNotifications();
  }

  Future<void> _fetchMoreNotifications() async {
    if (_hasMore && !_isLoading) {
      setState(() {
        _isLoading = true;
      });

      try {
        final notifications = await fetchNotifications(_pageSize, _currentPage);
        setState(() {
          _currentPage++;
          _notificationList.addAll(notifications.where((newNotification) =>
          !_notificationList.any((existingNotification) =>
          existingNotification.id == newNotification.id)));
          _hasMore = notifications.length == _pageSize;
        });
      } catch (e) {
        // 에러 처리
        print('Error fetching more notifications: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<List<NotificationItemData>> fetchNotifications(int pageSize, int page) async {
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
      Uri.parse('${Config.baseUrl}/api/announcement/v1/list?workplaceId=$selectedWorkplaceId&page=$page&size=$pageSize'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    print('Page: $page');
    print('Page Size: $pageSize');
    print('Response Body: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> notificationsJson = data['data']['data'];
      return notificationsJson.map((json) => NotificationItemData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<void> _refreshNotifications() async {
    try {
      final notifications = await fetchNotifications(_initialPageSize, 0);
      setState(() {
        _notificationList = notifications;
        _currentPage = 1; // 페이지를 1로 초기화
        _hasMore = notifications.length == _initialPageSize;
      });
      widget.onRefresh(); // 새로고침 콜백 호출
    } catch (error) {
      // 에러 처리
      print('Error refreshing notifications: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _fetchMoreNotifications();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _notificationList.length + 1,
        itemBuilder: (context, index) {
          if (index == _notificationList.length) {
            return _isLoading ? Center(child: CircularProgressIndicator()) : SizedBox.shrink();
          }
          final notification = _notificationList[index];
          return NotificationItem(
            id: notification.id,
            title: notification.title,
            content: notification.content,
            regDate: notification.regDate,
            onRefresh: _refreshNotifications, // 리프레시 콜백 사용
          );
        },
      ),
    );
  }
}
