import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saraneladmin/anasayfa.dart';

class AdminLoginPage extends StatefulWidget {
  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    DocumentSnapshot adminDoc = await FirebaseFirestore.instance
        .collection('adminoturum')
        .doc('8POvCoNNlCIEe8tP9R0K')
        .get();

    if (adminDoc.exists) {
      if (adminDoc['kullaniciadi'] == username &&
          adminDoc['sifre'] == password) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Anasayfa()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kullanıcı adı veya şifre yanlış!')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Admin bilgisi bulunamadı.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Girişi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Kullanıcı Adı'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Şifre'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Giriş Yap'),
            ),
          ],
        ),
      ),
    );
  }
}
