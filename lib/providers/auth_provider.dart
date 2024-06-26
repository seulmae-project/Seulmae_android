import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String _userRole = 'employee';
  bool _isLoggedIn = false;

  String get userRole => _userRole;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> login(String id, String password) async {
    // Here you would normally make an API call to validate the user credentials
    if ((id == 'test' && password == 'test') || (id == 'test2' && password == 'test2')) {
      _isLoggedIn = true;
      _userRole = id == 'test2' ? 'manager' : 'employee';
      notifyListeners();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', _isLoggedIn);
      await prefs.setString('userRole', _userRole);
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userRole = 'employee';
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userRole');
  }

  Future<void> deleteAccount() async {
    // Here you would normally make an API call to delete the user account
    // For now, we'll just simulate the deletion by clearing shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isLoggedIn = false;
    _userRole = 'employee';
    notifyListeners();
  }

  Future<void> loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userRole = prefs.getString('userRole') ?? 'employee';
    notifyListeners();
  }
}
