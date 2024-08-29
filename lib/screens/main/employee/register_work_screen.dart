import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as fd_picker;
import 'package:flutter_datetime_picker_plus/src/datetime_picker_theme.dart' as fd_theme;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../config.dart';
import '../../../providers/auth_provider.dart';
import 'package:http/http.dart' as http;

class RegisterWorkScreen extends StatefulWidget {
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final int hourlyWage;
  final String workplace;
  final int workplaceId; // Added workplaceId parameter

  RegisterWorkScreen({
    this.checkInTime,
    this.checkOutTime,
    required this.hourlyWage,
    required this.workplace,
    required this.workplaceId,
  });

  @override
  _RegisterWorkScreenState createState() => _RegisterWorkScreenState();
}

class _RegisterWorkScreenState extends State<RegisterWorkScreen> {
  late DateTime _checkInTime;
  late DateTime _checkOutTime;
  final TextEditingController _remarksController = TextEditingController();

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
              buildSaveButton(context, totalWage, duration.inMinutes / 60), // Update button to include parameters
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
      controller: _remarksController,
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

  Widget buildSaveButton(BuildContext context, double totalWage, double totalWorkTime) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => submitAttendance(context, totalWage, totalWorkTime),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          '저장',
          style: TextStyle(fontSize: 18.0, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> submitAttendance(BuildContext context, double totalWage, double totalWorkTime) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isTokenExpired()) {
      bool refreshed = await authProvider.refreshAccessToken();
      if (!refreshed) {
        _showMessageDialog(context, '세션을 새로 고칠 수 없습니다. 다시 로그인 해주세요.');
        return;
      }
    }

    final accessToken = authProvider.accessToken;
    final requestBody = jsonEncode({
      'workplaceId': widget.workplaceId,  // This must match the integer type expected by the API
      'workDate': DateFormat('yyyy-MM-dd').format(_checkInTime), // Correct format for date without time
      'workStartTime': _checkInTime.toIso8601String(),  // Correct ISO8601 format for time
      'workEndTime': _checkOutTime.toIso8601String(),  // Correct ISO8601 format for time
      'unconfirmedWage': totalWage.toInt(),  // Converted to integer as required
      'totalWorkTime': totalWorkTime,  // Keep it as a double to represent hours
    });

    print('Request Body: $requestBody'); // Debugging

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/attendance/v1/finish'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showMessageDialog(context, '출근 정보가 성공적으로 등록되었습니다.');
      } else {
        _showMessageDialog(context, '출근 정보 등록에 실패했습니다: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      _showMessageDialog(context, '출근 정보 등록 중 오류가 발생했습니다: $e');
    }
  }

  void _showMessageDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('알림'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
