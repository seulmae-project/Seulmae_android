import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../config.dart';
import '../../../providers/auth_provider.dart';
import '../app_state.dart';
import '../employee/employee_dashboard_screen.dart';
import '../notification/notice_section.dart';
import '../setting/settings_screen.dart';
import '../workplace/workplace_entry_screen.dart';
import '../workplace/workplace_management_screen.dart';
import '../notification/notification_screen.dart';
import 'workplace_employee_list.dart'; // Ensure this import is correct

class ManageDashboardScreen extends StatefulWidget {
  const ManageDashboardScreen({Key? key}) : super(key: key);

  @override
  ManageDashboardScreenState createState() => ManageDashboardScreenState();
}

class ManageDashboardScreenState extends State<ManageDashboardScreen> {
  PageController _pageController = PageController();
  int _currentNoticePage = 0;
  Timer? _noticeTimer;
  DateTime selectedDate = DateTime.now();
  List<dynamic> workInfoList = [];
  List<dynamic> notices = [];

  @override
  void initState() {
    super.initState();
    _startNoticeTimer();
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _noticeTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startNoticeTimer() {
    _noticeTimer = Timer.periodic(Duration(seconds: 7), (Timer timer) {
      if (notices.isEmpty) return;
      setState(() {
        _currentNoticePage = (_currentNoticePage + 1) % notices.length;
      });
      _pageController.animateToPage(
        _currentNoticePage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  Future<void> _initializeData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appState = Provider.of<AppState>(context, listen: false);
    final selectedWorkplaceId = authProvider.selectedWorkplaceId;

    if (authProvider.isTokenExpired()) {
      bool refreshed = await authProvider.refreshAccessToken();
      if (!refreshed) {
        throw Exception('Failed to refresh token');
      }
    }

    final accessToken = authProvider.accessToken;

    final String date = selectedDate.toIso8601String().split('T')[0];
    final workInfoResponse = await http.get(
      Uri.parse('${Config.baseUrl}/api/attendance/v1/main/manager?workplace=$selectedWorkplaceId&localDate=$date'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (workInfoResponse.statusCode == 200) {
      setState(() {
        workInfoList = jsonDecode(workInfoResponse.body)['data'];
      });
    } else {
      print('Failed to load work info');
    }

    final noticeResponse = await http.get(
      Uri.parse('${Config.baseUrl}/api/announcement/v1/list/important?workplaceId=$selectedWorkplaceId'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (noticeResponse.statusCode == 200) {
      setState(() {
        notices = jsonDecode(noticeResponse.body)['data'];
      });
    } else {
      print('Failed to load notices');
    }
  }

  Future<void> _refreshData() async {
    await _initializeData();
  }

  void _onApprove(int attendanceRequestHistoryId) {
    print("승인 처리 ID: $attendanceRequestHistoryId");
  }

  void _previousDay() {
    setState(() {
      selectedDate = selectedDate.subtract(Duration(days: 1));
    });
    _initializeData();
  }

  void _nextDay() {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: 1));
    });
    _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    if (appState.selectedWorkplace.isEmpty) {
      WorkplaceManagementScreen.fetchWorkplaces(context);
    }
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
          title: Text(
            appState.selectedWorkplace,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkplaceManagementScreen(),
                  ),
                ).then((_) {
                  _initializeData(); // Update data after coming back from WorkplaceManagementScreen
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text('근무지 설정'),
            ),
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationScreen(isManager: true),
                  ),
                ).then((_) {
                  _refreshData(); // Refresh the data after returning from NotificationScreen
                });
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WorkplaceEmployeeList(),
                  _buildNoticeSection(), // Modified to use a separate method
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildNoticeSection() {
    if (notices.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Text(
            '등록된 공지사항이 없습니다',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      );
    } else {
      return NoticeSection(
        pageController: _pageController,
        currentNoticePage: _currentNoticePage,
        notices: notices.map((notice) => notice['title'] as String).toList(),
        onPageChanged: (index) {
          setState(() {
            _currentNoticePage = index;
          });
        },
      );
    }
  }
  Widget _buildWorkInfoCard(Map<String, dynamic> workInfo) {
    String name = workInfo['userName'];
    String totalHours = workInfo['totalWorkTime'].toString() + '시간';
    String checkInTime = workInfo['workStartTime'].split('T')[1].substring(0, 5);
    String checkOutTime = workInfo['workEndTime'].split('T')[1].substring(0, 5);
    String profileImagePath = workInfo['userImageUrl'];
    bool isApproved = workInfo['isRequestApprove'];
    int attendanceRequestHistoryId = workInfo['attendanceRequestHistoryId'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(profileImagePath),
                  radius: 20,
                ),
                SizedBox(width: 8),
                Text(
                  name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  isApproved ? '완료' : '미완료',
                  style: TextStyle(
                    color: isApproved ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('총 근무 시간: $totalHours'),
            SizedBox(height: 4),
            Text('출근 시간: $checkInTime'),
            SizedBox(height: 4),
            Text('퇴근 시간: $checkOutTime'),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _onApprove(attendanceRequestHistoryId),
                  child: Text(
                    '승인',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // 수정 로직 추가
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text('수정'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
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
      case 7:
        return '일요일';
      default:
        return '';
    }
  }
}
