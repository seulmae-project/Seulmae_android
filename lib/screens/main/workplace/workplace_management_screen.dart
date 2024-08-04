import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../app_state.dart';
import 'workplace.dart';
import 'regist_work_place.dart';

class WorkplaceManagementScreen extends StatefulWidget {
  final List<Workplace> workplaces;

  const WorkplaceManagementScreen({Key? key, required this.workplaces}) : super(key: key);

  @override
  _WorkplaceManagementScreenState createState() => _WorkplaceManagementScreenState();
}

class _WorkplaceManagementScreenState extends State<WorkplaceManagementScreen> {
  int? selectedWorkplaceIndex;
  bool isDeleteMode = false;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    selectedWorkplaceIndex = widget.workplaces.indexWhere((workplace) => workplace.name == appState.selectedWorkplace);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('근무지 관리'),
        actions: [
          IconButton(
            icon: Icon(isDeleteMode ? Icons.close : Icons.add),
            onPressed: () {
              if (isDeleteMode) {
                setState(() {
                  isDeleteMode = false;
                });
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegistWorkPlaceScreen(),
                  ),
                ).then((value) {
                  // RegistWorkPlaceScreen에서 추가 완료 후 처리할 로직
                });
              }
            },
          ),
          if (!isDeleteMode)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  isDeleteMode = !isDeleteMode;
                });
              },
            ),
        ],
      ),
      body: widget.workplaces.isEmpty
          ? Center(
        child: Text('등록된 근무지가 없습니다.'),
      )
          : ListView.builder(
        itemCount: widget.workplaces.length,
        itemBuilder: (context, index) {
          Workplace workplace = widget.workplaces[index];
          bool isSelected = selectedWorkplaceIndex == index;

          return ListTile(
            title: Text(workplace.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('핸드폰 번호: ${workplace.phoneNumber}'),
                Text('주소: ${workplace.address}'),
              ],
            ),
            trailing: isDeleteMode
                ? IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _showDeleteConfirmationDialog(workplace);
              },
            )
                : Radio<int>(
              value: index,
              groupValue: selectedWorkplaceIndex,
              onChanged: (int? value) {
                setState(() {
                  selectedWorkplaceIndex = value;
                  appState.setSelectedWorkplace(workplace.name);
                  authProvider.updateUserRole(workplace.name);
                });
              },
            ),
            onTap: () {
              if (!isDeleteMode) {
                setState(() {
                  selectedWorkplaceIndex = index;
                  appState.setSelectedWorkplace(workplace.name);
                  authProvider.updateUserRole(workplace.name);
                });
              }
            },
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(Workplace workplace) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('근무지 삭제'),
          content: Text('선택된 근무지를 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('삭제', style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  widget.workplaces.remove(workplace);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
