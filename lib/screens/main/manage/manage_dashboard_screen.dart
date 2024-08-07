import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../employee/employee_dashboard_screen.dart';
import '../workplace/workplace_entry_screen.dart';
import '../workplace/workplace_management_screen.dart';
import '../notification/notification_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _startNoticeTimer();
  }

  @override
  void dispose() {
    _noticeTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startNoticeTimer() {
    _noticeTimer = Timer.periodic(Duration(seconds: 7), (Timer timer) {
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

  void _onApprove() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (appState.currentBackPressTime == null || now.difference(appState.currentBackPressTime!) > Duration(seconds: 2)) {
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
                    builder: (context) =>
                        WorkplaceManagementScreen(workplaces: workplaces),
                  ),
                );
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
                    builder: (context) => NotificationScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EmployeeProfilePictures(),
                NoticeSection(
                  pageController: _pageController,
                  currentNoticePage: _currentNoticePage,
                  notices: notices,
                  onPageChanged: (index) {
                    setState(() {
                      _currentNoticePage = index;
                    });
                  },
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '금일의 근무를 확인해주세요',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _selectDate(context),
                      child: Text(
                        "${selectedDate.toLocal()}".split(' ')[0],
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Divider(thickness: 1.5),
                SizedBox(height: 8),
                Text(
                  '${selectedDate.month}월 ${selectedDate.day}일 (${_getWeekday(selectedDate.weekday)})',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              '미완료',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '3개',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              '완료',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '1개',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: workInfoList.length,
                  itemBuilder: (context, index) {
                    final workInfo = workInfoList[index];
                    return _buildWorkInfoCard(
                      workInfo['name']!,
                      workInfo['totalHours']!,
                      workInfo['checkInTime']!,
                      workInfo['checkOutTime']!,
                      workInfo['profileImagePath']!,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkInfoCard(String name, String totalHours, String checkInTime, String checkOutTime, String profileImagePath) {
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
                  backgroundImage: AssetImage(profileImagePath),
                  radius: 20,
                ),
                SizedBox(width: 8),
                Text(
                  name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  '미완료',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '총 시간: $totalHours',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              '출근: $checkInTime',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              '퇴근: $checkOutTime',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text('승인'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
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

const workInfoList = [
  {
    'name': '조원호',
    'totalHours': '10시간',
    'checkInTime': 'AM 10:20',
    'checkOutTime': 'PM 20:20',
    'profileImagePath': 'assets/profile_image_1.png',
  },
  {
    'name': '김영호',
    'totalHours': '10시간',
    'checkInTime': 'AM 10:20',
    'checkOutTime': 'PM 20:20',
    'profileImagePath': 'assets/profile_image_1.png',
  },
  // 더 많은 근무 정보를 추가하세요.
];
