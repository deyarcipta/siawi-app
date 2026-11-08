import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/pkl_service.dart';
import 'package:siawi_app/utils/colors.dart';

class PresensiPklView extends StatefulWidget {
  final VoidCallback? onSwitchToPengajuan;

  const PresensiPklView({super.key, this.onSwitchToPengajuan});

  @override
  State<PresensiPklView> createState() => _PresensiPklViewState();
}

class _PresensiPklViewState extends State<PresensiPklView> {
  String? idSiswa;
  bool isLoading = true;
  bool isSubmitting = false;

  Map<String, dynamic>? pklTargetData;
  Position? currentPosition;
  int? currentDistance;
  bool isInsideGeofence = false;

  // Foto Selfie
  File? capturedImage;
  String? fotoBase64;
  final ImagePicker _picker = ImagePicker();

  // Riwayat Presensi Bulanan
  List<dynamic> riwayatList = [];
  Map<String, dynamic> ringkasanRiwayat = {'hadir': 0, 'izin': 0, 'sakit': 0};

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    idSiswa = prefs.getString('idSiswa');

    if (idSiswa != null && idSiswa!.isNotEmpty) {
      await _loadTargetAndLocation();
      _loadRiwayat();
    } else {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _loadTargetAndLocation() async {
    if (idSiswa == null) return;
    setState(() => isLoading = true);

    try {
      // 1. Ambil target geofencing dari server
      final data = await PklService.getStatusPresensi(idSiswa!);
      pklTargetData = data;

      // 2. Ambil lokasi GPS HP saat ini
      try {
        final pos = await PklService.getCurrentPosition();
        currentPosition = pos;

        if (pos != null && pklTargetData != null) {
          final per = pklTargetData!['perusahaan'];
          if (per != null && per['latitude'] != null && per['longitude'] != null) {
            double officeLat = double.parse(per['latitude'].toString());
            double officeLon = double.parse(per['longitude'].toString());
            int radiusMax = int.tryParse(per['radius_meter']?.toString() ?? '50') ?? 50;

            int dist = PklService.calculateDistance(pos.latitude, pos.longitude, officeLat, officeLon);
            currentDistance = dist;
            isInsideGeofence = dist <= radiusMax;
          }
        }
      } catch (gpsError) {
        Fluttertoast.showToast(msg: gpsError.toString(), backgroundColor: Colors.orange);
      }
    } catch (e) {
      debugPrint('Error loading PKL target: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _loadRiwayat() async {
    if (idSiswa == null) return;
    try {
      final res = await PklService.getRiwayatPresensi(idSiswa: idSiswa!);
      if (res != null && mounted) {
        setState(() {
          riwayatList = res['riwayat'] ?? [];
          if (res['ringkasan'] != null) {
            ringkasanRiwayat = Map<String, dynamic>.from(res['ringkasan']);
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _takeSelfie() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 720,
        maxHeight: 960,
        imageQuality: 75,
      );

      if (photo != null) {
        final bytes = await File(photo.path).readAsBytes();
        setState(() {
          capturedImage = File(photo.path);
          fotoBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal mengambil foto: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> _submitAttendance(String tipe) async {
    if (idSiswa == null) return;

    if (currentPosition == null) {
      Fluttertoast.showToast(msg: 'Mencari sinyal GPS Anda... Mohon tunggu sebentar.');
      await _loadTargetAndLocation();
      if (currentPosition == null) {
        Fluttertoast.showToast(msg: 'Gagal mendapatkan titik GPS. Pastikan GPS aktif.', backgroundColor: Colors.red);
        return;
      }
    }

    // Cek radius
    final per = pklTargetData?['perusahaan'];
    int radiusMax = int.tryParse(per?['radius_meter']?.toString() ?? '50') ?? 50;
    if (currentDistance != null && currentDistance! > radiusMax) {
      Fluttertoast.showToast(
        msg: 'Presensi ditolak. Anda berada di luar radius kantor ($currentDistance meter, batas $radiusMax meter).',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }

    // Cek foto jika mode mewajibkan foto
    final aturan = pklTargetData?['aturan_presensi'];
    bool wajibFoto = false;
    if (tipe == 'masuk') {
      wajibFoto = aturan?['wajib_foto_masuk'] == true;
    } else {
      wajibFoto = aturan?['wajib_foto_pulang'] == true;
    }

    if (wajibFoto && (fotoBase64 == null || fotoBase64!.isEmpty)) {
      Fluttertoast.showToast(msg: 'Silakan ambil foto selfie $tipe terlebih dahulu.', backgroundColor: Colors.orange);
      await _takeSelfie();
      if (fotoBase64 == null || fotoBase64!.isEmpty) return;
    }

    setState(() => isSubmitting = true);

    try {
      final res = await PklService.submitPresensi(
        idSiswa: idSiswa!,
        latitude: currentPosition!.latitude,
        longitude: currentPosition!.longitude,
        tipe: tipe,
        fotoBase64: fotoBase64,
      );

      if (res['success'] == true) {
        Fluttertoast.showToast(msg: res['message'] ?? 'Presensi $tipe berhasil!', backgroundColor: Colors.green);
        setState(() {
          capturedImage = null;
          fotoBase64 = null;
        });
        await _loadTargetAndLocation();
        await _loadRiwayat();
      } else {
        Fluttertoast.showToast(msg: res['message'] ?? 'Gagal memproses presensi.', backgroundColor: Colors.red);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString().replaceAll('Exception: ', ''), backgroundColor: Colors.red);
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  void _showDialogIzin() {
    String jenis = 'sakit';
    final TextEditingController ketController = TextEditingController();
    File? suratFile;
    String? suratBase64;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    const Text('Pengajuan Izin / Sakit PKL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Sakit')),
                        selected: jenis == 'sakit',
                        selectedColor: Colors.amber.shade100,
                        onSelected: (val) => setModalState(() => jenis = 'sakit'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Izin Khusus')),
                        selected: jenis == 'izin',
                        selectedColor: Colors.blue.shade100,
                        onSelected: (val) => setModalState(() => jenis = 'izin'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ketController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Alasan / Keterangan',
                    hintText: 'Tuliskan alasan izin atau gejala sakit...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                    if (photo != null) {
                      final b = await File(photo.path).readAsBytes();
                      setModalState(() {
                        suratFile = File(photo.path);
                        suratBase64 = 'data:image/jpeg;base64,${base64Encode(b)}';
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: Row(
                      children: [
                        Icon(suratFile != null ? Icons.check_circle : Icons.camera_alt, color: suratFile != null ? Colors.green : Colors.grey),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            suratFile != null ? 'Foto Surat / Bukti Terlampir' : 'Ambil Foto Surat Dokter / Keterangan',
                            style: TextStyle(fontSize: 12, color: suratFile != null ? Colors.green.shade800 : Colors.grey.shade700, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (ketController.text.trim().isEmpty) {
                        Fluttertoast.showToast(msg: 'Mohon isi alasan keterangan izin/sakit.');
                        return;
                      }
                      Navigator.pop(ctx);
                      setState(() => isSubmitting = true);
                      try {
                        final res = await PklService.submitIzin(
                          idSiswa: idSiswa!,
                          status: jenis,
                          keterangan: ketController.text.trim(),
                          fotoBuktiBase64: suratBase64,
                        );
                        Fluttertoast.showToast(msg: res['message'] ?? 'Pengajuan berhasil dikirim.', backgroundColor: Colors.green);
                        await _loadTargetAndLocation();
                        await _loadRiwayat();
                      } catch (e) {
                        Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red);
                      } finally {
                        if (mounted) setState(() => isSubmitting = false);
                      }
                    },
                    child: const Text('Kirim Pengajuan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pklTargetData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.business_center_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'Belum Ada Penempatan PKL Aktif',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Anda belum memiliki penempatan mitra PKL aktif. Silakan ajukan surat permohonan PKL terlebih dahulu.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (widget.onSwitchToPengajuan != null)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: widget.onSwitchToPengajuan,
                  icon: const Icon(Icons.description, color: Colors.white),
                  label: const Text('Buka Pengajuan Surat PKL', style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
        ),
      );
    }

    final per = pklTargetData?['perusahaan'];
    final presToday = pklTargetData?['presensi_hari_ini'];
    final aturan = pklTargetData?['aturan_presensi'];
    final aksi = pklTargetData?['aksi'];

    bool sudahMasuk = presToday?['sudah_masuk'] == true;
    bool sudahPulang = presToday?['sudah_pulang'] == true;
    String statusHariIni = presToday?['status'] ?? '-';
    bool isIzinSakit = ['izin', 'sakit'].contains(statusHariIni);

    int radiusMax = int.tryParse(per?['radius_meter']?.toString() ?? '50') ?? 50;
    bool wajibFotoMasuk = aturan?['wajib_foto_masuk'] == true;
    bool wajibFotoPulang = aturan?['wajib_foto_pulang'] == true;
    bool modeMemerlukanFoto = (!sudahMasuk && wajibFotoMasuk) || (sudahMasuk && !sudahPulang && wajibFotoPulang);

    return RefreshIndicator(
      onRefresh: () async {
        await _loadTargetAndLocation();
        await _loadRiwayat();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Banner Perusahaan & Mitra
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.mainColor, AppColors.sixColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: AppColors.mainColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: const Row(
                          children: [
                            Icon(Icons.business, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text('Mitra DU/DI', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Colors.emerald.shade400, borderRadius: BorderRadius.circular(20)),
                        child: const Text('Shift Fleksibel', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    per?['nama_perusahaan'] ?? '-',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    per?['alamat_perusahaan'] ?? '-',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.phone_android, size: 14, color: Colors.emerald.shade200),
                          const SizedBox(width: 4),
                          Text(
                            aturan?['is_device_locked'] == true ? 'HP Terkunci: ${aturan?['device_terdaftar'] ?? 'Valid'}' : 'HP Bebas Login',
                            style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Text('Radius: ${radiusMax}m', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Geofencing Radar & Jarak GPS
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.my_location, size: 16, color: Colors.blue),
                          SizedBox(width: 6),
                          Text('Validasi Lokasi Kantor', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isInsideGeofence ? Colors.emerald.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isInsideGeofence ? Colors.emerald.shade200 : Colors.red.shade200),
                        ),
                        child: Text(
                          currentDistance != null
                              ? (isInsideGeofence ? 'Dalam Radius (${currentDistance}m)' : 'Luar Radius (${currentDistance}m)')
                              : 'Mencari Lokasi...',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isInsideGeofence ? Colors.emerald.shade700 : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isInsideGeofence
                        ? 'Posisi Anda berada di area kantor mitra. Anda diizinkan melakukan presensi.'
                        : 'Jarak Anda saat ini: ${currentDistance ?? '?'}m dari kantor. Batas maksimal presensi: ${radiusMax}m. Silakan mendekat ke lokasi kantor.',
                    style: TextStyle(fontSize: 12, color: isInsideGeofence ? Colors.grey.shade700 : Colors.red.shade700),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Status Presensi Hari Ini
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kehadiran Hari Ini (${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now())})',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: sudahMasuk ? Colors.emerald.shade50 : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: sudahMasuk ? Colors.emerald.shade200 : Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.between,
                                children: [
                                  Text('Masuk', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: sudahMasuk ? Colors.emerald.shade800 : Colors.grey.shade600)),
                                  Icon(sudahMasuk ? Icons.check_circle : Icons.circle_outlined, size: 14, color: sudahMasuk ? Colors.emerald : Colors.grey),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sudahMasuk ? '${presToday?['jam_masuk']?.toString().substring(0, 5)} WIB' : 'Belum Masuk',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: sudahMasuk ? Colors.black87 : Colors.grey.shade400),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: sudahPulang ? Colors.emerald.shade50 : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: sudahPulang ? Colors.emerald.shade200 : Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.between,
                                children: [
                                  Text('Pulang', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: sudahPulang ? Colors.emerald.shade800 : Colors.grey.shade600)),
                                  Icon(sudahPulang ? Icons.check_circle : Icons.circle_outlined, size: 14, color: sudahPulang ? Colors.emerald : Colors.grey),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sudahPulang ? '${presToday?['jam_pulang']?.toString().substring(0, 5)} WIB' : 'Belum Pulang',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: sudahPulang ? Colors.black87 : Colors.grey.shade400),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. Modul Kamera Selfie (Hanya jika mode memerlukan foto dan belum selesai)
            if (modeMemerlukanFoto && !sudahPulang && !isIzinSakit) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        const Text('Foto Selfie Presensi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        TextButton.icon(
                          onPressed: _takeSelfie,
                          icon: const Icon(Icons.camera_alt, size: 16),
                          label: Text(capturedImage != null ? 'Foto Ulang' : 'Buka Kamera', style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (capturedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(capturedImage!, height: 180, width: double.infinity, fit: BoxFit.cover),
                      )
                    else
                      InkWell(
                        onTap: _takeSelfie,
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.face, size: 40, color: Colors.grey.shade500),
                              const SizedBox(height: 6),
                              Text('Ketuk untuk ambil foto selfie', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 5. Tombol Aksi Utama
            if (!isIzinSakit) ...[
              if (!sudahMasuk)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    onPressed: isSubmitting ? null : () => _submitAttendance('masuk'),
                    icon: isSubmitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.login, color: Colors.white),
                    label: Text(isSubmitting ? 'Memproses...' : 'Presensi Masuk Sekarang', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                )
              else if (!sudahPulang)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.emerald.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    onPressed: isSubmitting ? null : () => _submitAttendance('pulang'),
                    icon: isSubmitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.logout, color: Colors.white),
                    label: Text(isSubmitting ? 'Memproses...' : 'Presensi Pulang Sekarang', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.emerald.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.emerald.shade200)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.emerald.shade600),
                      const SizedBox(width: 8),
                      Text('Presensi PKL Hari Ini Sudah Lengkap', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.emerald.shade800)),
                    ],
                  ),
                ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.amber.shade200)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info, color: Colors.amber.shade700),
                    const SizedBox(width: 8),
                    Text('Status Hari Ini: ${statusHariIni.toUpperCase()}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Tombol Izin/Sakit (jika belum masuk)
            if (!sudahMasuk && !isIzinSakit)
              Center(
                child: TextButton.icon(
                  onPressed: _showDialogIzin,
                  icon: const Icon(Icons.medical_services_outlined, size: 16, color: Colors.amber),
                  label: const Text('Sedang Sakit / Izin Khusus? Ajukan di sini', style: TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.bold)),
                ),
              ),

            const SizedBox(height: 20),

            // 6. Rekapitulasi Riwayat Bulan Ini
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                const Text('Riwayat Presensi Bulan Ini', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('${riwayatList.length} Hari', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),

            // Summary mini-card
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                    child: Column(
                      children: [
                        const Text('Hadir', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('${ringkasanRiwayat['hadir'] ?? 0}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.emerald)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                    child: Column(
                      children: [
                        const Text('Izin', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('${ringkasanRiwayat['izin'] ?? 0}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                    child: Column(
                      children: [
                        const Text('Sakit', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('${ringkasanRiwayat['sakit'] ?? 0}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (riwayatList.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
                child: Center(
                  child: Text('Belum ada riwayat presensi PKL pada bulan ini.', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: riwayatList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = riwayatList[index];
                  String status = item['status'] ?? 'hadir';
                  String tgl = item['tanggal'] ?? '';

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tgl, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(
                              status == 'hadir'
                                  ? 'Masuk: ${item['jam_masuk']?.toString().substring(0, 5) ?? '-'} | Pulang: ${item['jam_pulang']?.toString().substring(0, 5) ?? '-'}'
                                  : 'Keterangan: ${item['keterangan'] ?? status}',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: status == 'hadir' ? Colors.emerald.shade50 : Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: status == 'hadir' ? Colors.emerald.shade200 : Colors.amber.shade200),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: status == 'hadir' ? Colors.emerald.shade700 : Colors.amber.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

