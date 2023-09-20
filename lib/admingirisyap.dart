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
      backgroundColor: Colors.blue.shade800,
      body: Padding(
        padding: const EdgeInsets.only(top: 250, right: 500, left: 500),
        child: Column(
          children: [
            SizedBox(height: 20),
            Center(
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Kullanıcı Adı',
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onSubmitted: (_) => _login(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Şifre',
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(30), 
                ),
              ),
              onSubmitted: (_) => _login(),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _login,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    Colors.blue.shade800), 
                side: MaterialStateProperty.all(BorderSide(
                    color: Color.fromARGB(255, 54, 50, 50),
                    width: 2)), // Çerçeve ekledik
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(30), 
                )),
              ),
              child: Text(
                'Giriş Yap',
                style: TextStyle(
                    color: Color.fromARGB(255, 54, 50, 50),
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
