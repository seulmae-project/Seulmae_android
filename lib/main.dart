  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import 'package:sm3/providers/auth_provider.dart';
  import 'screens/main/app_state.dart';
  import 'screens/splash_screen.dart';
  import 'package:flutter_localizations/flutter_localizations.dart';

  void main() {
    runApp(MyApp());
  }

  class MyApp extends StatefulWidget {
    const MyApp({Key? key}) : super(key: key);

    @override
    _MyAppState createState() => _MyAppState();
  }

  class _MyAppState extends State<MyApp> with WidgetsBindingObserver {


    @override
    void dispose() {
      WidgetsBinding.instance.removeObserver(this);
      super.dispose();
    }

    @override
    void didChangeAppLifecycleState(AppLifecycleState state) {
      super.didChangeAppLifecycleState(state);
    }

    @override
    Widget build(BuildContext context) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => AppState()),
        ],
        child: MaterialApp(
          home: SplashScreen(),
        ),
      );
    }


  }
