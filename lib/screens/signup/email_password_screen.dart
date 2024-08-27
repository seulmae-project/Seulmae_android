import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import 'profile_completion_screen.dart';
import 'sign_up_data.dart';
import 'package:google_fonts/google_fonts.dart';

class EmailAndPasswordScreen extends StatefulWidget {
  final SignUpData signUpData;

  const EmailAndPasswordScreen({
    Key? key,
    required this.signUpData,
  }) : super(key: key);

  @override
  _EmailAndPasswordScreenState createState() => _EmailAndPasswordScreenState();
}

class _EmailAndPasswordScreenState extends State<EmailAndPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isNextButtonEnabled = false;
  bool _isIdValidated = false;
  String _idStatusMessage = "";
  Color _idStatusColor = Colors.black;

  bool _hasLowercase = false;
  bool _hasDigits = false;
  bool _hasSpecialCharacters = false;
  bool _hasMinLength = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  void _onEmailChanged() {
    if (_isIdValidated) {
      setState(() {
        _isIdValidated = false;
        _idStatusMessage = "";
      });
    }
    _validateForm();
  }

  void _validateForm() {
    setState(() {
      final password = _passwordController.text;
      final email = _emailController.text;
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasDigits = password.contains(RegExp(r'[0-9]'));
      _hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _hasMinLength = password.length >= 8;

      _isNextButtonEnabled = email.isNotEmpty && email.length >= 5 && _isIdValidated &&
          _hasLowercase && _hasDigits && _hasSpecialCharacters && _hasMinLength &&
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  Future<void> _checkIdDuplication() async {
    final email = _emailController.text;

    // Check if the email length is less than 5 characters
    if (email.length < 5) {
      setState(() {
        _isIdValidated = false;
        _idStatusMessage = "아이디는 5글자 이상이어야 합니다.";
        _idStatusColor = Colors.red;
      });
      return;  // Exit the function early if the condition is not met
    }

    var response = await http.post(
      Uri.parse('${Config.baseUrl}/api/users/id/duplication'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'accountId': email}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      bool isDuplicated = data['data']['duplicated'];
      setState(() {
        _isIdValidated = !isDuplicated;
        _idStatusMessage = _isIdValidated ? "사용 가능한 아이디입니다." : "이미 사용 중인 아이디입니다.";
        _idStatusColor = _isIdValidated ? Colors.green : Colors.red;
      });
    } else {
      setState(() {
        _idStatusMessage = "아이디 중복 확인에 실패했습니다.";
        _idStatusColor = Colors.red;
      });
    }
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이메일과 비밀번호 입력'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '계정 아이디와\n비밀번호를 입력해 주세요.',
              style: GoogleFonts.roboto(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 32.0),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller: _emailController,
                    enabled: !_isIdValidated,  // 중복 확인이 완료되면 비활성화
                    decoration: InputDecoration(
                      labelText: '아이디',
                      hintText: '아이디 입력',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.teal),
                      ),
                      disabledBorder: OutlineInputBorder( // 비활성화 상태의 테두리 스타일
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isIdValidated ? null : _checkIdDuplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isIdValidated ? Colors.grey : Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('중복확인'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _idStatusMessage,
                style: TextStyle(color: _idStatusColor, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: '비밀번호',
                prefixIcon: Icon(Icons.lock),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.teal),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPasswordCriteriaRow('8자 이상', _hasMinLength),
                _buildPasswordCriteriaRow('소문자 포함', _hasLowercase),
                _buildPasswordCriteriaRow('숫자 포함', _hasDigits),
                _buildPasswordCriteriaRow('특수문자 포함', _hasSpecialCharacters),
              ],
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                prefixIcon: Icon(Icons.lock_outline),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.teal),
                ),
              ),
              obscureText: true,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: _isNextButtonEnabled ? _proceedToProfileCompletion : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isNextButtonEnabled ? Colors.teal : Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: const Text('다음으로'),
        ),
      ),
    );
  }

  Widget _buildPasswordCriteriaRow(String criteria, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isValid ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 4.0),
        Text(criteria, style: TextStyle(fontSize: 12.0)),
      ],
    );
  }
  Future<void> _proceedToProfileCompletion() async {
    if (_isNextButtonEnabled) {
      final updatedSignUpData = widget.signUpData.copyWith(
        accountId: _emailController.text,
        password: _passwordController.text,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileCompletionScreen(signUpData: updatedSignUpData),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please fill all the fields correctly before proceeding."),
            duration: Duration(seconds: 2),
          )
      );
    }
  }

}
