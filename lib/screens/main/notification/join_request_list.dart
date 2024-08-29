import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../config.dart';
import '../../../providers/auth_provider.dart';

import 'join_request_detail_screen.dart'; // 상세보기 스크린 import

class JoinRequestList extends StatefulWidget {
  @override
  _JoinRequestListState createState() => _JoinRequestListState();
}

class _JoinRequestListState extends State<JoinRequestList> {
  late Future<List<JoinRequestItemData>> _joinRequests;

  @override
  void initState() {
    super.initState();
    _joinRequests = fetchJoinRequests();
  }

  Future<List<JoinRequestItemData>> fetchJoinRequests() async {
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
      Uri.parse('${Config.baseUrl}/api/workplace/join/v1/request/list?workplaceId=$selectedWorkplaceId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> joinRequestsJson = data['data'];
      return joinRequestsJson.map((json) => JoinRequestItemData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load join requests');
    }
  }

  Future<void> _refreshJoinRequests() async {
    setState(() {
      _joinRequests = fetchJoinRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<JoinRequestItemData>>(
      future: _joinRequests,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No join requests available.'));
        } else {
          final joinRequests = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: joinRequests.map((joinRequest) {
              return JoinRequestItem(
                workplaceApproveId: joinRequest.workplaceApproveId,
                userName: joinRequest.userName,
                requestDate: joinRequest.requestDate,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JoinRequestDetailScreen(
                        workplaceApproveId: joinRequest.workplaceApproveId,
                        userName: joinRequest.userName,
                        requestDate: joinRequest.requestDate,
                      ),
                    ),
                  );

                  if (result == true) {
                    _refreshJoinRequests(); // 새로 고침
                  }
                },
              );
            }).toList(),
          );
        }
      },
    );
  }
}

class JoinRequestItem extends StatelessWidget {
  final int workplaceApproveId;
  final String userName;
  final String requestDate;
  final VoidCallback? onTap;

  JoinRequestItem({
    required this.workplaceApproveId,
    required this.userName,
    required this.requestDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.greenAccent,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          userName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('요청 일자: $requestDate'),
      ),
    );
  }
}

class JoinRequestItemData {
  final int workplaceApproveId;
  final String userName;
  final String requestDate;

  JoinRequestItemData({
    required this.workplaceApproveId,
    required this.userName,
    required this.requestDate,
  });

  factory JoinRequestItemData.fromJson(Map<String, dynamic> json) {
    return JoinRequestItemData(
      workplaceApproveId: json['workplaceApproveId'],
      userName: utf8.decode(json['userName'].runes.toList()), // 한글 깨짐 방지
      requestDate: json['requestDate'].split('T')[0], // 날짜 형식 변환
    );
  }
}

