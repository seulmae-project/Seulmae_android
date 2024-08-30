import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../config.dart';
import '../../../providers/auth_provider.dart';
import 'notification_models.dart';
import 'notification_widgets.dart';

class AlertList extends StatefulWidget {
  @override
  _AlertListState createState() => _AlertListState();
}

class _AlertListState extends State<AlertList> {
  late Future<List<AlertItemData>> _alerts;

  @override
  void initState() {
    super.initState();
    _alerts = fetchAlerts();
  }

  Future<List<AlertItemData>> fetchAlerts() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final selectedWorkplaceId = authProvider.selectedWorkplaceId;

    if (authProvider.isTokenExpired()) {
      bool refreshed = await authProvider.refreshAccessToken();
      if (!refreshed) {
        throw Exception('Failed to refresh token');
      }
    }

    final accessToken = authProvider.accessToken;
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/api/notification/v1/list?userWorkplaceId=$selectedWorkplaceId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> alertsJson = data['data'];
      return alertsJson.map((json) => AlertItemData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load alerts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AlertItemData>>(
      future: _alerts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No alerts available.'));
        } else {
          final alerts = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: alerts.map((alert) {
              return AlertItem(
                id: alert.id,
                title: alert.title,
                message: alert.message,
                regDateNotification: alert.regDateNotification,
              );
            }).toList(),
          );
        }
      },
    );
  }
}
