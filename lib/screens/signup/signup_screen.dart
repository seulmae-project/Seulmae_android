import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../config.dart';
import 'email_password_screen.dart';
import 'sign_up_data.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();

  bool _isNextButtonEnabled = false;
  bool _isVerificationSent = false;
  bool _isSendingVerification = false;
  String? _verificationMessage;
  Timer? _timer;
  int _remainingSeconds = 180; // 3 minutes timer for verification

  @override
  void initState() {
    super.initState();
    _phoneNumberController.addListener(_checkNextButtonEnabled);
    _verificationCodeController.addListener(_checkNextButtonEnabled);
  }

  void _checkNextButtonEnabled() {
    setState(() {
      _isNextButtonEnabled = _phoneNumberController.text.isNotEmpty &&
          _isValidPhoneNumber(_phoneNumberController.text) &&
          (_isVerificationSent ? _verificationCodeController.text.isNotEmpty : true);
    });
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    final RegExp regex = RegExp(r'^\d{11}$');
    return regex.hasMatch(phoneNumber);
  }

  Future<void> _sendVerificationCode() async {
    setState(() {
      _isSendingVerification = true;
      _verificationMessage = "인증번호 전송 중...";
    });
    final url = Uri.parse('${Config.baseUrl}/api/users/sms-certification/send');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'phoneNumber': _phoneNumberController.text}),
    );
    if (response.statusCode == 200) {
      setState(() {
        _isVerificationSent = true;
        _verificationMessage = "인증번호가 발송되었습니다.";
        _startTimer();
      });
    } else {
      setState(() {
        _verificationMessage = "인증번호 발송에 실패했습니다. 다시 시도해주세요.";
      });
    }

    setState(() {
      _isSendingVerification = false;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = 180; // reset to 3 minutes
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          timer.cancel();
          _verificationMessage = "인증 시간이 만료되었습니다. 다시 시도해주세요.";
        }
      });
    });
  }

  Future<void> _verifyCodeAndProceed() async {
    final url = Uri.parse('${Config.baseUrl}/api/users/sms-certification/confirm');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phoneNumber': _phoneNumberController.text,
        'authCode': _verificationCodeController.text,
      }),
    );

    if (response.statusCode == 200) {
      final signUpData = SignUpData(
        name: '',
        phoneNumber: _phoneNumberController.text,
        isMale: false,
        birthday: '',
        accountId: '',
        password: '',
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmailAndPasswordScreen(signUpData: signUpData),
        ),
      );
    } else if (response.statusCode == 400) {  // Assuming 400 indicates a wrong code or expired
      setState(() {
        _verificationMessage = "인증번호가 올바르지 않거나 만료되었습니다. 다시 시도해주세요.";
      });
    } else {
      setState(() {
        _verificationMessage = "인증에 실패했습니다. 다시 시도해주세요.";
      });
    }
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _verificationCodeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '정보 확인을 위해\n휴대폰 번호를 입력해주세요',
              style: TextStyle(fontSize: 23.4, color: Colors.black, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(
                      labelText: '휴대폰 번호',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      counterText: '',
                    ),
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _isNextButtonEnabled && !_isSendingVerification
                      ? _sendVerificationCode
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isNextButtonEnabled && !_isSendingVerification
                        ? Colors.lightBlue
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    _isVerificationSent
                        ? '재전송'
                        : '인증번호 받기',
                  ),
                ),
              ],
            ),
            if (_isVerificationSent) ...[
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextField(
                          controller: _verificationCodeController,
                          decoration: InputDecoration(
                            labelText: '인증번호 입력',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            counterText: '',
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                        Positioned(
                          right: 10,
                          child: Text(
                            "${_remainingSeconds ~/ 60}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: _verificationCodeController.text.isNotEmpty ? _verifyCodeAndProceed : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _verificationCodeController.text.isNotEmpty ? Colors.lightBlue : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('인증'),
                  ),
                ],
              ),
            ],
            if (_verificationMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _verificationMessage!,
                  style: TextStyle(
                    fontSize: 14,
                    color: _verificationMessage!.contains("실패") ||
                        _verificationMessage!.contains("만료")
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}
