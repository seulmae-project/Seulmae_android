import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../config.dart';
import '../../../providers/auth_provider.dart';
import '../main_screen.dart';
import 'detail_workplace.dart';
import 'package:http_parser/http_parser.dart';  // 추가된 라이브러리
import 'dart:typed_data';

class ApiWorkplace {
  static Future<List<DetailWorkplace>> fetchWorkplaces(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Check and refresh token if expired
    if (authProvider.isTokenExpired()) {
      bool refreshed = await authProvider.refreshAccessToken();
      print("refreshed");
      print(refreshed);
      if (!refreshed) {
        throw Exception('Failed to refresh token');
      }
    }

    final accessToken = authProvider.accessToken;
    final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/workplace/v1/info/all'),
        headers: {'Authorization': 'Bearer $accessToken'}
    );
    print(response.body);
    if (response.statusCode == 201) {

      List jsonResponse = json.decode(utf8.decode(response.bodyBytes))['data'] as List;
      return jsonResponse.map((data) {
        return DetailWorkplace.fromJson(data as Map<String, dynamic>);
      }).toList();
    } else {
      throw Exception('Failed to load workplaces from API');
    }

  }
  static Future<DetailWorkplace> fetchWorkplaceDetails(BuildContext context, int workplaceId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isTokenExpired()) {
      bool refreshed = await authProvider.refreshAccessToken();
      if (!refreshed) {
        throw Exception('Failed to refresh token');
      }
    }

    final accessToken = authProvider.accessToken;
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/api/workplace/v1/info?workplaceId=$workplaceId'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    // JSON 데이터가 한글 인코딩 문제를 겪는 경우 utf8 디코딩
    final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
    print(jsonResponse); // Log the entire JSON response for debugging

    if (response.statusCode == 200) {
      if (jsonResponse['data'] != null) {
        return DetailWorkplace.fromJson(jsonResponse['data']);
      } else {
        throw Exception('No data found in response');
      }
    } else {
      throw Exception('Failed to load workplace details');
    }
  }
  static Future<void> joinWorkplace(BuildContext context, int workplaceId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check and refresh token if expired
    if (authProvider.isTokenExpired()) {
      bool refreshed = await authProvider.refreshAccessToken();
      if (!refreshed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to refresh session, please log in again')),
        );
        return;
      }
    }

    final accessToken = authProvider.accessToken; // 액세스 토큰 가져오기
    final url = Uri.parse('${Config.baseUrl}/api/workplace/join/v1/request');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json', // Content-Type 설정
      },
      body: jsonEncode({
        'workplaceId': workplaceId, // JSON으로 변환할 데이터
      }),
    );

    print(response.request);
    print(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('성공'),
            content: Text('참여 요청이 성공적으로 전송되었습니다.'),
            actions: <Widget>[
              TextButton(
                child: Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop(); // 모달창을 닫습니다.
                },
              ),
            ],
          );
        },
      ).then((value) {
        Navigator.of(context).pop(); // 모달창 닫힌 후, 이전 화면으로 돌아갑니다.
      });
    }
 else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('참여 요청에 실패했습니다: ${response.body}')),
      );
    }
  }


  static Future<void> createWorkplace(BuildContext context, String workplaceName, String mainAddress, String subAddress, String tel, List<File> images) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isTokenExpired()) {
      bool refreshed = await authProvider.refreshAccessToken();
      if (!refreshed) {
        _showMessageDialog(context, 'Unable to refresh session, please log in again');
        return;
      }
    }

    final accessToken = authProvider.accessToken;
    var uri = Uri.parse('${Config.baseUrl}/api/workplace/v1/add');

    var tempDir = await getTemporaryDirectory();
    var tempFile = File('${tempDir.path}/temp.json');
    await tempFile.writeAsString(jsonEncode({
      "workplaceName": workplaceName,
      "mainAddress": mainAddress,
      "subAddress": subAddress,
      "workplaceTel": tel
    }));

    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'multipart/form-data'
      })
      ..files.add(await http.MultipartFile.fromPath(
          'workplaceAddDto',
          tempFile.path,
          contentType: MediaType('application', 'json')
      ));

    for (var image in images) {
      request.files.add(await http.MultipartFile.fromPath(
          'multipartFileList',
          image.path,
          contentType: MediaType.parse('image/jpeg')
      ));
    }

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    if (response.statusCode == 200 || response.statusCode == 201) {
      _showMessageDialog(context, 'Workplace successfully created');
    } else {
      _showMessageDialog(context, 'Failed to create workplace: $responseBody');
    }
  }

  static void _showMessageDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Notice'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(dialogContext); // 다이얼로그 닫기
                Navigator.pop(context); // 이전 화면으로 뒤로가기
              },
            ),
          ],
        );
      },
    );
  }

  // 이미지를 가져오는 함수
  static Future<Uint8List?> fetchImageWithAuth(String url, String? accessToken) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Failed to load image, status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching image: $e');
      return null;
    }
  }
  static Future<bool> deleteWorkplace(BuildContext context, int workplaceId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Check and refresh token if expired
      if (authProvider.isTokenExpired()) {
        bool refreshed = await authProvider.refreshAccessToken();
        print("refreshed");
        print(refreshed);
        if (!refreshed) {
          throw Exception('Failed to refresh token');
        }
      }

      final accessToken = authProvider.accessToken;
      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/api/workplace/v1/delete?workplaceId=$workplaceId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );


      if (response.statusCode == 200) {
        // Show success message
        _showMessageDialog(context, 'Workplace successfully deleted.');
        return true;
      } else {
        print('Error deleting workplace: ${response.body}');
        _showMessageDialog(context, 'Failed to delete workplace.');
        return false;
      }
    } catch (e) {
      print('Error deleting workplace: $e');
      _showMessageDialog(context, 'Error deleting workplace: $e');
      return false;
    }
  }

}
