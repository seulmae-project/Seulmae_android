import 'dart:convert';
import 'dart:typed_data'; // Import for Uint8List
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../config.dart';
import '../../../providers/auth_provider.dart';

class WorkplaceEmployeeList extends StatefulWidget {
  @override
  _WorkplaceEmployeeListState createState() => _WorkplaceEmployeeListState();
}

class _WorkplaceEmployeeListState extends State<WorkplaceEmployeeList> {
  List<dynamic> employeeList = [];
  bool isLoading = true;

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
      print("Token refreshed: $refreshed");
      if (!refreshed) {
        setState(() {
          isLoading = false;
        });
        return; // Exit if token refresh failed
      }
    }

    final accessToken = authProvider.accessToken;
    final selectedWorkplaceId = authProvider.selectedWorkplaceId;

    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/workplace/user/v1/list?workplaceId=$selectedWorkplaceId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      // Ensure the response body is decoded properly as UTF-8
      final responseBody = utf8.decode(response.bodyBytes);
      print('Response Body: $responseBody');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);

        // Check if 'data' is present in responseData
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final data = responseData['data'];

          setState(() {
            // Sort managers first by converting manager bool to int (true -> 1, false -> 0)
            employeeList = data
              ..sort((a, b) {
                int aManager = (a['manager'] as bool) ? 1 : 0;
                int bManager = (b['manager'] as bool) ? 1 : 0;
                return bManager.compareTo(aManager); // Managers first
              });
            isLoading = false;
          });
        } else {
          print('No valid employee data found.');
          setState(() {
            employeeList = []; // Ensure the list is set to empty if no valid data
            isLoading = false;
          });
        }
      } else {
        print('Failed to load employee list. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching employee list: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Cache for image data
  final Map<String, ImageProvider> _imageCache = {};

  Future<ImageProvider> _getImageProvider(String? url) async {
    if (url == null) {
      return AssetImage('assets/profile_image_1.png');
    }

    // Check if image is already cached
    if (_imageCache.containsKey(url)) {
      return _imageCache[url]!;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${authProvider.accessToken}'},
      );

      if (response.statusCode == 200) {
        final Uint8List imageBytes = response.bodyBytes;
        final imageProvider = MemoryImage(imageBytes);

        // Cache the image
        _imageCache[url] = imageProvider;

        return imageProvider;
      } else {
        print('Failed to load image. Status code: ${response.statusCode}');
        return AssetImage('assets/profile_image_1.png');
      }
    } catch (error) {
      print('Error fetching image: $error');
      return AssetImage('assets/profile_image_1.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (employeeList.isEmpty) {
      return Center(child: Text('No employees found.'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Horizontal scrolling
      child: Row(
        children: employeeList.map((employee) {
          final isManager = employee['manager'] ?? false;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none, // Prevents the overflow of positioned widget
                  children: [
                    FutureBuilder<ImageProvider>(
                      future: _getImageProvider(employee['userImageUrl']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircleAvatar(
                            radius: 30, // Adjust the radius as needed
                            backgroundImage: AssetImage('assets/profile_image_1.png'),
                          );
                        } else if (snapshot.hasError) {
                          return CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage('assets/profile_image_1.png'),
                          );
                        } else {
                          return CircleAvatar(
                            radius: 30,
                            backgroundImage: snapshot.data!,
                          );
                        }
                      },
                    ),
                    if (isManager)
                      Positioned(
                        right: -5,
                        bottom: -5,
                        child: Icon(Icons.verified, color: Colors.amber, size: 16),
                      ),
                  ],
                ),
                SizedBox(height: 4), // Spacing between image and name
                Text(
                  employee['userName'] ?? 'Unknown User',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
