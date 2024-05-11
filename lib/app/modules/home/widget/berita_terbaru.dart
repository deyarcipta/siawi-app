import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import 'package:siawi_app/app/models/berita.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

class BeritaTerbaru extends StatefulWidget {
  final VoidCallback signOut;
  const BeritaTerbaru(this.signOut, {Key? key}) : super(key: key);
  // final VoidCallback signOut;
  // const DataMahasiswa(this.signOut, {super.key});

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
    final response =
        await http.get(Uri.parse('http://203.194.113.46/api/berita'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> beritaData = responseData['data'];
      setState(() {
        beritaList.clear();
        for (var item in beritaData) {
          Berita berita = Berita.fromJson(item);
          beritaList.add(berita);
        }
      });
    } else {
      print('Failed to load berita');
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
                    itemBuilder: (_, index) => Card(
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
                                'http://203.194.113.46/storage/berita/${beritaList[index].cover}',
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                          // Image.asset(beritaList[index].judulBerita),
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
