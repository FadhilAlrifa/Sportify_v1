import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/court_detail_screen.dart';
import 'screens/home/booking_screen.dart';

class Routes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const courtDetail = '/court';
  static const booking = '/booking';

  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      // case register:
      //   return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case courtDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
            builder: (_) => CourtDetailScreen(courtId: args?['id']));
      case booking:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
            builder: (_) => BookingScreen(courtId: args?['id']));
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
