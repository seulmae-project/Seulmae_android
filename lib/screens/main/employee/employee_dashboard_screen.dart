import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // intl package import 추가
import '../employee_detail_screen.dart';
import '../manage/workplace_employee_list.dart';
import '../notification/notice_section.dart';
import '../notification/notification_screen.dart';
import '../workplace/workplace.dart';
import '../workplace/workplace_entry_screen.dart';
import '../app_state.dart';
import '../workplace/workplace_management_screen.dart';
import 'check_in_out.dart';
import 'check_in_out_widget.dart';

final Map<DateTime, int> dailyAmounts = {
  DateTime.utc(2024, 8, 1): 20000,
  DateTime.utc(2024, 8, 26): 20000
};

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({Key? key}) : super(key: key);

  @override
  _EmployeeDashboardScreenState createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  DateTime? _currentBackPressTime;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  PageController _pageController = PageController();
  int _currentNoticePage = 0;
  Timer? _noticeTimer;
  List<dynamic> notices = [];

  @override
  void initState() {
    super.initState();
    _startNoticeTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _noticeTimer?.cancel();
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

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    if (appState.selectedWorkplace.isEmpty) {
      WorkplaceManagementScreen.fetchWorkplaces(context);
    }
    return ChangeNotifierProvider(
      create: (_) => CheckInOut(),
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: _buildAppBar(context, appState),
          body: Column(
            children: <Widget>[
              WorkplaceEmployeeList(),
              _buildNoticeSection(), // Modified to use a separate method
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: CheckInOutWidget(),
              ),
            ],
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

  AppBar _buildAppBar(BuildContext context, AppState appState) {
    return AppBar(
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
                builder: (context) => NotificationScreen(isManager: false),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();

    if (_currentBackPressTime == null ||
        now.difference(_currentBackPressTime!) > Duration(seconds: 2)) {
      _currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('한 번 더 누르시면 앱이 종료됩니다.'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }

    return true;
  }
}
