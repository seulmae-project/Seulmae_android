import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmfao3/providers/auth_provider.dart';
import 'screens/main/app_state.dart';
import 'screens/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';  // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Ensures binding for async setup
  await Firebase.initializeApp();  // Initialize Firebase

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);  // Add observer for app lifecycle
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);  // Remove observer on dispose
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Handle app lifecycle state changes if needed
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),  // Auth provider
        ChangeNotifierProvider(create: (_) => AppState()),  // App state providerㅗ
      ],
      child: MaterialApp(
        home: SplashScreen(),  // Initial screen to display
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''), // English
          // Add other supported locales if needed
        ],
        debugShowCheckedModeBanner: false,  // Disable debug banner
      ),
    );
  }
}
