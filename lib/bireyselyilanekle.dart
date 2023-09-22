import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:saraneladmin/customappbar.dart';
import 'package:image_picker/image_picker.dart';

class BireyselBasvuruEkle extends StatefulWidget {
  @override
  _BireyselBasvuruEkleState createState() => _BireyselBasvuruEkleState();
}

class _BireyselBasvuruEkleState extends State<BireyselBasvuruEkle> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  String? _uploadedImageUrl1;
  bool isImage1Uploaded = false;
  int x = 14;

  String adsoyad = '';
  String aciklama = '';
  String il = '';
  String iletisimadres = '';
  String banka = '';
  String iban = '';
  String alici = '';
  String ibanaciklama = '';

  Future<void> _uploadImage(int imageNumber) async {
    final FileUploadInputElement uploadInput = FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files!.first;
      final reader = FileReader();

      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((event) async {
        final Uint8List? uploadedImage =
            Base64Decoder().convert(reader.result.toString().split(",").last);

        try {
          UploadTask uploadTask = FirebaseStorage.instance
              .ref('uploads/${file.name}')
              .putData(uploadedImage!);
          TaskSnapshot taskSnapshot = await uploadTask;
          String downloadUrl = await taskSnapshot.ref.getDownloadURL();

          setState(() {
            if (imageNumber == 1) {
              _uploadedImageUrl1 = downloadUrl;
              isImage1Uploaded = true;
            }
          });
        } catch (e) {
          print(e);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Görsel yüklenirken bir hata oluştu.")));
        }
      });
    });
  }

  Map<String, TextEditingController> controllers = {
    'adsoyad': TextEditingController(),
    'aciklama': TextEditingController(),
    'il': TextEditingController(),
    'iletisimadres': TextEditingController(),
    'banka' : TextEditingController(),
    'iban' : TextEditingController(),
    'alici' : TextEditingController(),
    'ibanaciklama' : TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    controllers['adsoyad']?.text = adsoyad;
    controllers['aciklama']?.text = aciklama;
    controllers['il']?.text = il;
    controllers['iletisimadres']?.text = iletisimadres;
    controllers['banka']?.text = banka;
    controllers['iban']?.text = iban;
    controllers['alici']?.text = alici;
    controllers['ibanaciklama']?.text = ibanaciklama;
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

      if (_uploadedImageUrl1 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lütfen tüm görsel alanlarını doldurunuz.')),
        );
        return;
      }

      var now = DateTime.now();
      var formatter = DateFormat('dd.MM.yyyy HH:mm');
      String formattedDate = formatter.format(now);

      yardimtalepleri.add({
        'adsoyad': controllers['adsoyad']?.text,
        'aciklama': controllers['aciklama']?.text,
        'il': controllers['il']?.text,
        'iletisimadres': controllers['iletisimadres']?.text,
        'eklenme_tarihi': formattedDate,
        'banka': controllers['banka']?.text,
        'iban': controllers['iban']?.text,
        'alici': controllers['alici']?.text,
        'ibanaciklama': controllers['ibanaciklama']?.text,
        'image': _uploadedImageUrl1,
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
      backgroundColor: Colors.blue.shade800,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(currentPage: 'BireyselBasvuruEkle'),
      body: Padding(
        padding: const EdgeInsets.only(top: 125, left: 245, right: 245),
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
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
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
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: controllers['aciklama'],
                cursorColor: Colors.blue.shade800,
                decoration: InputDecoration(
                  labelText: 'Açıklama',
                  labelStyle: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
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
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: controllers['il'],
                cursorColor: Colors.blue.shade800,
                decoration: InputDecoration(
                  labelText: 'İl',
                  labelStyle: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
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
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: controllers['banka'],
                cursorColor: Colors.blue.shade800,
                decoration: InputDecoration(
                  labelText: 'Banka Adı',
                  labelStyle: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen Banka Adı giriniz';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: controllers['iban'],
                cursorColor: Colors.blue.shade800,
                decoration: InputDecoration(
                  labelText: 'İban Bilgisi',
                  labelStyle: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen İban Bilgisi Giriniz';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: controllers['alici'],
                cursorColor: Colors.blue.shade800,
                decoration: InputDecoration(
                  labelText: 'Alıcı Adı',
                  labelStyle: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen Alıcı Adı giriniz';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: controllers['ibanaciklama'],
                cursorColor: Colors.blue.shade800,
                decoration: InputDecoration(
                  labelText: 'İbana Gönderim Açıklaması',
                  labelStyle: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen İbana Gönderim Açıklaması giriniz';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: controllers['iletisimadres'],
                cursorColor: Colors.blue.shade800,
                decoration: InputDecoration(
                  labelText: 'İletişim Adresi',
                  labelStyle: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
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
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                ),
                child: onayagorseliyuklebutonu(),
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

  InkWell onayagorseliyuklebutonu() {
    return InkWell(
      onTap: () => _uploadImage(1),
      child: Column(
        children: [
          Icon(
            Icons.add_a_photo,
            color: Colors.white,
            size: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              "Kampanya Onay Görseli Yükle",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 10),
            child: Text(
              "Kampanya onay belgesini yükleyiniz.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ),
          if (isImage1Uploaded)
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            )
        ],
      ),
    );
  }
}
