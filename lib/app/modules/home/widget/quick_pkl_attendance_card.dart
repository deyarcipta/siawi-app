import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';
import 'package:siawi_app/app/modules/pengajuan_pkl/views/pkl_main_view.dart';
import 'package:siawi_app/utils/colors.dart';

class QuickPklAttendanceCard extends StatefulWidget {
  final VoidCallback signOut;

  const QuickPklAttendanceCard(this.signOut, {super.key});

  @override
  State<QuickPklAttendanceCard> createState() => _QuickPklAttendanceCardState();
}

class _QuickPklAttendanceCardState extends State<QuickPklAttendanceCard> {
  bool isPklActive = false;
  String namaPerusahaan = '-';
  String actionType = 'masuk'; // 'masuk' | 'pulang' | 'selesai'
  String actionLabel = 'Presensi Masuk';
  String? jamMasuk;
  String? jamPulang;

  @override
  void initState() {
    super.initState();
    _loadPklData();
  }

  Future<void> _loadPklData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? idSiswa = prefs.getString('idSiswa');
      if (idSiswa == null) return;

      // Cek cache dulu
      String? cacheRaw = prefs.getString('cached_student_header_$idSiswa');
      if (cacheRaw != null && cacheRaw.isNotEmpty) {
        try {
          var cMap = jsonDecode(cacheRaw);
          if (cMap['hasPkl'] == true && cMap['pklNamaPerusahaan'] != null) {
            setState(() {
              isPklActive = true;
              namaPerusahaan = cMap['pklNamaPerusahaan'];
            });
          }
        } catch (_) {}
      }

      // Ambil data fresh dari API /home/$idSiswa
      final res = await ApiService.get('/home/$idSiswa', silent: true);
      if (res != null && mounted) {
        final pData = res['siswaPkl'];
        final quickAction = res['quickPklAction'];

        if (pData != null && pData['perusahaan'] != null) {
          final per = pData['perusahaan'];
          String pklStatus = pData['status']?.toString().toLowerCase() ?? '';
          bool aktif = !['selesai', 'ditolak', 'batal'].contains(pklStatus);

          setState(() {
            isPklActive = aktif;
            namaPerusahaan = per['nama_perusahaan'] ?? namaPerusahaan;
            if (quickAction != null) {
              actionType = quickAction['action_type'] ?? 'masuk';
              actionLabel = quickAction['action_label'] ?? 'Presensi Masuk';
              jamMasuk = quickAction['jam_masuk'];
              jamPulang = quickAction['jam_pulang'];
            }
          });
        }
      }
    } catch (_) {}
  }

  void _navigateToPklView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PklMainView(widget.signOut, initialTabIndex: 0),
      ),
    ).then((_) => _loadPklData());
  }

  @override
  Widget build(BuildContext context) {
    if (!isPklActive) {
      return const SizedBox.shrink();
    }

    String subText = 'Hari ini belum presensi';
    String timeText = 'Shift Fleksibel';
    Color btnBg = Colors.white;
    Color btnText = AppColors.mainColor;

    if (actionType == 'pulang') {
      subText = 'Masuk: ${jamMasuk?.substring(0, 5) ?? '--:--'} WIB';
      timeText = 'Sedang Bertugas';
      btnBg = Colors.emerald.shade400;
      btnText = Colors.slate.shade900;
    } else if (actionType == 'selesai') {
      subText = 'Masuk: ${jamMasuk?.substring(0, 5) ?? '--:--'} • Pulang: ${jamPulang?.substring(0, 5) ?? '--:--'}';
      timeText = '✓ Selesai';
      btnBg = Colors.white.withOpacity(0.2);
      btnText = Colors.white;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.mainColor,
            AppColors.sixColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.mainColor.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _navigateToPklView,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    const Text(
                      'PRESENSI KERJA INDUSTRI (PKL)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: Color(0xFFDDD4FF),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.business_center, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Aktif', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  namaPerusahaan,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.emerald.shade300),
                    const SizedBox(width: 4),
                    const Text(
                      'Validasi Geofencing Radius Kantor',
                      style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const Divider(color: Colors.white24, height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(subText, style: const TextStyle(fontSize: 10, color: Color(0xFFDDD4FF))),
                        const SizedBox(height: 1),
                        Text(timeText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btnBg,
                        foregroundColor: btnText,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _navigateToPklView,
                      icon: Icon(
                        actionType == 'selesai' ? Icons.check_circle : (actionType == 'pulang' ? Icons.logout : Icons.login),
                        size: 16,
                      ),
                      label: Text(
                        actionLabel,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

