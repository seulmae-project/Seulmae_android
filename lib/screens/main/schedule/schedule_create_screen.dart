import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import '../../../config.dart';
import '../../../providers/auth_provider.dart';

class ScheduleCreateScreen extends StatefulWidget {
  @override
  _ScheduleCreateScreenState createState() => _ScheduleCreateScreenState();
}

class _ScheduleCreateScreenState extends State<ScheduleCreateScreen> {
  final _titleController = TextEditingController();
  DateTime _startTime = DateTime(0, 0, 0, 9, 0); // Use DateTime for easier manipulation
  DateTime _endTime = DateTime(0, 0, 0, 13, 0);
  final List<bool> _selectedDays = List.generate(7, (_) => false); // Represents days of the week
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  List<int> _getSelectedDays() {
    return _selectedDays.asMap().entries.where((entry) => entry.value).map((entry) => entry.key).toList();
  }

  Future<void> _createSchedule() async {
    final title = _titleController.text;
    final startTime = '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
    final endTime = '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';
    final days = _getSelectedDays();

    if (title.isEmpty || startTime.isEmpty || endTime.isEmpty || days.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필드를 입력하고 최소 하나의 요일을 선택하세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = authProvider.accessToken;
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/schedule/v1'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'workplaceId': authProvider.selectedWorkplaceId,
          'workScheduleTitle': title,
          'startTime': startTime,
          'endTime': endTime,
          'days': days,
        }),
      );

      if (response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        final responseBody = response.body;
        throw Exception('근무 일정 생성 실패: $responseBody');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('근무 일정 생성 실패: $e')),
      );
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    DatePicker.showTimePicker(
      context,
      showTitleActions: true,
      onConfirm: (time) {
        setState(() {
          if (isStart) {
            _startTime = time;
          } else {
            _endTime = time;
          }
        });
      },
      currentTime: isStart ? _startTime : _endTime,
      locale: LocaleType.ko, // Use Korean locale for better experience
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('성공'),
          content: Text('근무 일정이 성공적으로 등록되었습니다.'),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Navigate back to the previous screen
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('근무 일정 생성'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: '근무 일정 제목'),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () => _selectTime(context, true),
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(
                      text: '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}'),
                  decoration: InputDecoration(
                    labelText: '시작 시간',
                    suffixIcon: Icon(Icons.access_time),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () => _selectTime(context, false),
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(
                      text: '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}'),
                  decoration: InputDecoration(
                    labelText: '종료 시간',
                    suffixIcon: Icon(Icons.access_time),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('근무 요일 선택:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(7, (index) {
                return ChoiceChip(
                  label: Text(_dayName(index)),
                  selected: _selectedDays[index],
                  onSelected: (selected) {
                    setState(() {
                      _selectedDays[index] = selected;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _createSchedule,
              child: Text('생성'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.shade700,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dayName(int index) {
    switch (index) {
      case 0:
        return '일요일';
      case 1:
        return '월요일';
      case 2:
        return '화요일';
      case 3:
        return '수요일';
      case 4:
        return '목요일';
      case 5:
        return '금요일';
      case 6:
        return '토요일';
      default:
        return '';
    }
  }
}
