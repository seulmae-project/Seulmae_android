import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import '../../../config.dart';
import '../../../providers/auth_provider.dart';

class PhoneNumberChangeScreen extends StatefulWidget {
  @override
  _PhoneNumberChangeScreenState createState() => _PhoneNumberChangeScreenState();
}

class _PhoneNumberChangeScreenState extends State<PhoneNumberChangeScreen> {
  late TextEditingController _phoneNumberController;
  bool _isNextButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _phoneNumberController = TextEditingController();
    _phoneNumberController.addListener(_updateNextButtonState);
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _updateNextButtonState() {
    setState(() {
      _isNextButtonEnabled = _phoneNumberController.text.length == 11;
    });
  }

  Future<void> _changePhoneNumber() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check and refresh token if expired
    if (authProvider.isTokenExpired()) {
      bool refreshed = await authProvider.refreshAccessToken();
      if (!refreshed) {
        throw Exception('Failed to refresh token');
      }
    }

    final accessToken = authProvider.accessToken;
    final url = Uri.parse('${Config.baseUrl}/api/users/phone?id=1');
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'phoneNumber': _phoneNumberController.text,
    });

    try {
      final response = await http.put(url, headers: headers, body: body);
      print(response.body);
      if (response.statusCode == 201) {
        // Success
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('변경 완료'),
            content: Text('휴대전화번호 변경이 완료되었습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('확인'),
              ),
            ],
          ),
        );
      } else if (response.statusCode == 401) {
        // Unauthorized
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('인증 오류'),
            content: Text('인증에 실패했습니다. 다시 로그인해주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('확인'),
              ),
            ],
          ),
        );
      } else {
        // General error
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('오류 발생'),
            content: Text('전화번호 변경 중 오류가 발생했습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('확인'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Network error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('네트워크 오류'),
          content: Text('전화번호 변경 중 네트워크 오류가 발생했습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('전화번호 변경'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '휴대폰 번호',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                hintText: '휴대폰 번호',
                counterText: '',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
              keyboardType: TextInputType.phone,
              maxLength: 11,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isNextButtonEnabled ? _changePhoneNumber : null,
            child: const Text('전화번호 변경'),
          ),
        ),
      ),
    );
  }
}
