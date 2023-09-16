import 'package:flutter/material.dart';
import 'package:saraneladmin/bireyselyardimonaywdg.dart';
import 'package:saraneladmin/bireyselyilanekle.dart';
import 'package:saraneladmin/smaonaywdg.dart';
import 'package:saraneladmin/admingirisyap.dart'; // AdminLoginPage için import

import 'ilaneklewdg.dart'; // AuthProvider sınıfını içe aktardığınız dosyanın yolu

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  CustomAppBar({
    Key? key,
  })  : preferredSize = Size.fromHeight(56.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('SARANEL'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        IlanEkle())); // IlanEkle widget'ını doğru şekilde içe aktardığınızdan emin olun
          },
          child: Text(
            'SMA Manuel Ekleme',
            style: TextStyle(color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        BireyselBasvuruEkle())); // IlanEkle widget'ını doğru şekilde içe aktardığınızdan emin olun
          },
          child: Text(
            'BireyselYT Manuel Ekleme',
            style: TextStyle(color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => SmaOnayPage()));
          },
          child: Text(
            'SMA Onay',
            style: TextStyle(color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => bireyselonay()));
          },
          child: Text(
            'Bireysel Onay',
            style: TextStyle(color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => AdminLoginPage()));
          },
          child: Text(
            'Çıkış Yap',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
