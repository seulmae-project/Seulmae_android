import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../config.dart';
import '../../../providers/auth_provider.dart';

class AddNotificationScreen extends StatefulWidget {
  @override
  _AddNotificationScreenState createState() => _AddNotificationScreenState();
}

class _AddNotificationScreenState extends State<AddNotificationScreen> {
  String _category = '일반';
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitNotification() async {
    if (_isSubmitting) return;

    final String title = _titleController.text;
    final String content = _contentController.text;
    final bool isImportant = _category == '필독';

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목과 내용을 모두 입력해주세요.')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final selectedWorkplaceId = authProvider.selectedWorkplaceId;

    if (authProvider.isTokenExpired()) {
      try {
        bool refreshed = await authProvider.refreshAccessToken();
        if (!refreshed) {
          throw Exception('Failed to refresh token');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('토큰 갱신에 실패했습니다. 다시 로그인 해주세요.')),
        );
        return;
      }
    }
    final accessToken = authProvider.accessToken;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/announcement/v1'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'workplaceId': selectedWorkplaceId,
          'title': title,
          'content': content,
          'isImportant': isImportant,
        }),
      );

      if (response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('공지사항 추가 완료'),
            content: Text('공지사항이 성공적으로 추가되었습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
                child: Text('확인'),
              ),
            ],
          ),
        ).then((_) {
          Navigator.pop(context, true); // 성공 결과 반환
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
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('공지 추가', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text('구분', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 20),
                ChoiceChip(
                  label: Text('일반'),
                  selected: _category == '일반',
                  onSelected: (selected) {
                    setState(() {
                      _category = '일반';
                    });
                  },
                  selectedColor: Colors.blueAccent,
                  backgroundColor: Colors.grey[200],
                ),
                SizedBox(width: 10),
                ChoiceChip(
                  label: Text('필독'),
                  selected: _category == '필독',
                  onSelected: (selected) {
                    setState(() {
                      _category = '필독';
                    });
                  },
                  selectedColor: Colors.blueAccent,
                  backgroundColor: Colors.grey[200],
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '제목을 입력해주세요',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: '공지사항 내용을 입력해주세요',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 5,
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitNotification,
              child: Text('저장'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
