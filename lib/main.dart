import 'dart:html';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saraneladmin/admingirisyap.dart';

import 'anasayfa.dart';
/* import 'package:saraneladmin/anasayfa.dart'; */

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyDN8mGKUitQTxfYOtYt7G4ZX8mq4ysgvNw",
          authDomain: "saranelapp.firebaseapp.com",
          projectId: "saranelapp",
          storageBucket: "saranelapp.appspot.com",
          messagingSenderId: "164382619834",
          appId: "1:164382619834:web:4d8cbf47ec0489149d2a83"));
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
      onGenerateRoute: (settings) {
        String? userToken = window.localStorage['userToken'];
        if (userToken != null) {
          // Kullanıcı zaten giriş yapmış, AnaSayfa'ya yönlendir
          return MaterialPageRoute(builder: (context) => Anasayfa());
        } else {
          // Kullanıcı giriş yapmamış, GirisSayfasi'na yönlendir
          return MaterialPageRoute(builder: (context) => AdminLoginPage());
        }
      },
      debugShowCheckedModeBanner: false,
      title: 'Saranel Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: AdminLoginPage(),
      ),
    );
  }
}
