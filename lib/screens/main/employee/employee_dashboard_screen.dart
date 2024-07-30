import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';  // intl 패키지 import 추가
import '../employee_detail_screen.dart';
import '../notification/notification_screen.dart';
import '../workplace/workplace.dart';
import '../workplace/workplace_entry_screen.dart';
import '../app_state.dart';
import '../workplace/workplace_management_screen.dart';
import 'check_in_out.dart';
import 'check_in_out_widget.dart';

final List<String> notices = [
  '공지사항 1',
  '공지사항 2',
  '공지사항 3',
];

final Map<DateTime, List<String>> _holidays = {
  DateTime.utc(2024, 1, 1): ['New Year\'s Day'],
  DateTime.utc(2024, 3, 1): ['삼일절'],
  DateTime.utc(2024, 5, 5): ['어린이날'],
  DateTime.utc(2024, 6, 6): ['현충일'],
  DateTime.utc(2024, 8, 15): ['광복절'],
  DateTime.utc(2024, 10, 3): ['개천절'],
  DateTime.utc(2024, 12, 25): ['Christmas Day'],
};

final Map<DateTime, int> dailyAmounts = {
  DateTime.utc(2024, 7, 1): 20000,
  DateTime.utc(2024, 7, 2): 20000,
  DateTime.utc(2024, 7, 3): 20000,
  DateTime.utc(2024, 7, 4): 20000,
  DateTime.utc(2024, 7, 8): 10000,
  DateTime.utc(2024, 7, 9): 20000,
  DateTime.utc(2024, 7, 10): 50000,
  DateTime.utc(2024, 7, 11): 11000,
  DateTime.utc(2024, 7, 12): 11000,
  DateTime.utc(2024, 7, 15): 50000,
  DateTime.utc(2024, 7, 16): 20000,
  DateTime.utc(2024, 7, 17): 20000,
  DateTime.utc(2024, 7, 18): 20000,
  DateTime.utc(2024, 7, 19): 20000,
  DateTime.utc(2024, 7, 20): 20000,
  DateTime.utc(2024, 7, 21): 20000,
  DateTime.utc(2024, 7, 22): 20000,
  DateTime.utc(2024, 7, 23): 20000,
  DateTime.utc(2024, 7, 24): 50000,
  DateTime.utc(2024, 7, 25): 50000,
  DateTime.utc(2024, 7, 26): 20000,
  DateTime.utc(2024, 7, 27): 20000,
  DateTime.utc(2024, 7, 28): 20000,
  DateTime.utc(2024, 7, 29): 20000,
  DateTime.utc(2024, 7, 30): 20000,
  DateTime.utc(2024, 7, 31): 1000,
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
    _noticeTimer = Timer.periodic(Duration(seconds: 10), (Timer timer) {
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

    return ChangeNotifierProvider(
      create: (_) => CheckInOut(),
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: _buildAppBar(context, appState),
          body: Column(
            children: <Widget>[
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: _buildCalendar(),
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

  TableCalendar _buildCalendar() {
    return TableCalendar(
      locale: 'ko_KR',
      focusedDay: _focusedDay,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {
        CalendarFormat.month: ''
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      holidayPredicate: (day) {
        return day.weekday == DateTime.sunday ||
            _holidays.containsKey(day);
      },
      calendarBuilders: CalendarBuilders(
        dowBuilder: (context, day) {
          final text = DateFormat.E('ko_KR').format(day);

          return Center(
            child: Text(
              text,
              style: TextStyle(
                color: day.weekday == DateTime.saturday ||
                    day.weekday == DateTime.sunday
                    ? Colors.red
                    : Colors.black,
              ),
            ),
          );
        },
        defaultBuilder: (context, date, _) {
          return _buildCalendarCell(date, Colors.white, Colors.black);
        },
        selectedBuilder: (context, date, _) {
          return _buildCalendarCell(date, Colors.blue, Colors.white);
        },
        holidayBuilder: (context, date, _) {
          return _buildCalendarCell(date, Colors.redAccent, Colors.white);
        },
      ),
      calendarStyle: CalendarStyle(
        holidayTextStyle: TextStyle(color: Colors.white),
        holidayDecoration: BoxDecoration(
          color: Colors.redAccent,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(6.0),
        ),
        weekendTextStyle: TextStyle(color: Colors.white),
        weekendDecoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(6.0),
        ),
      ),
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
    );
  }

  Widget _buildCalendarCell(DateTime date, Color bgColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 16.0,
              color: textColor,
            ),
          ),
          if (dailyAmounts.containsKey(date) && dailyAmounts[date]! > 0)
            Text(
              '${dailyAmounts[date]}',
              style: TextStyle(
                fontSize: 12,
                color: textColor == Colors.black ? Colors.blue : textColor,
              ),
            ),
        ],
      ),
    );
  }
}

class EmployeeProfilePictures extends StatelessWidget {
  final List<Map<String, String>> employees = [
    {'name': 'Employee 1', 'image': 'assets/profile_image_1.png'},
    {'name': 'Employee 2', 'image': 'assets/profile_image_2.png'},
    {'name': 'Employee 3', 'image': 'assets/profile_image_3.png'},
    {'name': 'Employee 4', 'image': 'assets/profile_image_4.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(employees.length, (index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmployeeDetailScreen(
                    employeeName: employees[index]['name']!,
                    employeeImage: employees[index]['image']!,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: CircleAvatar(
                backgroundImage: AssetImage(employees[index]['image']!),
                radius: 20.0,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class NoticeSection extends StatelessWidget {
  final PageController pageController;
  final int currentNoticePage;
  final List<String> notices;
  final Function(int) onPageChanged;

  NoticeSection({
    required this.pageController,
    required this.currentNoticePage,
    required this.notices,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
              spreadRadius: 2.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  notices.length,
                      (index) => GestureDetector(
                    onTap: () {
                      pageController.jumpToPage(index);
                      onPageChanged(index);
                    },
                    child: Container(
                      width: 8.0,
                      height: 8.0,
                      margin: EdgeInsets.symmetric(horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentNoticePage == index
                            ? Colors.grey
                            : Colors.black12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 50.0,
              child: PageView.builder(
                controller: pageController,
                itemCount: notices.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, index) {
                  return Center(
                    child: Text(
                      notices[index],
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
