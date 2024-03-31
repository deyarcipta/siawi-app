import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import 'package:siawi_app/app/models/berita.dart';

class BeritaTerbaru extends StatelessWidget {
  final List<Berita> listBerita = Berita.generateBerita();
  BeritaTerbaru({Key? key}) : super(key: key);

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
                          child: Image.asset(listBerita[index].bgImg),
                        ),
                      ),
                    ),
                    separatorBuilder: (_, index) => const SizedBox(width: 10),
                    itemCount: listBerita.length,
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
