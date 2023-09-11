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
  final DocumentReference allsmaDocRef = FirebaseFirestore.instance
      .collection('allsma')
      .doc('7DNg1yOoUq6v2zSXO84K');

  Map<String, dynamic>? allsmaDocData;

  Future<void> fetchAllsmaDocData() async {
    DocumentSnapshot snapshot = await allsmaDocRef.get();
    allsmaDocData = snapshot.data() as Map<String, dynamic>?;
  }

  @override
  void initState() {
    super.initState();
    fetchAllsmaDocData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: StreamBuilder(
        stream: bekleyenler.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.requireData;

          return DataTable2(
            columns: [
              DataColumn2(label: Text('Document ID'), size: ColumnSize.L),
              DataColumn2(label: Text('Aksiyonlar'), size: ColumnSize.L),
            ],
            rows: data.docs.map((document) {
              return DataRow(cells: [
                DataCell(Text(document.id), onTap: () {
                  // Document detaylarını göster
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
                                      title: Text(
                                        '${entry.key}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
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
                        // Onay işlemi
                        try {
                          await FirebaseFirestore.instance
                              .runTransaction((transaction) async {
                            var newDoc = await sma.add(document.data());

                            int fieldNumber = 0;
                            if (allsmaDocData != null) {
                              fieldNumber = allsmaDocData!.keys
                                  .where((k) => k.startsWith('idonaylanmis'))
                                  .length;
                            }

                            fieldNumber++;
                            await transaction.update(allsmaDocRef,
                                {'idonaylanmis$fieldNumber': newDoc.id});
                            await transaction.delete(document.reference);
                          });
                        } catch (e) {
                          // Hata işlemleri burada yapılabilir
                        }
                      },
                      child: Text('Onayla'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        // Red işlemi
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
                                    Navigator.of(context).pop(
                                        false); // Eğer hayır ise, false döner
                                  },
                                  child: Text('Hayır'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(true); // Eğer evet ise, true döner
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
