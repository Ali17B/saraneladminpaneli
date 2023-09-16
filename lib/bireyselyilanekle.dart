import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:saraneladmin/customappbar.dart'; // DateTime formatlamak için intl paketini import ettik

class BireyselBasvuruEkle extends StatefulWidget {
  @override
  _BireyselBasvuruEkleState createState() => _BireyselBasvuruEkleState();
}

class _BireyselBasvuruEkleState extends State<BireyselBasvuruEkle> {
  final _formKey = GlobalKey<FormState>();
  String adsoyad = '';
  String aciklama = '';
  String il = '';
  String iletisimadres = '';

  Map<String, TextEditingController> controllers = {
    'adsoyad': TextEditingController(),
    'aciklama': TextEditingController(),
    'il': TextEditingController(),
    'iletisimadres': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    controllers['adsoyad']?.text = adsoyad;
    controllers['aciklama']?.text = aciklama;
    controllers['il']?.text = il;
    controllers['iletisimadres']?.text = iletisimadres;
  }

  @override
  void dispose() {
    controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      CollectionReference yardimtalepleri =
          FirebaseFirestore.instance.collection('yardimtalepleri');

      var now = DateTime.now();
      var formatter = DateFormat('dd.MM.yyyy HH:mm');
      String formattedDate = formatter.format(now);

      yardimtalepleri.add({
        'adsoyad': controllers['adsoyad']?.text,
        'aciklama': controllers['aciklama']?.text,
        'il': controllers['il']?.text,
        'iletisimadres': controllers['iletisimadres']?.text,
        'eklenme_tarihi': formattedDate,
      }).then((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.blue.shade800,
              title: Text('İlanınız İncelemeye Alındı!',
                  style: TextStyle(color: Colors.white)),
              content: Text(
                'Bilgiler 48 saat içinde incelenecektir. Herhangi bir eksik tespit edilmesi durumunda, vermiş olduğunuz iletişim adreslerinden bilgilendirme yapılacaktır.',
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  child: Text('Kapat', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen eksik alanları tamamlayın.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar:
          CustomAppBar(), // CustomAppBar() kaldırıldı çünkü bu sınıf kodda tanımlı değil
      body: Padding(
        padding: const EdgeInsets.only(top: 25, left: 16, right: 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: controllers['adsoyad'],
                cursorColor: Colors.blue.shade800,
                decoration: InputDecoration(
                  labelText: 'Ad Soyad',
                  labelStyle: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen adınızı ve soyadınızı giriniz';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: controllers['aciklama'],
                cursorColor: Colors.blue.shade800,
                decoration: InputDecoration(
                  labelText: 'Açıklama',
                  labelStyle: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir açıklama giriniz';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: controllers['il'],
                cursorColor: Colors.blue.shade800,
                decoration: InputDecoration(
                  labelText: 'İl',
                  labelStyle: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen ilinizi giriniz';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: controllers['iletisimadres'],
                cursorColor: Colors.blue.shade800,
                decoration: InputDecoration(
                  labelText: 'İletişim Adresi',
                  labelStyle: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir iletişim adresi giriniz';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Gönder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
