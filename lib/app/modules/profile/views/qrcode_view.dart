import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';
import 'package:siawi_app/utils/colors.dart';

class QrCode extends StatefulWidget {
  final VoidCallback signOut;
  final Map<String, dynamic>? initialData;
  const QrCode(this.signOut, {this.initialData, super.key});

  @override
  State<QrCode> createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode> {
  bool _loading = true;
  String? _qrCodeSvg;

  String? _namaSiswa;
  String? _nis;
  String? _nisn;
  String? _fileFoto;
  String? _jenisKelamin;
  String? _tmptLahir;
  String? _tglLahir;
  String? _namaJurusan;
  String? _alamat;
  String? _rt;
  String? _rw;
  String? _noRumah;
  String? _kel;
  String? _kec;
  String? _kota;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _applyData(widget.initialData!);
      _loading = false;
      if (_nis != null && _nis!.isNotEmpty) {
        _fetchQRCode(_nis!);
      }
    }
    _loadStudentData();
  }

  void _applyData(Map<String, dynamic> data) {
    setState(() {
      _namaSiswa = data['nama_siswa']?.toString().toUpperCase();
      _nis = data['nis']?.toString();
      _nisn = data['nisn']?.toString();
      _fileFoto = data['foto']?.toString();
      _jenisKelamin = data['jenis_kelamin']?.toString();
      _tmptLahir = data['tmpt_lahir']?.toString();
      _tglLahir = data['tgl_lahir']?.toString();
      _namaJurusan = data['nama_jurusan']?.toString();
      _alamat = data['alamat']?.toString();
      _rt = data['rt']?.toString();
      _rw = data['rw']?.toString();
      _noRumah = data['no_rumah']?.toString();
      _kel = data['kel']?.toString();
      _kec = data['kec']?.toString();
      _kota = data['kota']?.toString();
    });
  }

  Future<void> _loadStudentData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? idSiswa = preferences.getString('idSiswa');
    if (idSiswa != null && idSiswa.isNotEmpty) {
      await _lihatData(idSiswa);
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _lihatData(String idSiswa) async {
    try {
      final datasiswa = await ApiService.get('/home/$idSiswa');
      if (datasiswa != null && datasiswa['data'] != null) {
        var sData = datasiswa['data'];
        var jData = sData['jurusan'];

        if (mounted) {
          setState(() {
            _namaSiswa = sData['nama_siswa']?.toString().toUpperCase();
            _nis = sData['nis']?.toString();
            _nisn = sData['nisn']?.toString();
            _fileFoto = sData['foto']?.toString();
            _jenisKelamin = sData['jenis_kelamin']?.toString();
            _tmptLahir = sData['tmpt_lahir']?.toString();
            _tglLahir = sData['tgl_lahir']?.toString();
            _namaJurusan =
                jData != null ? jData['nama_jurusan']?.toString() : null;
            _alamat = sData['alamat']?.toString();
            _rt = sData['rt']?.toString();
            _rw = sData['rw']?.toString();
            _noRumah = sData['no_rumah']?.toString();
            _kel = sData['kel']?.toString();
            _kec = sData['kec']?.toString();
            _kota = sData['kota']?.toString();
          });
        }

        if (_nis != null && _nis!.isNotEmpty) {
          await _fetchQRCode(_nis!);
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchQRCode(String studentNis) async {
    try {
      final svgData =
          await ApiService.getRaw('/generate-qrcode?data=$studentNis');
      if (mounted) {
        setState(() {
          _qrCodeSvg = svgData;
        });
      }
    } catch (_) {}
  }

  String _formatTTL(String? tempat, String? tanggal) {
    String cleanTempat = (tempat != null && tempat != '-' && tempat != 'null')
        ? tempat.trim()
        : 'Jakarta';
    String formattedTgl = '-';

    if (tanggal != null &&
        tanggal.trim().isNotEmpty &&
        tanggal != '-' &&
        tanggal != 'null') {
      try {
        DateTime parsed = DateTime.parse(tanggal.trim());
        const List<String> months = [
          'Januari',
          'Februari',
          'Maret',
          'April',
          'Mei',
          'Juni',
          'Juli',
          'Agustus',
          'September',
          'Oktober',
          'November',
          'Desember'
        ];
        formattedTgl =
            "${parsed.day} ${months[parsed.month - 1]} ${parsed.year}";
      } catch (_) {
        formattedTgl = tanggal.trim();
      }
    }

    if (cleanTempat.isNotEmpty && formattedTgl != '-') {
      return "$cleanTempat, $formattedTgl";
    } else if (cleanTempat.isNotEmpty) {
      return cleanTempat;
    }
    return formattedTgl;
  }

  String _formatAlamatLengkap() {
    List<String> parts = [];
    if (_alamat != null &&
        _alamat!.trim().isNotEmpty &&
        _alamat != '-' &&
        _alamat != 'null') {
      parts.add(_alamat!.trim());
    }
    if (_noRumah != null &&
        _noRumah!.trim().isNotEmpty &&
        _noRumah != '-' &&
        _noRumah != 'null') {
      parts.add("No. $_noRumah");
    }
    String rtRw = "";
    if (_rt != null && _rt!.trim().isNotEmpty && _rt != '-' && _rt != 'null') {
      rtRw += "Rt ${_rt!.padLeft(3, '0')}";
    }
    if (_rw != null && _rw!.trim().isNotEmpty && _rw != '-' && _rw != 'null') {
      rtRw += rtRw.isNotEmpty
          ? "/${_rw!.padLeft(3, '0')}"
          : "Rw ${_rw!.padLeft(3, '0')}";
    }
    if (rtRw.isNotEmpty) parts.add(rtRw);

    if (_kel != null &&
        _kel!.trim().isNotEmpty &&
        _kel != '-' &&
        _kel != 'null') {
      parts.add(_kel!.trim());
    }
    if (_kec != null &&
        _kec!.trim().isNotEmpty &&
        _kec != '-' &&
        _kec != 'null') {
      parts.add(_kec!.trim());
    }
    if (_kota != null &&
        _kota!.trim().isNotEmpty &&
        _kota != '-' &&
        _kota != 'null') {
      parts.add(_kota!.trim());
    }

    if (parts.isEmpty) {
      return "Jl. Raya Lenteng Agung, Jagakarsa Jakarta Selatan";
    }
    return parts.join(" ");
  }

  String _formatBerlakuSd() {
    // Estimasi berlaku s/d dari NIS (jika 2 digit pertama adalah angkatan)
    if (_nis != null && _nis!.length >= 2) {
      int? prefixYear = int.tryParse(_nis!.substring(0, 2));
      if (prefixYear != null && prefixYear >= 20 && prefixYear <= 35) {
        int expiryYear = 2000 + prefixYear + 3;
        return "30 Juni $expiryYear";
      }
    }
    return "30 Juni 2027";
  }

  String _getDefaultAvatarAsset() {
    final gender = (_jenisKelamin ?? '').trim().toUpperCase();
    if (gender == 'P' || gender == 'PEREMPUAN') {
      return 'assets/images/avatar_female.png';
    }
    return 'assets/images/avatar_male.png';
  }

  String _getStudentPhotoUrl(String? filename) {
    if (filename == null ||
        filename.isEmpty ||
        filename == 'null' ||
        filename == '-' ||
        filename == 'default.png' ||
        filename == 'avatar.jpg' ||
        filename == 'avatar.png' ||
        filename == 'avatar_male.jpg' ||
        filename == 'avatar_male.png' ||
        filename == 'avatar_female.jpg' ||
        filename == 'avatar_female.png') {
      return '';
    }
    return 'https://siawi.smkwisataindonesia.sch.id/storage/foto-siswa/$filename';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Kartu Pelajar',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Image.asset(
                'assets/logo/logo-splash.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 14),
                  Text(
                    "Memuat Kartu Pelajar...",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 30),
              child: Column(
                children: [
                  // 1. KARTU PELAJAR FISIK / DIGITAL UTAMA (PERSIS SEPERTI GAMBAR)
                  _buildPhysicalStudentCard(),

                  const SizedBox(height: 20),

                  // 2. KARTU QR CODE PRESENSI RESMI
                  _buildAttendanceQrCard(),
                ],
              ),
            ),
    );
  }

  // WIDGET KARTU PELAJAR DIGITAL PERSIS SEPERTI PADA GAMBAR
  Widget _buildPhysicalStudentCard() {
    String photoUrl = _getStudentPhotoUrl(_fileFoto);
    String defaultAsset = _getDefaultAvatarAsset();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFBCA7CC),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF50206B).withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // A. HEADER / KOP KARTU
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo SMK Wisata Indonesia (Kiri)
                Image.asset(
                  'assets/logo/logo-splash.png',
                  width: 52,
                  height: 52,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 10),

                // Teks Kop Yayasan & Sekolah
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "YAYASAN TAQWASH SHOBIRIN",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6A358A),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        "SMK WISATA INDONESIA",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF50206B),
                          letterSpacing: 0.3,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Perhotelan, Kuliner, Teknik Komputer & Jaringan",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Jl. Raya Lenteng Agung/Jl.Langgar No.1 Kebagusan Pasar Minggu Jakarta Selatan.",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 7.6,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const Text(
                        "Tlp/fax 78830761  E-mail : wistin@smkwi.sch.id  Website : www.smkwi.sch.id",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 7.4,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // B. RIBBON STRIP UNGU "KARTU PELAJAR"
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: const Color(0xFF6C3483),
            alignment: Alignment.center,
            child: const Text(
              "KARTU PELAJAR",
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.2,
              ),
            ),
          ),

          // C. BODY KARTU PELAJAR (LAVENDER SOFT BACKGROUND)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFEDE4F3),
                  Color(0xFFE5D6EB),
                ],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FOTO SISWA DI KIRI
                Column(
                  children: [
                    Container(
                      width: 90,
                      height: 118,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color:
                              const Color(0xFFDC2626), // Border merah pasfoto
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(1),
                        child: photoUrl.isNotEmpty
                            ? Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(defaultAsset,
                                        fit: BoxFit.cover),
                              )
                            : Image.asset(defaultAsset, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "SMK WISATA INDONESIA",
                      style: TextStyle(
                        fontSize: 7.2,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // TABEL BIODATA SISWA DI KANAN
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCardRow(
                        "No. Induk/NISN",
                        "${_nis ?? '-'} / ${_nisn ?? '-'}",
                      ),
                      _buildCardRow(
                        "Nama",
                        _namaSiswa ?? 'SISWA',
                        isBold: true,
                      ),
                      _buildCardRow(
                        "Tempat/Tgl Lahir",
                        _formatTTL(_tmptLahir, _tglLahir),
                      ),
                      _buildCardRow(
                        "Konsentrasi Keahlian",
                        _namaJurusan ?? 'Teknik Komputer dan Jaringan',
                      ),
                      _buildCardRow(
                        "Alamat",
                        _formatAlamatLengkap(),
                      ),
                      _buildCardRow(
                        "Berlaku s/d",
                        _formatBerlakuSd(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // HELPER BARIS DATA KARTU PELAJAR
  Widget _buildCardRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
                height: 1.25,
              ),
            ),
          ),
          const Text(
            ": ",
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
                color: const Color(0xFF0F172A),
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET QR CODE PRESENSI RESMI
  Widget _buildAttendanceQrCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.mainColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.qr_code_scanner_rounded,
                    size: 18, color: AppColors.mainColor),
              ),
              const SizedBox(width: 8),
              const Text(
                "QR Code Verifikasi",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tampilan QR Code Svg
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: _qrCodeSvg == null
                ? const SizedBox(
                    width: 170,
                    height: 170,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  )
                : SvgPicture.string(
                    _qrCodeSvg!,
                    width: 170,
                    height: 170,
                    fit: BoxFit.contain,
                  ),
          ),
          const SizedBox(height: 14),

          Text(
            "NIS: ${_nis ?? '-'}",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Tunjukkan QR Code ini kepada petugas sekolah untuk keperluan verifikasi.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
