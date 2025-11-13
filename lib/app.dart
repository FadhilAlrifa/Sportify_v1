import 'package:flutter/material.dart';
import 'routes.dart';

class SportifyApp extends StatelessWidget {
  const SportifyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sportify',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: Routes.login,
      onGenerateRoute: Routes.generate,
    );
  }
}
