import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:sm3/screens/main/settings_screen.dart';

class PhoneNumberChangeScreen extends StatefulWidget {
  @override
  _PhoneNumberChangeScreenState createState() => _PhoneNumberChangeScreenState();
}

class _PhoneNumberChangeScreenState extends State<PhoneNumberChangeScreen> {
  late TextEditingController _phoneNumberController;
  late TextEditingController _verificationCodeController;

  bool _isVerificationCodeSent = false;
  bool _isNextButtonEnabled = false;
  bool _isResendEnabled = false;
  int _resendSeconds = 180; // 3분 = 180초
  Timer? _timer;
  bool _sendButtonEnabled = false;
  bool _resendButtonActive = true;

  @override
  void initState() {
    super.initState();
    _phoneNumberController = TextEditingController();
    _verificationCodeController = TextEditingController(text: '');

    _phoneNumberController.addListener(_validateFields);
    _updateSendButtonState();
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _verificationCodeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _validateFields() {
    setState(() {
      bool isPhoneNumberValid = _isNumeric(_phoneNumberController.text);

      _isResendEnabled = isPhoneNumberValid;

      _isNextButtonEnabled = isPhoneNumberValid &&
          (_isVerificationCodeSent || _verificationCodeController.text.length == 6);

      if (_isVerificationCodeSent && isPhoneNumberValid) {
        _resendButtonActive = true;
      }
    });
  }

  bool _isNumeric(String str) {
    if (str.isEmpty) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  void _updateSendButtonState() {
    setState(() {
      _sendButtonEnabled = _phoneNumberController.text.length == 11;
      _resendButtonActive = _phoneNumberController.text.length == 11;
    });
  }

  void _sendVerificationCode() {
    setState(() {
      _isVerificationCodeSent = true;
      _isResendEnabled = false;
      _resendButtonActive = false;
      _resendSeconds = 180; // 타이머 3분으로 설정
      _startResendTimer();
      _verificationCodeController.text = ''; // Clear the verification code input
      _updateSendButtonState();
    });
    // TODO: Implement the actual code sending logic
  }

  void _startResendTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
          if (_resendSeconds <= 20) { // 2분 40초가 지난 후 재전송 버튼 활성화
            _isResendEnabled = true;
            if (_phoneNumberController.text.length == 11) {
              _resendButtonActive = true;
            }
          }
        } else {
          _isResendEnabled = true;
          if (_phoneNumberController.text.length == 11) {
            _resendButtonActive = true;
          }
          timer.cancel();
        }
      });
    });
  }

  String _formatTimer(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _verifyCode() {
    // TODO: Implement the actual verification logic
    setState(() {
      _isNextButtonEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true; // 뒤로 가기 허용
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('전화번호 변경'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '전화번호를 변경하려면\n휴대폰 번호와 인증번호를 입력하세요',
                style: TextStyle(fontSize: 23.4, color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '휴대폰 번호',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: TextFormField(
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
                          onChanged: (value) {
                            _updateSendButtonState();
                          },
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _resendButtonActive && _isResendEnabled ? _sendVerificationCode : null,
                          child: Text(_isVerificationCodeSent ? '재전송' : '전송'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _resendButtonActive && _isResendEnabled ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              if (_isVerificationCodeSent) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '인증번호',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              TextField(
                                controller: _verificationCodeController,
                                decoration: InputDecoration(
                                  hintText: '인증번호 6자리 입력',
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
                                maxLength: 6,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  if (value.length == 6) {
                                    _verifyCode();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _formatTimer(_resendSeconds),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ],
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isNextButtonEnabled
                  ? () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('변경 완료'),
                    content: Text('휴대전화번호 변경이 완료되었습니다.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => SettingsScreen()),
                                (Route<dynamic> route) => false,
                          );
                        },
                        child: Text('확인'),
                      ),
                    ],
                  ),
                );
              }
                  : null,
              child: const Text('다음'),
            ),
          ),
        ),
      ),
    );
  }
}
