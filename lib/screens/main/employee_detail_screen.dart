import 'package:flutter/material.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final String employeeName;
  final String employeeImage;

  EmployeeDetailScreen({required this.employeeName, required this.employeeImage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알바생'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(employeeImage),
                  radius: 30.0,
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employeeName,
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      Text('2024-04-01 가입'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.0),
            Text(
              '근무 일정',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                return Flexible(
                  child: Chip(
                    label: Text(
                      ['월', '화', '수', '목', '금', '토', '일'][index],
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: index < 5 ? Colors.blue : Colors.grey,
                  ),
                );
              }),
            ),
            SizedBox(height: 24.0),
            Text(
              '이력 조회',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.0),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey.shade200,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('시작일'),
                      Text('2024.10.26 (금)'),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('종료일'),
                      Text('2024.11.03 (일)'),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('총 합계 (시급)'),
                      Text('621,000원'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.0),
            Text(
              '근무 기록',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.0),
            _buildHistoryItem('2024.01.01', '오전 10:00 - 오후 20:00', '8시간', '9,900원'),
            _buildHistoryItem('2024.01.02', '오전 10:00 - 오후 20:00', '8시간', '9,900원'),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String date, String time, String hours, String wage) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date),
              Text(hours),
            ],
          ),
          SizedBox(height: 4.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time),
              Text(wage),
            ],
          ),
        ],
      ),
    );
  }
}
