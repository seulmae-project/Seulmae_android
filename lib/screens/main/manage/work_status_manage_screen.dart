import 'package:flutter/material.dart';
import 'package:sm3/screens/main/manage/work_detail_screen.dart';
import '../constants.dart';
import 'employee_detail_screen.dart';
import 'manage_mock_data.dart'; // import mock data

class ManagerWorkStatusScreen extends StatefulWidget {
  const ManagerWorkStatusScreen({Key? key}) : super(key: key);

  @override
  _ManagerWorkStatusScreenState createState() => _ManagerWorkStatusScreenState();
}

class _ManagerWorkStatusScreenState extends State<ManagerWorkStatusScreen> {
  late DateTime _selectedMonth;
  late DateTime _currentMonth;
  List<Map<String, dynamic>> workData = [];
  int totalWage = 0;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _selectedMonth = DateTime(_currentMonth.year, _currentMonth.month);
    _loadMonthlyWorkData();
  }

  void _incrementMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      _loadMonthlyWorkData();
    });
  }

  void _decrementMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      _loadMonthlyWorkData();
    });
  }

  String _getFormattedMonth(DateTime dateTime) {
    return '${dateTime.year}년 ${AppConstants.months[dateTime.month - 1]}';
  }

  void _loadMonthlyWorkData() {
    workData = [];
    totalWage = 0;

    for (var employee in morningShiftData) {
      for (var work in employee['workHistory']) {
        DateTime workDate = DateTime.parse(work['date']);
        if (workDate.year == _selectedMonth.year && workDate.month == _selectedMonth.month) {
          int startHour = int.parse(work['startTime'].split(':')[0]);
          int endHour = int.parse(work['endTime'].split(':')[0]);
          int wage = ((endHour - startHour) * employee['hourlyWage']).toInt();
          totalWage += wage;

          workData.add({
            'date': workDate,
            'employeeName': employee['name'],
            'startTime': work['startTime'],
            'endTime': work['endTime'],
            'employeeData': employee,
            'workData': work,
            'totalWage': wage,
          });
        }
      }
    }

    for (var employee in afternoonShiftData) {
      for (var work in employee['workHistory']) {
        DateTime workDate = DateTime.parse(work['date']);
        if (workDate.year == _selectedMonth.year && workDate.month == _selectedMonth.month) {
          int startHour = int.parse(work['startTime'].split(':')[0]);
          int endHour = int.parse(work['endTime'].split(':')[0]);
          int wage = ((endHour - startHour) * employee['hourlyWage']).toInt();
          totalWage += wage;

          workData.add({
            'date': workDate,
            'employeeName': employee['name'],
            'startTime': work['startTime'],
            'endTime': work['endTime'],
            'employeeData': employee,
            'workData': work,
            'totalWage': wage,
          });
        }
      }
    }
  }

  void _updateWorkData(Map<String, dynamic> updatedWorkData) {
    setState(() {
      int index = workData.indexWhere((work) =>
      work['date'] == DateTime.parse(updatedWorkData['date']) &&
          work['employeeName'] == updatedWorkData['employeeName']);
      if (index != -1) {
        workData[index]['workData'] = updatedWorkData;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('근무 현황 (매니저)'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _decrementMonth,
                  icon: Icon(Icons.arrow_back),
                ),
                Text(
                  _getFormattedMonth(_selectedMonth),
                  style: TextStyle(fontSize: 18.0),
                ),
                IconButton(
                  onPressed: _incrementMonth,
                  icon: Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '총 합계: $totalWage원',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: workData.length,
              itemBuilder: (context, index) {
                DateTime date = workData[index]['date'];
                String employee = workData[index]['employeeName'];
                String startTime = workData[index]['startTime'];
                String endTime = workData[index]['endTime'];
                String formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => WorkDetailScreen(
                          employeeData: workData[index]['employeeData'],
                          workData: workData[index]['workData'],
                        ),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.ease;

                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );

                    if (result != null) {
                      _updateWorkData(result);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 3,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '날짜: $formattedDate',
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '직원: $employee',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '근무 시간: $startTime - $endTime',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          Text(
                            workData[index]['workData']['isApproved'] ? '승인됨' : '미승인',
                            style: TextStyle(
                              color: workData[index]['workData']['isApproved'] ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
