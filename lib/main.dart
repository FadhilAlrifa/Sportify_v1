import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'routes.dart';
import 'providers/auth_provider.dart';
import 'providers/court_provider.dart';
import 'providers/booking_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/vendor/vendor_home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: 'https://fsvthiragrerthjcsdzs.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZzdnRoaXJhZ3JlcnRoamNzZHpzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUzNTgzNjEsImV4cCI6MjA4MDkzNDM2MX0.uWITztsUhovjSLN4dHtkMHdF1bxTOs42yQOpKH3r7s0',
  );

  await initializeDateFormatting('id_ID', null);

  runApp(const SportifyApp());
}

class SportifyApp extends StatelessWidget {
  const SportifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CourtProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MaterialApp(
        title: 'Sportify',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
        ),

        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isLoggedIn) {
              // LOGIKA PENGECEKAN ROLE
              if (auth.role == 'vendor') {
                return const VendorHomeScreen(); // Masuk Dashboard Vendor
              } else {
                return const HomeScreen(); // Masuk Dashboard User Biasa
              }
            }
            return const LoginScreen();
          },
        ),

        onGenerateRoute: Routes.generate,
      ),
    );
  }
}
