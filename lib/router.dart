import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/Ui/Onboardings/OnBoardingScreen.dart';
import '/Ui/Profile/ProfilePage.dart';
import '/Ui/Profile/editProfile.dart';
import './/Ui/BasePage/BasePage.dart';
import './/Ui/Home/HomePage.dart';
import './/Ui/Notifications/NotificationsPage.dart';
import './/Ui/Splash/SplashPage.dart';
import 'Ui/Auth/LoginPage.dart';

class AppRouter {
  static String currentRoute = "/";
  static Route<dynamic> generateRoute(RouteSettings settings) {
    currentRoute = settings.name ?? "/";
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
            builder: (_) => SplashPage(), settings: settings);
      case '/login':
        return CupertinoPageRoute(
            builder: (_) => LoginPage(), settings: settings);
      case '/base':
        return CupertinoPageRoute(
            builder: (_) => BasePage(), settings: settings);
      case '/home':
        return CupertinoPageRoute(
            builder: (_) => HomePage(), settings: settings);
      case '/editProfile':
        return CupertinoPageRoute(
            builder: (_) => EditProfilePage(), settings: settings);
      case '/profile':
        return CupertinoPageRoute(
            builder: (_) => ProfilePage(), settings: settings);
      case '/notifications':
        return CupertinoPageRoute(
            builder: (_) => NotificationsPage(), settings: settings);
      case '/onboard':
        return CupertinoPageRoute(
            builder: (_) => OnBoardingScreen(), settings: settings);

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
