import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:siawi_app/app/models/berita.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:siawi_app/app/data/api_service.dart';
import 'package:siawi_app/app/modules/home/widget/berita_lengkap.dart';

class BeritaTerbaru extends StatefulWidget {
  final VoidCallback signOut;
  const BeritaTerbaru(this.signOut, {Key? key}) : super(key: key);

  @override
  State<BeritaTerbaru> createState() => _BeritaTerbaruState();
}

class _BeritaTerbaruState extends State<BeritaTerbaru> {
  List<Berita> beritaList = [];

  @override
  void initState() {
    super.initState();
    _fetchBerita();
  }

  Future<void> _fetchBerita() async {
    try {
      final responseData = await ApiService.get('/berita');
      if (responseData != null && responseData['data'] != null) {
        final List<dynamic> beritaData = responseData['data'];
        setState(() {
          beritaList.clear();
          for (var item in beritaData) {
            Berita berita = Berita.fromJson(item);
            beritaList.add(berita);
          }
        });
      }
    } catch (e) {
      print('Failed to load berita: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Berita Terbaru",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                child: SizedBox(
                  height: 135,
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(0, 10, 15, 20),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, index) => GestureDetector(
                      onTap: () {
                        // Navigasi ke halaman berita lengkap
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BeritaLengkap(
                              berita: beritaList[
                                  index], // Kirim berita ke halaman lain
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl:
                                  'https://siawi.smkwisataindonesia.sch.id/storage/berita/${beritaList[index].cover}',
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                    ),
                    separatorBuilder: (_, index) => const SizedBox(width: 10),
                    itemCount: beritaList.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
