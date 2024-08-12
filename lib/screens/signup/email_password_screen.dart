import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  bool _hasLowercase = false;
  bool _hasDigits = false;
  bool _hasSpecialCharacters = false;
  bool _hasMinLength = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      final password = _passwordController.text;
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasDigits = password.contains(RegExp(r'[0-9]'));
      _hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _hasMinLength = password.length >= 8;

      _isNextButtonEnabled = _emailController.text.isNotEmpty &&
          _hasLowercase &&
          _hasDigits &&
          _hasSpecialCharacters &&
          _hasMinLength &&
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  Future<void> _proceedToProfileCompletion() async {
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
              '아이디로 사용하실\n이메일을 입력해 주세요.',
              style: GoogleFonts.roboto(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 32.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: '이메일',
                prefixIcon: Icon(Icons.email),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.teal),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            const Text(
              '비밀번호',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
            const Text(
              '비밀번호 확인',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
}
