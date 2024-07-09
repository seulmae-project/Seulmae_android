import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../workplace/workplace.dart';
import '../workplace/workplace_entry_screen.dart';
import '../app_state.dart';
import '../workplace/workplace_management_screen.dart';
import 'check_in_out.dart';  // 새로 추가된 파일을 임포트
import 'check_in_out_widget.dart';  // 새로 추가된 파일을 임포트

// notices 정의
final List<String> notices = [
  '공지사항 1',
  '공지사항 2',
  '공지사항 3',
];

// _holidays 정의
final Map<DateTime, List<String>> _holidays = {
  DateTime.utc(2024, 1, 1): ['New Year\'s Day'],
  DateTime.utc(2024, 3, 1): ['삼일절'],
  DateTime.utc(2024, 5, 5): ['어린이날'],
  DateTime.utc(2024, 6, 6): ['현충일'],
  DateTime.utc(2024, 8, 15): ['광복절'],
  DateTime.utc(2024, 10, 3): ['개천절'],
  DateTime.utc(2024, 12, 25): ['Christmas Day'],
};

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({Key? key}) : super(key: key);

  @override
  _EmployeeDashboardScreenState createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  DateTime? _currentBackPressTime;
  CalendarFormat _calendarFormat = CalendarFormat.month;
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
            title: const Text('메인'),
            automaticallyImplyLeading: false,
            actions: [
              PopupMenuButton<Workplace>(
                onSelected: (Workplace selectedWorkplace) {
                  if (selectedWorkplace.name == '근무지 설정') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkplaceManagementScreen(workplaces: workplaces),
                      ),
                    );
                  } else {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      appState.setSelectedWorkplace(selectedWorkplace.name);
                    });
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    ...workplaces.map((Workplace workplace) {
                      return PopupMenuItem<Workplace>(
                        value: workplace,
                        child: Text(workplace.name),
                      );
                    }).toList(),
                    PopupMenuItem<Workplace>(
                      value: Workplace(name: '근무지 설정', phoneNumber: '', address: '', profileImagePath: ''),
                      child: Text('근무지 설정'),
                    ),
                  ];
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                children: <Widget>[
                  EmployeeStatusSection(),
                  NoticeSection(
                    pageController: _pageController,
                    currentNoticePage: _currentNoticePage,
                    notices: notices,
                  ),
                  ScheduleSection(appState: appState),
                  TableCalendar(
                    locale: 'ko_KR',
                    calendarFormat: _calendarFormat,
                    focusedDay: _focusedDay,
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
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
                    ),
                    holidayPredicate: (day) {
                      return day.weekday == DateTime.sunday || _holidays.containsKey(day);
                    },
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
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    alignment: Alignment.center,
                    child: Consumer<CheckInOut>(
                      builder: (context, checkInOut, child) {
                        return Text(
                          _selectedDay != null
                              ? isWorkday(_selectedDay!)
                              ? '${DateFormat('HH:mm').format(checkInOut.workStartTime)} ~ ${DateFormat('HH:mm').format(checkInOut.workEndTime)} 근무입니다!'
                              : '해당 날짜에 근무가 없습니다.'
                              : '날짜를 선택해 주세요.',
                          style: TextStyle(fontSize: 18.0),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Consumer<CheckInOut>(
            builder: (context, checkInOut, child) {
              return CheckInOutWidget();
            },
          ),
        ),
      ),
    );
  }

  bool isWorkday(DateTime dateTime) {
    return dateTime.weekday >= 1 && dateTime.weekday <= 5;
  }
}

class EmployeeStatusSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '현재 근무자 상태',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
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
      padding: const EdgeInsets.all(16.0),
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
                        color: currentNoticePage == index ? Colors.white : Colors.grey,
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

class ScheduleSection extends StatelessWidget {
  final AppState appState;

  ScheduleSection({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        '${appState.selectedWorkplace} 스케쥴',
        style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      ),
    );
  }
}
