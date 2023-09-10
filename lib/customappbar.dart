import 'package:flutter/material.dart';
import 'package:saraneladmin/smaonay.dart';

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
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => SMAOnaySayfasi()));
          },
          child: Text(
            'SMA Onay',
            style: TextStyle(color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () {
            // Gelen Bildirimler işlevini buraya yazın
          },
          child: Text(
            'Gelen Bildirimler',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
