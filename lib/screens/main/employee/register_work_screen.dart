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
        title: Text('근무 등록', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              buildWageInfoCard(duration, totalWage),
              SizedBox(height: 16.0),
              buildInfoRow('근무일', DateFormat('MM월 dd일 (E)', 'ko_KR').format(_checkInTime)),
              SizedBox(height: 8.0),
              buildInfoRow('근무한 시간', '${DateFormat('HH:mm').format(_checkInTime)} ~ ${DateFormat('HH:mm').format(_checkOutTime)}'),
              SizedBox(height: 8.0),
              buildInfoRow('총 근무 시간', '${duration.inHours}시간 ${duration.inMinutes.remainder(60)}분'),
              SizedBox(height: 16.0),
              buildTextField(),
              SizedBox(height: 20.0),
              buildSaveButton(),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget buildWageInfoCard(Duration duration, double totalWage) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${duration.inHours}시간 ${duration.inMinutes.remainder(60)}분',
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
              Text(
                '시급 ${NumberFormat.currency(symbol: '₩').format(widget.hourlyWage)}',
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${NumberFormat.currency(symbol: '₩').format(totalWage)}',
              style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget buildTextField() {
    return TextField(
      maxLines: 4,
      decoration: InputDecoration(
        hintText: '전달사항을 입력해주세요',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // 저장 로직
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          '저장',
          style: TextStyle(fontSize: 18.0, color: Colors.white),
        ),
      ),
    );
  }
}