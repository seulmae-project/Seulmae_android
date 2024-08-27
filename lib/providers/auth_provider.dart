  import 'dart:async';
  import 'dart:convert';
  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'package:shared_preferences/shared_preferences.dart';
import 'package:sm3/screens/main/no_workplace_screen.dart';
  import '../config.dart';
import '../screens/main/employee/employee_dashboard_screen.dart';
  import '../screens/main/main_screen.dart';
import '../screens/main/manage/manage_dashboard_screen.dart';
import '../screens/main/user_workplace_info.dart';

  class AuthProvider with ChangeNotifier {
    bool _isLoggedIn = false;
    String? _accessToken;
    String? _refreshToken;
    List<UserWorkplaceInfo> _workplaces = [];
    DateTime? _tokenExpiryTime;
    int? _selectedWorkplaceId;  // 추가된 변수
    int? get selectedWorkplaceId => _selectedWorkplaceId;

    bool get isLoggedIn => _isLoggedIn;
    String? get accessToken => _accessToken;
    String? get refreshToken => _refreshToken;
    List<UserWorkplaceInfo> get workplaces => _workplaces;

    Future<void> loadUserData() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _accessToken = prefs.getString('accessToken');
      _refreshToken = prefs.getString('refreshToken');
      _tokenExpiryTime = prefs.getString('tokenExpiryTime') != null
          ? DateTime.parse(prefs.getString('tokenExpiryTime')!)
          : null;

      notifyListeners();
    }

    Future<void> login(String id, String password, BuildContext context) async {
      try {
        final url = Uri.parse('${Config.baseUrl}/api/users/login');
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'accountId': id,
            'password': password,
          }),
        );
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          _accessToken = responseData['data']['tokenResponse']['accessToken'];
          _refreshToken = responseData['data']['tokenResponse']['refreshToken'];
          int expiresIn = responseData['data']['expiresIn'] as int? ?? 3600;
          _tokenExpiryTime = DateTime.now().add(Duration(seconds: expiresIn));
          _isLoggedIn = true;

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', _accessToken!);
          await prefs.setString('refreshToken', _refreshToken!);
          await prefs.setBool('isLoggedIn', _isLoggedIn);
          await prefs.setString('tokenExpiryTime', _tokenExpiryTime!.toIso8601String());

          notifyListeners();

          // Check for workplaces and navigate based on their presence
          bool hasWorkplaces = await userFetchWorkplaces(context);
          if (hasWorkplaces) {
            final int? workplaceId = selectedWorkplaceId;
            if (workplaceId != null) {
              UserWorkplaceInfo? workplaceInfo = await fetchUserWorkplaceInfo(workplaceId);
              if (workplaceInfo != null) {
                await saveSelectedWorkplaceId(workplaceId);

                // Navigate to the MainScreen with BottomNavigationBar
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                );
              } else {
                print("근무지 정보가 없습니다.");
              }
            }
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => NoWorkplaceScreen()),
            );
          }
        } else {
          _isLoggedIn = false;
          final errorResponse = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('로그인 실패: ${errorResponse['message']}'),
          ));
        }
      } catch (e) {
        _isLoggedIn = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 중 문제가 발생했습니다. 나중에 다시 시도해주세요.')),
        );
      }
    }

    Future<void> logout() async {
      _isLoggedIn = false;
      _accessToken = null;
      _refreshToken = null;
      _tokenExpiryTime = null;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      notifyListeners();
    }
    // 로컬에 저장된 선택된 근무지 불러오기
    Future<void> loadSelectedWorkplaceId() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _selectedWorkplaceId = prefs.getInt('selectedWorkplaceId');
    }


    Future<void> saveSelectedWorkplaceId(int workplaceId) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('selectedWorkplaceId', workplaceId);
      _selectedWorkplaceId = workplaceId;
      notifyListeners();
    }
    Future<bool> userFetchWorkplaces(BuildContext context) async {
      if (await _checkAndRefreshTokenIfNeeded()) {
          try {
            final url = Uri.parse('${Config.baseUrl}/api/workplace/v1/info/join');
          final response = await http.get(url, headers: {
            'Authorization': 'Bearer $_accessToken',
            'Accept': 'application/json; charset=utf-8',
          });
          print(response.body);
          if (response.statusCode == 200) {
            final responseData = json.decode(response.body);
            _workplaces = (responseData['data'] as List?)
                ?.map((workplace) => UserWorkplaceInfo.fromJson(workplace))
                .toList() ?? [];;
            notifyListeners();
            if (_workplaces.isNotEmpty) {
              // 저장된 근무지 ID가 있는지 확인
              await loadSelectedWorkplaceId();
              if (_selectedWorkplaceId == null || !_workplaces.any((workplace) => workplace.workplaceId == _selectedWorkplaceId)) {
                // 저장된 근무지가 없거나, 현재 리스트에 없는 경우 첫 번째 근무지 선택
                _selectedWorkplaceId = _workplaces.first.workplaceId;
                await saveSelectedWorkplaceId(_selectedWorkplaceId!);
              }
              return true;
            }
          }
          return false;
        } catch (e) {
          print('Error fetching workplaces: $e');
          return false;
        }
      }
      return false;
    }
    Future<UserWorkplaceInfo?> fetchUserWorkplaceInfo(int? workplaceId) async {
      try {
        // Ensure workplaceId is not null
        if (workplaceId == null) {
          throw Exception('Workplace ID is null');
        }

        // Ensure _workplaces is not empty
        if (_workplaces.isEmpty) {
          throw Exception('Workplaces list is empty');
        }

        // Find the workplace with the given ID
        UserWorkplaceInfo workplaceInfo = _workplaces.firstWhere(
              (workplace) => workplace.workplaceId == workplaceId,
          orElse: () => _workplaces.first, // Fallback if not found
        );

        return workplaceInfo;
      } catch (e) {
        print("Error fetching workplace info: $e");
        return null; // Return null in case of error
      }
    }




    Future<bool> _checkAndRefreshTokenIfNeeded() async {
      if (_accessToken != null && (_tokenExpiryTime == null || DateTime.now().isAfter(_tokenExpiryTime!))) {
        return await refreshAccessToken();
      }
      return true;
    }

    Future<bool> refreshAccessToken() async {
      print("start_refreshAccessToken");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? refreshToken = prefs.getString('refreshToken');
      String? accessToken = prefs.getString('accessToken');

      if (refreshToken == null || accessToken == null) {
        print('Tokens are null, logging out');
        return false; // Indicate failure
      }

      final url = Uri.parse('${Config.baseUrl}/api/users/refresh-token');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization-refresh': 'Bearer $refreshToken',
          'Authorization': 'Bearer $accessToken',
        },
      );
      print(response.body);

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          try {
            final responseData = json.decode(response.body);
            _accessToken = responseData['data']['accessToken'];
            _refreshToken = responseData['data']['refreshToken'];
            final expiresIn = responseData['data']['expiresIn'] ?? 3600; // 기본 값을 설정합니다 (예: 1시간)
            _tokenExpiryTime = DateTime.now().add(Duration(seconds: expiresIn));
            print(responseData['data']['accessToken']);
            print(responseData['data']['refreshToken']);
            await prefs.setString('accessToken', _accessToken!);
            await prefs.setString('refreshToken', _refreshToken!);
            await prefs.setString('tokenExpiryTime', _tokenExpiryTime!.toIso8601String());

            notifyListeners();
            return true; // 성공을 나타냅니다
          } catch (e) {
            print('Error parsing response body: $e');
            return false; // 실패를 나타냅니다
          }
        }
      } else if (response.statusCode == 302) {
        print('Received a 302 response, possible redirection. Check server configuration.');
        return false; // Indicate failure
      } else {
        print('Failed to refresh token: Status code ${response.statusCode}');
        print('Response body: ${response.body}');
        return false; // Indicate failure
      }

      // 모든 경우를 처리하지 않았을 경우 기본적으로 false 반환
      return false;
    }



    bool isTokenExpired() {
      print(_refreshToken);
      print(_accessToken);
      if (_tokenExpiryTime == null) {
        return true;  // Consider the token expired if there's no expiry time set
      }
      return DateTime.now().isAfter(_tokenExpiryTime!);
    }

  }
