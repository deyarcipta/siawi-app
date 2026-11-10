import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';

class PklService {
  /// Mendapatkan ID unik perangkat (Android ID / iOS Identifier) untuk Lock Device
  static Future<Map<String, String>> getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId = '';
    String deviceName = 'Perangkat Mobile';

    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id; // Unique Android hardware/build ID
        deviceName = '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
        deviceName = '${iosInfo.name} ${iosInfo.model}';
      } else {
        deviceId = 'device_${Platform.operatingSystem}';
        deviceName = Platform.operatingSystem;
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
    }

    // Fallback jika deviceId kosong
    if (deviceId.isEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      deviceId = prefs.getString('fallback_device_uuid') ?? '';
      if (deviceId.isEmpty) {
        deviceId = 'uuid_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';
        await prefs.setString('fallback_device_uuid', deviceId);
      }
    }

    return {
      'device_id': deviceId,
      'device_name': deviceName,
    };
  }

  /// Memeriksa dan meminta izin GPS perangkat
  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const FormatException('Layanan lokasi (GPS) belum aktif di HP Anda. Silakan aktifkan GPS.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const FormatException('Izin akses lokasi GPS ditolak oleh pengguna.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const FormatException('Izin lokasi ditolak permanen. Buka Pengaturan HP untuk mengaktifkan izin lokasi.');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  /// Menghitung jarak Haversine antara 2 koordinat (dalam satuan meter)
  static int calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meter
    double dLat = (lat2 - lat1) * (pi / 180.0);
    double dLon = (lon2 - lon1) * (pi / 180.0);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180.0)) *
            cos(lat2 * (pi / 180.0)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return (earthRadius * c).round();
  }

  /// Mengambil data target geofencing dan status presensi hari ini
  static Future<Map<String, dynamic>?> getStatusPresensi(String idSiswa) async {
    try {
      final res = await ApiService.get(
        '/presensi-pkl/target/$idSiswa',
        forceRefresh: true,
        silent: true,
      );
      if (res != null && res['data'] != null) {
        return Map<String, dynamic>.from(res['data']);
      }
    } catch (e) {
      debugPrint('Info getStatusPresensi (belum ditempatkan / offline): $e');
    }
    return null;
  }

  /// Mengirim presensi masuk atau pulang PKL
  static Future<Map<String, dynamic>> submitPresensi({
    required String idSiswa,
    required double latitude,
    required double longitude,
    required String tipe, // 'masuk' atau 'pulang'
    String? fotoBase64,
    String? keterangan,
  }) async {
    final dev = await getDeviceInfo();

    final Map<String, String> body = {
      'id_siswa': idSiswa,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'tipe': tipe,
      'device_id': dev['device_id'] ?? '',
      'device_name': dev['device_name'] ?? '',
    };

    if (fotoBase64 != null && fotoBase64.isNotEmpty) {
      body['foto'] = fotoBase64;
    }

    if (keterangan != null && keterangan.isNotEmpty) {
      body['keterangan'] = keterangan;
    }

    final res = await ApiService.post('/presensi-pkl', body);
    if (res is Map<String, dynamic>) {
      return res;
    }
    throw const FormatException('Respons tidak valid dari server.');
  }

  /// Mengajukan izin atau sakit selama PKL
  static Future<Map<String, dynamic>> submitIzin({
    required String idSiswa,
    required String status, // 'izin' atau 'sakit'
    required String keterangan,
    String? fotoBuktiBase64,
  }) async {
    final Map<String, String> body = {
      'id_siswa': idSiswa,
      'status': status,
      'keterangan': keterangan,
    };

    if (fotoBuktiBase64 != null && fotoBuktiBase64.isNotEmpty) {
      body['foto'] = fotoBuktiBase64;
    }

    final res = await ApiService.post('/presensi-pkl/izin', body);
    if (res is Map<String, dynamic>) {
      return res;
    }
    throw const FormatException('Respons tidak valid dari server.');
  }

  /// Mengambil riwayat presensi PKL siswa bulanan
  static Future<Map<String, dynamic>?> getRiwayatPresensi({
    required String idSiswa,
    int? bulan,
    int? tahun,
  }) async {
    final int b = bulan ?? DateTime.now().month;
    final int t = tahun ?? DateTime.now().year;

    try {
      final res = await ApiService.get(
        '/presensi-pkl/riwayat/$idSiswa?bulan=$b&tahun=$t',
        forceRefresh: true,
        silent: true,
      );
      if (res != null && res['data'] != null) {
        return Map<String, dynamic>.from(res['data']);
      }
    } catch (e) {
      debugPrint('Info getRiwayatPresensi: $e');
    }
    return null;
  }
}

