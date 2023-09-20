import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

import 'package:saraneladmin/customappbar.dart';

class DernekEklemeSayfasi extends StatefulWidget {
  @override
  _DernekEklemeSayfasiState createState() => _DernekEklemeSayfasiState();
}

class _DernekEklemeSayfasiState extends State<DernekEklemeSayfasi> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();
  final TextEditingController _kurumktController = TextEditingController();
  final TextEditingController _kurumgmController = TextEditingController();
  final TextEditingController _kurumHakkindaController =
      TextEditingController();
  final TextEditingController _webSiteUrlController = TextEditingController();

  html.File? _logoFile;
  String? _logoUrl;

  String? _logoFileName;

  void _pickLogo() async {
    final html.InputElement uploadInput = html.InputElement(type: 'file')
      ..accept = 'image/*'
      ..multiple = false;
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.length > 0) {
        final file = files[0];
        setState(() {
          _logoFile = file;
          _logoFileName = file.name;
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Dosya seçimi iptal edildi')));
      }
    });
  }

  Future<bool> _uploadLogo() async {
    if (_logoFile == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lütfen bir dosya seçin')));
      return false;
    }

    try {
      String filePath =
          'stkLogoları/${_logoFileName ?? DateTime.now().millisecondsSinceEpoch}';

      final reader = html.FileReader();
      reader.readAsArrayBuffer(_logoFile!);
      await reader.onLoad.first;

      final blob = html.Blob([reader.result]);
      final storageRef = FirebaseStorage.instance.ref().child(filePath);
      final uploadTask = storageRef.putBlob(blob);
      await uploadTask;
      _logoUrl = await storageRef.getDownloadURL();
      return true;
    } catch (e) {
      print('Logo yükleme hatası: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Logo yükleme hatası: $e')));
      return false;
    }
  }

  void _dernekEkle() async {
    if (_formKey.currentState!.validate()) {
      bool uploadSuccess = await _uploadLogo();
      if (uploadSuccess) {
        try {
          await FirebaseFirestore.instance.collection('dernekler').add({
            'logoPath': _logoUrl,
            'ad': _adController.text,
            'kategori': _kategoriController.text,
            'kurumkt': _kurumktController.text,
            'kurumgm': _kurumgmController.text,
            'kurumHakkinda': _kurumHakkindaController.text,
            'webSiteUrl': _webSiteUrlController.text,
          });
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Dernek başarıyla eklendi!')));

          _formKey.currentState!.reset();

          _adController.clear();
          _kategoriController.clear();
          _kurumktController.clear();
          _kurumgmController.clear();
          _kurumHakkindaController.clear();
          _webSiteUrlController.clear();

          setState(() {
            _logoFile = null;
            _logoUrl = null;
            _logoFileName = null;
          });
        } catch (e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Bir hata oluştu: $e')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Logo yüklenemedi. Lütfen tekrar deneyin.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade800,
      appBar: CustomAppBar(currentPage: 'DernekEklemeSayfasi'),
      body: Padding(
        padding: const EdgeInsets.only(top: 125, left: 245, right: 245),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_logoFile != null)
                FutureBuilder<Uint8List>(
                  future: _readFileAsBytes(_logoFile!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Hata: ${snapshot.error}'));
                      } else {
                        return Image.memory(
                          snapshot.data!,
                          height: 100,
                          width: 100,
                        );
                      }
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.white), 
                ),
                onPressed: _pickLogo,
                child: Text(
                  'Logo Seç',
                  style: TextStyle(color: Colors.blue.shade800),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: _adController,
                cursorColor: Colors.blue.shade800,
                decoration: InputDecoration(
                  labelText: 'Dernek Adı',
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
                    return 'Lütfen bir dernek adı girin';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: _kategoriController,
                cursorColor: Colors.blue.shade800,
                decoration: InputDecoration(
                  labelText: 'Kategori',
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
                    return 'Lütfen bir kategori girin';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: _kurumktController,
                cursorColor: Colors.blue.shade800,
                decoration: InputDecoration(
                    labelText: 'Kurum Kuruluş Tarihi (örn: 1970)',
                    labelStyle: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.w400,
                        fontSize: 12),
                    filled: true,
                    fillColor: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir kuruluş tarihi girin';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: _kurumgmController,
                cursorColor: Colors.blue.shade800,
                decoration: InputDecoration(
                  labelText: 'Kurum Genel Merkezi (örn: Ankara, Türkiye)',
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
                    return 'Lütfen bir Genel Merkez girin';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: _kurumHakkindaController,
                cursorColor: Colors.blue.shade800,
                decoration: InputDecoration(
                  labelText: 'Kurum Hakkında',
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
                    return 'Lütfen kurum hakkında bilgi girin';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: _webSiteUrlController,
                cursorColor: Colors.blue.shade800,
                decoration: InputDecoration(
                  labelText: 'Web Sitesi URL\'si',
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
                    return 'Lütfen bir web sitesi URL\'si girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: _dernekEkle,
                child: Text(
                  'Dernek Ekle',
                  style: TextStyle(color: Colors.blue.shade800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Uint8List> _readFileAsBytes(html.File file) async {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    return reader.result as Uint8List;
  }
}
