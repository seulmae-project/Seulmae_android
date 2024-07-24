import 'package:flutter/material.dart';

class AddNotificationScreen extends StatefulWidget {
  @override
  _AddNotificationScreenState createState() => _AddNotificationScreenState();
}

class _AddNotificationScreenState extends State<AddNotificationScreen> {
  String _category = '일반';
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

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
              onPressed: () {
                // Save the new notification (this is where you add your saving logic)
                Navigator.pop(context);
              },
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