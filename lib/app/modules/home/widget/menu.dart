import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';
import 'package:siawi_app/app/modules/absensi/views/absensi_view.dart';
import 'package:siawi_app/app/modules/dokumen_gabungan/views/dokumen_gabungan_view.dart';
import 'package:siawi_app/app/modules/informasi/views/informasi_view.dart';
import 'package:siawi_app/app/modules/jadwal/views/jadwal_view.dart';
import 'package:siawi_app/app/modules/kalender/views/kalender_view.dart';
import 'package:siawi_app/app/modules/modul/views/modul_mapel_view.dart';
import 'package:siawi_app/app/modules/point_siswa/views/point_siswa_view.dart';
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
  final VoidCallback? onTap;

  const _MenuItemData({
    required this.title,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    this.destination,
    this.onTap,
  });
}

class _MenuState extends State<Menu> {
  String role = "siswa";

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        role = preferences.getString('role') ?? 'siswa';
      });
    }
  }

  void _showSuratPklModal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idSiswa = prefs.getString('idSiswa');

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6FAF5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.work_outline_rounded,
                      color: Color(0xFF0F766E),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Layanan Surat PKL",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Pengajuan & Monitoring Surat PKL Siswa",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FutureBuilder<dynamic>(
                future: idSiswa != null
                    ? ApiService.get('/pengajuan-pkl/$idSiswa')
                    : Future.value(null),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0F766E),
                          strokeWidth: 2.5,
                        ),
                      ),
                    );
                  }

                  List<dynamic> items = [];
                  if (snapshot.hasData && snapshot.data != null) {
                    items = snapshot.data['data'] ?? [];
                  }

                  if (items.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.assignment_late_outlined,
                              color: Color(0xFF94A3B8), size: 36),
                          SizedBox(height: 8),
                          Text(
                            "Belum Ada Pengajuan Surat PKL",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Color(0xFF334155),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Pengajuan surat permohonan PKL dapat dikoordinasikan langsung ke pihak BKK & Hubin Sekolah.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: items.take(3).map((item) {
                      String status =
                          (item['status'] ?? 'pending').toString().toLowerCase();
                      Color statusColor;
                      String statusText;

                      if (status == 'acc' || status == 'disetujui') {
                        statusColor = const Color(0xFF10B981);
                        statusText = 'Disetujui (ACC)';
                      } else if (status == 'ditolak') {
                        statusColor = const Color(0xFFEF4444);
                        statusText = 'Ditolak';
                      } else {
                        statusColor = const Color(0xFFF59E0B);
                        statusText = 'Menunggu Proses';
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['nama_perusahaan'] ??
                                        item['perusahaan']?['nama_perusahaan'] ??
                                        'Instansi / Perusahaan',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "No: ${item['kode_pengajuan'] ?? '-'}",
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Tutup",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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
        onTap: _showSuratPklModal,
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
    return GestureDetector(
      onTap: () {
        if (item.destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => item.destination!),
          );
        } else if (item.onTap != null) {
          item.onTap!();
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
            // Squircle container warna pastel dengan icon berwarna
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(
                item.icon,
                color: item.iconColor,
                size: 24,
              ),
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
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
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
}
