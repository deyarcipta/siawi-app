import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siawi_app/app/data/api_service.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:intl/intl.dart';

class UbahDataDiriScreen extends StatefulWidget {
  final VoidCallback signOut;
  const UbahDataDiriScreen(this.signOut, {super.key});

  @override
  State<UbahDataDiriScreen> createState() => _UbahDataDiriScreenState();
}

class _UbahDataDiriScreenState extends State<UbahDataDiriScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers Siswa
  final TextEditingController _nisController = TextEditingController();
  final TextEditingController _nisnController = TextEditingController();
  final TextEditingController _namaSiswaController = TextEditingController();
  final TextEditingController _tmptLahirController = TextEditingController();
  final TextEditingController _tglLahirController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _noTlpnController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _rtController = TextEditingController();
  final TextEditingController _rwController = TextEditingController();
  final TextEditingController _noRumahController = TextEditingController();
  final TextEditingController _kelController = TextEditingController();
  final TextEditingController _kecController = TextEditingController();
  final TextEditingController _kotaController = TextEditingController();
  final TextEditingController _provController = TextEditingController();

  // Controllers Ayah
  final TextEditingController _nikAyahController = TextEditingController();
  final TextEditingController _namaAyahController = TextEditingController();
  final TextEditingController _noHpAyahController = TextEditingController();
  final TextEditingController _tmptLahirAyahController = TextEditingController();
  final TextEditingController _tglLahirAyahController = TextEditingController();

  // Controllers Ibu
  final TextEditingController _nikIbuController = TextEditingController();
  final TextEditingController _namaIbuController = TextEditingController();
  final TextEditingController _noHpIbuController = TextEditingController();
  final TextEditingController _tmptLahirIbuController = TextEditingController();
  final TextEditingController _tglLahirIbuController = TextEditingController();

  // Controllers Wali
  final TextEditingController _nikWaliController = TextEditingController();
  final TextEditingController _namaWaliController = TextEditingController();
  final TextEditingController _noHpWaliController = TextEditingController();
  final TextEditingController _tmptLahirWaliController = TextEditingController();
  final TextEditingController _tglLahirWaliController = TextEditingController();

  // Dropdown States
  String? agama = 'islam';
  String? jenisKelamin = 'L';
  String? namaKelas;
  String? namaJurusan;
  String? pendidikanAyah = '-';
  String? pekerjaanAyah = '-';
  String? penghasilanAyah = '-';
  String? pendidikanIbu = '-';
  String? pekerjaanIbu = '-';
  String? penghasilanIbu = '-';
  String? pendidikanWali = '-';
  String? pekerjaanWali = '-';
  String? penghasilanWali = '-';

  bool _loading = true; // Dimulai true agar form tidak dirender sebelum data terisi
  bool _saving = false;
  String _idSiswa = "";

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _nisController.dispose();
    _nisnController.dispose();
    _namaSiswaController.dispose();
    _tmptLahirController.dispose();
    _tglLahirController.dispose();
    _noHpController.dispose();
    _noTlpnController.dispose();
    _emailController.dispose();
    _alamatController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    _noRumahController.dispose();
    _kelController.dispose();
    _kecController.dispose();
    _kotaController.dispose();
    _provController.dispose();

    _nikAyahController.dispose();
    _namaAyahController.dispose();
    _noHpAyahController.dispose();
    _tmptLahirAyahController.dispose();
    _tglLahirAyahController.dispose();

    _nikIbuController.dispose();
    _namaIbuController.dispose();
    _noHpIbuController.dispose();
    _tmptLahirIbuController.dispose();
    _tglLahirIbuController.dispose();

    _nikWaliController.dispose();
    _namaWaliController.dispose();
    _noHpWaliController.dispose();
    _tmptLahirWaliController.dispose();
    _tglLahirWaliController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
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
    try {
      final datasiswa = await ApiService.get('/home/$studentId');
      if (datasiswa != null && datasiswa['data'] != null) {
        var sData = datasiswa['data'];
        var kData = sData['kelas'];
        var jData = sData['jurusan'];

        if (mounted) {
          setState(() {
            // Isi semua controller dengan data dari database
            _nisController.text = sData['nis']?.toString() ?? '';
            _nisnController.text = sData['nisn']?.toString() ?? '';
            _namaSiswaController.text = sData['nama_siswa']?.toString() ?? '';
            _tmptLahirController.text = sData['tmpt_lahir']?.toString() ?? '';
            _tglLahirController.text = _cleanDate(sData['tgl_lahir']);

            _noHpController.text = sData['no_hp']?.toString() ?? '';
            _noTlpnController.text = sData['no_tlpn']?.toString() ?? '';
            _emailController.text = sData['email']?.toString() ?? '';
            _alamatController.text = sData['alamat']?.toString() ?? '';
            _rtController.text = sData['rt']?.toString() ?? '';
            _rwController.text = sData['rw']?.toString() ?? '';
            _noRumahController.text = sData['no_rumah']?.toString() ?? '';
            _kelController.text = sData['kel']?.toString() ?? '';
            _kecController.text = sData['kec']?.toString() ?? '';
            _kotaController.text = sData['kota']?.toString() ?? '';
            _provController.text = sData['prov']?.toString() ?? '';

            // Ayah
            _nikAyahController.text = sData['nik_ayah']?.toString() ?? '';
            _namaAyahController.text = sData['nama_ayah']?.toString() ?? '';
            _noHpAyahController.text = sData['no_hp_ayah']?.toString() ?? '';
            _tmptLahirAyahController.text = sData['tmpt_lahir_ayah']?.toString() ?? '';
            _tglLahirAyahController.text = _cleanDate(sData['tgl_lahir_ayah']);

            // Ibu
            _nikIbuController.text = sData['nik_ibu']?.toString() ?? '';
            _namaIbuController.text = sData['nama_ibu']?.toString() ?? '';
            _noHpIbuController.text = sData['no_hp_ibu']?.toString() ?? '';
            _tmptLahirIbuController.text = sData['tmpt_lahir_ibu']?.toString() ?? '';
            _tglLahirIbuController.text = _cleanDate(sData['tgl_lahir_ibu']);

            // Wali
            _nikWaliController.text = sData['nik_wali']?.toString() ?? '';
            _namaWaliController.text = sData['nama_wali']?.toString() ?? '';
            _noHpWaliController.text = sData['no_hp_wali']?.toString() ?? '';
            _tmptLahirWaliController.text = sData['tmpt_lahir_wali']?.toString() ?? '';
            _tglLahirWaliController.text = _cleanDate(sData['tgl_lahir_wali']);

            // Dropdowns
            agama = _normalizeAgama(sData['agama']?.toString());
            String? rawJk = sData['jenis_kelamin']?.toString().toUpperCase();
            jenisKelamin = (rawJk == 'P' || rawJk == 'PEREMPUAN') ? 'P' : 'L';

            namaKelas = kData != null ? kData['nama_kelas']?.toString() : null;
            namaJurusan = jData != null ? jData['nama_jurusan']?.toString() : null;

            pendidikanAyah = _normalizePendidikan(sData['pendidikan_ayah']?.toString());
            pekerjaanAyah = _normalizePekerjaan(sData['pekerjaan_ayah']?.toString());
            penghasilanAyah = _normalizePenghasilan(sData['penghasilan_ayah']?.toString());

            pendidikanIbu = _normalizePendidikan(sData['pendidikan_ibu']?.toString());
            pekerjaanIbu = _normalizePekerjaan(sData['pekerjaan_ibu']?.toString());
            penghasilanIbu = _normalizePenghasilan(sData['penghasilan_ibu']?.toString());

            pendidikanWali = _normalizePendidikan(sData['pendidikan_wali']?.toString());
            pekerjaanWali = _normalizePekerjaan(sData['pekerjaan_wali']?.toString());
            penghasilanWali = _normalizePenghasilan(sData['penghasilan_wali']?.toString());
          });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _cleanDate(dynamic dateVal) {
    if (dateVal == null) return '';
    String str = dateVal.toString().trim();
    if (str == '-' || str == 'null') return '';
    return str;
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime initialDate = DateTime(2007, 1, 1);
    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateFormat('yyyy-MM-dd').parse(controller.text);
      } catch (_) {}
    }

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.mainColor,
              onPrimary: Colors.white,
              onSurface: const Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi isian wajib terlebih dahulu'),
          backgroundColor: Color(0xFFE11D48),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    String valOrDash(String? text) {
      if (text == null) return '-';
      String trimmed = text.trim();
      return trimmed.isEmpty ? '-' : trimmed;
    }

    try {
      final payload = {
        'nis': _nisController.text.trim(),
        'nisn': _nisnController.text.trim(),
        'nama_siswa': _namaSiswaController.text.trim(),
        'tmpt_lahir': valOrDash(_tmptLahirController.text),
        'tgl_lahir': valOrDash(_tglLahirController.text),
        'agama': valOrDash(agama ?? 'islam'),
        'jenis_kelamin': valOrDash(jenisKelamin ?? 'L'),
        'no_hp': valOrDash(_noHpController.text),
        'no_tlpn': valOrDash(_noTlpnController.text),
        'email': valOrDash(_emailController.text),
        'alamat': valOrDash(_alamatController.text),
        'rt': valOrDash(_rtController.text),
        'rw': valOrDash(_rwController.text),
        'no_rumah': valOrDash(_noRumahController.text),
        'kel': valOrDash(_kelController.text),
        'kec': valOrDash(_kecController.text),
        'kota': valOrDash(_kotaController.text),
        'prov': valOrDash(_provController.text),

        // Data Ayah
        'nik_ayah': valOrDash(_nikAyahController.text),
        'nama_ayah': valOrDash(_namaAyahController.text),
        'tmpt_lahir_ayah': valOrDash(_tmptLahirAyahController.text),
        'tgl_lahir_ayah': valOrDash(_tglLahirAyahController.text),
        'pendidikan_ayah': valOrDash(pendidikanAyah),
        'pekerjaan_ayah': valOrDash(pekerjaanAyah),
        'penghasilan_ayah': valOrDash(penghasilanAyah),
        'no_hp_ayah': valOrDash(_noHpAyahController.text),

        // Data Ibu
        'nik_ibu': valOrDash(_nikIbuController.text),
        'nama_ibu': valOrDash(_namaIbuController.text),
        'tmpt_lahir_ibu': valOrDash(_tmptLahirIbuController.text),
        'tgl_lahir_ibu': valOrDash(_tglLahirIbuController.text),
        'pendidikan_ibu': valOrDash(pendidikanIbu),
        'pekerjaan_ibu': valOrDash(pekerjaanIbu),
        'penghasilan_ibu': valOrDash(penghasilanIbu),
        'no_hp_ibu': valOrDash(_noHpIbuController.text),

        // Data Wali
        'nik_wali': valOrDash(_nikWaliController.text),
        'nama_wali': valOrDash(_namaWaliController.text),
        'tmpt_lahir_wali': valOrDash(_tmptLahirWaliController.text),
        'tgl_lahir_wali': valOrDash(_tglLahirWaliController.text),
        'pendidikan_wali': valOrDash(pendidikanWali),
        'pekerjaan_wali': valOrDash(pekerjaanWali),
        'penghasilan_wali': valOrDash(penghasilanWali),
        'no_hp_wali': valOrDash(_noHpWaliController.text),
      };

      final response = await ApiService.post('/updateSiswa/$_idSiswa', payload);

      if (mounted) {
        if (response != null && response['success'] != false) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data profil dan nomor HP berhasil disimpan!'),
              backgroundColor: Color(0xFF059669),
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          String errMsg = response != null && response['message'] != null
              ? response['message'].toString()
              : 'Gagal mengubah data siswa';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errMsg),
              backgroundColor: const Color(0xFFE11D48),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String displayError = e.toString().replaceFirst('HttpException: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $displayError'),
            backgroundColor: const Color(0xFFE11D48),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Ubah Data Diri',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _submitData,
            icon: _saving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded, color: Colors.white, size: 20),
            label: const Text(
              "Simpan",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "Memuat data diri siswa...",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  children: [
                    // KARTU 1: IDENTITAS SISWA
                    _buildCardGroup(
                      title: "Data Diri Siswa",
                      icon: Icons.person_rounded,
                      iconColor: const Color(0xFF4F46E5),
                      children: [
                        // FORM NAMA LENGKAP SISWA
                        _buildTextField(
                          label: "Nama Lengkap Siswa *",
                          controller: _namaSiswaController,
                          icon: Icons.badge_outlined,
                          validator: (val) => (val == null || val.trim().isEmpty)
                              ? "Nama siswa wajib diisi"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        // FORM NIS (READONLY, TIDAK DAPAT DIUBAH) & NISN
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: "NIS (Terkunci)",
                                controller: _nisController,
                                readOnly: true,
                                icon: Icons.lock_outline_rounded,
                                helperText: "Tidak dapat diubah",
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                label: "NISN (Terkunci)",
                                controller: _nisnController,
                                readOnly: true,
                                icon: Icons.lock_outline_rounded,
                                helperText: "Tidak dapat diubah",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildTextField(
                                label: "Tempat Lahir *",
                                controller: _tmptLahirController,
                                icon: Icons.location_city_rounded,
                                validator: (val) =>
                                    (val == null || val.trim().isEmpty)
                                        ? "Wajib diisi"
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 4,
                              child: _buildDatePickerField(
                                label: "Tanggal Lahir *",
                                controller: _tglLahirController,
                                onTap: () => _selectDate(_tglLahirController),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownField<String>(
                                label: "Jenis Kelamin",
                                value: jenisKelamin == 'P' ? 'P' : 'L',
                                icon: Icons.wc_rounded,
                                items: const [
                                  DropdownMenuItem(value: 'L', child: Text('Laki - Laki')),
                                  DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                                ],
                                onChanged: (val) => setState(() => jenisKelamin = val),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildDropdownField<String>(
                                label: "Agama",
                                value: _normalizeAgama(agama),
                                icon: Icons.auto_awesome_rounded,
                                items: const [
                                  DropdownMenuItem(value: 'islam', child: Text('Islam')),
                                  DropdownMenuItem(value: 'kristen', child: Text('Kristen')),
                                  DropdownMenuItem(value: 'katolik', child: Text('Katolik')),
                                  DropdownMenuItem(value: 'hindu', child: Text('Hindu')),
                                  DropdownMenuItem(value: 'budha', child: Text('Budha')),
                                  DropdownMenuItem(value: 'konghucu', child: Text('Konghucu')),
                                ],
                                onChanged: (val) => setState(() => agama = val),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // KARTU 2: KONTAK & TEMPAT TINGGAL
                    _buildCardGroup(
                      title: "Kontak & Tempat Tinggal Siswa",
                      icon: Icons.contact_phone_rounded,
                      iconColor: const Color(0xFF0D9488),
                      children: [
                        _buildTextField(
                          label: "Nomor WhatsApp / HP Siswa *",
                          controller: _noHpController,
                          icon: Icons.phone_android_rounded,
                          keyboardType: TextInputType.phone,
                          validator: (val) => (val == null || val.trim().isEmpty)
                              ? "Nomor HP siswa wajib diisi"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: "No. Telp Rumah",
                                controller: _noTlpnController,
                                icon: Icons.call_rounded,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                label: "Email Siswa",
                                controller: _emailController,
                                icon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: "Alamat Lengkap *",
                          controller: _alamatController,
                          icon: Icons.home_rounded,
                          maxLines: 2,
                          validator: (val) => (val == null || val.trim().isEmpty)
                              ? "Alamat tinggal wajib diisi"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: "RT",
                                controller: _rtController,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildTextField(
                                label: "RW",
                                controller: _rwController,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: _buildTextField(
                                label: "No. Rumah",
                                controller: _noRumahController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: "Kelurahan",
                                controller: _kelController,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                label: "Kecamatan",
                                controller: _kecController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: "Kota / Kab",
                                controller: _kotaController,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                label: "Provinsi",
                                controller: _provController,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // KARTU 3: DATA AYAH KANDUNG
                    _buildCardGroup(
                      title: "Data Ayah Kandung",
                      icon: Icons.face_rounded,
                      iconColor: const Color(0xFF0284C7),
                      children: [
                        _buildTextField(
                          label: "Nama Lengkap Ayah",
                          controller: _namaAyahController,
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 12),
                        // FORM NOMOR HP AYAH
                        _buildTextField(
                          label: "Nomor WhatsApp / HP Ayah",
                          controller: _noHpAyahController,
                          icon: Icons.phone_android_rounded,
                          keyboardType: TextInputType.phone,
                          hintText: "Contoh: 08123456789",
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: "NIK Ayah",
                          controller: _nikAyahController,
                          icon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: "Tempat Lahir Ayah",
                                controller: _tmptLahirAyahController,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildDatePickerField(
                                label: "Tgl Lahir Ayah",
                                controller: _tglLahirAyahController,
                                onTap: () => _selectDate(_tglLahirAyahController),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownField<String>(
                          label: "Pendidikan Terakhir Ayah",
                          value: _normalizePendidikan(pendidikanAyah),
                          items: _pendidikanItems,
                          onChanged: (val) => setState(() => pendidikanAyah = val),
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownField<String>(
                          label: "Pekerjaan Ayah",
                          value: _normalizePekerjaan(pekerjaanAyah),
                          items: _pekerjaanItems,
                          onChanged: (val) => setState(() => pekerjaanAyah = val),
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownField<String>(
                          label: "Penghasilan Ayah",
                          value: _normalizePenghasilan(penghasilanAyah),
                          items: _penghasilanItems,
                          onChanged: (val) => setState(() => penghasilanAyah = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // KARTU 4: DATA IBU KANDUNG
                    _buildCardGroup(
                      title: "Data Ibu Kandung",
                      icon: Icons.face_3_rounded,
                      iconColor: const Color(0xFFE11D48),
                      children: [
                        _buildTextField(
                          label: "Nama Lengkap Ibu",
                          controller: _namaIbuController,
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 12),
                        // FORM NOMOR HP IBU
                        _buildTextField(
                          label: "Nomor WhatsApp / HP Ibu",
                          controller: _noHpIbuController,
                          icon: Icons.phone_android_rounded,
                          keyboardType: TextInputType.phone,
                          hintText: "Contoh: 08123456789",
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: "NIK Ibu",
                          controller: _nikIbuController,
                          icon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: "Tempat Lahir Ibu",
                                controller: _tmptLahirIbuController,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildDatePickerField(
                                label: "Tgl Lahir Ibu",
                                controller: _tglLahirIbuController,
                                onTap: () => _selectDate(_tglLahirIbuController),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownField<String>(
                          label: "Pendidikan Terakhir Ibu",
                          value: _normalizePendidikan(pendidikanIbu),
                          items: _pendidikanItems,
                          onChanged: (val) => setState(() => pendidikanIbu = val),
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownField<String>(
                          label: "Pekerjaan Ibu",
                          value: _normalizePekerjaan(pekerjaanIbu),
                          items: _pekerjaanItems,
                          onChanged: (val) => setState(() => pekerjaanIbu = val),
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownField<String>(
                          label: "Penghasilan Ibu",
                          value: _normalizePenghasilan(penghasilanIbu),
                          items: _penghasilanItems,
                          onChanged: (val) => setState(() => penghasilanIbu = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // KARTU 5: DATA WALI (OPSIONAL)
                    _buildCardGroup(
                      title: "Data Wali Murid (Opsional)",
                      subtitle: "Hanya diisi jika siswa diasuh oleh pihak wali",
                      icon: Icons.supervisor_account_rounded,
                      iconColor: const Color(0xFF7C3AED),
                      children: [
                        _buildTextField(
                          label: "Nama Lengkap Wali",
                          controller: _namaWaliController,
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 12),
                        // FORM NOMOR HP WALI
                        _buildTextField(
                          label: "Nomor WhatsApp / HP Wali",
                          controller: _noHpWaliController,
                          icon: Icons.phone_android_rounded,
                          keyboardType: TextInputType.phone,
                          hintText: "Contoh: 08123456789",
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: "NIK Wali",
                          controller: _nikWaliController,
                          icon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: "Tempat Lahir Wali",
                                controller: _tmptLahirWaliController,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildDatePickerField(
                                label: "Tgl Lahir Wali",
                                controller: _tglLahirWaliController,
                                onTap: () => _selectDate(_tglLahirWaliController),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownField<String>(
                          label: "Pendidikan Terakhir Wali",
                          value: _normalizePendidikan(pendidikanWali),
                          items: _pendidikanItems,
                          onChanged: (val) => setState(() => pendidikanWali = val),
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownField<String>(
                          label: "Pekerjaan Wali",
                          value: _normalizePekerjaan(pekerjaanWali),
                          items: _pekerjaanItems,
                          onChanged: (val) => setState(() => pekerjaanWali = val),
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownField<String>(
                          label: "Penghasilan Wali",
                          value: _normalizePenghasilan(penghasilanWali),
                          items: _penghasilanItems,
                          onChanged: (val) => setState(() => penghasilanWali = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // TOMBOL SIMPAN BESAR DI BAWAH
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _submitData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainColor,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _saving
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Menyimpan Perubahan...",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save_rounded, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    "Simpan Seluruh Data",
                                    style: TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w800,
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
    );
  }

  // WIDGET HELPERS
  Widget _buildCardGroup({
    required String title,
    String? subtitle,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFECEFF5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hintText,
    String? helperText,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: readOnly ? const Color(0xFF64748B) : const Color(0xFF1E293B),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        helperText: helperText,
        helperStyle: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
        labelStyle: const TextStyle(
          fontSize: 12.5,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          fontSize: 12.5,
          color: Color(0xFFCBD5E1),
        ),
        prefixIcon: icon != null
            ? Icon(icon, size: 18, color: readOnly ? const Color(0xFF94A3B8) : const Color(0xFF64748B))
            : null,
        filled: readOnly,
        fillColor: readOnly ? const Color(0xFFF1F5F9) : Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: readOnly ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: readOnly ? const Color(0xFFCBD5E1) : AppColors.mainColor,
            width: readOnly ? 1 : 1.5,
          ),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 12.5,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(Icons.calendar_today_rounded, size: 17, color: Color(0xFF64748B)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.mainColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    IconData? icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 12.5,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: icon != null
            ? Icon(icon, size: 18, color: const Color(0xFF64748B))
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.mainColor, width: 1.5),
        ),
      ),
    );
  }

  // NORMALIZERS FOR DROPDOWNS
  String _normalizeAgama(String? a) {
    if (a == null) return 'islam';
    String norm = a.trim().toLowerCase();
    const valid = ['islam', 'kristen', 'katolik', 'hindu', 'budha', 'konghucu'];
    return valid.contains(norm) ? norm : 'islam';
  }

  String _normalizePendidikan(String? p) {
    if (p == null || p.trim().isEmpty || p == '-' || p == 'null') return '-';
    String norm = p.trim().toLowerCase();
    const valid = ['-', 'sd', 'smp', 'sma', 's1', 's2', 's3'];
    return valid.contains(norm) ? norm : '-';
  }

  String _normalizePekerjaan(String? p) {
    if (p == null || p.trim().isEmpty || p == '-' || p == 'null') return '-';
    String norm = p.trim().toLowerCase();
    const valid = [
      '-',
      'karyawan',
      'pns',
      'tni/polisi',
      'wiraswasta',
      'guru',
      'ibu rumah tangga',
      'lainnya'
    ];
    return valid.contains(norm) ? norm : 'lainnya';
  }

  String _normalizePenghasilan(String? p) {
    if (p == null || p.trim().isEmpty || p == '-' || p == 'null') return '-';
    const valid = [
      '-',
      'Rp.500.000 - Rp 2.000.000',
      'Rp.2.100.000 - Rp 3.000.000',
      'Rp.3.100.000 - Rp 4.000.000',
      'Rp.4.100.000 - Rp 5.000.000',
      '>Rp 5.000.000'
    ];
    return valid.contains(p) ? p : '-';
  }

  final List<DropdownMenuItem<String>> _pendidikanItems = const [
    DropdownMenuItem(value: '-', child: Text('-')),
    DropdownMenuItem(value: 'sd', child: Text('SD')),
    DropdownMenuItem(value: 'smp', child: Text('SMP')),
    DropdownMenuItem(value: 'sma', child: Text('SMA/SMK')),
    DropdownMenuItem(value: 's1', child: Text('S1')),
    DropdownMenuItem(value: 's2', child: Text('S2')),
    DropdownMenuItem(value: 's3', child: Text('S3')),
  ];

  final List<DropdownMenuItem<String>> _pekerjaanItems = const [
    DropdownMenuItem(value: '-', child: Text('-')),
    DropdownMenuItem(value: 'karyawan', child: Text('Karyawan Swasta')),
    DropdownMenuItem(value: 'pns', child: Text('PNS / ASN')),
    DropdownMenuItem(value: 'tni/polisi', child: Text('TNI / POLRI')),
    DropdownMenuItem(value: 'wiraswasta', child: Text('Wiraswasta / Pengusaha')),
    DropdownMenuItem(value: 'guru', child: Text('Guru / Dosen')),
    DropdownMenuItem(value: 'ibu rumah tangga', child: Text('Ibu Rumah Tangga')),
    DropdownMenuItem(value: 'lainnya', child: Text('Lainnya')),
  ];

  final List<DropdownMenuItem<String>> _penghasilanItems = const [
    DropdownMenuItem(value: '-', child: Text('-')),
    DropdownMenuItem(
        value: 'Rp.500.000 - Rp 2.000.000', child: Text('Rp.500.000 - Rp 2.000.000')),
    DropdownMenuItem(
        value: 'Rp.2.100.000 - Rp 3.000.000', child: Text('Rp.2.100.000 - Rp 3.000.000')),
    DropdownMenuItem(
        value: 'Rp.3.100.000 - Rp 4.000.000', child: Text('Rp.3.100.000 - Rp 4.000.000')),
    DropdownMenuItem(
        value: 'Rp.4.100.000 - Rp 5.000.000', child: Text('Rp.4.100.000 - Rp 5.000.000')),
    DropdownMenuItem(value: '>Rp 5.000.000', child: Text('>Rp 5.000.000')),
  ];
}
