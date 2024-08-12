import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';
import 'dart:async';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({Key? key}) : super(key: key);

  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}
bool _isBackPressedOnce = false;
class _PasswordResetScreenState extends State<PasswordResetScreen> {
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _verificationCodeController;
  bool _isBackPressedOnce = false;
  bool _isVerificationCodeSent = false;
  bool _isNextButtonEnabled = false;
  bool _isResendEnabled = false; // 재전송 버튼 활성화 여부
  int _resendSeconds = 180; // 재전송까지 남은 시간 (초)

  Timer? _resendTimer;

  String? _sentEmail;
  String? _sentName;
  String? _sentPhoneNumber;

  @override

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _nameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _verificationCodeController = TextEditingController();
    _emailController.addListener(_validateFields);
    _nameController.addListener(_validateFields);
    _phoneNumberController.addListener(_validateFields);
    _verificationCodeController.addListener(_validateFields);
  }

  void _verifyCode() {
    if (_emailController.text == _sentEmail &&
        _nameController.text == _sentName &&
        _phoneNumberController.text == _sentPhoneNumber) {
      setState(() {
        _isNextButtonEnabled = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneNumberController.dispose();
    _verificationCodeController.dispose();
    if (_resendTimer != null) {
      _resendTimer!.cancel();
    }
    super.dispose();
  }

  void _validateFields() {
    setState(() {
      bool isEmailValid = _emailController.text.isNotEmpty;
      bool isNameValid = _nameController.text.isNotEmpty;
      bool isPhoneNumberValid = _phoneNumberController.text.isNotEmpty &&
          _phoneNumberController.text.length == 11 &&
          _isNumeric(_phoneNumberController.text);

      // Enable resend button only if all fields (email, name, phone number) are valid
      _isResendEnabled = isEmailValid && isNameValid && isPhoneNumberValid;

      _isNextButtonEnabled = isEmailValid && isNameValid && isPhoneNumberValid &&
          (_isVerificationCodeSent ||
              _verificationCodeController.text.length == 6);
    });
  }





  void _sendVerificationCode() {
    // Validate name, email, and phone number
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneNumberController.text.length != 11 ||
        !_isNumeric(_phoneNumberController.text)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('입력 오류'),
          content: Text('이름, 이메일, 휴대폰 번호를 올바르게 입력해주세요.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        ),
      );
      return; // 입력이 올바르지 않으면 메서드 종료
    }

    // Cancel previous timer if it's active
    if (_resendTimer != null) {
      _resendTimer!.cancel();
      _resendTimer = null; // Ensure timer is null after cancellation
    }

    // Proceed with sending verification code
    setState(() {
      _isVerificationCodeSent = true;
      _sentEmail = _emailController.text;
      _sentName = _nameController.text;
      _sentPhoneNumber = _phoneNumberController.text;
    });

    _startResendTimer();
  }
  void _startResendTimer() {
    _resendSeconds = 180;
    _isResendEnabled = false;

    // Cancel previous timer if it's active
    if (_resendTimer != null) {
      _resendTimer!.cancel();
    }

    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _isResendEnabled = true;
          _resendTimer!.cancel();
          _resendTimer = null; // Ensure timer is null after cancellation
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return true;
    },
      child: Scaffold(
      appBar: AppBar(
      title: const Text('비밀번호 재설정'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              '비밀번호 재설정을 위해\n정보를 입력하세요',
              style: TextStyle(
                fontSize: 23.4,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '이메일',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: '이메일',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '이름',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
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
                  ),
                ),
              ],
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
                          counterText: '', // Remove 0/11 indicator
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
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isResendEnabled
                            ? () {
                          _sendVerificationCode(); // 전송 또는 재전송 요청
                        }
                            : null,
                        child: Text(_isVerificationCodeSent ? '재전송' : '전송'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
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
                                counterText: '', // 0/6 제거
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide:
                                  const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide:
                                  const BorderSide(color: Colors.blue),
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
                  SizedBox(height: 24),
                ],
              ),
            ]
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
              if (_emailController.text == _sentEmail &&
                  _nameController.text == _sentName &&
                  _phoneNumberController.text == _sentPhoneNumber) {
                // Check if timer has ended
                if (_resendSeconds > 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ResetPasswordScreen()),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('인증번호 만료'),
                      content: Text('인증번호가 만료되었습니다. 재발급 해주세요.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _sendVerificationCode(); // 재발급 요청
                          },
                          child: Text('확인'),
                        ),
                      ],
                    ),
                  );
                }
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('오류'),
                    content: Text('입력된 정보가 인증 정보와 일치하지 않습니다.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('확인'),
                      ),
                    ],
                  ),
                );
              }
            }
                : null,
            child: const Text('다음'),
          ),
        ),
      ),
    ),
    );
  }
  String _formatTimer(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  bool _isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }
}

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  bool _isResetButtonEnabled = false;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _newPasswordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    setState(() {
      String password = _newPasswordController.text;
      bool hasLetter = password.contains(RegExp(r'[a-zA-Z]')); // Check for letters (both uppercase and lowercase)
      bool hasDigit = password.contains(RegExp(r'[0-9]')); // Check for digits
      bool hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')); // Check for special characters

      int validConditions = 0;
      if (hasLetter) validConditions++;
      if (hasDigit) validConditions++;
      if (hasSpecialCharacters) validConditions++;

      if (password.length < 8 ||
          password.isEmpty ||
          validConditions < 3) { // Require 3 out of the 3 conditions
        _passwordError = '비밀번호는 8자리 이상 영문자, 숫자, 특수문자를 모두 포함해야 합니다.';
      } else {
        _passwordError = null;
      }

      if (_confirmPasswordController.text.isNotEmpty &&
          _newPasswordController.text != _confirmPasswordController.text) {
        _confirmPasswordError = '비밀번호가 일치하지 않습니다.';
      } else {
        _confirmPasswordError = null;
      }

      _updateNextButtonState();
    });
  }

  void _updateNextButtonState() {
    setState(() {
      _isResetButtonEnabled = _newPasswordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _newPasswordController.text == _confirmPasswordController.text &&
          _passwordError == null &&
          _confirmPasswordError == null;
    });
  }

  void _resetPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('비밀번호 재설정 완료'),
        content: Text('비밀번호가 성공적으로 재설정되었습니다.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isBackPressedOnce) {
          // If already pressed once, allow navigation
          return true;
        } else {
          // Show dialog and await user confirmation
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('정말 나가시겠습니까?'),
              content: Text('작성한 정보가 저장되지 않습니다. 그래도 나가시겠습니까?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Allow back navigation
                  },
                  child: Text('예'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Stay on the current screen
                  },
                  child: Text('아니요'),
                ),
              ],
            ),
          ).then((value) {
            if (value == true) {
              // If user confirmed to exit, set _isBackPressedOnce to true
              setState(() {
                _isBackPressedOnce = true;
              });
            }
          });
          // Prevent back navigation temporarily
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('비밀번호 재설정'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '새 비밀번호를 입력하세요',
                style: TextStyle(
                  fontSize: 23.4,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '새 비밀번호',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      hintText: '새 비밀번호',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                    ),
                    obscureText: true,
                  ),
                  if (_passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _passwordError!,
                        style: TextStyle(color: Colors.red, fontSize: 12.0),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '새 비밀번호 확인',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      hintText: '새 비밀번호 확인',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                    ),
                    obscureText: true,
                  ),
                  if (_confirmPasswordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _confirmPasswordError!,
                        style: TextStyle(color: Colors.red, fontSize: 12.0),
                      ),
                    ),
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
              onPressed: _isResetButtonEnabled ? _resetPassword : null,
              child: const Text('재설정'),
            ),
          ),
        ),
      ),
    );
  }
}
