import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'email_password_screen.dart';
import 'sign_up_data.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final SignUpData signUpData;

  const PhoneVerificationScreen({
    Key? key,
    required this.signUpData,
  }) : super(key: key);

  @override
  _PhoneVerificationScreenState createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final List<TextEditingController> _verificationCodeControllers = List.generate(6, (_) => TextEditingController());
  bool _isNextButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _verificationCodeControllers.forEach((controller) {
      controller.addListener(_checkButtonEnabled);
    });
  }

  @override
  void dispose() {
    _verificationCodeControllers.forEach((controller) {
      controller.dispose();
    });
    super.dispose();
  }

  void _checkButtonEnabled() {
    setState(() {
      _isNextButtonEnabled = _verificationCodeControllers.every((controller) => controller.text.isNotEmpty);
    });
  }

  Future<void> _verifyCode() async {
    final authCode = _verificationCodeControllers.map((controller) => controller.text).join();
    final url = Uri.parse('http://144.24.81.53:8080/api/users/sms-certification/confirm');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phoneNumber': widget.signUpData.phoneNumber,
        'authCode': authCode,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmailAndPasswordScreen(signUpData: widget.signUpData),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('인증에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('휴대폰 인증'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '인증번호를 입력해주세요',
              style: TextStyle(fontSize: 23.4, color: Colors.black, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32.0),
            Row(
              children: [
                for (int i = 0; i < 6; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: SizedBox(
                        height: 40.0,
                        child: TextField(
                          controller: _verificationCodeControllers[i],
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && i < 5) {
                              FocusScope.of(context).nextFocus();
                            }
                            _checkButtonEnabled();
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                // Handle when "인증번호를 못 받으셨습니까?" is tapped
              },
              child: const Text(
                '인증번호를 못 받으셨습니까?',
                style: TextStyle(fontSize: 14.0, color: Colors.blue),
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
            onPressed: _isNextButtonEnabled ? _verifyCode : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isNextButtonEnabled ? Colors.lightBlue : Colors.grey,
            ),
            child: const Text('확인'),
          ),
        ),
      ),
    );
  }
}
