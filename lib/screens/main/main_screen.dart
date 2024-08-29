import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmfao3/providers/auth_provider.dart';
import 'package:tmfao3/screens/main/schedule/schedule_list_screen.dart';
import 'package:tmfao3/screens/main/setting/settings_screen.dart';
import 'package:tmfao3/screens/main/user_workplace_info.dart';
import 'package:tmfao3/screens/main/no_workplace_screen.dart';
import 'package:tmfao3/screens/main/employee/employee_dashboard_screen.dart';
import 'package:tmfao3/screens/main/employee/work_status_screen.dart';
import 'package:tmfao3/screens/main/manage/manage_dashboard_screen.dart';
import 'app_state.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  AuthProvider? authProvider;
  List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    _loadWorkplaceInfo();
  }

  Future<void> _loadWorkplaceInfo() async {
    bool hasWorkplaces = await authProvider!.userFetchWorkplaces(context);

    if (!hasWorkplaces) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NoWorkplaceScreen()),
      );
      return;
    }

    await authProvider!.loadSelectedWorkplaceId();
    final int? workplaceId = authProvider!.selectedWorkplaceId;
    if (workplaceId != null) {
      UserWorkplaceInfo? workplaceInfo = await authProvider!.fetchUserWorkplaceInfo(workplaceId);

      if (workplaceInfo != null) {
        setState(() {
          if (workplaceInfo.isManager) {
            _screens = [
              ManageDashboardScreen(),
              ScheduleListScreen(),
              SettingsScreen(),
            ];
            Provider.of<AppState>(context, listen: false).setSelectedIndex(0);
          } else {
            _screens = [
              EmployeeDashboardScreen(),
              WorkStatusScreen(),
              SettingsScreen(),
            ];
            Provider.of<AppState>(context, listen: false).setSelectedIndex(0);
          }
        });
      } else {
        print("근무지 정보가 없습니다.");
      }
    } else {
      print("선택된 근무지 ID가 없습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      body: _screens.isNotEmpty
          ? _screens[appState.selectedIndex]
          : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '메인'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: '근무 현황'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
        currentIndex: appState.selectedIndex,
        onTap: (index) {
          setState(() => appState.setSelectedIndex(index));
        },
      ),
    );
  }
}
