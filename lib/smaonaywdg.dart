import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:saraneladmin/customappbar.dart';

class SmaOnayPage extends StatefulWidget {
  @override
  _SmaOnayPageState createState() => _SmaOnayPageState();
}

class _SmaOnayPageState extends State<SmaOnayPage> {
  final CollectionReference bekleyenler =
      FirebaseFirestore.instance.collection('bekleyenler');
  final CollectionReference sma = FirebaseFirestore.instance.collection('sma');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade800,
      appBar: CustomAppBar(currentPage: 'SmaOnayPage'),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 1200, // Kare şeklinin genişliği
            height: 700, // Kare şeklinin yüksekliği
            decoration: BoxDecoration(
              color: Colors.white, // Kare şeklinin kenarlık rengi ve genişliği
            ),
            child: Center(
              child: StreamBuilder(
                stream: bekleyenler.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Bir hata oluştu: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.requireData;

                  return DataTable2(
                    columns: [
                      DataColumn2(
                          label: Text('Document ID'), size: ColumnSize.L),
                      DataColumn2(
                          label: Text('Aksiyonlar'), size: ColumnSize.L),
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
                                    children: (document.data()
                                                as Map<String, dynamic>?)
                                            ?.entries
                                            .map<Widget>((entry) {
                                          return Card(
                                            elevation: 1,
                                            margin: EdgeInsets.symmetric(
                                                vertical: 4),
                                            child: ListTile(
                                              title: Text('${entry.key}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
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
                        DataCell(
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await sma.add(document.data());
                                      await document.reference.delete();
                                    } catch (e) {
                                      // Hata işlemleri burada yapılabilir
                                    }
                                  },
                                  child: Text('Onayla'),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final bool? isConfirmed = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Reddet'),
                                          content: Text(
                                              'Bu belgeyi reddetmek istediğinizden emin misiniz?'),
                                          actions: [
                                            Container(
                                              width: 100,
                                              child: TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                },
                                                child: Text('Hayır'),
                                              ),
                                            ),
                                            Container(
                                              width: 100,
                                              child: TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                },
                                                child: Text('Evet'),
                                              ),
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
                              ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
