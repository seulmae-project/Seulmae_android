import 'package:flutter/material.dart';
import 'user_roles.dart';

class AppState extends ChangeNotifier {
  int selectedIndex = 0;
  DateTime selectedDate = DateTime.now();
  DateTime? currentBackPressTime;
  String selectedWorkplace = '근무지 A';
  User? currentUser;
  String userRole = 'employee'; // 기본 역할

  final PageController pageController = PageController();
  int currentPage = 0;

  void setSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void setSelectedWorkplace(String workplace) {
    selectedWorkplace = workplace;
    Future.microtask(() {
      updateUserRole();
      notifyListeners();
    });
  }

  void setCurrentBackPressTime(DateTime time) {
    currentBackPressTime = time;
    notifyListeners();
  }

  void setCurrentUser(User user) {
    Future.microtask(() {
      currentUser = user;
      updateUserRole();
      notifyListeners();
    });
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

  void updateUserRole() {
    if (currentUser != null && currentUser!.roles.containsKey(selectedWorkplace)) {
      userRole = currentUser!.roles[selectedWorkplace]!;
    } else {
      userRole = 'employee'; // 기본 역할
    }
  }
}
