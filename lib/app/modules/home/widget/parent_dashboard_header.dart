import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';
import 'package:siawi_app/app/models/menu_item.dart';
import 'package:siawi_app/app/models/menu_items.dart';
import 'package:siawi_app/app/modules/password/views/password_view.dart';
import 'package:siawi_app/utils/colors.dart';

class ParentDashboardHeader extends StatefulWidget {
  final VoidCallback signOut;
  final Function(String idSiswa)? onChildChanged;

  const ParentDashboardHeader(this.signOut, {super.key, this.onChildChanged});

  @override
  State<ParentDashboardHeader> createState() => _ParentDashboardHeaderState();
}

class _ParentDashboardHeaderState extends State<ParentDashboardHeader> {
  String? namaOrtu;
  String? idSiswa;
  List<dynamic> children = [];
  String? selectedChildId;

  // Student details for the active child
  bool loading = false;
  String? namaSiswa;
  String? namaKelas;
  String? namaJurusan;
  String? nis;
  String? nisn;
  String? fileFoto;
  String jenisKelamin = 'L';
  int presentaseKehadiran = 0;
  String presensiRatio = "0 / 0 Hari";
  String presensiSemester = "-";
  bool hasRapor = false;
  String nilaiRapor = "-";
  String trendRapor = "-";
  bool isTrendUp = true;
  String predikatRapor = "Belum Ada Rapot";

  // PKL detailed data (strictly without any phone number)
  bool hasPkl = false;
  bool isPklLevel = true;
  String statusPklText = "Belum Ditempatkan";
  String pklNamaPerusahaan = "-";
  String pklPenanggungJawabSekolah = "-";
  String pklPenanggungJawabIndustri = "-";
  String pklAlamat = "-";
  String pklStatus = "Belum Ditempatkan";
  String? pklPeriode;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? currentId = preferences.getString('idSiswa');
    String? currentNamaOrtu = preferences.getString('namaOrtu');
    String? childrenRaw = preferences.getString('childrenJson');

    List<dynamic> parsedChildren = [];
    if (childrenRaw != null && childrenRaw.isNotEmpty) {
      try {
        parsedChildren = jsonDecode(childrenRaw);
      } catch (e) {
        debugPrint('Error parse childrenJson: $e');
      }
    }

    // Ambil data awal siswa langsung dari list children (instan tanpa delay network)
    dynamic activeChild;
    if (parsedChildren.isNotEmpty) {
      if (currentId != null && currentId.isNotEmpty) {
        activeChild = parsedChildren.firstWhere(
          (c) => c['id_siswa']?.toString() == currentId.toString(),
          orElse: () => parsedChildren.first,
        );
      } else {
        activeChild = parsedChildren.first;
      }
    }

    String? initNama;
    String? initKelas;
    String? initJurusan;
    String? initNis;
    String? initNisn;
    String? initFoto;

    if (activeChild != null) {
      initNama = activeChild['nama_siswa']?.toString().toUpperCase();
      var k = activeChild['kelas'];
      initKelas =
          k != null ? (k['nama_kelas'] ?? k['kode_kelas'])?.toString() : null;
      var j = activeChild['jurusan'];
      initJurusan = j != null
          ? (j['nama_jurusan'] ?? j['kode_jurusan'])?.toString()
          : null;
      initNis = activeChild['nis']?.toString();
      initNisn = activeChild['nisn']?.toString();
      initFoto = activeChild['foto']?.toString();
      if (activeChild['jenis_kelamin'] != null) {
        jenisKelamin = activeChild['jenis_kelamin'].toString();
      }
    }

    // Coba muat cache statistik terakhir jika tersedia agar data instan tampil
    int initPres = presentaseKehadiran;
    String initRatio = presensiRatio;
    String initSem = presensiSemester;
    bool initHasRapor = hasRapor;
    String initNilaiRapor = nilaiRapor;
    String initPredikatRapor = predikatRapor;
    bool initHasPkl = hasPkl;
    String initStatusPkl = statusPklText;
    String initPklNama = pklNamaPerusahaan;
    String initPklStatus = pklStatus;
    String initPklSekolah = pklPenanggungJawabSekolah;
    String initPklIndustri = pklPenanggungJawabIndustri;
    String initPklAlamat = pklAlamat;
    bool initIsPklLevel = isPklLevel;
    String? initPklPeriode = pklPeriode;

