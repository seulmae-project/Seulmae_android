import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 추가된 import
import 'phone_verification_screen.dart';
import '../signin/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ssnFrontController = TextEditingController();
  final TextEditingController _ssnBackController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _carrierController = TextEditingController();
  String _carrier = '통신사 선택';
  bool _isNextButtonEnabled = false;
  DateTime? _lastPressedAt;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_checkNextButtonEnabled);
    _phoneNumberController.addListener(_checkNextButtonEnabled);
    _carrierController.addListener(_checkNextButtonEnabled);
    _ssnFrontController.addListener(_checkNextButtonEnabled);
    _ssnBackController.addListener(_checkNextButtonEnabled);

    _ssnFrontController.addListener(() {
      if (_ssnFrontController.text.length == 6 && _ssnBackController.text.isEmpty) {
        FocusScope.of(context).nextFocus();
      }
    });
  }

  void _checkNextButtonEnabled() {
    setState(() {
      _isNextButtonEnabled = _nameController.text.isNotEmpty &&
          _carrier != '통신사 선택' &&
          _isValidPhoneNumber(_phoneNumberController.text) &&
          _ssnFrontController.text.length == 6 &&
          _ssnBackController.text.length == 1;
    });
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    final RegExp regex = RegExp(r'^\d{11}$');
    return regex.hasMatch(phoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ssnFrontController.dispose();
    _ssnBackController.dispose();
    _phoneNumberController.dispose();
    _carrierController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastPressedAt == null || now.difference(_lastPressedAt!) > Duration(seconds: 2)) {
      _lastPressedAt = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('한 번 더 누르시면 이전 화면으로 돌아갑니다.')),
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('회원가입'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '본인확인을 위해\n휴대폰 정보를 입력해주세요',
                style: TextStyle(fontSize: 23.4, color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32.0),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '이름',
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
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ssnFrontController,
                      decoration: InputDecoration(
                        labelText: '주민등록번호 앞자리',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        counterText: '', // 글자 수 제한 표시 제거
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '-',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        TextField(
                          controller: _ssnBackController,
                          decoration: InputDecoration(
                            labelText: '주민등록번호 뒷자리',
                            hintText: '3●●●●●●', // 힌트 추가
                            counterText: '', // 글자 수 제한 표시 제거
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        if (_ssnBackController.text.isNotEmpty)
                          Positioned(
                            left: 30,
                            child: Text(
                              '●●●●●●',
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _carrier,
                items: ['통신사 선택', 'SKT', 'KT', 'LGU+']
                    .map((carrier) => DropdownMenuItem(
                  value: carrier,
                  child: Text(carrier),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _carrier = value!;
                    _carrierController.text = value; // _carrierController의 값을 업데이트
                    _checkNextButtonEnabled(); // 다음 버튼이 활성화될 수 있는지 확인
                  });
                },
                decoration: InputDecoration(
                  labelText: '통신사',
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
              const SizedBox(height: 16.0),
              TextField(
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
                  counterText: '', // 글자 수 제한 표시 제거
                ),
                keyboardType: TextInputType.phone,
                maxLength: 11,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 24.0),
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
                    builder: (context) => PhoneVerificationScreen(
                      name: _nameController.text,
                      ssnFront: _ssnFrontController.text,
                      ssnBack: _ssnBackController.text,
                      phoneNumber: _phoneNumberController.text,
                      carrier: _carrier,
                    ),
                  ),
                );
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isNextButtonEnabled ? Colors.lightBlue : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // 원하는 네모의 모양을 만들기 위해 설정
                ),
              ),
              child: const Text('다음'),
            ),
          ),
        ),
      ),
    );
  }
}
