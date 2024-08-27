import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import '../../../config.dart';
import '../../../providers/auth_provider.dart';

class JoinRequestDetailScreen extends StatefulWidget {
  final int workplaceApproveId;
  final String userName;
  final String requestDate;

  JoinRequestDetailScreen({
    required this.workplaceApproveId,
    required this.userName,
    required this.requestDate,
  });

  @override
  _JoinRequestDetailScreenState createState() => _JoinRequestDetailScreenState();
}

class _JoinRequestDetailScreenState extends State<JoinRequestDetailScreen> {
  List<Map<String, dynamic>> _workSchedules = [];
  int? _selectedScheduleId;
  final _paydayController = TextEditingController();
  final _baseWageController = TextEditingController();
  final _memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchWorkSchedules();
  }

  @override
  void dispose() {
    _paydayController.dispose();
    _baseWageController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _fetchWorkSchedules() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isTokenExpired()) {
      bool refreshed = await authProvider.refreshAccessToken();
      if (!refreshed) {
        throw Exception('토큰 갱신 실패');
      }
    }
    final selectedWorkplaceId = authProvider.selectedWorkplaceId;
    final accessToken = authProvider.accessToken;
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/api/schedule/v1/list?workplaceId=$selectedWorkplaceId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _workSchedules = List<Map<String, dynamic>>.from(data['data']);
      });
    } else {
      throw Exception('근무 일정 불러오기 실패');
    }
  }

  Future<void> approveRequest(BuildContext context) async {
    if (_selectedScheduleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('근무 일정을 선택하세요.')),
      );
      return;
    }

    final payday = int.tryParse(_paydayController.text);
    final baseWage = int.tryParse(_baseWageController.text);
    final memo = _memoController.text;

    if (payday == null || baseWage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('유효한 숫자를 입력하세요.')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isTokenExpired()) {
      bool refreshed = await authProvider.refreshAccessToken();
      if (!refreshed) {
        throw Exception('토큰 갱신 실패');
      }
    }

    final accessToken = authProvider.accessToken;
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/api/workplace/join/v1/approval'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'workplaceApproveId': widget.workplaceApproveId,
        'workplaceScheduleId': _selectedScheduleId,
        'payday': payday,
        'baseWage': baseWage,
        'memo': memo,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context); // 성공 시 화면 닫기
    } else {
      throw Exception('승인 요청 실패');
    }
  }

  Future<void> rejectRequest(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isTokenExpired()) {
      bool refreshed = await authProvider.refreshAccessToken();
      if (!refreshed) {
        throw Exception('토큰 갱신 실패');
      }
    }

    final accessToken = authProvider.accessToken;
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/api/workplace/join/v1/rejection?workplaceApproveId=${widget.workplaceApproveId}'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      Navigator.pop(context); // 성공 시 화면 닫기
    } else {
      throw Exception('거절 요청 실패');
    }
  }

  String formatDate(String date) {
    final inputFormat = DateFormat('yyyy-MM-dd');
    final outputFormat = DateFormat('yyyy년 M월 d일');
    final dateTime = inputFormat.parse(date);
    return outputFormat.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('가입 요청 상세'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이름: ${widget.userName}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 15),
            Text(
              '요청일: ${formatDate(widget.requestDate)}',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            Text(
              '근무 일정',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButton<int>(
                isExpanded: true,
                underline: SizedBox(),
                hint: Text('근무 일정을 선택하세요'),
                value: _selectedScheduleId,
                items: _workSchedules.map((schedule) {
                  return DropdownMenuItem<int>(
                    value: schedule['workScheduleId'],
                    child: Text('${schedule['workScheduleTitle']} (${schedule['startTime']} - ${schedule['endTime']})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedScheduleId = value;
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            _buildTextField(controller: _paydayController, label: '급여일', hintText: '급여일을 입력하세요 (예: 25)'),
            SizedBox(height: 15),
            _buildTextField(controller: _baseWageController, label: '기본 시급', hintText: '기본 시급을 입력하세요 (예: 10000)'),
            SizedBox(height: 15),
            _buildTextField(controller: _memoController, label: '메모', hintText: '메모를 입력하세요', maxLines: 5),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context: context,
                  label: '승인',
                  color: Colors.blueAccent,
                  onPressed: () => approveRequest(context),
                ),
                _buildActionButton(
                  context: context,
                  label: '거절',
                  color: Colors.redAccent,
                  onPressed: () => rejectRequest(context),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: TextStyle(color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: color,
        minimumSize: Size(140, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
