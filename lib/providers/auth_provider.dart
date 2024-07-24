import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../screens/main/app_state.dart';
import '../screens/main/user_roles.dart';

class AuthProvider with ChangeNotifier {
  String _userRole = 'employee';
  bool _isLoggedIn = false;
  User? _currentUser;

  String get userRole => _userRole;
  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;

  Future<void> login(String id, String password, BuildContext context) async {
    if ((id == 'test' && password == 'test') || (id == 'test2' && password == 'test2')) {
      _isLoggedIn = true;
      _currentUser = id == 'test2' ? testUser2 : testUser;
      _userRole = _currentUser!.roles.values.first;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', _isLoggedIn);
      await prefs.setString('userRole', _userRole);
      await prefs.setString('userId', _currentUser!.id);

      final appState = Provider.of<AppState>(context, listen: false);
      appState.setCurrentUser(_currentUser!);

      notifyListeners();
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
      _currentUser = userId == 'test2' ? testUser2 : testUser;
    }

    notifyListeners();
  }

  void updateUserRole(String workplace) {
    if (_currentUser != null && _currentUser!.roles.containsKey(workplace)) {
      _userRole = _currentUser!.roles[workplace]!;
      notifyListeners();
    }
  }
}
