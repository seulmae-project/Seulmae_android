import 'package:flutter/material.dart';
import 'package:sm3/screens/main/workplace/workplace.dart';
import 'package:sm3/screens/main/workplace/workplace_management_screen.dart';
import '../employee/employee_dashboard_screen.dart';
import 'workplace_entry_screen.dart';
import 'workplace_creation_screen.dart';

class RegistWorkPlaceScreen extends StatefulWidget {
  const RegistWorkPlaceScreen({Key? key}) : super(key: key);

  @override
  _RegistWorkPlaceScreenState createState() => _RegistWorkPlaceScreenState();
}

class _RegistWorkPlaceScreenState extends State<RegistWorkPlaceScreen> {
  List<String> workplaces = [];

  void navigateToWorkplaceEntryScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkplaceEntryScreen(),
      ),
    );
  }

  void navigateToWorkplaceCreationScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkplaceCreationScreen(),
      ),
    );
  }
  void navigateToWorkplaceManagementScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkplaceManagementScreen(workplaces:[
          Workplace(name: '근무지 A', phoneNumber: '031-1111-2222', address: '인천광역시 남구', profileImagePath: ''),
          Workplace(name: '근무지 B', phoneNumber: '032-2222-3333', address: '서울특별시 강남구', profileImagePath: ''),
          Workplace(name: '근무지 C', phoneNumber: '033-3333-4444', address: '부산광역시 해운대구', profileImagePath: ''),
        ],),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('근무지 추가'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => navigateToWorkplaceEntryScreen(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              child: Text(
                '근무지 입장 화면으로',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => navigateToWorkplaceCreationScreen(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
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
}
