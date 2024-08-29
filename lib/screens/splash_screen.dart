import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmfao3/providers/auth_provider.dart';
import 'package:tmfao3/screens/main/no_workplace_screen.dart';
import 'main/main_screen.dart';
import 'main/workplace/regist_work_place.dart';
import 'signin/login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirectToNextScreen();
    });
  }

  void _redirectToNextScreen() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadUserData();

    if (authProvider.isLoggedIn) {
      bool hasWorkplaces = await authProvider.userFetchWorkplaces(context);
      if (hasWorkplaces) {

        _navigateToScreen(MainScreen());
      } else {
        _navigateToScreen(NoWorkplaceScreen());
      }
    } else {
      _navigateToScreen(LoginScreen());
    }
  }

  void _navigateToScreen(Widget screen) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
