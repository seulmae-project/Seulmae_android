import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'password_reset_screen.dart';
import 'login_screen.dart';
import 'dart:async'; // For Timer

class IdSearchScreen extends StatefulWidget {
  const IdSearchScreen({Key? key}) : super(key: key);

  @override
  _IdSearchScreenState createState() => _IdSearchScreenState();
}

class _IdSearchScreenState extends State<IdSearchScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _verificationCodeController;

  bool _isVerificationCodeSent = false;
  bool _isNextButtonEnabled = false;
  bool _isResendEnabled = false;
  int _resendSeconds = 180;
  Timer? _timer;
  bool _sendButtonEnabled = false;
  bool _resendButtonActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _verificationCodeController = TextEditingController(text: ''); // Initialize with an empty string

    _nameController.addListener(_validateFields);
    _phoneNumberController.addListener(_validateFields);
    _updateSendButtonState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _verificationCodeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _validateFields() {
    setState(() {
      bool isNameValid = _nameController.text.isNotEmpty;
      bool isPhoneNumberValid = _isNumeric(_phoneNumberController.text);

      _isResendEnabled = isNameValid && isPhoneNumberValid;

      _isNextButtonEnabled = isNameValid &&
          isPhoneNumberValid &&
          (_isVerificationCodeSent || _verificationCodeController.text.length == 6);

      if (_isVerificationCodeSent && isNameValid && isPhoneNumberValid) {
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
      _sendButtonEnabled = _nameController.text.isNotEmpty && _phoneNumberController.text.length == 11;
      _resendButtonActive = _nameController.text.isNotEmpty && _phoneNumberController.text.length == 11;
    });
  }

  void _sendVerificationCode() {
    setState(() {
      _isVerificationCodeSent = true;
      _isResendEnabled = false;
      _resendButtonActive = false;
      _resendSeconds = 180;
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
        } else {
          _isResendEnabled = true;
          if (_nameController.text.isNotEmpty && _phoneNumberController.text.length == 11) {
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
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('아이디 찾기'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '아이디를 찾기 위해 \n이름과 휴대폰 번호를 입력하세요',
                style: TextStyle(fontSize: 23.4, color: Colors.black, fontWeight: FontWeight.bold),
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
                    maxLength: 16,
                    onChanged: (value) {
                      _updateSendButtonState();
                    },
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
                          onPressed: _resendButtonActive ? _sendVerificationCode : null,
                          child: Text(_resendButtonActive ? '전송' : '재전송'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _resendButtonActive ? (_isResendEnabled ? Colors.blue : Colors.grey) : Colors.grey,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewUserIdEmail()),
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

class ViewUserIdEmail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button press
      child: Scaffold(
        appBar: AppBar(
          title: const Text('아이디 찾기 결과'),
          automaticallyImplyLeading: false, // Hide back button
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '아이디 찾기 결과 화면',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to PasswordResetScreen and replace current screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => PasswordResetScreen()),
                  );
                },
                child: const Text('비밀번호 찾기'),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to LoginScreen and replace current screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: const Text('로그인 화면으로'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