    String? cacheRaw = currentId != null
        ? preferences.getString('cached_parent_header_$currentId')
        : null;
    if (cacheRaw != null && cacheRaw.isNotEmpty) {
      try {
        var cMap = jsonDecode(cacheRaw);
        initPres = cMap['pres'] ?? initPres;
        initRatio = cMap['ratio'] ?? initRatio;
        initSem = cMap['sem'] ?? initSem;
        initHasRapor = cMap['hasRapor'] ?? initHasRapor;
        initNilaiRapor = cMap['nilaiRapor'] ?? initNilaiRapor;
        initPredikatRapor = cMap['predikatRapor'] ?? initPredikatRapor;
        initHasPkl = cMap['hasPkl'] ?? initHasPkl;
        initIsPklLevel = cMap['isPklLevel'] ?? initIsPklLevel;
        initStatusPkl = cMap['statusPkl'] ?? initStatusPkl;
        initPklNama = cMap['pklNama'] ?? initPklNama;
        initPklStatus = cMap['pklStatus'] ?? initPklStatus;
        initPklSekolah = cMap['pklSekolah'] ?? initPklSekolah;
        initPklIndustri = cMap['pklIndustri'] ?? initPklIndustri;
        initPklAlamat = cMap['pklAlamat'] ?? initPklAlamat;
        initPklPeriode = cMap['pklPeriode'] ?? initPklPeriode;
      } catch (_) {}
    }

    setState(() {
      namaOrtu = currentNamaOrtu;
      children = parsedChildren;
      selectedChildId = currentId;
      idSiswa = currentId;
      if (initNama != null) namaSiswa = initNama;
      if (initKelas != null) namaKelas = initKelas;
      if (initJurusan != null) namaJurusan = initJurusan;
      if (initNis != null) nis = initNis;
      if (initNisn != null) nisn = initNisn;
      if (initFoto != null) fileFoto = initFoto;
      presentaseKehadiran = initPres;
      presensiRatio = initRatio;
      presensiSemester = initSem;
      hasRapor = initHasRapor;
      nilaiRapor = initNilaiRapor;
      predikatRapor = initPredikatRapor;
      hasPkl = initHasPkl;
      isPklLevel = initIsPklLevel;
      statusPklText = initStatusPkl;
      pklNamaPerusahaan = initPklNama;
      pklStatus = initPklStatus;
      pklPenanggungJawabSekolah = initPklSekolah;
      pklPenanggungJawabIndustri = initPklIndustri;
      pklAlamat = initPklAlamat;
      pklPeriode = initPklPeriode;
    });

