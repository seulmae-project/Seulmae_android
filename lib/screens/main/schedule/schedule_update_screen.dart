import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import '../../../config.dart';
import '../../../providers/auth_provider.dart';

class ScheduleUpdateScreen extends StatefulWidget {
  final int scheduleId;

  ScheduleUpdateScreen({required this.scheduleId});

  @override
  _ScheduleUpdateScreenState createState() => _ScheduleUpdateScreenState();
}

class _ScheduleUpdateScreenState extends State<ScheduleUpdateScreen> {
  final _titleController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _daysController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchScheduleDetails();
  }

  Future<void> _fetchScheduleDetails() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/api/schedule/v1/${widget.scheduleId}'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final schedule = data['data'];
      setState(() {
        _titleController.text = schedule['workScheduleTitle'];
        _startTimeController.text = schedule['startTime'];
        _endTimeController.text = schedule['endTime'];
        _daysController.text = json.encode(schedule['days']); // Assuming days is a JSON array
      });
    } else {
      throw Exception('근무 일정 불러오기 실패');
    }
  }

  Future<void> _updateSchedule() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;

    final response = await http.put(
      Uri.parse('${Config.baseUrl}/api/schedule/v1/${widget.scheduleId}'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'workScheduleTitle': _titleController.text,
        'startTime': _startTimeController.text,
        'endTime': _endTimeController.text,
        'days': json.decode(_daysController.text),
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
    } else {
      throw Exception('근무 일정 수정 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('근무 일정 수정'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(controller: _titleController, label: '근무 일정 제목'),
            SizedBox(height: 15),
            _buildTextField(controller: _startTimeController, label: '시작 시간 (예: 09:00)'),
            SizedBox(height: 15),
            _buildTextField(controller: _endTimeController, label: '종료 시간 (예: 13:00)'),
            SizedBox(height: 15),
            _buildTextField(controller: _daysController, label: '근무 요일 (JSON 배열)'),
            Spacer(),
            ElevatedButton(
              onPressed: _updateSchedule,
              child: Text('수정'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}
