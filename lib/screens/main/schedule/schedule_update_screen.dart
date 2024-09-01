import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import '../../../config.dart';
import '../../../providers/auth_provider.dart';
import 'schedule_list_screen.dart';

class ScheduleUpdateScreen extends StatefulWidget {
  final int scheduleId;

  ScheduleUpdateScreen({required this.scheduleId});

  @override
  _ScheduleUpdateScreenState createState() => _ScheduleUpdateScreenState();
}

class _ScheduleUpdateScreenState extends State<ScheduleUpdateScreen> {
  final _titleController = TextEditingController();
  DateTime _startTime = DateTime(0, 0, 0, 9, 0);
  DateTime _endTime = DateTime(0, 0, 0, 13, 0);
  final List<bool> _selectedDays = List.generate(7, (_) => false);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchScheduleDetails();
  }

  Future<void> _fetchScheduleDetails() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/api/schedule/v1?workScheduleId=${widget.scheduleId}'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    print('123123124');
    print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final schedule = data['data'];
      setState(() {
        _titleController.text = schedule['workScheduleTitle'];
        _startTime = _parseTime(schedule['startTime']);
        _endTime = _parseTime(schedule['endTime']);
        _setSelectedDays(schedule['days']);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일정 정보를 불러오는 데 실패했습니다.')),
      );
    }
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    return DateTime(0, 0, 0, int.parse(parts[0]), int.parse(parts[1]));
  }

  void _setSelectedDays(List<dynamic> days) {
    setState(() {
      _selectedDays.fillRange(0, 7, false);
      for (var day in days) {
        if (day >= 0 && day < 7) {
          _selectedDays[day] = true;
        }
      }
    });
  }

  Future<void> _updateSchedule() async {
    final title = _titleController.text;
    final startTime = '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
    final endTime = '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';
    final days = _selectedDays.asMap().entries.where((entry) => entry.value).map((entry) => entry.key).toList();

    if (title.isEmpty || days.isEmpty) {
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
      final response = await http.put(
        Uri.parse('${Config.baseUrl}/api/schedule/v1?workScheduleId=${widget.scheduleId}'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'workScheduleTitle': title,
          'startTime': startTime,
          'endTime': endTime,
          'days': days,
        }),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog();
      } else {
        final responseBody = response.body;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('근무 일정 업데이트 실패: $responseBody')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('근무 일정 업데이트 실패: $e')),
      );
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
            _startTime = DateTime(
              _startTime.year,
              _startTime.month,
              _startTime.day,
              time.hour,
              time.minute,
            );
          } else {
            _endTime = DateTime(
              _endTime.year,
              _endTime.month,
              _endTime.day,
              time.hour,
              time.minute,
            );
          }
        });
      },
      currentTime: isStart ? _startTime : _endTime,
      locale: LocaleType.ko,
      showSecondsColumn: false,
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('성공'),
          content: Text('근무 일정이 성공적으로 저장되었습니다.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(true); // Go back to the previous screen
                // Trigger a callback or a state refresh if needed
                // widget.onScheduleChanged(); // Uncomment if you add a callback in constructor
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
        title: Text('근무 일정 수정'),
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
              onPressed: _updateSchedule,
              child: Text('변경 사항 저장'),
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
