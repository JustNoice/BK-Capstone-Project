import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bk_lapor_book_main/components/styles.dart';
import 'package:bk_lapor_book_main/components/models/akun.dart';
import 'package:bk_lapor_book_main/components/models/laporan.dart';

class ListItem extends StatefulWidget {
  final Laporan laporan;
  final Akun akun;
  final bool isLaporanku;

  ListItem({
    Key? key,
    required this.laporan,
    required this.akun,
    required this.isLaporanku,
  });

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  late Future<int> _likeCountFuture;

  void deleteLaporan() async {
    try {
      await _firestore.collection('laporan').doc(widget.laporan.docId).delete();

      // menghapus gambar dari storage
      if (widget.laporan.gambar != '') {
        await _storage.refFromURL(widget.laporan.gambar!).delete();
      }
      Navigator.popAndPushNamed(context, '/dashboard');
    } catch (e) {
      print(e);
    }
  }

  Future<int> fetchLikeCount() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('laporan')
          .doc(widget.laporan.docId)
          .get();

      return snapshot['likeCount'] ?? 0;
    } catch (e) {
      print('Error fetching like count: $e');
      return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    _likeCountFuture = fetchLikeCount();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/detail', arguments: {
              'laporan': widget.laporan,
              'akun': widget.akun,
            });
          },
          onLongPress: () {
            if (widget.isLaporanku) {
              showDialog(
                context: context,
                builder: (BuildContext) {
                  return AlertDialog(
                    title: Text('Delete ${widget.laporan.judul}?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          deleteLaporan();
                        },
                        child: Text('Hapus'),
                      ),
                    ],
                  );
                },
              );
            }
          },
          child: Column(
            children: [
              widget.laporan.gambar != ''
                  ? Image.network(
                      widget.laporan.gambar!,
                      width: 130,
                      height: 130,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/istock-default.jpg',
                      width: 130,
                      height: 130,
                      fit: BoxFit.cover,
                    ),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  border: Border.symmetric(horizontal: BorderSide(width: 2)),
                ),
                child: Text(
                  widget.laporan.judul,
                  style: headerStyle(level: 4),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: warningColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                        ),
                        border: const Border.symmetric(
                          vertical: BorderSide(width: 1),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.laporan.status,
                        style: headerStyle(level: 5, dark: false),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: secColor,
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(5),
                        ),
                        border: const Border.symmetric(
                          vertical: BorderSide(width: 1),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FutureBuilder<int>(
                            future: _likeCountFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting ||
                                  !snapshot.hasData) {
                                return Text(
                                  'Loading...',
                                  style: headerStyle(level: 5, dark: false),
                                );
                              } else {
                                int likes = snapshot.data ?? 0;
                                return Text(
                                  ' $likes',
                                  style: headerStyle(level: 5, dark: false),
                                );
                              }
                            },
                          ),
                        ],
                      ),

                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
