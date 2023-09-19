import 'package:flutter/material.dart';
import 'package:saraneladmin/anasayfa.dart';
import 'package:saraneladmin/bireyselyardimonaywdg.dart';
import 'package:saraneladmin/bireyselyilanekle.dart';
import 'package:saraneladmin/smaonaywdg.dart';
import 'package:saraneladmin/admingirisyap.dart';
import 'package:saraneladmin/stk_dernekEkle.dart';
import 'ilaneklewdg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentPage;
  @override
  final Size preferredSize;

  CustomAppBar({
    Key? key,
    required this.currentPage,
  })  : preferredSize = Size.fromHeight(56.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('SARANEL PLATFORMU'),
      actions: [
        _buildTextButton('Anasayfa', 'Anasayfa', context,
            Anasayfa()), // Anasayfa widget'ınızın adını 'Anasayfa' olarak varsayıyorum. Lütfen gerçek adıyla değiştirin.
        _buildTextButton('SMA Manuel Ekleme', 'IlanEkle', context, IlanEkle()),
        _buildTextButton('BireyselYT Manuel Ekleme', 'BireyselBasvuruEkle',
            context, BireyselBasvuruEkle()),
        _buildTextButton('Dernek-STK Ekleme', 'DernekEklemeSayfasi', context,
            DernekEklemeSayfasi()),
        _buildTextButton('SMA Onay', 'SmaOnayPage', context, SmaOnayPage()),
        _buildTextButton(
            'Bireysel Onay', 'bireyselonay', context, bireyselonay()),
        _buildTextButton(
            'Çıkış Yap', 'AdminLoginPage', context, AdminLoginPage(),
            color: Colors.red),
      ],
    );
  }

  Widget _buildTextButton(
      String title, String pageKey, BuildContext context, Widget targetPage,
      {Color color = Colors.white}) {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => targetPage));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        decoration: currentPage == pageKey
            ? BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(8.0),
              )
            : null,
        child: Text(
          title,
          style: TextStyle(
            color:
                currentPage == pageKey ? Colors.white.withOpacity(0.5) : color,
          ),
        ),
      ),
    );
  }
}
