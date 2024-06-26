import 'package:flutter/material.dart';
import '../signin/login_screen.dart';
import 'email_password_screen.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String name;
  final String ssnFront;
  final String ssnBack;
  final String phoneNumber;
  final String carrier;

  const PhoneVerificationScreen({
    Key? key,
    required this.name,
    required this.ssnFront,
    required this.ssnBack,
    required this.phoneNumber,
    required this.carrier,
  }) : super(key: key);

  @override
  _PhoneVerificationScreenState createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final List<TextEditingController> _verificationCodeControllers = List.generate(6, (_) => TextEditingController());
  bool _isNextButtonEnabled = false;
  DateTime? _lastPressedAt;

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

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastPressedAt == null || now.difference(_lastPressedAt!) > Duration(seconds: 2)) {
      _lastPressedAt = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('한 번 더 누르시면 로그인 화면으로 돌아갑니다.')),
      );
      return Future.value(false);
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
                  // Implement your logic here
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
              onPressed: _isNextButtonEnabled
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmailAndPasswordScreen(
                      name: widget.name,
                      ssnFront: widget.ssnFront,
                      ssnBack: widget.ssnBack,
                      phoneNumber: widget.phoneNumber,
                      carrier: widget.carrier,
                    ),
                  ),
                );
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isNextButtonEnabled ? Colors.lightBlue : Colors.grey,
              ),
              child: const Text('확인'),
            ),
          ),
        ),
      ),
    );
  }
}
