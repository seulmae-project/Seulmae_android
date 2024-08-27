import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../app_state.dart';
import '../no_workplace_screen.dart';
import '../user_workplace_info.dart';
import 'api_workplace.dart';
import 'regist_work_place.dart';

class WorkplaceManagementScreen extends StatefulWidget {
  const WorkplaceManagementScreen({Key? key}) : super(key: key);
  static Future<void> fetchWorkplaces(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final fetched = await authProvider.userFetchWorkplaces(context);
    if (fetched) {
      final appState = Provider.of<AppState>(context, listen: false);
      final _workplaces = authProvider.workplaces;
      final selectedWorkplaceIndex = _workplaces.indexWhere((workplace) => workplace.workplaceId == authProvider.selectedWorkplaceId);
      if (selectedWorkplaceIndex != -1) {
        appState.setSelectedWorkplace(_workplaces[selectedWorkplaceIndex].workplaceName);
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => NoWorkplaceScreen()),
      );
    }
  }
  @override
  _WorkplaceManagementScreenState createState() => _WorkplaceManagementScreenState();
}

class _WorkplaceManagementScreenState extends State<WorkplaceManagementScreen> {
  int? selectedWorkplaceIndex;
  bool isDeleteMode = false;
  List<UserWorkplaceInfo> _workplaces = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWorkplaces();
  }

  Future<void> _fetchWorkplaces() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final fetched = await authProvider.userFetchWorkplaces(context);
    if (fetched) {
      setState(() {
        _workplaces = authProvider.workplaces;
        _isLoading = false;

        final appState = Provider.of<AppState>(context, listen: false);
        // Update selectedWorkplaceIndex based on the loaded selectedWorkplaceId
        selectedWorkplaceIndex = _workplaces.indexWhere((workplace) => workplace.workplaceId == authProvider.selectedWorkplaceId);
        if (selectedWorkplaceIndex != -1) {
          appState.setSelectedWorkplace(_workplaces[selectedWorkplaceIndex!].workplaceName);
        }
      });
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => NoWorkplaceScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

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
                  _fetchWorkplaces(); // 새로 등록 후 목록 갱신
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _workplaces.isEmpty
          ? Center(child: Text('등록된 근무지가 없습니다.'))
          : ListView.builder(
        itemCount: _workplaces.length,
        itemBuilder: (context, index) {
          UserWorkplaceInfo workplace = _workplaces[index];
          bool isSelected = selectedWorkplaceIndex == index;

          return ListTile(
            title: Text(workplace.workplaceName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('핸드폰 번호: ${workplace.workplaceTel}'),
                Text('주소: ${workplace.address.mainAddress} ${workplace.address.subAddress}'),
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
              onChanged: (int? value) async {
                if (value != null) {
                  setState(() {
                    selectedWorkplaceIndex = value;
                  });
                  final selectedWorkplace = _workplaces[value];
                  await Provider.of<AuthProvider>(context, listen: false).saveSelectedWorkplaceId(selectedWorkplace.workplaceId);
                  appState.setSelectedWorkplace(selectedWorkplace.workplaceName);
                }
              },
            ),

            onTap: () async {
              if (!isDeleteMode) {
                setState(() {
                  selectedWorkplaceIndex = index;
                });
                final selectedWorkplace = _workplaces[index];
                await Provider.of<AuthProvider>(context, listen: false).saveSelectedWorkplaceId(selectedWorkplace.workplaceId);
                appState.setSelectedWorkplace(selectedWorkplace.workplaceName);
              }
            },
          );
        },
      ),
    );
  }
  void _showDeleteConfirmationDialog(UserWorkplaceInfo workplace) {
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
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                final success = await ApiWorkplace.deleteWorkplace(context, workplace.workplaceId);
                if (success) {
                  _fetchWorkplaces(); // Refresh the list after successful deletion
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('근무지 삭제 실패')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }


}
