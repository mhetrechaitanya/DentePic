import 'package:Dentepic/screens/admin/admin_bottom_nav.dart';
import 'package:Dentepic/screens/auth/login/login_tab.dart';
import 'package:Dentepic/screens/doctor/doctor_bottom_nav.dart';
import 'package:Dentepic/services/notifi_service.dart';
import 'package:Dentepic/theme/theme_notifer,dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app_export.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
   WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  ///Please update theme as per your need if required.
  ThemeHelper().changeTheme('primary');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
     var themeNotifier = Provider.of<ThemeNotifier>(context);

    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          theme: ThemeHelper().getLightThemeData(), // Light theme
          darkTheme: ThemeHelper().getDarkThemeData(), // Dark theme
          themeMode: themeNotifier.themeMode, // Theme
          title: 'app',
          debugShowCheckedModeBanner: false,
          home: Splash(), // Add a SplashScreen to check user role
        );
      },
    );
  }
}

class Splash extends StatefulWidget {
  const Splash({Key? key});

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkUserRoleAndNavigate(context);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    // Display loading indicator while checking user role
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> checkUserRoleAndNavigate(BuildContext context) async {
    // Retrieve user role from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userRole = prefs.getString('userRole');

    // Navigate based on user role
    if (userRole == 'doctors') {
      // If user is a doctor, navigate to DoctorBottomNav screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => DoctorBottom(
                  userId: '',
                )),
      );
    } else if (userRole == 'admins') {
      // If user is an admin, navigate to AdminBottomNav screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => AdminBottom(
                  userId: '',
                )),
      );
    } else {
      // If user role is not set or unknown, navigate to LoginTab screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginTab()),
      );
    }
  }
}
