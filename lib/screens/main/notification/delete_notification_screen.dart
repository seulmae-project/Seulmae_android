  import 'dart:convert';
  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'package:provider/provider.dart';

  import '../../../config.dart';
  import '../../../providers/auth_provider.dart';

  class DeleteNotificationScreen extends StatelessWidget {
    final String id;

    DeleteNotificationScreen({required this.id});

    Future<void> _deleteNotification(BuildContext context) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = authProvider.accessToken;

      try {
        final response = await http.delete(
          Uri.parse('${Config.baseUrl}/api/announcement/v1?announcementId=$id'),
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        );
        if (response.statusCode == 200) {
          // Show a confirmation dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('삭제 완료'),
              content: Text('공지사항이 성공적으로 삭제 되었습니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Notify that action was successful
                  },
                  child: Text('확인'),
                ),
              ],
            ),
          ).then((_) {
            Navigator.pop(context, true); // Notify the caller about the success
          });
        } else {
          final responseData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('오류: ${responseData['message']}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버와의 통신 중 오류가 발생했습니다.')),
        );
      }
    }

    @override
    Widget build(BuildContext context) {
      return AlertDialog(
        title: Text('삭제 확인'),
        content: Text('이 공지사항을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () {
              _deleteNotification(context);
            },
            child: Text('삭제'),
          ),
        ],
      );
    }
  }
