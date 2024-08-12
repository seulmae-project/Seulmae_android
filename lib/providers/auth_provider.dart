import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../screens/main/app_state.dart';
import '../screens/main/user_roles.dart';
import '../screens/signin/login_screen.dart';

class AuthProvider with ChangeNotifier {
  String _userRole = 'employee';
  bool _isLoggedIn = false;
  User? _currentUser;

  String get userRole => _userRole;
  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;

  Future<void> login(String id, String password, BuildContext context) async {
    final url = Uri.parse('${Config.baseUrl}/api/users/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': id,
          'password': password,
        }),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Assuming the response contains user data
        _currentUser = User.fromJson(responseData['data']);
        _userRole = _currentUser!.roles.values.first;
        _isLoggedIn = true;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', _isLoggedIn);
        await prefs.setString('userRole', _userRole);
        await prefs.setString('userId', _currentUser!.id);

        final appState = Provider.of<AppState>(context, listen: false);
        appState.setCurrentUser(_currentUser!);
        appState.setSelectedWorkplace(appState.selectedWorkplace);

        notifyListeners();
      } else {
        _isLoggedIn = false;
        final responseData = json.decode(response.body);
        print('로그인 실패: ${responseData['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인에 실패하였습니다. 아이디와 비밀번호를 확인해주세요.')),
        );
      }
    } catch (error) {
      _isLoggedIn = false;
      print('로그인 요청 중 오류: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 요청 중 오류가 발생했습니다.')),
      );
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userRole = 'employee';
    _currentUser = null;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userRole');
    await prefs.remove('userId');

    notifyListeners();
  }

  Future<void> deleteAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isLoggedIn = false;
    _userRole = 'employee';
    _currentUser = null;

    notifyListeners();
  }

  Future<void> loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userRole = prefs.getString('userRole') ?? 'employee';
    String? userId = prefs.getString('userId');
    if (userId != null) {
      // Load the user details based on the stored userId
      // This could involve another API call to get the user details
      _currentUser = await fetchUserDetails(userId);
    }

    notifyListeners();
  }

  void updateUserRole(String workplace) {
    if (_currentUser != null && _currentUser!.roles.containsKey(workplace)) {
      _userRole = _currentUser!.roles[workplace]!;
      notifyListeners();
    }
  }

  Future<User?> fetchUserDetails(String userId) async {
    // You can implement this to fetch user details from an API using the userId
    // For now, we'll just return one of the example users based on the ID
    return userId == 'test2' ? testUser2 : testUser;
  }

  Future<void> signUp({
    required String accountId,
    required String password,
    required String phoneNumber,
    required String name,
    required bool isMale,
    required String birthday,
    required BuildContext context,
    File? profileImage,
  }) async {
    final url = Uri.parse('${Config.baseUrl}/api/users');

    try {
      var request = http.MultipartRequest('POST', url);

      // Adding form data
      request.fields['userSignUpDto'] = json.encode({
        "accountId": accountId,
        "password": password,
        "phoneNumber": phoneNumber,
        "name": name,
        "isMale": isMale,
        "birthday": birthday,
      });

      // Adding file if available
      if (profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          profileImage.path,
        ));
      }

      // Sending the request
      var response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입이 성공적으로 완료되었습니다.')),
        );
        // Handle successful signup, e.g., navigate to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        var responseData = await http.Response.fromStream(response);
        var decodedResponse = json.decode(responseData.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입에 실패하였습니다: ${decodedResponse['message']}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 중 오류가 발생했습니다.')),
      );
      print('회원가입 오류: $error');
    }
  }
}