    if (currentId != null && currentId.isNotEmpty) {
      _fetchStudentData(currentId);
    }
  }

  Future<void> _fetchStudentData(String studentId) async {
    setState(() {
      loading = true;
    });

    try {
      final res = await ApiService.get('/home/$studentId');
      if (res != null && res['data'] != null) {
        var sData = res['data'];
        var kData = sData['kelas'];
        var jData = sData['jurusan'];
        var rData = res['rapotTerakhir'];
        var prevRData = res['dataRapot'];
        var pData = res['siswaPkl'];

        // Ambil data presensi riil dari API
        int pres =
            int.tryParse(res['presentaseKehadiran']?.toString() ?? '0') ?? 0;
        int totalH =
            int.tryParse(res['totalKehadiran']?.toString() ?? '0') ?? 0;
        int hadirH = int.tryParse(res['jumlahHadir']?.toString() ?? '0') ?? 0;

        // Jika endpoint /home belum mengembalikan detail hari, sinkronkan langsung dengan endpoint /absensi
        try {
          final absenRes = await ApiService.get('/absensi/$studentId');
          if (absenRes != null) {
            int h =
                int.tryParse(absenRes['jumlahHadir']?.toString() ?? '0') ?? 0;
            int th =
                int.tryParse(absenRes['jumlahTidakHadir']?.toString() ?? '0') ??
                    0;
            int p = int.tryParse(
                    absenRes['presentaseKehadiran']?.toString() ?? '0') ??
                0;
            hadirH = h;
            totalH = h + th;
            pres = p > 0 ? p : pres;
          }
        } catch (_) {}

        String ratioStr = "$hadirH / $totalH Hari";
        if (totalH == 0) {
          ratioStr = "0 / 0 Hari";
        }

        // Rapor calculations riil dari database
        bool rExists = false;
        String rNilai = "-";
        String rTrend = "-";
        bool rTrendUp = true;
        String rPredikat = "Belum Ada Rapot";
        int currentMonth = DateTime.now().month;
        String rSemester =
            (currentMonth >= 7 && currentMonth <= 12) ? 'Ganjil' : 'Genap';

        if (rData != null &&
            rData['rata_rata'] != null &&
            rData['rata_rata'].toString().isNotEmpty &&
            rData['rata_rata'].toString() != 'null') {
          double? val = double.tryParse(rData['rata_rata'].toString());
          if (val != null && val > 0) {
            rExists = true;
            rNilai = val.toStringAsFixed(1);
            if (val >= 88) {
              rPredikat = "Sangat Baik";
            } else if (val >= 78) {
              rPredikat = "Baik";
            } else if (val >= 70) {
              rPredikat = "Cukup";
            } else {
              rPredikat = "Perlu Bimbingan";
            }
          }

          if (rData['semester'] != null) {
            var semVal = rData['semester'].toString();
            int? semNum = int.tryParse(semVal);
            if (semNum != null) {
              rSemester = (semNum % 2 == 0) ? 'Genap' : 'Ganjil';
            } else if (semVal.toLowerCase().contains('genap')) {
              rSemester = 'Genap';
            } else if (semVal.toLowerCase().contains('ganjil')) {
              rSemester = 'Ganjil';
            } else {
              rSemester = semVal;
            }
          }

          if (prevRData != null &&
              prevRData['rata_rata'] != null &&
              val != null) {
            double? prevVal =
                double.tryParse(prevRData['rata_rata'].toString());
            if (prevVal != null) {
              double diff = val - prevVal;
              rTrendUp = diff >= 0;
              rTrend = "${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)}%";
            }
          }
        }

        // PKL Data riil dari database
        bool pExists = false;
        String pNama = "-";
        String pStatus = "Belum Ditempatkan";
        String pSekolah = "-";
        String pIndustri = "-";
        String pAlamat = "-";
        String? pPeriode;

        if (pData != null && pData['perusahaan'] != null) {
          var per = pData['perusahaan'];
          pExists = true;
          pNama = per['nama_perusahaan'] ?? '-';
          pStatus = pData['status_label'] ?? pData['status'] ?? 'Ditempatkan';
          if (per['guru'] != null && per['guru']['nama_guru'] != null) {
            pSekolah = per['guru']['nama_guru'].toString();
          } else if (pData['guru'] != null &&
              pData['guru']['nama_guru'] != null) {
            pSekolah = pData['guru']['nama_guru'].toString();
          }
          pIndustri = per['penanggung_jawab'] ?? per['pic'] ?? '-';
          pAlamat = per['alamat_perusahaan'] ?? '-';
          if (pData['tanggal_mulai'] != null &&
              pData['tanggal_selesai'] != null) {
            pPeriode =
                "${pData['tanggal_mulai']} s/d ${pData['tanggal_selesai']}";
          }
        }

        String pklText = pExists ? "$pStatus ($pNama)" : "Belum Ditempatkan";

        bool pklLevelAllowed = true;
        if (res['is_pkl_level'] != null) {
          pklLevelAllowed = res['is_pkl_level'] == true ||
              res['is_pkl_level'] == 1 ||
              res['is_pkl_level'].toString() == 'true';
        }

        setState(() {
          namaSiswa = sData['nama_siswa']?.toString().toUpperCase();
          namaKelas =
              kData != null ? kData['nama_kelas']?.toString() : 'XII - TKJ 1';
          namaJurusan = jData != null
              ? jData['nama_jurusan']?.toString()
              : 'Teknik Komputer & Jaringan';
          nis = sData['nis']?.toString();
          nisn = sData['nisn']?.toString();
          fileFoto = sData['foto']?.toString();
          if (sData['jenis_kelamin'] != null &&
              sData['jenis_kelamin'].toString().isNotEmpty) {
            jenisKelamin = sData['jenis_kelamin'].toString();
          }
          presentaseKehadiran = pres;
          presensiRatio = ratioStr;
          presensiSemester = rSemester;
          hasRapor = rExists;
          hasPkl = pExists;
          isPklLevel = pklLevelAllowed;
          nilaiRapor = rNilai;
          trendRapor = rTrend;
          isTrendUp = rTrendUp;
          predikatRapor = rPredikat;
          statusPklText = pklText;

          pklNamaPerusahaan = pNama;
          pklStatus = pStatus;
          pklPenanggungJawabSekolah = pSekolah;
          pklPenanggungJawabIndustri = pIndustri;
          pklAlamat = pAlamat;
          pklPeriode = pPeriode;
        });

        try {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          if (namaSiswa != null) await prefs.setString('namaSiswa', namaSiswa!);
          if (namaKelas != null) await prefs.setString('namaKelas', namaKelas!);
          if (namaJurusan != null) await prefs.setString('namaJurusan', namaJurusan!);
          if (nis != null) await prefs.setString('nis', nis!);
          await prefs.setBool('is_pkl_level', isPklLevel);
          await prefs.setString(
            'cached_parent_header_$studentId',
            jsonEncode({
              'pres': pres,
              'ratio': ratioStr,
              'sem': rSemester,
              'hasRapor': rExists,
              'nilaiRapor': rNilai,
              'predikatRapor': rPredikat,
              'hasPkl': pExists,
              'isPklLevel': pklLevelAllowed,
              'statusPkl': pklText,
              'pklNama': pNama,
              'pklStatus': pStatus,
              'pklSekolah': pSekolah,
              'pklIndustri': pIndustri,
              'pklAlamat': pAlamat,
              'pklPeriode': pPeriode,
            }),
          );
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Error fetching student data in ParentDashboardHeader: $e');
    }

    setState(() {
      loading = false;
    });
  }

  String _getDefaultAvatarAsset([String? jk]) {
    final gender = (jk ?? jenisKelamin).trim().toUpperCase();
    if (gender == 'P' || gender == 'PEREMPUAN') {
      return 'assets/images/avatar_female.png';
    }
    return 'assets/images/avatar_male.png';
  }

  String _getStudentPhotoUrl(String? filename) {
    if (filename == null ||
        filename.isEmpty ||
        filename == 'null' ||
        filename == 'default.png' ||
        filename == 'avatar.jpg' ||
        filename == 'avatar.png' ||
        filename == 'avatar_male.jpg' ||
        filename == 'avatar_male.png' ||
        filename == 'avatar_female.jpg' ||
        filename == 'avatar_female.png') {
      return '';
    }
    if (filename.startsWith('http://') || filename.startsWith('https://')) {
      return filename;
    }
    return 'https://siawi.smkwisataindonesia.sch.id/storage/foto-siswa/$filename';
  }

  void _onSelectChild(String newChildId) async {
    if (newChildId == selectedChildId) return;

    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('idSiswa', newChildId);

    setState(() {
      selectedChildId = newChildId;
      idSiswa = newChildId;
    });

    _fetchStudentData(newChildId);
    if (widget.onChildChanged != null) {
      widget.onChildChanged!(newChildId);
    }
  }

  String _getGreeting() {
    int hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat Pagi';
    if (hour >= 11 && hour < 15) return 'Selamat Siang';
    if (hour >= 15 && hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    String greeting = _getGreeting();
    String parentName =
        (namaOrtu != null && namaOrtu!.isNotEmpty) ? namaOrtu! : 'Pak Hendra';
    String activeChildShort = namaSiswa ?? 'M. Rizky Pratama';
    if (activeChildShort.length > 18) {
      activeChildShort = '${activeChildShort.substring(0, 16)}...';
    }

    // Siapkan daftar anak untuk switcher:
    List<Map<String, dynamic>> displayChildren = [];
    if (children.isNotEmpty) {
      for (var c in children) {
        String cId = c['id_siswa'].toString();
        String? cFoto = c['foto']?.toString();
        if ((cFoto == null || cFoto.isEmpty) && cId == selectedChildId) {
          cFoto = fileFoto;
        }
        displayChildren.add({
          'id': cId,
          'nama': c['nama_siswa']?.toString() ?? 'Anak',
          'kelas': (c['kelas'] != null && c['kelas']['nama_kelas'] != null)
              ? c['kelas']['nama_kelas'].toString()
              : (cId == selectedChildId ? (namaKelas ?? 'Kelas') : 'Kelas'),
          'foto': cFoto,
        });
      }
    } else if (selectedChildId != null && selectedChildId!.isNotEmpty) {
      displayChildren.add({
        'id': selectedChildId!,
        'nama': namaSiswa ?? 'Anak',
        'kelas': namaKelas ?? 'Kelas',
        'foto': fileFoto,
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. TOP BAR: PORTAL ORANG TUA / DASHBOARD
        _buildTopBar(),

        // 2. KARTU 1: SALAM & SEKOLAH
        _buildGreetingCard(greeting, parentName, activeChildShort),

        // 3. KARTU 2: PILIH ANAK / SISWA (Hanya tampil jika memiliki lebih dari 1 anak)
        if (displayChildren.length > 1)
          _buildChildSelectorCard(displayChildren),

        // 4. KARTU 3: BIG FEATURED PURPLE STUDENT CARD
        _buildFeaturedStudentCard(),
      ],
    );
  }

  /// 1. TOP APP BAR
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(3),
              child: ClipOval(
                child: Image.asset(
                  'assets/logo/logo-splash.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.school_rounded,
                    color: Color(0xFF5B4BD1),
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PORTAL ORANG TUA',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tidak ada pemberitahuan baru'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.mainColor, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<MenuKu>(
              tooltip: 'Menu Akun',
              padding: EdgeInsets.zero,
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              onSelected: (item) => _onMenuSelected(context, item),
              itemBuilder: (context) => [
                _buildMenuItem(MenuItems.itemPassword),
                _buildMenuItem(MenuItems.itemLogout),
              ],
              offset: const Offset(0.0, 48.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<MenuKu> _buildMenuItem(MenuKu item) => PopupMenuItem<MenuKu>(
        value: item,
        child: Row(
          children: [
            Icon(
              item.icon,
              color: item == MenuItems.itemLogout
                  ? Colors.redAccent
                  : Colors.black87,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              item.text,
              style: TextStyle(
                color: item == MenuItems.itemLogout
                    ? Colors.redAccent
                    : Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );

  void _onMenuSelected(BuildContext context, MenuKu item) {
    if (item == MenuItems.itemLogout || item.text == 'Logout') {
      widget.signOut();
    } else if (item == MenuItems.itemPassword || item.text == 'Ubah Password') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PasswordView(widget.signOut),
        ),
      );
    }
  }

  /// 2. GREETING & SCHOOL CARD
  Widget _buildGreetingCard(
      String greeting, String parentName, String activeChildShort) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SMK WISATA INDONESIA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: Color(0xFF5B4BD1),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$greeting, $parentName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E2432),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F0FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        size: 14,
                        color: Color(0xFF5B4BD1),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                            children: [
                              const TextSpan(text: 'Siswa Aktif: '),
                              TextSpan(
                                text: activeChildShort,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E2432),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF5FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.verified_rounded,
                      size: 14,
                      color: Color(0xFF007BFF),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Akun Terverifikasi',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF007BFF),
                      ),
                    ),
                  ],
                ),
              ),
            ], // end of Row
          ),
        ],
      ),
    );
  }

  /// 3. PILIH ANAK / SISWA SELECTOR CARD
  Widget _buildChildSelectorCard(List<Map<String, dynamic>> displayChildren) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  Icon(
                    Icons.swap_horiz_rounded,
                    size: 19,
                    color: Color(0xFF5B4BD1),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Pilih Anak / Siswa',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E2432),
                    ),
                  ),
                ],
              ),
              Text(
                'Ketuk untuk beralih',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9EA3AE),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: displayChildren.map((child) {
              bool isSelected = (child['id'] == selectedChildId) ||
                  (selectedChildId == null && child == displayChildren.first);

              String cNama = child['nama'] ?? 'Anak';
              if (cNama.length > 12) {
                cNama = '${cNama.substring(0, 10)}...';
              }
              String cKelas = child['kelas'] ?? 'Kelas';

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: child == displayChildren.last ? 0 : 8,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      _onSelectChild(child['id']);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFF5B4BD1),
                                  Color(0xFF6F5EE8),
                                ],
                              )
                            : null,
                        color: isSelected ? null : const Color(0xFFF9F9FC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : const Color(0xFFE5E7EB),
                          width: 1.2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF5B4BD1)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Builder(
                            builder: (context) {
                              String cPhoto = _getStudentPhotoUrl(
                                  child['foto']?.toString());
                              String cAvatar = _getDefaultAvatarAsset(
                                  child['jenis_kelamin']?.toString());
                              return CircleAvatar(
                                radius: 17,
                                backgroundColor: isSelected
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : const Color(0xFFEDE9FE),
                                backgroundImage: cPhoto.isNotEmpty
                                    ? NetworkImage(cPhoto) as ImageProvider
                                    : AssetImage(cAvatar) as ImageProvider,
                                onBackgroundImageError:
                                    cPhoto.isNotEmpty ? (_, __) {} : null,
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cNama,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF1E2432),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  cKelas,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.8)
                                        : const Color(0xFF8A92A6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 18,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFFB0B6C3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 4. BIG FEATURED PURPLE STUDENT CARD
  Widget _buildFeaturedStudentCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF503FE4),
            Color(0xFF6351EB),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF503FE4).withValues(alpha: 0.38),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // Subtle decorative background circles
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
            ),

            // Main Card Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: (Badges + Nama + Kompetensi on Left) & (Large Photo on Right)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Badges, Name (with ellipsis), and Kompetensi
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badges: Kelas & NISN
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.20),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Kelas ${namaKelas ?? "XII – TKJ 1"}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'NISN: ${nisn != null && nisn!.isNotEmpty ? nisn : (nis ?? "0068492011")}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.88),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Nama Lengkap Siswa (Ellipsis agar tidak turun ke bawah foto)
                            Text(
                              namaSiswa ?? 'Muhammad Rizky Pratama',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 3),

                            // Subtitle Kompetensi
                            Text(
                              'Kompetensi: ${namaJurusan ?? "Teknik Komputer & Jaringan"}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Right: Photo Avatar (ukuran diperkecil sekitar 58-60px)
                      Builder(
                        builder: (context) {
                          String mainPhoto = _getStudentPhotoUrl(fileFoto);
                          return Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.16),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: CircleAvatar(
                                radius: 27,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                                backgroundImage: mainPhoto.isNotEmpty
                                    ? NetworkImage(mainPhoto) as ImageProvider
                                    : AssetImage(_getDefaultAvatarAsset())
                                        as ImageProvider,
                                onBackgroundImageError:
                                    mainPhoto.isNotEmpty ? (_, __) {} : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Middle Stats Box (Presensi & Rapor)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        // Left: Circular Indicator + Presensi Semester & Ratio
                        CircularPercentIndicator(
                          radius: 27.0,
                          lineWidth: 5.5,
                          percent: (presentaseKehadiran / 100).clamp(0.0, 1.0),
                          center: Text(
                            '$presentaseKehadiran%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.white.withValues(alpha: 0.22),
                          progressColor: Colors.white,
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Presensi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              presensiSemester,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              presensiRatio,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          width: 1,
                          height: 44,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        const Spacer(),
                        // Right: Rata-rata Rapor + Nilai (+Trend%) + Predikat
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rata-rata Rapor',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (hasRapor) ...[
                              Row(
                                children: [
                                  Text(
                                    nilaiRapor,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00E5FF)
                                          .withValues(alpha: 0.22),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isTrendUp
                                              ? Icons.trending_up
                                              : Icons.trending_down,
                                          color: const Color(0xFF00F5D4),
                                          size: 12,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          trendRapor,
                                          style: const TextStyle(
                                            color: Color(0xFF00F5D4),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Row(
                                children: [
                                  const Text(
                                    '-',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Belum Ada',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 2),
                            Text(
                              predikatRapor,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (isPklLevel) ...[
                    // Bottom Action Banner: Status PKL (Clickable)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _showPklDetailBottomSheet(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                hasPkl
                                    ? Icons.check_box_outlined
                                    : Icons.info_outline_rounded,
                                color: hasPkl
                                    ? const Color(0xFF38BDF8)
                                    : const Color(0xFFFBBF24),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Status PKL: ',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.8),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      TextSpan(
                                        text: statusPklText,
                                        style: TextStyle(
                                          color: hasPkl
                                              ? Colors.white
                                              : const Color(0xFFFEF3C7),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white.withValues(alpha: 0.8),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 5. PKL DETAIL BOTTOM SHEET MODAL (TANPA NOMOR HP)
  void _showPklDetailBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (hasPkl
                              ? const Color(0xFF503FE4)
                              : const Color(0xFFF59E0B))
                          .withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasPkl
                          ? Icons.business_center_rounded
                          : Icons.info_outline_rounded,
                      color: hasPkl
                          ? const Color(0xFF503FE4)
                          : const Color(0xFFD97706),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi PKL Siswa',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          namaSiswa ?? 'Data Siswa',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: (hasPkl
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B))
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hasPkl ? pklStatus : 'Belum Terdaftar',
                      style: TextStyle(
                        color: hasPkl
                            ? const Color(0xFF059669)
                            : const Color(0xFFD97706),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const Divider(height: 1),
              const SizedBox(height: 16),

              if (!hasPkl) ...[
                // Empty state matching the admin UI in user's screenshot
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_rounded,
                        color: Color(0xFF64748B),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Siswa belum terdaftar atau belum ditempatkan pada program PKL industri.',
                          style: TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Detail Tiles (Strictly WITHOUT phone number)
                _buildPklInfoTile(
                  icon: Icons.apartment_rounded,
                  iconBg: const Color(0xFFEEF2FF),
                  iconColor: const Color(0xFF4F46E5),
                  label: 'Nama Perusahaan Mitra',
                  value: pklNamaPerusahaan,
                ),
                const SizedBox(height: 10),

                _buildPklInfoTile(
                  icon: Icons.school_rounded,
                  iconBg: const Color(0xFFECFDF5),
                  iconColor: const Color(0xFF059669),
                  label: 'Penanggung Jawab Sekolah (Pembimbing)',
                  value: pklPenanggungJawabSekolah,
                ),
                const SizedBox(height: 10),

                _buildPklInfoTile(
                  icon: Icons.badge_rounded,
                  iconBg: const Color(0xFFFFFBEB),
                  iconColor: const Color(0xFFD97706),
                  label: 'Penanggung Jawab Industri (Pembimbing Lapangan)',
                  value: pklPenanggungJawabIndustri,
                ),
                const SizedBox(height: 10),

                _buildPklInfoTile(
                  icon: Icons.location_on_rounded,
                  iconBg: const Color(0xFFFEF2F2),
                  iconColor: const Color(0xFFDC2626),
                  label: 'Alamat Perusahaan',
                  value: pklAlamat,
                ),

                if (pklPeriode != null && pklPeriode!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _buildPklInfoTile(
                    icon: Icons.calendar_month_rounded,
                    iconBg: const Color(0xFFF0FDF4),
                    iconColor: const Color(0xFF16A34A),
                    label: 'Periode Pelaksanaan PKL',
                    value: pklPeriode!,
                  ),
                ],
              ],

              const SizedBox(height: 22),

              // Tombol Tutup
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF503FE4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPklInfoTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
