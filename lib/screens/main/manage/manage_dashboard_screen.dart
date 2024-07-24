import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'employee_detail_screen.dart';
import 'manage_mock_data.dart'; // import mock data
import '../workplace/workplace.dart';
import '../workplace/workplace_management_screen.dart';
import '../notification/notification_screen.dart';

class ManageDashboardScreen extends StatelessWidget {
  final List<Workplace> workplaces = [
    Workplace(name: '근무지 A', phoneNumber: '031-1111-2222', address: '인천광역시 남구', profileImagePath: ''),
    Workplace(name: '근무지 B', phoneNumber: '032-2222-3333', address: '서울특별시 강남구', profileImagePath: ''),
    Workplace(name: '근무지 C', phoneNumber: '033-3333-4444', address: '부산광역시 해운대구', profileImagePath: ''),
  ];

  void _showEmployeeDetail(BuildContext context, Map<String, dynamic> employeeData) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDetailScreen(employeeData: employeeData),
      ),
    );
  }

  Widget _buildShiftCard(BuildContext context, String shiftTitle, List<Map<String, dynamic>> shiftData, DateTime selectedDate) {
    final filteredShiftData = shiftData.where((employee) {
      return employee['workHistory'].any((work) {
        DateTime workDate = DateTime.parse(work['date']);
        return workDate.year == selectedDate.year &&
            workDate.month == selectedDate.month &&
            workDate.day == selectedDate.day;
      });
    }).toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shiftTitle,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Row(
            children: filteredShiftData.map((employee) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => _showEmployeeDetail(context, employee),
                  child: Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(employee['profileImage']),
                          radius: 24.0,
                        ),
                        SizedBox(height: 4.0),
                        Text(employee['name']),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (appState.currentBackPressTime == null || now.difference(appState.currentBackPressTime!) > Duration(seconds: 2)) {
          appState.setCurrentBackPressTime(now);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('한 번 더 누르시면 앱이 종료됩니다.')),
          );
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            appState.selectedWorkplace,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WorkplaceManagementScreen(workplaces: workplaces),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text('근무지 설정'),
            ),
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: ListView(
          children: <Widget>[
            Container(
              height: 50.0,
              color: Colors.blueAccent,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: appState.pageController,
                    itemCount: 3,
                    onPageChanged: (index) {
                      appState.setCurrentPage(index);
                    },
                    itemBuilder: (context, index) {
                      return Center(
                        child: Text(
                          '공지사항 ${index + 1}',
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 8.0,
                    left: 0.0,
                    right: 0.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                            (index) => GestureDetector(
                          onTap: () {
                            appState.pageController.animateToPage(
                              index,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          },
                          child: Container(
                            width: 8.0,
                            height: 8.0,
                            margin: EdgeInsets.symmetric(horizontal: 2.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: appState.currentPage == index ? Colors.white : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '현재 근무자 상태',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: appState.decrementDate,
                      icon: Icon(Icons.arrow_back),
                    ),
                    Text(
                      appState.getFormattedDate(),
                      style: TextStyle(fontSize: 18.0),
                    ),
                    IconButton(
                      onPressed: appState.incrementDate,
                      icon: Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
              ),
            ),
            _buildShiftCard(context, '오전 파트(오전 09:00 - 오후 01:00)', morningShiftData, appState.selectedDate),
            _buildShiftCard(context, '오후 파트(오후 02:00 - 오후 06:00)', afternoonShiftData, appState.selectedDate),
          ],
        ),
      ),
    );
  }
}
