import 'package:flutter/material.dart';
import 'package:sm3/screens/main/workplace/workplace.dart';
import 'regist_work_place.dart'; // RegistWorkPlaceScreen을 import합니다.
import '../employee/employee_dashboard_screen.dart'; // RegistWorkPlaceScreen을 import합니다.

class WorkplaceManagementScreen extends StatefulWidget {
  final List<Workplace> workplaces; // 근무지 목록을 저장할 리스트

  const WorkplaceManagementScreen({Key? key, required this.workplaces}) : super(key: key);

  @override
  _WorkplaceManagementScreenState createState() => _WorkplaceManagementScreenState();
}

class _WorkplaceManagementScreenState extends State<WorkplaceManagementScreen> {
  List<Workplace> selectedWorkplaces = []; // 선택된 근무지 목록을 저장할 리스트

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('근무지 관리'), // 앱바 제목 설정
        actions: [
          IconButton(
            icon: Icon(Icons.add), // 추가 버튼 아이콘
            onPressed: () {
              // RegistWorkPlaceScreen으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegistWorkPlaceScreen(),
                ),
              ).then((value) {
                // RegistWorkPlaceScreen에서 추가 완료 후 처리할 로직
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.delete), // 삭제 버튼 아이콘
            onPressed: () {
              _showDeleteConfirmationDialog(selectedWorkplaces); // 선택된 근무지 삭제 다이얼로그 표시
            },
          ),
        ],
      ),
      body: widget.workplaces.isEmpty
          ? Center(
        child: Text('등록된 근무지가 없습니다.'), // 등록된 근무지가 없을 때 표시할 문구
      )
          : ListView.builder(
        itemCount: widget.workplaces.length,
        itemBuilder: (context, index) {
          Workplace workplace = widget.workplaces[index];
          bool isSelected = selectedWorkplaces.contains(workplace);

          return ListTile(
            title: Text(workplace.name), // 근무지 이름 표시
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('핸드폰 번호: ${workplace.phoneNumber}'), // 핸드폰 번호 표시
                Text('주소: ${workplace.address}'), // 주소 표시
              ],
            ),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value != null && value) {
                    selectedWorkplaces.add(workplace);
                  } else {
                    selectedWorkplaces.remove(workplace);
                  }
                });
              },
            ),
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedWorkplaces.remove(workplace);
                } else {
                  selectedWorkplaces.add(workplace);
                }
              });
            },
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(List<Workplace> selectedWorkplaces) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('근무지 삭제'), // 다이얼로그 제목
          content: Text('선택된 근무지를 삭제하시겠습니까?'), // 삭제 확인 메시지
          actions: <Widget>[
            TextButton(
              child: Text('취소'), // 취소 버튼
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
            TextButton(
              child: Text('삭제', style: TextStyle(color: Colors.red)), // 삭제 버튼 (빨간색 텍스트)
              onPressed: () {
                setState(() {
                  widget.workplaces.removeWhere((workplace) => selectedWorkplaces.contains(workplace));
                  selectedWorkplaces.clear(); // 선택된 목록 비우기
                });
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }
}
