import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import '../../../config.dart';
import '../../../providers/auth_provider.dart';
import 'schedule_create_screen.dart';
import 'schedule_detail_screen.dart';

class ScheduleListScreen extends StatefulWidget {
  @override
  _ScheduleListScreenState createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  List<Map<String, dynamic>> _schedules = [];
  int _page = 0;
  int _size = 5;
  bool _hasMore = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = authProvider.accessToken;
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/schedule/v1/list?workplaceId=${authProvider.selectedWorkplaceId}&page=$_page&size=$_size'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final schedulesData = data['data']['data'] as List<dynamic>?;

        if (schedulesData == null || schedulesData.isEmpty) {
          setState(() {
            _hasMore = false;
          });
        } else {
          final schedules = List<Map<String, dynamic>>.from(schedulesData);
          setState(() {
            _page++;
            _schedules.addAll(schedules);
          });
        }
      } else {
        throw Exception('스케줄 목록 불러오기 실패');
      }
    } catch (e) {
      // Handle exceptions or show an error message to the user
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('근무 일정 목록'),
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
      body: _schedules.isEmpty
          ? Center(child: _isLoading ? CircularProgressIndicator() : Text('스케줄이 없습니다.'))
          : ListView.builder(
        itemCount: _schedules.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _schedules.length) {
            _fetchSchedules(); // Load more data
            return Center(child: CircularProgressIndicator());
          }

          final schedule = _schedules[index];
          return ListTile(
            title: Text(schedule['workScheduleTitle']),
            subtitle: Text('${schedule['startTime']} - ${schedule['endTime']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScheduleDetailScreen(scheduleId: schedule['workScheduleId']),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScheduleCreateScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
