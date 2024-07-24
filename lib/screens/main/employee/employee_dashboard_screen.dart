import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../employee_detail_screen.dart';
import '../notification/notification_screen.dart';
import '../workplace/workplace.dart';
import '../workplace/workplace_entry_screen.dart';
import '../app_state.dart';
import '../workplace/workplace_management_screen.dart';
import 'check_in_out.dart';
import 'check_in_out_widget.dart';

// 공지사항 목록 정의
final List<String> notices = [
  '공지사항 1',
  '공지사항 2',
  '공지사항 3',
];

// 휴일 목록 정의
final Map<DateTime, List<String>> _holidays = {
  DateTime.utc(2024, 1, 1): ['New Year\'s Day'],
  DateTime.utc(2024, 3, 1): ['삼일절'],
  DateTime.utc(2024, 5, 5): ['어린이날'],
  DateTime.utc(2024, 6, 6): ['현충일'],
  DateTime.utc(2024, 8, 15): ['광복절'],
  DateTime.utc(2024, 10, 3): ['개천절'],
  DateTime.utc(2024, 12, 25): ['Christmas Day'],
};

// 일별 금액 정의
final Map<DateTime, int> dailyAmounts = {
  DateTime.utc(2024, 7, 1): 20000,
  DateTime.utc(2024, 7, 2): 20000,
  DateTime.utc(2024, 7, 3): 20000,
  DateTime.utc(2024, 7, 4): 20000,
  DateTime.utc(2024, 7, 5): 0,
  DateTime.utc(2024, 7, 6): 0,
  DateTime.utc(2024, 7, 7): 0,
  DateTime.utc(2024, 7, 8): 10000,
  DateTime.utc(2024, 7, 9): 20000,
  DateTime.utc(2024, 7, 10): 50000,
  DateTime.utc(2024, 7, 11): 11000,
  DateTime.utc(2024, 7, 12): 11000,
  DateTime.utc(2024, 7, 14): 0,
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
        onWillPop: () async {
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
          body: Column(
            children: <Widget>[
              EmployeeProfilePictures(),
              NoticeSection(
                pageController: _pageController,
                currentNoticePage: _currentNoticePage,
                notices: notices,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    // 높이를 조절하고 싶다면 이 부분을 수정하면 됩니다.
                    height: MediaQuery.of(context).size.height * 1, // 화면 높이의 60%로 설정
                    child: TableCalendar(
                      locale: 'ko_KR',
                      focusedDay: _focusedDay,
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      calendarFormat: CalendarFormat.month, // 월간 보기로 고정
                      availableCalendarFormats: const {
                        CalendarFormat.month: ''
                      }, // 다른 형식 옵션 제거
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
                        formatButtonVisible: false, // format 버튼 숨기기
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
                        defaultBuilder: (context, date, _) {
                          return Column(
                            children: [
                              Text('${date.day}'),
                              if (dailyAmounts.containsKey(date))
                                Text(
                                  '${dailyAmounts[date]}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: dailyAmounts[date]! > 0
                                        ? Colors.blue
                                        : Colors.red,
                                  ),
                                ),
                            ],
                          );
                        },
                        selectedBuilder: (context, date, _) {
                          return Container(
                            margin: const EdgeInsets.all(4.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${date.day}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                if (dailyAmounts.containsKey(date))
                                  Text(
                                    '${dailyAmounts[date]}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      calendarStyle: CalendarStyle(
                        holidayTextStyle: TextStyle(color: Colors.red),
                        holidayDecoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        weekendTextStyle: TextStyle(color: Colors.blue),
                        weekendDecoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                        });
                      },
                    ),
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

  bool isWorkday(DateTime dateTime) {
    return dateTime.weekday >= 1 && dateTime.weekday <= 5;
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
      padding: const EdgeInsets.all(8.0), // padding을 줄여서 여백 최소화
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

  NoticeSection({
    required this.pageController,
    required this.currentNoticePage,
    required this.notices,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0), // padding을 줄여서 여백 최소화
      child: Container(
        height: 50.0,
        color: Colors.blueAccent,
        child: Stack(
          children: [
            PageView.builder(
              controller: pageController,
              itemCount: notices.length,
              onPageChanged: (index) {
                // Set the current notice page in the state
              },
              itemBuilder: (context, index) {
                return Center(
                  child: Text(
                    notices[index],
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 8.0,
              left: 0.0,
              right: 0.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  notices.length,
                      (index) => GestureDetector(
                    onTap: () {
                      pageController.animateToPage(
                        index,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                    child: Container(
                      width: 8.0,
                      height: 8.0,
                      margin: EdgeInsets.symmetric(horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentNoticePage == index
                            ? Colors.white
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
