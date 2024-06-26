import 'dart:math';
import 'package:flutter/material.dart';

class WorkStatusScreen extends StatefulWidget {
  const WorkStatusScreen({Key? key}) : super(key: key);

  @override
  _WorkStatusScreenState createState() => _WorkStatusScreenState();
}

class _WorkStatusScreenState extends State<WorkStatusScreen> {
  late DateTime _selectedMonth; // Selected month
  late DateTime _currentMonth; // Current month

  final List<String> _months = [
    '1월', '2월', '3월', '4월', '5월', '6월',
    '7월', '8월', '9월', '10월', '11월', '12월'
  ];

  // Total hours worked
  int _totalHoursWorked = 0;

  // Total earnings for selected month
  double _totalEarnings = 0;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _selectedMonth = DateTime(_currentMonth.year, _currentMonth.month);
    _calculateTotalHoursWorked();
    _calculateTotalEarnings(); // Calculate total earnings initially
  }

  void _incrementMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      _calculateTotalHoursWorked();
      _calculateTotalEarnings();
    });
  }

  void _decrementMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      _calculateTotalHoursWorked();
      _calculateTotalEarnings();
    });
  }

  String _getFormattedMonth(DateTime dateTime) {
    return '${dateTime.year}년 ${_months[dateTime.month - 1]}';
  }

  void _calculateTotalHoursWorked() {
    // Simulating total hours worked calculation (dummy logic)
    _totalHoursWorked = Random().nextInt(80); // Assuming up to 80 hours
  }

  void _calculateTotalEarnings() {
    // Simulating total earnings calculation for the selected month
    _totalEarnings = 0;
    for (int i = 0; i < 30; i++) { // Assuming 30 days in a month for simplicity
      bool isWeekday = Random().nextBool(); // 평일 여부
      double hourlyRate = isWeekday ? 9900.0 : 15000.0; // 시급 (평일: 9,900원, 주말: 15,000원)
      int startHour = Random().nextInt(8) + 8; // 8시부터 16시까지 랜덤
      int endHour = startHour + Random().nextInt(4) + 4; // 최대 4시간 근무
      double dailyWage = hourlyRate * (endHour - startHour); // 하루 일당 계산
      _totalEarnings += dailyWage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('근무 현황'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [],
            ),
          ),
        ],
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
                  '${_getFormattedMonth(_selectedMonth)}',
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
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200], // 회색 배경
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '총합계',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Spacer(), // 왼쪽에 공간을 차지하여 오른쪽으로 밀어줌
                        Text(
                          '${_totalEarnings.toStringAsFixed(0)} 원',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // 10일
              itemBuilder: (context, index) {
                // Individual work status entries
                bool isWeekday = Random().nextBool(); // 평일 여부
                bool isHoliday = Random().nextBool(); // 공휴일 여부
                double hourlyRate = isWeekday ? 9900.0 : 15000.0; // 시급
                int startHour = Random().nextInt(8) + 8; // 8시부터 16시까지 랜덤
                int endHour = startHour + Random().nextInt(4) + 4; // 최대 4시간 근무
                double dailyWage = hourlyRate * (endHour - startHour); // 하루 일당 계산
                String startTime = '${startHour.toString().padLeft(2, '0')}:00';
                String endTime = '${endHour.toString().padLeft(2, '0')}:00';
                Color dayColor =
                isWeekday ? Colors.blue : (isHoliday || !isWeekday) ? Colors.red : Colors.black;
                String dayType = isWeekday ? '평일' : isHoliday ? '공휴일' : '주말';
                String date =
                    '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}-${(index + 1).toString().padLeft(2, '0')}';

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // 회색 배경
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayType,
                          style: TextStyle(fontSize: 18.0, color: dayColor),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('날짜: $date'),
                                SizedBox(height: 4),
                                Text('근무 시간: $startTime - $endTime'),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '시급: ${hourlyRate.toStringAsFixed(0)}원',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '일당: ${dailyWage.toStringAsFixed(0)} 원',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
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
