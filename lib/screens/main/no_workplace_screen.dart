import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sm3/providers/auth_provider.dart';
import 'package:sm3/screens/main/workplace/workplace_creation_screen.dart';
import 'package:sm3/screens/main/workplace/workplace_entry_screen.dart';
import '../signin/login_screen.dart';
import 'main_screen.dart'; // Make sure to import the MainScreen if it's in a different file.

class NoWorkplaceScreen extends StatefulWidget {
  @override
  _NoWorkplaceScreenState createState() => _NoWorkplaceScreenState();
}

class _NoWorkplaceScreenState extends State<NoWorkplaceScreen> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkForWorkplaces();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _checkForWorkplaces() async {
    bool hasWorkplaces = await Provider.of<AuthProvider>(context, listen: false).userFetchWorkplaces(context);
    print(hasWorkplaces);
    if (hasWorkplaces) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
    }
  }

  void navigateToWorkplaceEntryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WorkplaceEntryScreen()),
    ).then((_) {
      // 사용자가 뒤로 가기를 누르고 돌아올 때 호출됨
      _checkForWorkplaces();
    });
  }

  void navigateToWorkplaceCreationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WorkplaceCreationScreen()),
    ).then((_) {
      // 사용자가 뒤로 가기를 누르고 돌아올 때 호출됨
      _checkForWorkplaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('근무지 없음'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (BuildContext context) {
              return {'로그아웃'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: navigateToWorkplaceEntryScreen,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical:20),
              ),
              child: Text(
                '근무지 입장 화면으로',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: navigateToWorkplaceCreationScreen,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical:20),
              ),
              child: Text(
                '근무지 생성 화면으로',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String choice) {
    if (choice == '로그아웃') {
      _logout();
    }
  }

  void _logout() {
    Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}
