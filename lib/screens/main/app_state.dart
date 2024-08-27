import 'package:flutter/material.dart';
import 'package:sm3/screens/main/user_workplace_info.dart';
import 'user_roles.dart';

class AppState extends ChangeNotifier {
  int selectedIndex = 0;
  UserWorkplaceInfo? currentWorkplace;



  void setSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void setCurrentWorkplace(UserWorkplaceInfo workplace) {
    currentWorkplace = workplace;
    notifyListeners();
  }

  DateTime selectedDate = DateTime.now();
  DateTime? currentBackPressTime;
  String selectedWorkplace = '';
  User? currentUser;
  String userRole = 'employee'; // 기본 역할

  final PageController pageController = PageController();
  int currentPage = 0;



  void setSelectedWorkplace(String workplace) {
    selectedWorkplace = workplace;
    _updateUserRole();
    notifyListeners();
  }

  void setCurrentBackPressTime(DateTime time) {
    currentBackPressTime = time;
    notifyListeners();
  }

  void setCurrentUser(User user) {
    currentUser = user;
    _updateUserRole();
    notifyListeners();
  }

  void setCurrentPage(int page) {
    currentPage = page;
    notifyListeners();
  }

  void incrementDate() {
    selectedDate = selectedDate.add(Duration(days: 1));
    notifyListeners();
  }

  void decrementDate() {
    selectedDate = selectedDate.subtract(Duration(days: 1));
    notifyListeners();
  }

  String getFormattedDate() {
    return "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
  }

  void _updateUserRole() {
    if (currentUser != null && currentUser!.roles.containsKey(selectedWorkplace)) {
      userRole = currentUser!.roles[selectedWorkplace]!;
    } else {
      userRole = 'employee'; // 기본 역할
    }
    notifyListeners();
  }
  void resetState() {
    selectedIndex = 0;
    currentWorkplace = null;
    selectedDate = DateTime.now();
    currentBackPressTime = null;
    selectedWorkplace = '';
    currentUser = null;
    userRole = 'employee'; // 기본 역할
    pageController.dispose();
    currentPage = 0;
    notifyListeners();
  }
}
