import 'package:flutter/material.dart';
import 'work_detail_screen.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> employeeData;

  const EmployeeDetailScreen({Key? key, required this.employeeData}) : super(key: key);

  @override
  _EmployeeDetailScreenState createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  late Map<String, dynamic> data;

  @override
  void initState() {
    super.initState();
    data = widget.employeeData;
  }

  void _updateWorkData(Map<String, dynamic> updatedWorkData) {
    setState(() {
      int index = data['workHistory'].indexWhere((work) => work['date'] == updatedWorkData['date']);
      if (index != -1) {
        data['workHistory'][index] = updatedWorkData;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final int totalWage = data['workHistory'].fold(0, (sum, work) => sum + (work['wage'] ?? 0));

    return Scaffold(
        appBar: AppBar(
        title: Text('알바생 디테일'),
    ),
    body: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Container(
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.circular(16.0),
    ),
    child: Row(
    children: [
    CircleAvatar(
    backgroundImage: AssetImage(data['profileImage'] ?? 'assets/images/default_profile.png'),
    radius: 30.0,
    ),
    SizedBox(width: 16.0),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    data['name'] ?? '이름 없음',
    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
    ),
    SizedBox(height: 8.0),
    Text('2024-04-01 가입'),
    SizedBox(height: 8.0),
    Row(
    children: [
    Expanded(child: Text('시급: ${data['hourlyWage'] ?? 0}원')),
    SizedBox(width: 16.0),
    Expanded(child: Text('근무일: ${data['workDays'] ?? '알 수 없음'}')),
    SizedBox(width: 16.0),
    Expanded(child: Text('월급일: ${data['payday'] ?? '알 수 없음'}일')),
    ],
    ),
    ],
    ),
    ),
    ],
    ),
    ),
    SizedBox(height: 16.0),
    Text(

      '이력 조회',
      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
    ),
      SizedBox(height: 8.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('시작일: ${data['startDate'] ?? '알 수 없음'}'),
          Text('종료일: ${data['endDate'] ?? '알 수 없음'}'),
        ],
      ),
      SizedBox(height: 16.0),
      Text(
        '총 합계: $totalWage원 - (보정액 9,000원)',
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 16.0),
      Expanded(
        child: ListView.builder(
          itemCount: data['workHistory'] != null ? (data['workHistory'] as List).length : 0,
          itemBuilder: (context, index) {
            final Map<String, dynamic> work = (data['workHistory'] as List)[index] as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkDetailScreen(employeeData: data, workData: work),
                    ),
                  );
                  if (result != null) {
                    _updateWorkData(result);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              work['date'] ?? '알 수 없음',
                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text('총 ${work['hours'] ?? 0}시간'),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('시간: ${work['startTime'] ?? '알 수 없음'} - ${work['endTime'] ?? '알 수 없음'}'),
                          Text('${work['wage'] ?? 0}원'),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Text('업무 내용: ${work['description'] ?? '없음'}'),
                      SizedBox(height: 8.0),
                      Text(
                        work['isApproved'] ? '승인됨' : '미승인',
                        style: TextStyle(
                          color: work['isApproved'] ? Colors.green : Colors.red,
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
    ),
    );
  }
}
