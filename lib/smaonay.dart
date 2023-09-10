import 'package:flutter/material.dart';
import 'package:saraneladmin/customappbar.dart';

class SMAOnaySayfasi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: Text(
          'Burası SMA Onay Sayfası',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
