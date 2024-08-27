import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sm3/screens/main/setting/settings_screen.dart';
import 'app_state.dart';
import 'employee/employee_dashboard_screen.dart';
import 'employee/work_status_screen.dart';
import 'manage/manage_dashboard_screen.dart';
import 'manage/work_status_manage_screen.dart';

class RoleSpecificScreen extends StatelessWidget {
  final String userRole;

  const RoleSpecificScreen({Key? key, required this.userRole}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = userRole == 'manager'
        ? [ManageDashboardScreen(), ManagerWorkStatusScreen(), SettingsScreen()]
        : [EmployeeDashboardScreen(), WorkStatusScreen(), SettingsScreen()];
    return IndexedStack(
      index: Provider.of<AppState>(context).selectedIndex,
      children: screens,
    );
  }
}
