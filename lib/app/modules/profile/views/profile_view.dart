import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';
import 'package:siawi_app/app/modules/profile/views/edit_data_diri.dart';
import 'package:siawi_app/app/modules/profile/views/qrcode_view.dart';
import 'package:siawi_app/utils/colors.dart';

class ProfileView extends StatefulWidget {
  final VoidCallback signOut;
  const ProfileView(this.signOut, {super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  int _activeTab = 0; // 0: Biodata Siswa, 1: Orang Tua, 2: Wali Murid
  bool _loading = true;
  String _idSiswa = "";
  Map<String, dynamic>? _rawStudentData;

  // Data Akademik & Siswa
  String? _namaSiswa;
  String? _nis;
  String? _nisn;
  String? _fileFoto;
  String? _jenisKelamin;
  String? _agama;
  String? _tmptLahir;
  String? _tglLahir;
  String? _namaKelas;
  String? _namaJurusan;
  String? _noHp;
  String? _noTlpn;
  String? _email;
  String? _alamat;
  String? _noRumah;
  String? _rt;
  String? _rw;
  String? _kel;
  String? _kec;
  String? _kota;
  String? _prov;

  // Data Orang Tua (Ayah)
  String? _nikAyah;
  String? _namaAyah;
  String? _tmptLahirAyah;
  String? _tglLahirAyah;
  String? _pendidikanAyah;
  String? _pekerjaanAyah;
  String? _penghasilanAyah;
  String? _noHpAyah;

  // Data Orang Tua (Ibu)
  String? _nikIbu;
  String? _namaIbu;
  String? _tmptLahirIbu;
  String? _tglLahirIbu;
  String? _pendidikanIbu;
  String? _pekerjaanIbu;
  String? _penghasilanIbu;
  String? _noHpIbu;

  // Data Wali
  String? _nikWali;
  String? _namaWali;
  String? _tmptLahirWali;
  String? _tglLahirWali;
  String? _pendidikanWali;
  String? _pekerjaanWali;
  String? _penghasilanWali;
  String? _noHpWali;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? currentId = preferences.getString('idSiswa');
    if (currentId != null && currentId.isNotEmpty) {
      _idSiswa = currentId;
      await _fetchStudentData(currentId);
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchStudentData(String studentId) async {
    if (mounted) setState(() => _loading = true);
    try {
      final datasiswa = await ApiService.get('/home/$studentId');
      if (datasiswa != null && datasiswa['data'] != null) {
        var sData = datasiswa['data'];
        var kData = sData['kelas'];
        var jData = sData['jurusan'];

        if (mounted) {
          setState(() {
            _rawStudentData = Map<String, dynamic>.from(sData);
            if (kData != null) _rawStudentData!['nama_kelas'] = kData['nama_kelas'];
            if (jData != null) _rawStudentData!['nama_jurusan'] = jData['nama_jurusan'];

            _namaSiswa = sData['nama_siswa']?.toString().toUpperCase();
            _nis = sData['nis']?.toString();
            _nisn = sData['nisn']?.toString();
            _fileFoto = sData['foto']?.toString();
            _jenisKelamin = sData['jenis_kelamin']?.toString();
            _agama = sData['agama']?.toString();
            _tmptLahir = sData['tmpt_lahir']?.toString();
            _tglLahir = sData['tgl_lahir']?.toString();
            _namaKelas = kData != null ? kData['nama_kelas']?.toString() : null;
            _namaJurusan = jData != null ? jData['nama_jurusan']?.toString() : null;
            _noHp = sData['no_hp']?.toString();
            _noTlpn = sData['no_tlpn']?.toString();
            _email = sData['email']?.toString();
            _alamat = sData['alamat']?.toString();
            _noRumah = sData['no_rumah']?.toString();
            _rt = sData['rt']?.toString();
            _rw = sData['rw']?.toString();
            _kel = sData['kel']?.toString();
            _kec = sData['kec']?.toString();
            _kota = sData['kota']?.toString();
            _prov = sData['prov']?.toString();

            // Ayah
            _nikAyah = sData['nik_ayah']?.toString();
            _namaAyah = sData['nama_ayah']?.toString();
            _tmptLahirAyah = sData['tmpt_lahir_ayah']?.toString();
            _tglLahirAyah = sData['tgl_lahir_ayah']?.toString();
            _pendidikanAyah = sData['pendidikan_ayah']?.toString();
            _pekerjaanAyah = sData['pekerjaan_ayah']?.toString();
            _penghasilanAyah = sData['penghasilan_ayah']?.toString();
            _noHpAyah = sData['no_hp_ayah']?.toString();

            // Ibu
            _nikIbu = sData['nik_ibu']?.toString();
            _namaIbu = sData['nama_ibu']?.toString();
            _tmptLahirIbu = sData['tmpt_lahir_ibu']?.toString();
            _tglLahirIbu = sData['tgl_lahir_ibu']?.toString();
            _pendidikanIbu = sData['pendidikan_ibu']?.toString();
            _pekerjaanIbu = sData['pekerjaan_ibu']?.toString();
            _penghasilanIbu = sData['penghasilan_ibu']?.toString();
            _noHpIbu = sData['no_hp_ibu']?.toString();

            // Wali
            _nikWali = sData['nik_wali']?.toString();
            _namaWali = sData['nama_wali']?.toString();
            _tmptLahirWali = sData['tmpt_lahir_wali']?.toString();
            _tglLahirWali = sData['tgl_lahir_wali']?.toString();
            _pendidikanWali = sData['pendidikan_wali']?.toString();
            _pekerjaanWali = sData['pekerjaan_wali']?.toString();
            _penghasilanWali = sData['penghasilan_wali']?.toString();
            _noHpWali = sData['no_hp_wali']?.toString();
          });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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

  String _formatGender(String? jk) {
    if (jk == null || jk.isEmpty) return '-';
    final g = jk.trim().toUpperCase();
    if (g == 'L' || g == 'LAKI-LAKI' || g == 'LAKI - LAKI') return 'Laki - Laki';
    if (g == 'P' || g == 'PEREMPUAN') return 'Perempuan';
    return jk;
  }

  String _formatTTL(String? tempat, String? tanggal) {
    bool hasTempat = tempat != null && tempat.trim().isNotEmpty && tempat != '-' && tempat != 'null';
    bool hasTgl = tanggal != null && tanggal.trim().isNotEmpty && tanggal != '-' && tanggal != 'null';
    if (hasTempat && hasTgl) return "$tempat, $tanggal";
    if (hasTempat) return tempat;
    if (hasTgl) return tanggal;
    return '-';
  }

  String _formatAlamatLengkap() {
    List<String> parts = [];
    if (_alamat != null && _alamat!.trim().isNotEmpty && _alamat != '-' && _alamat != 'null') {
      parts.add(_alamat!.trim());
    }
    if (_noRumah != null && _noRumah!.trim().isNotEmpty && _noRumah != '-' && _noRumah != 'null') {
      parts.add("No. $_noRumah");
    }
    String rtRw = "";
    if (_rt != null && _rt!.trim().isNotEmpty && _rt != '-' && _rt != 'null') {
      rtRw += "RT $_rt";
    }
    if (_rw != null && _rw!.trim().isNotEmpty && _rw != '-' && _rw != 'null') {
      rtRw += rtRw.isNotEmpty ? " / RW $_rw" : "RW $_rw";
    }
    if (rtRw.isNotEmpty) parts.add(rtRw);
    if (_kel != null && _kel!.trim().isNotEmpty && _kel != '-' && _kel != 'null') {
      parts.add("Kel. $_kel");
    }
    if (_kec != null && _kec!.trim().isNotEmpty && _kec != '-' && _kec != 'null') {
      parts.add("Kec. $_kec");
    }
    if (_kota != null && _kota!.trim().isNotEmpty && _kota != '-' && _kota != 'null') {
      parts.add(_kota!.trim());
    }
    if (_prov != null && _prov!.trim().isNotEmpty && _prov != '-' && _prov != 'null') {
      parts.add(_prov!.trim());
    }

    if (parts.isEmpty) return "-";
    return parts.join(", ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Profil Siswa',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Kartu Pelajar',
            icon: const Icon(Icons.badge_rounded, color: Colors.white, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QrCode(
                    widget.signOut,
                    initialData: _rawStudentData,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_idSiswa.isNotEmpty) {
            await _fetchStudentData(_idSiswa);
          }
        },
        color: AppColors.mainColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            children: [
              // 1. HERO HEADER PROFILE
              _buildHeroHeader(context),

              // 2. SEGMENTED TAB SWITCHER
              _buildSegmentedTabs(),

              // 3. TAB CONTENT
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: _loading
                    ? _buildLoadingSkeleton()
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _buildCurrentTabContent(),
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // HERO HEADER PROFILE
  Widget _buildHeroHeader(BuildContext context) {
    String photoUrl = _getStudentPhotoUrl(_fileFoto);
    String defaultAsset = _getDefaultAvatarAsset();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.mainColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.mainColor.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        children: [
          // Foto Profil Siswa (Tanpa tombol ubah foto)
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: photoUrl.isNotEmpty
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        width: 88,
                        height: 88,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: Colors.white.withValues(alpha: 0.3),
                            child: const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(defaultAsset, fit: BoxFit.cover);
                        },
                      )
                    : Image.asset(defaultAsset, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Nama Siswa
          Text(
            _namaSiswa ?? 'MEMUAT DATA...',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),

          // Badges NIS & Kelas
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildHeaderBadge(Icons.badge_outlined, "NIS: ${_nis ?? '-'}"),
              _buildHeaderBadge(Icons.school_outlined, _namaKelas ?? 'Kelas -'),
            ],
          ),
          const SizedBox(height: 4),

          // Nama Jurusan
          Text(
            _namaJurusan ?? 'SMK Wisata Indonesia',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),

          // Action Row: Ubah Data Diri & QR Kartu
          Row(
            children: [
              // Tombol Ubah Data Diri
              Expanded(
                flex: 3,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  elevation: 2,
                  shadowColor: Colors.black.withValues(alpha: 0.15),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UbahDataDiriScreen(widget.signOut),
                        ),
                      ).then((_) {
                        if (_idSiswa.isNotEmpty) {
                          _fetchStudentData(_idSiswa);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            size: 19,
                            color: AppColors.mainColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Ubah Data Diri",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.mainColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Tombol Kartu Pelajar
              Expanded(
                flex: 2,
                child: Material(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QrCode(
                            widget.signOut,
                            initialData: _rawStudentData,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.28),
                          width: 1.1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.badge_rounded,
                            size: 17,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Kartu Pelajar",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // SEGMENTED TABS
  Widget _buildSegmentedTabs() {
    final List<Map<String, dynamic>> tabs = [
      {"label": "Data Diri", "icon": Icons.person_rounded},
      {"label": "Orang Tua", "icon": Icons.family_restroom_rounded},
      {"label": "Wali Murid", "icon": Icons.supervisor_account_rounded},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            for (int i = 0; i < tabs.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeTab = i;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: _activeTab == i ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _activeTab == i
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tabs[i]["icon"] as IconData,
                          size: 15,
                          color: _activeTab == i
                              ? AppColors.mainColor
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          tabs[i]["label"] as String,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight:
                                _activeTab == i ? FontWeight.w800 : FontWeight.w600,
                            color: _activeTab == i
                                ? const Color(0xFF1E293B)
                                : const Color(0xFF64748B),
                          ),
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

  // TAB CONTENT SWITCHER
  Widget _buildCurrentTabContent() {
    switch (_activeTab) {
      case 0:
        return _buildTabBiodata();
      case 1:
        return _buildTabOrangTua();
      case 2:
        return _buildTabWali();
      default:
        return _buildTabBiodata();
    }
  }

  // TAB 1: BIODATA SISWA
  Widget _buildTabBiodata() {
    return Column(
      key: const ValueKey(0),
      children: [
        // Kartu 1: Data Akademik
        _buildSectionCard(
          title: "Informasi Akademik",
          icon: Icons.school_rounded,
          iconColor: const Color(0xFF4F46E5),
          iconBg: const Color(0xFFEEF2FF),
          items: [
            _InfoItem("NIS (Nomor Induk Siswa)", _nis ?? '-', Icons.tag_rounded),
            _InfoItem("NISN", _nisn ?? '-', Icons.pin_rounded),
            _InfoItem("Kelas", _namaKelas ?? '-', Icons.meeting_room_rounded),
            _InfoItem("Kompetensi Keahlian", _namaJurusan ?? '-', Icons.workspace_premium_rounded),
            _InfoItem("Status Siswa", "Siswa Aktif Terdaftar", Icons.verified_rounded, valueColor: const Color(0xFF059669)),
          ],
        ),
        const SizedBox(height: 14),

        // Kartu 2: Identitas Diri
        _buildSectionCard(
          title: "Identitas Diri Siswa",
          icon: Icons.badge_rounded,
          iconColor: const Color(0xFF0D9488),
          iconBg: const Color(0xFFCCFBF1),
          items: [
            _InfoItem("Tempat, Tanggal Lahir", _formatTTL(_tmptLahir, _tglLahir), Icons.cake_rounded),
            _InfoItem("Jenis Kelamin", _formatGender(_jenisKelamin), Icons.wc_rounded),
            _InfoItem("Agama", _agama ?? '-', Icons.auto_awesome_rounded),
          ],
        ),
        const SizedBox(height: 14),

        // Kartu 3: Kontak & Komunikasi
        _buildSectionCard(
          title: "Kontak & Komunikasi",
          icon: Icons.contact_phone_rounded,
          iconColor: const Color(0xFF2563EB),
          iconBg: const Color(0xFFDBEAFE),
          items: [
            _InfoItem("Nomor Handphone (WhatsApp)", _noHp ?? '-', Icons.phone_android_rounded),
            _InfoItem("Nomor Telepon Rumah", _noTlpn ?? '-', Icons.call_rounded),
            _InfoItem("Alamat Email", _email ?? '-', Icons.mail_rounded),
          ],
        ),
        const SizedBox(height: 14),

        // Kartu 4: Alamat Domisili
        _buildSectionCard(
          title: "Alamat Tempat Tinggal",
          icon: Icons.location_on_rounded,
          iconColor: const Color(0xFFD97706),
          iconBg: const Color(0xFFFEF3C7),
          items: [
            _InfoItem("Alamat Lengkap", _formatAlamatLengkap(), Icons.home_rounded),
            _InfoItem("RT / RW", "${_rt ?? '-'} / ${_rw ?? '-'}", Icons.signpost_rounded),
            _InfoItem("Kelurahan", _kel ?? '-', Icons.maps_home_work_rounded),
            _InfoItem("Kecamatan", _kec ?? '-', Icons.location_city_rounded),
            _InfoItem("Kota / Kabupaten", _kota ?? '-', Icons.apartment_rounded),
            _InfoItem("Provinsi", _prov ?? '-', Icons.public_rounded),
          ],
        ),
      ],
    );
  }

  // TAB 2: DATA ORANG TUA
  Widget _buildTabOrangTua() {
    return Column(
      key: const ValueKey(1),
      children: [
        // Kartu Data Ayah
        _buildSectionCard(
          title: "Data Ayah Kandung",
          icon: Icons.face_rounded,
          iconColor: const Color(0xFF0284C7),
          iconBg: const Color(0xFFE0F2FE),
          badgeTag: "Ayah",
          items: [
            _InfoItem("Nama Lengkap Ayah", _namaAyah ?? '-', Icons.person_outline_rounded),
            _InfoItem("Nomor HP / WhatsApp Ayah", _noHpAyah ?? '-', Icons.phone_android_rounded),
            _InfoItem("NIK Ayah", _nikAyah ?? '-', Icons.badge_outlined),
            _InfoItem("Tempat, Tanggal Lahir", _formatTTL(_tmptLahirAyah, _tglLahirAyah), Icons.cake_outlined),
            _InfoItem("Pendidikan Terakhir", _pendidikanAyah ?? '-', Icons.school_outlined),
            _InfoItem("Pekerjaan", _pekerjaanAyah ?? '-', Icons.work_outline_rounded),
            _InfoItem("Penghasilan Bulanan", _penghasilanAyah ?? '-', Icons.payments_outlined),
          ],
        ),
        const SizedBox(height: 16),

        // Kartu Data Ibu
        _buildSectionCard(
          title: "Data Ibu Kandung",
          icon: Icons.face_3_rounded,
          iconColor: const Color(0xFFE11D48),
          iconBg: const Color(0xFFFFE4E6),
          badgeTag: "Ibu",
          items: [
            _InfoItem("Nama Lengkap Ibu", _namaIbu ?? '-', Icons.person_outline_rounded),
            _InfoItem("Nomor HP / WhatsApp Ibu", _noHpIbu ?? '-', Icons.phone_android_rounded),
            _InfoItem("NIK Ibu", _nikIbu ?? '-', Icons.badge_outlined),
            _InfoItem("Tempat, Tanggal Lahir", _formatTTL(_tmptLahirIbu, _tglLahirIbu), Icons.cake_outlined),
            _InfoItem("Pendidikan Terakhir", _pendidikanIbu ?? '-', Icons.school_outlined),
            _InfoItem("Pekerjaan", _pekerjaanIbu ?? '-', Icons.work_outline_rounded),
            _InfoItem("Penghasilan Bulanan", _penghasilanIbu ?? '-', Icons.payments_outlined),
          ],
        ),
      ],
    );
  }

  // TAB 3: DATA WALI
  Widget _buildTabWali() {
    bool hasWali = _namaWali != null &&
        _namaWali!.trim().isNotEmpty &&
        _namaWali != '-' &&
        _namaWali != 'null';

    return Column(
      key: const ValueKey(2),
      children: [
        if (hasWali) ...[
          _buildSectionCard(
            title: "Data Wali Murid",
            icon: Icons.supervisor_account_rounded,
            iconColor: const Color(0xFF7C3AED),
            iconBg: const Color(0xFFEDE9FE),
            badgeTag: "Wali",
            items: [
              _InfoItem("Nama Lengkap Wali", _namaWali ?? '-', Icons.person_outline_rounded),
              _InfoItem("Nomor HP / WhatsApp Wali", _noHpWali ?? '-', Icons.phone_android_rounded),
              _InfoItem("NIK Wali", _nikWali ?? '-', Icons.badge_outlined),
              _InfoItem("Tempat, Tanggal Lahir", _formatTTL(_tmptLahirWali, _tglLahirWali), Icons.cake_outlined),
              _InfoItem("Pendidikan Terakhir", _pendidikanWali ?? '-', Icons.school_outlined),
              _InfoItem("Pekerjaan", _pekerjaanWali ?? '-', Icons.work_outline_rounded),
              _InfoItem("Penghasilan Bulanan", _penghasilanWali ?? '-', Icons.payments_outlined),
            ],
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFECEFF5), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.supervisor_account_outlined,
                    size: 30,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Tidak Ada Data Wali",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Data wali hanya diisi apabila siswa diasuh oleh pihak wali (selain orang tua kandung).",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // REUSABLE CARD CONTAINER
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    String? badgeTag,
    required List<_InfoItem> items,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFECEFF5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              if (badgeTag != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeTag,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: iconColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),

          // Items List
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 16, color: Color(0xFFF8FAFC)),
            _buildInfoRow(items[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(_InfoItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
          ),
          child: Icon(
            item.icon,
            size: 14,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.value,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: item.valueColor ?? const Color(0xFF1E293B),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // SKELETON LOADING
  Widget _buildLoadingSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFECEFF5), width: 1.2),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          CircularProgressIndicator(
            color: AppColors.mainColor,
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 16),
          const Text(
            "Memuat data profil siswa...",
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  _InfoItem(this.label, this.value, this.icon, {this.valueColor});
}
