import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../config.dart';
import '../../../providers/auth_provider.dart';
import '../user_workplace_info.dart';
import 'delete_notification_screen.dart';
import 'update_notification_screen.dart';

class NotificationDetailScreen extends StatelessWidget {
  final String id;

  NotificationDetailScreen({required this.id});

  Future<Map<String, dynamic>> fetchNotificationDetail(
      BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isTokenExpired()) {
      bool refreshed = await authProvider.refreshAccessToken();
      if (!refreshed) {
        throw Exception('Failed to refresh token');
      }
    }

    final accessToken = authProvider.accessToken;
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/api/announcement/v1?announcementId=$id'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load notification details');
    }
  }

  Future<bool> checkIfUserIsManager(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    UserWorkplaceInfo? workplaceInfo = await authProvider
        .fetchUserWorkplaceInfo(authProvider.selectedWorkplaceId);

    if (workplaceInfo != null) {
      return workplaceInfo.isManager;
    } else {
      return false; // Default to false if workplaceInfo is null
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('공지사항 상세'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchNotificationDetail(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('세부 정보가 없습니다.'));
          } else {
            final notification = snapshot.data!;
            return FutureBuilder<bool>(
              future: checkIfUserIsManager(context),
              builder: (context, managerSnapshot) {
                if (managerSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (managerSnapshot.hasError) {
                  return Center(child: Text('오류 발생: ${managerSnapshot.error}'));
                } else if (!managerSnapshot.hasData) {
                  return Center(child: Text('근무지 정보가 없습니다.'));
                } else {
                  final isManager = managerSnapshot.data ?? false;
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 80.0),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  notification['title'],
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    Text(
                                      '등록일: ${notification['regDate']}',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '조회수: ${notification['views']}',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.0),
                                Divider(color: Colors.grey),
                                SizedBox(height: 16.0),
                                Text(
                                  notification['content'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (isManager) ...[
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UpdateNotificationScreen(
                                                notification: notification),
                                      ),
                                    ).then((result) {
                                      if (result == true) {
                                        Navigator.pop(context,
                                            true); // Notify the caller to refresh
                                      }
                                    });
                                  },
                                  icon: Icon(Icons.edit, color: Colors.white),
                                  label: Text('수정'),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.green,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    bool? confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) =>
                                          DeleteNotificationScreen(id: id),
                                    );

                                    if (confirm == true) {
                                      Navigator.pop(context,
                                          true); // Notify the caller to refresh
                                    }
                                  },
                                  icon: Icon(Icons.delete, color: Colors.white),
                                  label: Text('삭제'),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.red,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}