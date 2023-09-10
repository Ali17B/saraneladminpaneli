import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saraneladmin/customappbar.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Anasayfa(),
    );
  }
}

class AuthProvider extends ChangeNotifier {
  String? _username;

  String? get username => _username;

  void login(String username) {
    _username = username;
    notifyListeners();
  }

  void logout() {
    _username = null;
    notifyListeners();
  }
}

class Anasayfa extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /* final authProvider = Provider.of<AuthProvider>(context); */
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
          child: Text("Saranel admin panele Hoş Geldiniz",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800))),
    );
  }
}
