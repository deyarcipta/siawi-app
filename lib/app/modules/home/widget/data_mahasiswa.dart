import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DataMahasiswa extends StatefulWidget {
  final VoidCallback signOut;
  const DataMahasiswa(this.signOut, {super.key});
  // final VoidCallback signOut;
  // const DataMahasiswa(this.signOut, {super.key});

  @override
  State<DataMahasiswa> createState() => _DataMahasiswaState();
}

class _DataMahasiswaState extends State<DataMahasiswa> {
  String role = 'siswa';
  List<dynamic> children = [];
  String? selectedChildId;

  Future<void> _loadPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? idSiswa = preferences.getString('idSiswa');
    String savedRole = preferences.getString('role') ?? 'siswa';
    String? childrenRaw = preferences.getString('childrenJson');
    List<dynamic> parsedChildren = [];
    if (childrenRaw != null && childrenRaw.isNotEmpty) {
      try {
        parsedChildren = jsonDecode(childrenRaw);
      } catch (e) {
        print('Error parse childrenJson: $e');
      }
    }

    setState(() {
      role = savedRole;
      children = parsedChildren;
      selectedChildId = idSiswa;
    });

    if (idSiswa != null) {
      _lihatData(idSiswa);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  bool loading = false;
  String? nama;
  String? namaJurusan;
  String? nis;
  String? nisn;
  String? namaKelas;
  // String? rataRata;
  // String? info;
  int presentaseKehadiran = 0;
  double kehadiran = 0;
  Future<void> _lihatData(String idSiswa) async {
    setState(() {
      loading = true;
    });
    try {
      final datasiswa = await ApiService.get('/home/$idSiswa');
      if (datasiswa != null && datasiswa['data'] != null) {
        var siswaData = datasiswa['data'];
        var kelasData = siswaData['kelas'];
        var jurusanData = siswaData['jurusan'];
        if (siswaData['nis'] != null) {
          setState(() {
            nama = siswaData['nama_siswa'].toString().toUpperCase();
            namaKelas = kelasData['nama_kelas'].toString();
            namaJurusan = jurusanData['nama_jurusan']?.toString();
            nis = siswaData['nis']?.toString();
            nisn = siswaData['nisn']?.toString();
            presentaseKehadiran =
                int.tryParse(datasiswa['presentaseKehadiran'].toString()) ?? 0;
            kehadiran = presentaseKehadiran / 100;
          });
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Wrap(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (role == 'orang_tua' && children.length > 1) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.swap_horiz, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Pilih Anak:",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedChildId,
                          dropdownColor: AppColors.mainColor,
                          isDense: true,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.white),
                          items:
                              children.map<DropdownMenuItem<String>>((child) {
                            String cId = child['id_siswa'].toString();
                            String cNama = child['nama_siswa'] ?? 'Anak';
                            String cKelas = (child['kelas'] != null &&
                                    child['kelas']['nama_kelas'] != null)
                                ? ' (${child['kelas']['nama_kelas']})'
                                : '';
                            return DropdownMenuItem<String>(
                              value: cId,
                              child: Text(
                                '$cNama$cKelas',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (newId) async {
                            if (newId != null && newId != selectedChildId) {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString('idSiswa', newId);
                              setState(() {
                                selectedChildId = newId;
                              });
                              _lihatData(newId);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Container(
              width: double.infinity, // Use double.infinity for full width
              height: size.height * .25,
              decoration: BoxDecoration(
                color: AppColors.mainColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center the column vertically
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Center the column vertically
                          children: [
                            SizedBox(height: 5),
                            _buildTitleData('Kompetensi Keahlian'),
                            _buildData((namaJurusan ?? 'Loading...').length > 32
                                ? '${(namaJurusan ?? 'Loading...').substring(0, 32)}...'
                                : (namaJurusan ?? 'Loading...')),
                            _buildTitleData('NIS / NISN'),
                            _buildData(
                                '${nis ?? 'Loading...'} / ${nisn ?? 'Loading...'}'),
                            _buildTitleData('Kelas'),
                            _buildData(namaKelas ?? 'Loading...'),
                            _buildTitleData('Rata-Rata Rapot'),
                            Row(
                              children: [
                                _buildRata('-'),
                              ],
                            ),
                          ],
                        ),
                        Flexible(
                          child: CircularPercentIndicator(
                            animation: true,
                            radius:
                                size.width * 0.18, // 20% of the screen width
                            lineWidth: 12.0,
                            percent: kehadiran.clamp(0.0, 1.0),
                            center: Text(
                              '$presentaseKehadiran%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    size.width * 0.08, // Scaled to screen width
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: AppColors.secondColor,
                            progressColor: AppColors.thirdColor,
                            circularStrokeCap: CircularStrokeCap.round,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleData(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 13,
        color: Colors.white,
      ),
    );
  }

  Widget _buildData(String text) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      // width: double.maxFinite,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRata(String text) {
    return Container(
      padding: const EdgeInsets.only(right: 1),
      // width: double.maxFinite,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
        ),
      ),
    );
  }
}
