import 'package:bk_lapor_book_main/components/button_like.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bk_lapor_book_main/components/status_dialog.dart';
import 'package:bk_lapor_book_main/components/styles.dart';
import 'package:bk_lapor_book_main/components/models/akun.dart';
import 'package:bk_lapor_book_main/components/models/laporan.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isLoading = false;

  String? status;

  int likeCount = 0;
  bool isLiked = false;
  bool likeButtonVisible = true;

  @override
  void initState() {
    super.initState();
    // checkUserLiked();
  }

  // Future<void> checkUserLiked() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     isLiked = prefs.getBool('isLiked') ?? false;
  //   });
  // }

  Future<void> saveLikeData(String docId) async {
    try {
      CollectionReference laporanCollection =
          FirebaseFirestore.instance.collection('laporan');

      final String uid = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot likeDoc =
          await laporanCollection.doc(docId).collection('likes').doc(uid).get();

      if (!likeDoc.exists) {
        await laporanCollection.doc(docId).collection('likes').doc(uid).set({
          'timestamp': FieldValue.serverTimestamp(),
        });

        await laporanCollection.doc(docId).update({
          'likeCount': FieldValue.increment(1),
        });

        setState(() {
          isLiked = true;
        });

        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // prefs.setBool('isLiked', isLiked);
      }
    } catch (e) {
      print('Error saving like data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    Laporan laporan = arguments['laporan'];
    Akun akun = arguments['akun'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Detail Laporan', style: headerStyle(level: 3, dark: false)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (akun.role == 'admin')
                        Container(
                          width: 250,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                status = laporan.status;
                              });
                              statusDialog(laporan);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text('Ubah Status'),
                          ),
                        ),
                      Text(
                        laporan.judul,
                        style: headerStyle(level: 3),
                      ),
                      SizedBox(height: 15),
                      laporan.gambar != ''
                          ? Image.network(laporan.gambar!)
                          : Image.asset('assets/istock-default.jpg'),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          LikeButton(
                            isLiked: isLiked,
                            onTap: () {
                              if (!isLiked && likeButtonVisible) {
                                likeCount++;
                                isLiked = true;
                                saveLikeData(laporan.docId!);
                                setState(() {
                                  likeButtonVisible = false;
                                });
                              }
                            },
                          ),
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('laporan')
                                .doc(laporan.docId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  !snapshot.hasData) {
                                return Text('Loading...');
                              } else {
                                // Tambahkan pengecekan untuk likeCount
                                int likes = snapshot.data?['likeCount'] ?? 0; // Default to 0 if null
                                return Text('Jumlah Like: $likes');
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ListTile(
                        leading: Icon(Icons.person),
                        title: const Center(child: Text('Nama Pelapor')),
                        subtitle: Center(
                          child: Text(laporan.nama),
                        ),
                        trailing: SizedBox(width: 45),
                      ),
                      ListTile(
                        leading: Icon(Icons.date_range),
                        title: Center(child: Text('Tanggal Laporan')),
                        subtitle: Center(
                          child: Text(DateFormat('dd MMMM yyyy')
                              .format(laporan.tanggal)),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.location_on),
                          onPressed: () {
                            launch(laporan.maps);
                          },
                        ),
                      ),
                      SizedBox(height: 50),
                      Text(
                        'Deskripsi Laporan',
                        style: headerStyle(level: 3),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(laporan.deskripsi ?? ''),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void statusDialog(Laporan laporan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatusDialog(
          laporan: laporan,
        );
      },
    );
  }
}