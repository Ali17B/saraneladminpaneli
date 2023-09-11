import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saraneladmin/customappbar.dart';
import 'anasayfa.dart';

class IlanEkle extends StatefulWidget {
  @override
  _IlanEkleState createState() => _IlanEkleState();
}

class _IlanEkleState extends State<IlanEkle> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  String? _uploadedImageUrl1;
  String? _uploadedImageUrl2;

  bool isImage1Uploaded = false;
  bool isImage2Uploaded = false;

  String adSoyad = '';
  String kampanyaTuru = 'SMA';
  String tamamlanmaOrani = '';
  String bankaAdi = '';
  String iban = '';
  String alici = '';
  String aciklama = '';
  String ekDetaylar = '';
  String ilgiliadSoyad = '';
  String email = '';
  String telefonNo = '';

  get html => null;

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
            } else if (imageNumber == 2) {
              _uploadedImageUrl2 = downloadUrl;
              isImage2Uploaded = true;
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
    'ilgiliadSoyad': TextEditingController(),
    'telefonNo': TextEditingController(),
    'email': TextEditingController(),
    'adSoyad': TextEditingController(),
    'tamamlanmaOrani': TextEditingController(),
    'bankaAdi': TextEditingController(),
    'iban': TextEditingController(),
    'alici': TextEditingController(),
    'aciklama': TextEditingController(),
    'ekDetaylar': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    controllers['ilgiliadSoyad']?.text = ilgiliadSoyad;
    controllers['telefonNo']?.text = telefonNo;
    controllers['email']?.text = email;
    controllers['adSoyad']?.text = adSoyad;
    controllers['kampanyaTuru']?.text = kampanyaTuru;
    controllers['tamamlanmaOrani']?.text = tamamlanmaOrani;
    controllers['bankaAdi']?.text = bankaAdi;
    controllers['iban']?.text = iban;
    controllers['alici']?.text = alici;
    controllers['aciklama']?.text = aciklama;
    controllers['ekDetaylar']?.text = ekDetaylar;
  }

  @override
  void dispose() {
    controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Görsel alanlarının kontrolü
      if (_uploadedImageUrl1 == null || _uploadedImageUrl2 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lütfen tüm görsel alanlarını doldurunuz.')),
        );
        return;
      }

      // Diğer zorunlu alanların kontrolü
      if (ilgiliadSoyad.isEmpty ||
          telefonNo.isEmpty ||
          email.isEmpty ||
          adSoyad.isEmpty ||
          kampanyaTuru.isEmpty ||
          tamamlanmaOrani.isEmpty ||
          bankaAdi.isEmpty ||
          iban.isEmpty ||
          alici.isEmpty ||
          aciklama.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lütfen tüm alanları doldurunuz.')),
        );
        return;
      }

      try {
        CollectionReference sma = FirebaseFirestore.instance.collection('sma');

        // Yeni bir doküman ekleyin
        DocumentReference docRef = await sma.add({
          'aciklama1': adSoyad,
          'kampanyaTuru': kampanyaTuru,
          'bagis': tamamlanmaOrani,
          'banka2': bankaAdi,
          'iban': iban,
          'alici': alici,
          'aciklamasi': aciklama,
          'ilgiliadSoyad': ilgiliadSoyad,
          'email': email,
          'telefonNo': telefonNo,
          'detayaciklama': ekDetaylar,
          'image': _uploadedImageUrl1,
          'ylink': _uploadedImageUrl2,
        });

        String newDocId = docRef.id;
        DocumentReference allSmaDocRef = FirebaseFirestore.instance
            .collection('allsma')
            .doc('7DNg1yOoUq6v2zSXO84K');

        // Mevcut dokümanı getirin ve yeni field oluşturun
        DocumentSnapshot allSmaDoc = await allSmaDocRef.get();
        Map<String, dynamic>? data = allSmaDoc.data() as Map<String, dynamic>?;
        int newFieldNumber = data != null
            ? data.keys.where((k) => k.startsWith('id')).length + 1
            : 1;
        String newFieldName = 'id$newFieldNumber';

        // Yeni field ismini ve değerini güncelleyin
        await allSmaDocRef.update({newFieldName: newDocId});

        // Diyalog göster
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.blue.shade800,
              title: Text("İlan firebase'e eklendi",
                  style: TextStyle(color: Colors.white)),
              content: Text('naber ali', style: TextStyle(color: Colors.white)),
              actions: [
                TextButton(
                  child: Text('Kapat', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => Anasayfa(),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu: $error')),
        );
      }
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
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.only(top: 125, left: 245, right: 245),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(children: <Widget>[
                Expanded(
                  child: Divider(
                    color: Colors.blue.shade100,
                    thickness: 0.5,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("Yetkili İletişim Bilgileri",
                      style:
                          TextStyle(fontSize: 12, color: Colors.blue.shade100)),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.blue.shade100,
                    thickness: 0.5,
                  ),
                ),
              ]),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: yetkiliadsoyadinput(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: telnoinput(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: emailinput(),
              ),
              Row(children: <Widget>[
                Expanded(
                  child: Divider(
                    color: Colors.blue.shade100,
                    thickness: 0.5,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("Kampanya Bilgileri",
                      style:
                          TextStyle(fontSize: 12, color: Colors.blue.shade100)),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.blue.shade100,
                    thickness: 0.5,
                  ),
                ),
              ]),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: adsoyadinput(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  width: 100, // İstediğiniz genişliği ayarlayabilirsiniz.
                  child: kampanyaturuinput(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 40),
                child: tamamlanmaoraniinput(),
              ),
              Row(children: <Widget>[
                Expanded(
                  child: Divider(
                    color: Colors.blue.shade100,
                    thickness: 0.5,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("Kampanya Bağış Bilgileri",
                      style:
                          TextStyle(fontSize: 12, color: Colors.blue.shade100)),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.blue.shade100,
                    thickness: 0.5,
                  ),
                ),
              ]),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: bankaadiinput(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ibaninput(),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                ),
                child: aliciadsoyadinput(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: bagisaciklamasiinput(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 30),
                child: digerdetaylarinput(),
              ),
              Row(children: <Widget>[
                Expanded(
                  child: Divider(
                    color: Colors.blue.shade100,
                    thickness: 0.5,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("Kampanya Görselleri",
                      style:
                          TextStyle(fontSize: 12, color: Colors.blue.shade100)),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.blue.shade100,
                    thickness: 0.5,
                  ),
                ),
              ]),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: kampanyagorseliyuklebutonu(),
              ),
              Divider(
                thickness: 0.5,
                color: Colors.blue.shade100,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                ),
                child: izinbelgesiyuklebutonu(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 22, bottom: 15),
                child: ilanionayagonderbutonu(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ElevatedButton ilanionayagonderbutonu() {
    return ElevatedButton(
      onPressed: _submitForm,
      child: Text(
        "İlanı Onaya Gönder",
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.blue.shade600,
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(
          Color.fromARGB(255, 255, 255, 255),
        ),
      ),
    );
  }

  InkWell izinbelgesiyuklebutonu() {
    return InkWell(
      onTap: () => _uploadImage(2),
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
              "İzin Belgesi Yükle",
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
              "Valilik onay belgesini yanlızca görsel olarak yükleyiniz. PDF ya da diğer formatlar kabul edilememektedir.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ),
          if (isImage2Uploaded) // Eğer görsel yüklendiyse, onay işaretini göster
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            )
        ],
      ),
    );
  }

  InkWell kampanyagorseliyuklebutonu() {
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
              "Kampanya Görseli Yükle",
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
              "Kampanya kimin için yapılıyorsa o kişinin görselini yükleyiniz. Kendi resminizi ya da reklam afişinizi yüklemeyiniz.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ),
          if (isImage1Uploaded) // Eğer görsel yüklendiyse, onay işaretini göster
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            )
        ],
      ),
    );
  }

  TextFormField digerdetaylarinput() {
    return TextFormField(
      controller: controllers['ekDetaylar'],
      cursorColor: Colors.blue.shade800,
      maxLines: null, // Kullanıcının birden fazla satır girebilmesi için
      decoration: InputDecoration(
        labelText: 'Eklemek İstediğiniz Diğer Detaylar',
        labelStyle: TextStyle(
          color: Colors.blue.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (value) {
        ekDetaylar =
            value; // Bu değişkeni sınıfınızın üst kısmında tanımlamanız gerekiyor
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'Ek detaylar alanı boş olamaz';
        }
        return null;
      },
    );
  }

  TextFormField bagisaciklamasiinput() {
    return TextFormField(
      controller: controllers['aciklama'],
      cursorColor: Colors.blue.shade800,
      decoration: InputDecoration(
        labelText: 'Bağış Açıklaması',
        labelStyle: TextStyle(
          color: Colors.blue.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (value) {
        aciklama = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'Bağış açıklaması alanı boş olamaz';
        }
        return null;
      },
    );
  }

  TextFormField aliciadsoyadinput() {
    return TextFormField(
      controller: controllers['alici'],
      cursorColor: Colors.blue.shade800,
      decoration: InputDecoration(
        labelText: 'Alıcı Adı Soyadı',
        labelStyle: TextStyle(
          color: Colors.blue.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (value) {
        alici = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'Alıcı adı soyadı alanı boş olamaz';
        }
        return null;
      },
    );
  }

  TextFormField ibaninput() {
    return TextFormField(
      controller: controllers['iban'],
      cursorColor: Colors.blue.shade800,
      decoration: InputDecoration(
        labelText: 'IBAN ',
        labelStyle: TextStyle(
          color: Colors.blue.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (value) {
        iban = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'IBAN alanı boş olamaz';
        }
        // IBAN için ekstra doğrulama yapabilirsiniz.
        return null;
      },
    );
  }

  TextFormField bankaadiinput() {
    return TextFormField(
      controller: controllers['bankaAdi'],
      cursorColor: Colors.blue.shade800,
      decoration: InputDecoration(
        labelText: 'Banka Adı',
        labelStyle: TextStyle(
          color: Colors.blue.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (value) {
        bankaAdi = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'Banka adı alanı boş olamaz';
        }
        return null;
      },
    );
  }

  TextFormField tamamlanmaoraniinput() {
    return TextFormField(
      controller: controllers['tamamlanmaOrani'],
      cursorColor: Colors.blue.shade800,
      keyboardType: TextInputType.number, // Sadece sayısal değer girişi için
      decoration: InputDecoration(
        labelText: 'Kampanya Tamamlanma Oranı (%)',
        labelStyle: TextStyle(
          color: Colors.blue.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (value) {
        tamamlanmaOrani = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'Tamamlanma oranı alanı boş olamaz';
        }
        final int? oran = int.tryParse(value);
        if (oran == null || oran < 0 || oran > 100) {
          return 'Lütfen 0 ile 100 arasında bir değer girin';
        }
        return null;
      },
    );
  }

  DropdownButtonFormField<String> kampanyaturuinput() {
    return DropdownButtonFormField<String>(
      value: kampanyaTuru,
      decoration: InputDecoration(
        labelText: 'Kampanya Türü',
        labelStyle: TextStyle(
          color: Colors.blue.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: <String>['SMA'].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        // Burada seçilen değeri işleyebilirsiniz.
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Kampanya türü seçilmelidir';
        }
        return null;
      },
    );
  }

  TextFormField adsoyadinput() {
    return TextFormField(
      controller: controllers['adSoyad'],
      cursorColor: Colors.blue.shade800,
      decoration: InputDecoration(
        labelText: 'Ad Soyad',
        labelStyle: TextStyle(
            color: Colors.blue.shade800,
            fontSize: 12,
            fontWeight: FontWeight.w400),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (value) {
        adSoyad = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'Ad soyad alanı boş olamaz';
        }
        return null;
      },
    );
  }

  TextFormField emailinput() {
    return TextFormField(
      controller: controllers['email'],
      keyboardType: TextInputType.emailAddress, // E-mail için klavye tipi
      decoration: InputDecoration(
        labelText: 'E-mail',
        labelStyle: TextStyle(
          color: Colors.blue.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (value) {
        email = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'E-mail alanı boş olamaz';
        }
        // E-mail doğrulama işlemleri de burada yapılabilir.
        return null;
      },
    );
  }

  TextFormField telnoinput() {
    return TextFormField(
      controller: controllers['telefonNo'],
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Telefon Numarası',
        labelStyle: TextStyle(
          color: Colors.blue.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (value) {
        telefonNo = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'Telefon numarası alanı boş olamaz';
        }
        return null;
      },
    );
  }

  TextFormField yetkiliadsoyadinput() {
    return TextFormField(
      controller: controllers['ilgiliadSoyad'], // Burada controller'ı ekledik
      decoration: InputDecoration(
        labelText: 'Yetkili Ad Soyad',
        labelStyle: TextStyle(
          color: Colors.blue.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (value) {
        ilgiliadSoyad = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'Ad soyad alanı boş olamaz';
        }
        return null;
      },
    );
  }
}
