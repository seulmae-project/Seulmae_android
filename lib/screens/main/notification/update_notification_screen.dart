import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../config.dart';
import '../../../providers/auth_provider.dart';

class UpdateNotificationScreen extends StatefulWidget {
  final Map<String, dynamic> notification;

  UpdateNotificationScreen({required this.notification});

  @override
  _UpdateNotificationScreenState createState() => _UpdateNotificationScreenState();
}

class _UpdateNotificationScreenState extends State<UpdateNotificationScreen> {
  late String _category;
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _category = widget.notification['isImportant'] ? '필독' : '일반';
    _titleController = TextEditingController(text: widget.notification['title']);
    _contentController = TextEditingController(text: widget.notification['content']);
  }

  Future<void> _updateNotification() async {
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
    final accessToken = authProvider.accessToken;
    final announcementId = widget.notification['id']; // Pass the ID to update

    try {
      final response = await http.put(
        Uri.parse('${Config.baseUrl}/api/announcement/v1?announcementId=$announcementId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'content': content,
          'isImportant': isImportant,
        }),
      );
        print(response.body);
      print(jsonEncode({
        'title': title,
        'content': content,
        'isImportant': isImportant,
      }));
      if (response.statusCode == 200) {
        Navigator.pop(context, true); // Notify the caller about the success
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
    return Scaffold(
      appBar: AppBar(
        title: Text('공지 수정', style: TextStyle(fontWeight: FontWeight.bold)),
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
              onPressed: _updateNotification,
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
