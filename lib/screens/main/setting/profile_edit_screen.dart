import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sm3/screens/main/setting/profile_image_picker.dart';
import 'dart:io';
import 'settings_screen.dart';

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedDate;
  bool _isButtonEnabled = false;
  File? _profileImage;

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _nameController.text.isNotEmpty &&
          _selectedGender != null &&
          _selectedDate != null;
    });
  }

  void _showWarningDialog() {
    String message;
    if (_nameController.text.isEmpty) {
      message = '이름을 입력해주세요.';
    } else if (_selectedGender == null) {
      message = '성별을 선택해주세요.';
    } else if (_selectedDate == null) {
      message = '생년월일을 선택해주세요.';
    } else {
      message = '모든 필드를 채워주세요.';
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('경고'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('알림'),
          content: Text('프로필 수정이 완료되었습니다.'),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 수정'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ProfileImagePicker(
              profileImage: _profileImage,
              onImagePicked: (image) {
                setState(() {
                  _profileImage = image;
                });
              },
            ),
            SizedBox(height: 24),
            Text(
              '이름',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: '이름',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              ),
              onChanged: (value) {
                _updateButtonState();
              },
            ),
            SizedBox(height: 16),
            Text(
              '성별',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Radio<String>(
                  value: '남성',
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                      _updateButtonState();
                    });
                  },
                ),
                Text('남성'),
                Radio<String>(
                  value: '여성',
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                      _updateButtonState();
                    });
                  },
                ),
                Text('여성'),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '생년월일',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            InkWell(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  locale: const Locale('ko', 'KR'), // 생년월일 선택창을 한국어로 설정
                );
                if (pickedDate != null && pickedDate != _selectedDate) {
                  setState(() {
                    _selectedDate = pickedDate;
                    _updateButtonState();
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  _selectedDate != null
                      ? '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일'
                      : '생년월일 선택',
                  style: TextStyle(
                    color: _selectedDate != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isButtonEnabled
                ? () {
              _showConfirmationDialog(context);
            }
                : _showWarningDialog,
            child: Text('다음으로'),
          ),
        ),
      ),
    );
  }
}
