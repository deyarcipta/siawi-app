import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/modules/absensi/views/absensi_view.dart';
import 'package:siawi_app/app/modules/dokumen_gabungan/views/dokumen_gabungan_view.dart';
import 'package:siawi_app/app/modules/informasi/views/informasi_view.dart';
import 'package:siawi_app/app/modules/jadwal/views/jadwal_view.dart';
import 'package:siawi_app/app/modules/kalender/views/kalender_view.dart';
import 'package:siawi_app/app/modules/modul/views/modul_mapel_view.dart';
import 'package:siawi_app/app/modules/point_siswa/views/point_siswa_view.dart';
import 'package:siawi_app/app/modules/pengajuan_pkl/views/pengajuan_pkl_view.dart';
import 'package:siawi_app/app/modules/tagihan/views/tagihan_view.dart';

class Menu extends StatefulWidget {
  final VoidCallback signOut;
  const Menu(this.signOut, {super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuItemData {
  final String title;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final Widget? destination;

  const _MenuItemData({
    required this.title,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    this.destination,
  });
}

class _MenuState extends State<Menu> {
  String role = "siswa";
  bool isPklLevel = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String currentRole = preferences.getString('role') ?? 'siswa';
    String? idSiswa = preferences.getString('idSiswa');

    bool pklLevel = true;
    if (preferences.containsKey('is_pkl_level')) {
      pklLevel = preferences.getBool('is_pkl_level') ?? true;
    } else if (idSiswa != null) {
      String? cacheRaw =
          preferences.getString('cached_student_header_$idSiswa');
      if (cacheRaw != null && cacheRaw.isNotEmpty) {
        try {
          var cMap = jsonDecode(cacheRaw);
          if (cMap['isPklLevel'] != null) {
            pklLevel = cMap['isPklLevel'] == true;
          } else if (cMap['namaKelas'] != null) {
            String nk = cMap['namaKelas'].toString().toUpperCase();
            pklLevel = !nk.startsWith('X-') && !nk.startsWith('X ');
          }
        } catch (_) {}
      }
    }

    if (mounted) {
      setState(() {
        role = currentRole;
        isPklLevel = pklLevel;
      });
    }
  }

  List<_MenuItemData> _getSiswaMenuItems() {
    return [
      // 1. Informasi
      _MenuItemData(
        title: "Informasi",
        icon: Icons.campaign_rounded,
        bgColor: const Color(0xFFFFFBEB),
        iconColor: const Color(0xFFD97706),
        destination: InformasiView(widget.signOut),
      ),
      // 2. Kalender
      _MenuItemData(
        title: "Kalender",
        icon: Icons.calendar_month_rounded,
        bgColor: const Color(0xFFFFF1F2),
        iconColor: const Color(0xFFE11D48),
        destination: KalenderView(widget.signOut),
      ),
      // 3. Absensi
      _MenuItemData(
        title: "Absensi",
        icon: Icons.fact_check_rounded,
        bgColor: const Color(0xFFDCFCE7),
        iconColor: const Color(0xFF059669),
        destination: AbsensiView(widget.signOut),
      ),
      // 4. Jadwal
      _MenuItemData(
        title: "Jadwal",
        icon: Icons.access_time_rounded,
        bgColor: const Color(0xFFE0F2FE),
        iconColor: const Color(0xFF0284C7),
        destination: JadwalView(widget.signOut),
      ),
      // 5. Dokumen
      _MenuItemData(
        title: "Dokumen",
        icon: Icons.description_rounded,
        bgColor: const Color(0xFFEEF2FF),
        iconColor: const Color(0xFF4F46E5),
        destination: DokumenGabunganView(widget.signOut),
      ),
      // 6. Poin Siswa (Teks Lengkap)
      _MenuItemData(
        title: "Poin Siswa",
        icon: Icons.balance_rounded,
        bgColor: const Color(0xFFF3E8FF),
        iconColor: const Color(0xFF9333EA),
        destination: PointSiswaView(widget.signOut),
      ),
      // 7. Modul
      _MenuItemData(
        title: "Modul",
        icon: Icons.menu_book_rounded,
        bgColor: const Color(0xFFFFEDD5),
        iconColor: const Color(0xFFEA580C),
        destination: const ModulMapelView(),
      ),
      // 8. Surat PKL (Sesuai Mockup Gambar, Posisi Paling Akhir)
      _MenuItemData(
        title: "Surat PKL",
        icon: Icons.work_outline_rounded,
        bgColor: const Color(0xFFE6FAF5),
        iconColor: const Color(0xFF0F766E),
        destination: PengajuanPklView(widget.signOut),
      ),
    ];
  }

  List<_MenuItemData> _getOrangTuaMenuItems() {
    return [
      _MenuItemData(
        title: "Tagihan",
        icon: Icons.account_balance_wallet_rounded,
        bgColor: const Color(0xFFFFFBEB),
        iconColor: const Color(0xFFD97706),
        destination: TagihanView(widget.signOut),
      ),
      _MenuItemData(
        title: "Kalender",
        icon: Icons.calendar_month_rounded,
        bgColor: const Color(0xFFFFF1F2),
        iconColor: const Color(0xFFE11D48),
        destination: KalenderView(widget.signOut),
      ),
      _MenuItemData(
        title: "Absensi",
        icon: Icons.fact_check_rounded,
        bgColor: const Color(0xFFDCFCE7),
        iconColor: const Color(0xFF059669),
        destination: AbsensiView(widget.signOut),
      ),
      _MenuItemData(
        title: "Jadwal",
        icon: Icons.access_time_rounded,
        bgColor: const Color(0xFFE0F2FE),
        iconColor: const Color(0xFF0284C7),
        destination: JadwalView(widget.signOut),
      ),
      _MenuItemData(
        title: "Dokumen",
        icon: Icons.description_rounded,
        bgColor: const Color(0xFFEEF2FF),
        iconColor: const Color(0xFF4F46E5),
        destination: DokumenGabunganView(widget.signOut),
      ),
      _MenuItemData(
        title: "Poin Siswa",
        icon: Icons.balance_rounded,
        bgColor: const Color(0xFFF3E8FF),
        iconColor: const Color(0xFF9333EA),
        destination: PointSiswaView(widget.signOut),
      ),
      _MenuItemData(
        title: "Modul",
        icon: Icons.menu_book_rounded,
        bgColor: const Color(0xFFFFEDD5),
        iconColor: const Color(0xFFEA580C),
        destination: const ModulMapelView(),
      ),
      _MenuItemData(
        title: "Informasi",
        icon: Icons.campaign_rounded,
        bgColor: const Color(0xFFFFFBEB),
        iconColor: const Color(0xFFD97706),
        destination: InformasiView(widget.signOut),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<_MenuItemData> items =
        role == "orang_tua" ? _getOrangTuaMenuItems() : _getSiswaMenuItems();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Fitur & Layanan Siswa + Badge Menu Terpadu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role == "orang_tua"
                            ? "Fitur & Layanan Akademik"
                            : "Fitur & Layanan Siswa",
                        style: const TextStyle(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        "Akses cepat administrasi akademik",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.apps_rounded,
                        size: 15,
                        color: Color(0xFF4F46E5),
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Menu Terpadu",
                        style: TextStyle(
                          color: Color(0xFF4F46E5),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Baris 1: Informasi, Kalender, Absensi, Jadwal
            Row(
              children: [
                for (int i = 0; i < 4; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _buildMenuItem(items[i]),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),

            // Baris 2: Dokumen, Poin Siswa, Modul, Surat PKL
            Row(
              children: [
                for (int i = 4; i < 8; i++) ...[
                  if (i > 4) const SizedBox(width: 8),
                  Expanded(
                    child: _buildMenuItem(items[i]),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(_MenuItemData item) {
    bool isPklMenu = item.title == "Surat PKL";
    bool isLocked = isPklMenu && !isPklLevel;

    return GestureDetector(
      onTap: () async {
        if (isPklMenu) {
          // Validasi secara realtime dengan preferences terkini
          SharedPreferences prefs = await SharedPreferences.getInstance();
          bool allowed = isPklLevel;
          if (prefs.containsKey('is_pkl_level')) {
            allowed = prefs.getBool('is_pkl_level') ?? allowed;
          }
          if (!allowed) {
            if (!mounted) return;
            _showPklRestrictedDialog(context);
            return;
          }
        }

        if (item.destination != null) {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => item.destination!),
          );
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(2, 9, 2, 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFECEFF5),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Squircle container warna pastel dengan icon berwarna & badge lock jika tidak aktif
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isLocked ? const Color(0xFFF1F5F9) : item.bgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    item.icon,
                    color: isLocked ? const Color(0xFF94A3B8) : item.iconColor,
                    size: 24,
                  ),
                ),
                if (isLocked)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      padding: const EdgeInsets.all(3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF64748B),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            // Jarak icon dan teks dibuat rapat/dekat sesuai permintaan user
            const SizedBox(height: 5),

            // Label Title (Poin Siswa & Surat PKL lengkap tanpa terpotong)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: SizedBox(
                height: 22,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      item.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isLocked
                            ? const Color(0xFF64748B)
                            : const Color(0xFF1E293B),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPklRestrictedDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "PklRestrictedDialog",
      barrierColor: Colors.black.withValues(alpha: 0.54),
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
      pageBuilder: (context, anim1, anim2) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Header Lingkaran
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD97706).withValues(alpha: 0.2),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock_person_rounded,
                      color: Color(0xFFD97706),
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Badge Layanan BKK & Hubin
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Layanan BKK & Hubin",
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4F46E5),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Judul
                const Text(
                  "Khusus Tingkat Aktif PKL",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),

                // Deskripsi Penjelasan
                Text(
                  "Menu Surat PKL hanya dapat diakses oleh siswa pada tingkat yang sedang aktif mengikuti program PKL.\n\nTingkat kelas Anda saat ini belum memasuki masa aktif PKL yang ditetapkan oleh sekolah. Silakan berkoordinasi dengan wali kelas atau pihak BKK & Hubin jika ada pertanyaan.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),

                // Tombol Aksi "Saya Mengerti"
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Saya Mengerti",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
