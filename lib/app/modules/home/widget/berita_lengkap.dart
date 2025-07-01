import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:siawi_app/app/models/berita.dart';
import 'package:siawi_app/utils/colors.dart';

class BeritaLengkap extends StatelessWidget {
  final Berita berita;

  // Constructor untuk menerima data berita
  const BeritaLengkap({Key? key, required this.berita}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
        leading: BackButton(color: AppColors.white),
        title: Text(
          'SI AWI',
          style: TextStyle(color: AppColors.white),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
            child: Image.asset(
              'assets/logo/logo-splash.png',
              width: 30,
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl:
                  'https://siawi.smkwisataindonesia.sch.id/storage/berita/${berita.cover}',
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            SizedBox(height: 20),
            Text(
              berita.judulBerita,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(berita.isiBerita), // Menampilkan isi berita
          ],
        ),
      ),
    );
  }
}
