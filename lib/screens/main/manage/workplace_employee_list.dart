import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http; // Import the http package

import '../../../config.dart';
import '../../../providers/auth_provider.dart';

class WorkplaceEmployeeList extends StatefulWidget {
  @override
  _WorkplaceEmployeeListState createState() => _WorkplaceEmployeeListState();
}

class _WorkplaceEmployeeListState extends State<WorkplaceEmployeeList> {
  List<dynamic> employeeList = [];

  @override
  void initState() {
    super.initState();
    _fetchEmployeeList();
  }

  Future<void> _fetchEmployeeList() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check and refresh token if expired
    if (authProvider.isTokenExpired()) {
      bool refreshed = await authProvider.refreshAccessToken();
      print("refreshed: $refreshed");
      if (!refreshed) {
        throw Exception('Failed to refresh token');
      }
    }

    final accessToken = authProvider.accessToken;
    final selectedWorkplaceId = authProvider.selectedWorkplaceId;

    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/workplace/user/v1/list?workplace=$selectedWorkplaceId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          employeeList = jsonDecode(response.body)['data'];
        });
      } else {
        print('Failed to load employee list');
      }
    } catch (error) {
      print('Error fetching employee list: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (employeeList.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: employeeList.length,
      itemBuilder: (context, index) {
        final employee = employeeList[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(employee['profileImageUrl'] ?? ''),
          ),
          title: Text(employee['userName']),
          subtitle: Text(employee['position']),
        );
      },
    );
  }
}
