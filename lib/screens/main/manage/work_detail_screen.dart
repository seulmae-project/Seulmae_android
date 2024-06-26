import 'package:flutter/material.dart';

class WorkDetailScreen extends StatefulWidget {
  final Map<String, dynamic> employeeData;
  final Map<String, dynamic> workData;

  const WorkDetailScreen({Key? key, required this.employeeData, required this.workData}) : super(key: key);

  @override
  _WorkDetailScreenState createState() => _WorkDetailScreenState();
}

class _WorkDetailScreenState extends State<WorkDetailScreen> {
  late bool isApproved;

  @override
  void initState() {
    super.initState();
    isApproved = widget.workData['isApproved'] ?? false;
  }

  void _toggleApproval() {
    setState(() {
      isApproved = !isApproved;
      widget.workData['isApproved'] = isApproved;
    });
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context, widget.workData);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    int startHour = int.parse(widget.workData['startTime'].split(':')[0]);
    int endHour = int.parse(widget.workData['endTime'].split(':')[0]);
    int hourlyWage = widget.employeeData['hourlyWage'] ?? 0;
    int totalWage = (endHour - startHour) * hourlyWage;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('근무 상세 정보'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(widget.employeeData['profileImage'] ?? 'assets/images/default_profile.png'),
                    radius: 30.0,
                  ),
                  SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.employeeData['name'] ?? '이름 없음',
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      Text('시급: ${widget.employeeData['hourlyWage'] ?? 0}원'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Text(
                '${widget.employeeData['name']} 의 근무 기록',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('일자: ${widget.workData['date'] ?? '알 수 없음'}'),
                  Text('시간: ${widget.workData['startTime'] ?? '알 수 없음'} ~ ${widget.workData['endTime'] ?? '알 수 없음'}'),
                ],
              ),
              SizedBox(height: 16.0),
              Text('총 알바비: $totalWage원'),
              SizedBox(height: 16.0),
              Text('업무 내용: ${widget.workData['description'] ?? '없음'}'),
              SizedBox(height: 16.0),
              if (isApproved)
                Text(
                  '승인됨',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                )
              else
                Text(
                  '미승인',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: _toggleApproval,
            child: Text(isApproved ? '승인 취소' : '승인'),
          ),
        ),
      ),
    );
  }
}
