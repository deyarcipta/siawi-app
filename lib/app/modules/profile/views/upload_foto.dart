import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:siawi_app/app/modules/profile/views/profile_view.dart';
import 'package:siawi_app/utils/colors.dart';

class UploadFoto extends StatefulWidget {
  final VoidCallback signOut;
  const UploadFoto(this.signOut, {Key? key}) : super(key: key);

  @override
  State<UploadFoto> createState() => _UploadFotoState();
}

class _UploadFotoState extends State<UploadFoto> {
  var appBarHeight = AppBar().preferredSize.height;
  File? _image;
  final picker = ImagePicker();

  Future<String?> getIdSiswa() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? idSiswa = preferences.getString('idSiswa');
    return idSiswa;
  }

  @override
  void initState() {
    super.initState();
    getIdSiswa().then((idSiswa) {
      if (idSiswa != null) {
        _lihatData(idSiswa);
      }
    });
  }

  bool loading = false;
  String? namaSiswa;
  String? namaJurusan;
  String? namaKelas;
  String? fileFoto;

  Future<void> _lihatData(String idSiswa) async {
    setState(() {
      loading = true;
    });
    final response = await http.get(
        Uri.parse('https://siawi.smkwisataindonesia.sch.id/api/home/$idSiswa'));

    if (response.statusCode == 200) {
      var datasiswa = json.decode(response.body);
      var siswaData = datasiswa['data'];
      var kelasData = siswaData['kelas'];
      var jurusanData = siswaData['jurusan'];
      if (siswaData['nis'] != null) {
        setState(() {
          namaSiswa = siswaData['nama_siswa'].toString().toUpperCase();
          namaKelas = kelasData['nama_kelas'].toString();
          namaJurusan = jurusanData['nama_jurusan'].toString();
          fileFoto = siswaData['foto'].toString();
        });
      }
    } else {
      // Handle error
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _uploadImage(String idSiswa) async {
    setState(() {
      loading = true;
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://siawi.smkwisataindonesia.sch.id/api/uploadFoto/$idSiswa'),
    );
    request.files.add(
      await http.MultipartFile.fromPath('foto', _image!.path),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Image uploaded');
      _lihatData(idSiswa); // Refresh data
    } else {
      print('Image upload failed');
    }

    setState(() {
      loading = false;
    });
  }

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
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Wrap(
                children: <Widget>[
                  SafeArea(
                    child: Container(
                      width: double.infinity,
                      height: size.height,
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // abu-abu putih
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(top: 35),
                              child: ClipOval(
                                child: _image == null
                                    ? Image.network(
                                        'https://siawi.smkwisataindonesia.sch.id/storage/foto-siswa/$fileFoto',
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        _image!,
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            _buildTitle('Upload Foto'),
                            ElevatedButton(
                              onPressed: _pickImage,
                              child: Text('Pilih Foto'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                String? idSiswa = await getIdSiswa();
                                if (idSiswa != null && _image != null) {
                                  await _uploadImage(idSiswa);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Foto Berhasil Diubah'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Pilih Foto Terlebih Dahulu'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              child: Text('Simpan Foto'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

Widget _buildTitle(String text) {
  return Container(
    padding: const EdgeInsets.only(top: 10),
    child: Text(
      text,
      maxLines: 2,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.black,
      ),
    ),
  );
}

Widget _buildTitleData(String text) {
  return Container(
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.black,
      ),
    ),
  );
}
