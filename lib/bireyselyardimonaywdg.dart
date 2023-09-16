import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saraneladmin/customappbar.dart';

class bireyselonay extends StatefulWidget {
  @override
  _bireyselonayState createState() => _bireyselonayState();
}

class _bireyselonayState extends State<bireyselonay> {
  final CollectionReference bekleyenyt =
      FirebaseFirestore.instance.collection('bekleyenyt');
  final CollectionReference yardimt =
      FirebaseFirestore.instance.collection('yardimtalepleri');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: StreamBuilder(
        stream: bekleyenyt.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.requireData;

          return DataTable(
            columns: [
              DataColumn(label: Text('Document ID')),
              DataColumn(label: Text('Aksiyonlar')),
            ],
            rows: data.docs.map((document) {
              return DataRow(cells: [
                DataCell(Text(document.id), onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Document Detayları'),
                        content: Container(
                          width: double.maxFinite,
                          child: ListView(
                            shrinkWrap: true,
                            children: (document.data() as Map<String, dynamic>?)
                                    ?.entries
                                    .map<Widget>((entry) {
                                  return Card(
                                    elevation: 1,
                                    margin: EdgeInsets.symmetric(vertical: 4),
                                    child: ListTile(
                                      title: Text('${entry.key}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Text('${entry.value}'),
                                      isThreeLine: true,
                                      dense: false,
                                    ),
                                  );
                                }).toList() ??
                                [Text('Document has no data')],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Kapat'),
                          ),
                        ],
                      );
                    },
                  );
                }),
                DataCell(Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await yardimt.add(document.data());
                          await document.reference.delete();
                        } catch (e) {
                          // Hata işlemleri burada yapılabilir
                        }
                      },
                      child: Text('Onayla'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final bool? isConfirmed = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Reddet'),
                              content: Text(
                                  'Bu belgeyi reddetmek istediğinizden emin misiniz?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Text('Hayır'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: Text('Evet'),
                                ),
                              ],
                            );
                          },
                        );

                        if (isConfirmed ?? false) {
                          await document.reference.delete();
                        }
                      },
                      child: Text('Reddet'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                )),
              ]);
            }).toList(),
          );
        },
      ),
    );
  }
}
