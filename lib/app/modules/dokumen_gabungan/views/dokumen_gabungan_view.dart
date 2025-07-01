import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:siawi_app/app/modules/dokumen/views/dokumen_view.dart';
import 'package:siawi_app/app/modules/rapot/views/rapot_view.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:siawi_app/app/modules/rapot/widget/rapot_list.dart';

class DokumenGabunganView extends StatefulWidget {
  final VoidCallback signOut;
  const DokumenGabunganView(this.signOut, {super.key});

  @override
  State<DokumenGabunganView> createState() => _DokumenGabunganViewState();
}

class _DokumenGabunganViewState extends State<DokumenGabunganView> {
  List<RapotList> rapotList = [];
  List<dynamic> dokumenList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idSiswa = prefs.getString('idSiswa');

    if (idSiswa != null) {
      await _fetchRapot(idSiswa);
      await _fetchDokumen(idSiswa);
    }
  }

  Future<void> _fetchRapot(String id) async {
    final response = await http.get(
      Uri.parse('https://siawi.smkwisataindonesia.sch.id/api/rapot/$id'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      setState(() {
        rapotList =
            data.map<RapotList>((item) => RapotList.fromJson(item)).toList();
      });
    }
  }

  Future<void> _fetchDokumen(String id) async {
    final response = await http.get(
      Uri.parse('https://siawi.smkwisataindonesia.sch.id/api/dokumen/$id'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      setState(() {
        dokumenList = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuList = [
      {
        'title': 'Dokumen',
        'page': DokumenView(widget.signOut),
      },
      {
        'title': 'Rapot',
        'page': RapotView(widget.signOut),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        title: const Text("Dokumen", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: ListView.builder(
          itemCount: menuList.length,
          itemBuilder: (context, index) {
            final item = menuList[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                tileColor: AppColors.thirdColor,
                title: Text(
                  item['title'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.arrow_forward_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => item['page']),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
