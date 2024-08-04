import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sm3/screens/main/setting/settings_screen.dart';
import '../../providers/auth_provider.dart';
import 'app_state.dart';
import 'employee/employee_dashboard_screen.dart';
import 'employee/work_status_screen.dart';
import 'manage/manage_dashboard_screen.dart';
import 'manage/work_status_manage_screen.dart';

class MainScreen extends StatelessWidget {
  final List<Widget> _employeeOptions = <Widget>[
    EmployeeDashboardScreen(),
    WorkStatusScreen(),
    SettingsScreen(),
  ];

  final List<Widget> _managerOptions = <Widget>[
    ManageDashboardScreen(),
    ManagerWorkStatusScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final List<Widget> _widgetOptions = authProvider.userRole == 'manager'
        ? _managerOptions
        : _employeeOptions;

    return Scaffold(
      body: IndexedStack(
        index: appState.selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '메인',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: '근무 현황',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
        currentIndex: appState.selectedIndex,
        onTap: (index) {
          appState.setSelectedIndex(index);
        },
      ),
    );
  }
}
