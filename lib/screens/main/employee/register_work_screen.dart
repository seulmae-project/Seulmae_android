import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as fd_picker;
import 'package:flutter_datetime_picker_plus/src/datetime_picker_theme.dart' as fd_theme;
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
        title: Text('근무 등록', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              buildWageInfoCard(duration, totalWage),
              SizedBox(height: 20.0),
              buildInfoRowWithPicker('근무일', DateFormat('MM월 dd일 (E)', 'ko_KR').format(_checkInTime), Icons.calendar_today, () {
                showDatePickerDialog(context);
              }),
              SizedBox(height: 12.0),
              buildInfoRowWithPicker('근무한 시간', '${DateFormat('HH:mm').format(_checkInTime)} ~ ${DateFormat('HH:mm').format(_checkOutTime)}', Icons.access_time, () {
                showTimeRangePickerDialog(context);
              }),
              SizedBox(height: 12.0),
              buildInfoRow('총 근무 시간', '${duration.inHours}시간 ${duration.inMinutes.remainder(60)}분'),
              SizedBox(height: 20.0),
              buildTextField(),
              SizedBox(height: 30.0),
              buildSaveButton(context),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  void showDatePickerDialog(BuildContext context) {
    fd_picker.DatePicker.showDatePicker(
      context,
      locale: fd_picker.LocaleType.ko,
      showTitleActions: true,
      minTime: DateTime(2000, 1, 1),
      maxTime: DateTime(2100, 12, 31),
      onConfirm: (date) {
        setState(() {
          _checkInTime = DateTime(date.year, date.month, date.day, _checkInTime.hour, _checkInTime.minute);
          _checkOutTime = DateTime(date.year, date.month, date.day, _checkOutTime.hour, _checkOutTime.minute);
        });
      },
      currentTime: _checkInTime,
      theme: fd_theme.DatePickerTheme(),
    );
  }

  void showTimeRangePickerDialog(BuildContext context) async {
    fd_picker.DatePicker.showTimePicker(
      context,
      showTitleActions: true,
      onConfirm: (time) {
        setState(() {
          _checkInTime = DateTime(_checkInTime.year, _checkInTime.month, _checkInTime.day, time.hour, time.minute);
        });

        fd_picker.DatePicker.showTimePicker(
          context,
          showTitleActions: true,
          onConfirm: (endTime) {
            setState(() {
              _checkOutTime = DateTime(_checkOutTime.year, _checkOutTime.month, _checkOutTime.day, endTime.hour, endTime.minute);
            });
          },
          currentTime: _checkOutTime,
          locale: fd_picker.LocaleType.ko,
          theme: fd_theme.DatePickerTheme(),
        );
      },
      currentTime: _checkInTime,
      locale: fd_picker.LocaleType.ko,
      theme: fd_theme.DatePickerTheme(),
    );
  }

  Widget buildWageInfoCard(Duration duration, double totalWage) {
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${duration.inHours}시간 ${duration.inMinutes.remainder(60)}분',
                style: TextStyle(fontSize: 16.0, color: Colors.black54),
              ),
              Text(
                '시급 ${NumberFormat.currency(symbol: '₩').format(widget.hourlyWage)}',
                style: TextStyle(fontSize: 16.0, color: Colors.black54),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${NumberFormat.currency(symbol: '₩').format(totalWage)}',
              style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRowWithPicker(String title, String value, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.black54),
                SizedBox(width: 10.0),
                Text(
                  title,
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(fontSize: 16.0, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
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
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.all(16.0),
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
    );
  }

  Widget buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // 저장 로직 추가
          // 저장 후 특정 화면으로 이동하는 로직 추가
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          '저장',
          style: TextStyle(fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
