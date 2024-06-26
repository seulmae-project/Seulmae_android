import 'dart:async';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../manage/manage_mock_data.dart';
import '../workplace/workplace.dart';
import '../workplace/workplace_management_screen.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<EmployeeDashboardScreen> {
  DateTime? _currentBackPressTime;

  List<Workplace> workplaces = [
    Workplace(name: '근무지 A', phoneNumber: '031-1111-2222', address: '인천광역시 남구', profileImagePath: ''),
    Workplace(name: '근무지 B', phoneNumber: '032-2222-3333', address: '서울특별시 강남구', profileImagePath: ''),
    Workplace(name: '근무지 C', phoneNumber: '033-3333-4444', address: '부산광역시 해운대구', profileImagePath: ''),
  ];

  String selectedWorkplace = '근무지 A';

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  int _selectedIndex = 0;

  List<String> notices = [
    '공지사항 1',
    '공지사항 2',
    '공지사항 3',
  ];

  PageController _pageController = PageController();
  int _currentNoticePage = 0;
  Timer? _noticeTimer;

  final Map<DateTime, List<String>> _holidays = {
    DateTime.utc(2024, 1, 1): ['New Year\'s Day'],
    DateTime.utc(2024, 3, 1): ['삼일절'],
    DateTime.utc(2024, 5, 5): ['어린이날'],
    DateTime.utc(2024, 6, 6): ['현충일'],
    DateTime.utc(2024, 8, 15): ['광복절'],
    DateTime.utc(2024, 10, 3): ['개천절'],
    DateTime.utc(2024, 12, 25): ['Christmas Day'],
  };

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

  Future<void> _showAddWorkplaceDialog() async {
    TextEditingController workplaceController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('근무지 설정'),
          content: TextField(
            controller: workplaceController,
            decoration: InputDecoration(hintText: '근무지 이름을 입력하세요'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('추가'),
              onPressed: () {
                setState(() {
                  workplaces.add(workplaceController.text as Workplace);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return WillPopScope(
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
                  appState.setSelectedWorkplace(selectedWorkplace.name);
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
        body: Center(
          child: Column(
            children: <Widget>[
              Container(
                height: 50.0,
                color: Colors.blueAccent,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: notices.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentNoticePage = index;
                        });
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
                              _pageController.animateToPage(
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
                                color: _currentNoticePage == index
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '현재 근무자 상태',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Container(
                height: 80.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: morningShiftData.length + afternoonShiftData.length, // userProfiles로 변경
                  itemBuilder: (context, index) {
                    final profile = index < morningShiftData.length
                        ? morningShiftData[index]
                        : afternoonShiftData[index - morningShiftData.length];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage(profile['profileImage']), // 프로필 이미지 사용
                            backgroundColor: profile['status'] == 'Online'
                                ? Colors.green
                                : Colors.grey,
                          ),
                          SizedBox(height: 4),
                          Text(profile['name']),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '${appState.selectedWorkplace} 스케쥴',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
              ),
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
                  // Check if it's Sunday or a holiday
                  return day.weekday == DateTime.sunday ||
                      _holidays.containsKey(day);
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
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  child: Text(
                    _selectedDay != null
                        ? isWorkday(_selectedDay!)
                        ? '10:30 ~ 14:30 근무입니다!'
                        : '해당 날짜에 근무가 없습니다.'
                        : '날짜를 선택해 주세요.',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle 출근 & 퇴근 button press
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: Text('출근 & 퇴근'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isWorkday(DateTime dateTime) {
    // Define your logic to determine if it's a workday
    // Here is a placeholder
    return dateTime.weekday >= 1 && dateTime.weekday <= 5;
  }
}
