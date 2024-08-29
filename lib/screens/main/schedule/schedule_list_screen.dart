import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import '../../../config.dart';
import '../../../providers/auth_provider.dart';
import '../app_state.dart';
import 'schedule_create_screen.dart';
import 'schedule_detail_screen.dart';
import '../manage/manage_dashboard_screen.dart'; // Import the ManageDashboardScreen

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
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _fetchSchedules(); // Fetch schedules initially
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_scrollListener);
    _scrollController?.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController!.position.pixels == _scrollController!.position.maxScrollExtent) {
      _fetchSchedules(); // Fetch more data when scrolled to the end
    }
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
        final schedulesData = data['data'] as List<dynamic>?;

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
        throw Exception('Failed to load schedules');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _refreshSchedules() {
    setState(() {
      _schedules.clear();
      _page = 0;
      _hasMore = true;
      _fetchSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (Navigator.of(context).canPop()) {
          return Future.value(true);
        }
        if (appState.currentBackPressTime == null ||
            now.difference(appState.currentBackPressTime!) > Duration(seconds: 2)) {
          appState.setCurrentBackPressTime(now);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('한 번 더 누르시면 앱이 종료됩니다.')),
          );
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
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
          leading: SizedBox(), // 이 줄을 추가하여 뒤로가기 아이콘 제거
        ),
        body: _schedules.isEmpty
            ? Center(child: _isLoading ? CircularProgressIndicator() : Text('스케줄이 없습니다.'))
            : ListView.builder(
          controller: _scrollController,
          itemCount: _schedules.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _schedules.length) {
              return Center(child: _isLoading ? CircularProgressIndicator() : SizedBox());
            }

            final schedule = _schedules[index];
            return ListTile(
              title: Text(schedule['workScheduleTitle']),
              subtitle: Text('${schedule['startTime']} - ${schedule['endTime']}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScheduleDetailScreen(
                      scheduleId: schedule['workScheduleId'],
                      onScheduleChanged: _refreshSchedules, // Pass the callback
                    ),
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
            ).then((_) {
              _refreshSchedules(); // Refresh the list after creating a new schedule
            });
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
