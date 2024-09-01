import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import '../../../config.dart';
import '../../../providers/auth_provider.dart';
import 'schedule_update_screen.dart';

class ScheduleDetailScreen extends StatefulWidget {
  final int scheduleId;
  final VoidCallback onScheduleChanged; // Callback for updating the list

  ScheduleDetailScreen({required this.scheduleId, required this.onScheduleChanged});

  @override
  _ScheduleDetailScreenState createState() => _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends State<ScheduleDetailScreen> {
  Map<String, dynamic>? _schedule;

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
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _schedule = data['data'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일정 정보를 불러오는 데 실패했습니다.')),
      );
    }
  }

  Future<void> _deleteSchedule() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;

    final url = Uri.parse('${Config.baseUrl}/api/schedule/v1?workScheduleId=${widget.scheduleId}');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일정이 삭제되었습니다.')),
      );
      widget.onScheduleChanged(); // Notify the parent that the schedule was changed
      Navigator.of(context).pop(); // Go back to the previous screen
    } else {
      final responseBody = response.body;
      print(responseBody);
      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text('일정 삭제에 실패했습니다: $responseBody')),
      );
      print('Error: $responseBody');
    }
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

  @override
  Widget build(BuildContext context) {
    if (_schedule == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('일정 상세'),
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final days = (_schedule!['days'] as List<dynamic>)
        .map((day) => _dayName(day as int))
        .join(', ');

    return Scaffold(
      appBar: AppBar(
        title: Text('일정 상세'),
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
            Text(
              '제목: ${_schedule!['workScheduleTitle']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '시작 시간: ${_schedule!['startTime']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '종료 시간: ${_schedule!['endTime']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '작업 일: $days',
              style: TextStyle(fontSize: 16),
            ),
            Spacer(), // Pushes the buttons to the bottom
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScheduleUpdateScreen(scheduleId: widget.scheduleId),
                        ),
                      ).then((isUpdated) {
                        if (isUpdated == true) {
                          _fetchScheduleDetails(); // Refresh the schedule details
                          widget.onScheduleChanged(); // Notify the parent that the schedule has been changed
                        }
                      });
                    },
                    child: Text('일정 수정'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // A more neutral blue color
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('삭제 확인'),
                          content: Text('이 일정을 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('삭제'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('취소'),
                            ),
                          ],
                        ),
                      );
                      if (shouldDelete == true) {
                        await _deleteSchedule();
                      }
                    },
                    child: Text('일정 삭제'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
