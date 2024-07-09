import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegisterWorkScreen extends StatefulWidget {
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final int hourlyWage;
  final String workplace;

  RegisterWorkScreen({
    this.checkInTime,
    this.checkOutTime,
    required this.hourlyWage,
    required this.workplace,
  });

  @override
  _RegisterWorkScreenState createState() => _RegisterWorkScreenState();
}

class _RegisterWorkScreenState extends State<RegisterWorkScreen> {
  late DateTime _checkInTime;
  late DateTime _checkOutTime;

  @override
  void initState() {
    super.initState();
    _checkInTime = widget.checkInTime ?? DateTime.now();
    _checkOutTime = widget.checkOutTime ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final duration = _checkOutTime.difference(_checkInTime);
    final totalWage = (duration.inSeconds / 3600) * widget.hourlyWage;

    return Scaffold(
      appBar: AppBar(
        title: Text('근무 등록'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '근무지: ${widget.workplace}',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              '시급: ${NumberFormat.currency(symbol: '₩').format(widget.hourlyWage)}',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              '총 급여: ${NumberFormat.currency(symbol: '₩').format(totalWage)}',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Divider(),
            SizedBox(height: 16.0),
            Text(
              '근무일: ${DateFormat('MM월 dd일 (EEE)', 'ko_KR').format(_checkInTime)}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text(
              '근무시간: ${DateFormat('HH:mm').format(_checkInTime)} ~ ${DateFormat('HH:mm').format(_checkOutTime)}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Divider(),
            SizedBox(height: 16.0),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '메모를 입력해주세요',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 저장 로직
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Text(
                  '저장',
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
