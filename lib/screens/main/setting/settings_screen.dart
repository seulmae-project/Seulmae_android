  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import 'package:sm3/screens/main/password_confirmation_screen.dart';
  import 'package:sm3/screens/main/setting/phone_number_change_screen.dart';
  import 'package:sm3/screens/main/setting/profile_edit_screen.dart';
  import 'package:sm3/screens/signin/login_screen.dart';
  import 'package:shared_preferences/shared_preferences.dart';

  import '../../../providers/auth_provider.dart';

  class SettingsScreen extends StatelessWidget {
    Future<void> _showLogoutDialog(BuildContext context) async {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('로그아웃'),
            content: Text('로그아웃 하시면 새 소식을 알림이 가지 않습니다.\n정말 로그아웃을 하시나요?'),
            actions: [
              TextButton(
                child: Text('취소하기'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('로그아웃'),
                onPressed: () async {
                  await Provider.of<AuthProvider>(context, listen: false).logout();
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.clear(); // Clear shared preferences
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) => LoginScreen()),
                        (route) => false,
                  );
                },
              ),
            ],
          );
        },
      );
    }

    Future<void> _showDeleteAccountDialog(BuildContext context) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('회원 탈퇴'),
            content: Text('탈퇴하시면 모든 정보가 삭제됩니다.\n정말 탈퇴하시나요?'),
            actions: [
              TextButton(
                child: Text('취소하기'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('탈퇴하기'),
                onPressed: () async {
                  // await Provider.of<AuthProvider>(context, listen: false).deleteAccount(); 탈퇴 미완성
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.clear(); // Clear shared preferences
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) => LoginScreen()),
                        (route) => false,
                  );
                },
              ),
            ],
          );
        },
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('설정'),
        ),
        body: ListView(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/profile_image_1.png'),
              ),
              title: Text('테스트'),
              subtitle: Text('프로필 수정'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileEditScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('비밀번호 변경'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PasswordConfirmationScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('휴대폰 번호 변경'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhoneNumberChangeScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('로그아웃'),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
            ListTile(
              title: Text('탈퇴'),
              onTap: () {
                _showDeleteAccountDialog(context);
              },
            ),
          ],
        ),
      );
    }
  }
