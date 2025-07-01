import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:siawi_app/utils/colors.dart';
import 'package:intl/intl.dart';

class UbahDataDiriScreen extends StatefulWidget {
  final VoidCallback signOut;
  const UbahDataDiriScreen(this.signOut, {super.key});

  @override
  State<UbahDataDiriScreen> createState() => _UbahDataDiriScreenState();
}

class _UbahDataDiriScreenState extends State<UbahDataDiriScreen> {
  TextEditingController _tglLahirController = TextEditingController();
  TextEditingController _tglLahirAyahController = TextEditingController();
  TextEditingController _tglLahirIbuController = TextEditingController();
  TextEditingController _tglLahirWaliController = TextEditingController();

  Future<String?> getIdSiswa() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString('idSiswa');
  }

  @override
  void initState() {
    super.initState();
    getIdSiswa().then((idSiswa) {
      if (idSiswa != null) {
        _lihatData(idSiswa);
      }
    });
  }

  bool loading = false;

  String? tmptLahir;
  String? tglLahir;
  String? nis;
  String? nisn;
  String? agama;
  String? namaSiswa;
  String? jenisKelamin;
  String? jenisKelaminFormatted;
  String? namaJurusan;
  String? namaKelas;

  String? noHp;
  String? noTlpn;
  String? email;
  String? alamat;
  String? noRumah;
  String? rt;
  String? rw;
  String? kel;
  String? kec;
  String? kota;
  String? prov;

  String? nikAyah;
  String? namaAyah;
  String? tmptLahirAyah;
  String? tglLahirAyah;
  String? pendidikanAyah;
  String? pekerjaanAyah;
  String? penghasilanAyah;
  String? nikIbu;
  String? namaIbu;
  String? tmptLahirIbu;
  String? tglLahirIbu;
  String? pendidikanIbu;
  String? pekerjaanIbu;
  String? penghasilanIbu;

  String? nikWali;
  String? namaWali;
  String? tmptLahirWali;
  String? tglLahirWali;
  String? pendidikanWali;
  String? pekerjaanWali;
  String? penghasilanWali;

  Future<void> _lihatData(String idSiswa) async {
    setState(() {
      loading = true;
    });
    final response =
        await http.get(Uri.parse('http://103.75.209.90/api/home/$idSiswa'));

    if (response.statusCode == 200) {
      var datasiswa = json.decode(response.body);
      var siswaData = datasiswa['data'];
      var kelasData = siswaData['kelas'];
      var jurusanData = siswaData['jurusan'];

      setState(() {
        tmptLahir = siswaData['tmpt_lahir']?.toString();
        tglLahir = siswaData['tgl_lahir']?.toString();
        namaSiswa = siswaData['nama_siswa']?.toString();
        nis = siswaData['nis']?.toString();
        nisn = siswaData['nisn']?.toString();
        agama = siswaData['agama']?.toString();
        jenisKelamin = siswaData['jenis_kelamin']?.toString();
        jenisKelaminFormatted = jenisKelamin == 'L' ? 'L' : 'P';
        namaKelas = kelasData['nama_kelas']?.toString();
        namaJurusan = jurusanData['kode_jurusan']?.toString();
        noHp = siswaData['no_hp']?.toString();
        noTlpn = siswaData['no_tlpn']?.toString();
        email = siswaData['email']?.toString();
        alamat = siswaData['alamat']?.toString();
        noRumah = siswaData['no_rumah']?.toString();
        kel = siswaData['kel']?.toString();
        kec = siswaData['kec']?.toString();
        kota = siswaData['kota']?.toString();
        rt = siswaData['rt']?.toString();
        rw = siswaData['rw']?.toString();
        prov = siswaData['prov']?.toString();
        nikAyah = siswaData['nik_ayah']?.toString();
        namaAyah = siswaData['nama_ayah']?.toString();
        tmptLahirAyah = siswaData['tmpt_lahir_ayah']?.toString();
        tglLahirAyah = siswaData['tgl_lahir_ayah']?.toString();
        pendidikanAyah = siswaData['pendidikan_ayah']?.toString();
        pekerjaanAyah = siswaData['pekerjaan_ayah']?.toString();
        penghasilanAyah = siswaData['penghasilan_ayah']?.toString();
        nikIbu = siswaData['nik_ibu']?.toString();
        namaIbu = siswaData['nama_ibu']?.toString();
        tmptLahirIbu = siswaData['tmpt_lahir_ibu']?.toString();
        tglLahirIbu = siswaData['tgl_lahir_ibu']?.toString();
        pendidikanIbu = siswaData['pendidikan_ibu']?.toString();
        pekerjaanIbu = siswaData['pekerjaan_ibu']?.toString();
        penghasilanIbu = siswaData['penghasilan_ibu']?.toString();
        nikWali = siswaData['nik_wali']?.toString();
        namaWali = siswaData['nama_wali']?.toString();
        tmptLahirWali = siswaData['tmpt_lahir_wali']?.toString();
        tglLahirWali = siswaData['tgl_lahir_wali']?.toString();
        pendidikanWali = siswaData['pendidikan_wali']?.toString();
        pekerjaanWali = siswaData['pekerjaan_wali']?.toString();
        penghasilanWali = siswaData['penghasilan_wali']?.toString();
        _tglLahirController.text = tglLahir ?? '';
        _tglLahirAyahController.text = tglLahirAyah ?? '';
        _tglLahirIbuController.text = tglLahirIbu ?? '';
        _tglLahirWaliController.text = tglLahirWali ?? '';
      });
    } else {
      print('Failed to load data');
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime initialDate = DateTime.now();
    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateFormat('yyyy-MM-dd').parse(controller.text);
      } catch (e) {
        print("Error parsing date: $e");
      }
    }

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null && selectedDate != initialDate) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      print("Selected Date: $formattedDate"); // Debug print
      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  final _profilFormKey = GlobalKey<FormState>();
  final _dataDiriFormKey = GlobalKey<FormState>();
  final _orangTuaFormKey = GlobalKey<FormState>();
  final _waliFormKey = GlobalKey<FormState>();

  Future<void> _ubahDataDiri(String idSiswa) async {
    print("Tanggal Lahir yang dikirim: ${_tglLahirController.text}");
    if (_profilFormKey.currentState!.validate() &&
        _dataDiriFormKey.currentState!.validate() &&
        _orangTuaFormKey.currentState!.validate() &&
        _waliFormKey.currentState!.validate()) {
      _profilFormKey.currentState!.save();
      _dataDiriFormKey.currentState!.save();
      _orangTuaFormKey.currentState!.save();
      _waliFormKey.currentState!.save();

      setState(() {
        loading = true;
      });

      final response = await http.post(
        Uri.parse('http://103.75.209.90/api/updateSiswa/$idSiswa'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'nis': nis ?? '',
          'nisn': nisn ?? '',
          'nama_siswa': namaSiswa ?? '',
          'tmpt_lahir': tmptLahir ?? '',
          'tgl_lahir': _tglLahirController.text,
          'agama': agama ?? '',
          'jenis_kelamin': jenisKelaminFormatted ?? '',
          'no_hp': noHp ?? '',
          'no_tlpn': noTlpn ?? '',
          'email': email ?? '',
          'alamat': alamat ?? '',
          'rt': rt ?? '',
          'rw': rw ?? '',
          'no_rumah': noRumah ?? '',
          'kel': kel ?? '',
          'kec': kec ?? '',
          'kota': kota ?? '',
          'prov': prov ?? '',
          'nik_ayah': nikAyah ?? '',
          'nama_ayah': namaAyah ?? '',
          'tmpt_lahir_ayah': tmptLahirAyah ?? '',
          'tgl_lahir_ayah': _tglLahirAyahController.text,
          'pendidikan_ayah': pendidikanAyah ?? '',
          'pekerjaan_ayah': pekerjaanAyah ?? '',
          'penghasilan_ayah': penghasilanAyah ?? '',
          'nik_ibu': nikIbu ?? '',
          'nama_ibu': namaIbu ?? '',
          'tmpt_lahir_ibu': tmptLahirIbu ?? '',
          'tgl_lahir_ibu': _tglLahirIbuController.text,
          'pendidikan_ibu': pendidikanIbu ?? '',
          'pekerjaan_ibu': pekerjaanIbu ?? '',
          'penghasilan_ibu': penghasilanIbu ?? '',
          'nik_wali': nikWali ?? '',
          'nama_wali': namaWali ?? '',
          'tmpt_lahir_wali': tmptLahirWali ?? '',
          'tgl_lahir_wali': _tglLahirWaliController.text,
          'pendidikan_wali': pendidikanWali ?? '',
          'pekerjaan_wali': pekerjaanWali ?? '',
          'penghasilan_wali': penghasilanWali ?? '',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data berhasil diubah')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Gagal mengubah data')));
      }

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
        leading: BackButton(color: AppColors.white),
        title: Text(
          'SI AWI',
          style: TextStyle(color: AppColors.white),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
            child: Image.asset(
              'assets/logo/logo-splash.png',
              width: 30,
            ),
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  _buildTitle('Edit Data Diri'),
                  const SizedBox(
                    height: 10,
                  ),
                  Form(
                    key: _profilFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: nis,
                          decoration: const InputDecoration(labelText: 'NIS'),
                          onSaved: (value) => nis = value,
                          validator: (value) =>
                              value!.isEmpty ? 'NIS tidak boleh kosong' : null,
                          enabled: false,
                        ),
                        TextFormField(
                          initialValue: nisn,
                          decoration: const InputDecoration(labelText: 'NISN'),
                          onSaved: (value) => nisn = value,
                          validator: (value) =>
                              value!.isEmpty ? 'NISN tidak boleh kosong' : null,
                          enabled: false,
                        ),
                        TextFormField(
                          initialValue: namaSiswa,
                          decoration:
                              const InputDecoration(labelText: 'Nama Siswa'),
                          onSaved: (value) => namaSiswa = value,
                          validator: (value) =>
                              value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                          enabled: false,
                        ),
                        TextFormField(
                          initialValue: tmptLahir,
                          decoration:
                              const InputDecoration(labelText: 'Tempat Lahir'),
                          onSaved: (value) => tmptLahir = value,
                          validator: (value) => value!.isEmpty
                              ? 'Tempat Lahir tidak boleh kosong'
                              : null,
                        ),
                        TextFormField(
                          controller: _tglLahirController,
                          decoration:
                              const InputDecoration(labelText: 'Tanggal Lahir'),
                          onTap: () => _selectDate(_tglLahirController),
                        ),
                        DropdownButtonFormField<String>(
                          value: agama,
                          decoration: const InputDecoration(labelText: 'Agama'),
                          items: const [
                            DropdownMenuItem(
                                value: 'islam', child: Text('islam')),
                            DropdownMenuItem(
                                value: 'kristen', child: Text('Kristen')),
                            DropdownMenuItem(
                                value: 'hindu', child: Text('hindu')),
                            DropdownMenuItem(
                                value: 'budha', child: Text('Budha')),
                            DropdownMenuItem(
                                value: 'konghucu', child: Text('Konghucu')),
                          ],
                          onChanged: (value) {
                            agama = value;
                          },
                        ),
                        DropdownButtonFormField<String>(
                          value: jenisKelaminFormatted,
                          decoration:
                              const InputDecoration(labelText: 'Jenis Kelamin'),
                          items: const [
                            DropdownMenuItem(
                                value: 'L', child: Text('Laki - Laki')),
                            DropdownMenuItem(
                                value: 'P', child: Text('Perempuan')),
                          ],
                          onChanged: (value) {
                            jenisKelaminFormatted = value;
                          },
                        ),
                        TextFormField(
                          initialValue: namaKelas,
                          decoration:
                              const InputDecoration(labelText: 'Nama Kelas'),
                          onSaved: (value) => namaKelas = value,
                          validator: (value) => value!.isEmpty
                              ? 'Nama Kelas tidak boleh kosong'
                              : null,
                        ),
                        TextFormField(
                          initialValue: namaJurusan,
                          decoration:
                              const InputDecoration(labelText: 'Nama Jurusan'),
                          onSaved: (value) => namaJurusan = value,
                          validator: (value) => value!.isEmpty
                              ? 'Nama Jurusan tidak boleh kosong'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  Form(
                    key: _dataDiriFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: noHp,
                          decoration: const InputDecoration(labelText: 'No HP'),
                          onSaved: (value) => noHp = value,
                          validator: (value) => value!.isEmpty
                              ? 'No HP tidak boleh kosong'
                              : null,
                        ),
                        TextFormField(
                          initialValue: noTlpn,
                          decoration:
                              const InputDecoration(labelText: 'No Telepon'),
                          onSaved: (value) => noTlpn = value,
                          validator: (value) => value!.isEmpty
                              ? 'No Telepon tidak boleh kosong'
                              : null,
                        ),
                        TextFormField(
                          initialValue: email,
                          decoration: const InputDecoration(labelText: 'Email'),
                          onSaved: (value) => email = value,
                          validator: (value) => value!.isEmpty
                              ? 'Email tidak boleh kosong'
                              : null,
                        ),
                        TextFormField(
                          initialValue: alamat,
                          decoration:
                              const InputDecoration(labelText: 'Alamat'),
                          onSaved: (value) => alamat = value,
                          validator: (value) => value!.isEmpty
                              ? 'Alamat tidak boleh kosong'
                              : null,
                        ),
                        TextFormField(
                          initialValue: noRumah,
                          decoration:
                              const InputDecoration(labelText: 'No Rumah'),
                          onSaved: (value) => noRumah = value,
                          validator: (value) => value!.isEmpty
                              ? 'No Rumah tidak boleh kosong'
                              : null,
                        ),
                        TextFormField(
                          initialValue: rt,
                          decoration: const InputDecoration(labelText: 'RT'),
                          onSaved: (value) => rt = value,
                          validator: (value) =>
                              value!.isEmpty ? 'RT tidak boleh kosong' : null,
                        ),
                        TextFormField(
                          initialValue: rw,
                          decoration: const InputDecoration(labelText: 'RW'),
                          onSaved: (value) => rw = value,
                          validator: (value) =>
                              value!.isEmpty ? 'RW tidak boleh kosong' : null,
                        ),
                        TextFormField(
                          initialValue: kel,
                          decoration:
                              const InputDecoration(labelText: 'Kelurahan'),
                          onSaved: (value) => kel = value,
                          validator: (value) => value!.isEmpty
                              ? 'Kelurahan tidak boleh kosong'
                              : null,
                        ),
                        TextFormField(
                          initialValue: kec,
                          decoration:
                              const InputDecoration(labelText: 'Kecamatan'),
                          onSaved: (value) => kec = value,
                          validator: (value) => value!.isEmpty
                              ? 'Kecamatan tidak boleh kosong'
                              : null,
                        ),
                        TextFormField(
                          initialValue: kota,
                          decoration: const InputDecoration(labelText: 'Kota'),
                          onSaved: (value) => kota = value,
                          validator: (value) =>
                              value!.isEmpty ? 'Kota tidak boleh kosong' : null,
                        ),
                        TextFormField(
                          initialValue: prov,
                          decoration:
                              const InputDecoration(labelText: 'Provinsi'),
                          onSaved: (value) => prov = value,
                          validator: (value) => value!.isEmpty
                              ? 'Provinsi tidak boleh kosong'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  Form(
                    key: _orangTuaFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: nikAyah,
                          decoration:
                              const InputDecoration(labelText: 'NIK Ayah'),
                          onSaved: (value) => nikAyah = value,
                          validator: (value) => value!.isEmpty
                              ? 'NIK Ayah tidak boleh kosong'
                              : null,
                        ),
                        TextFormField(
                          initialValue: namaAyah,
                          decoration:
                              const InputDecoration(labelText: 'Nama Ayah'),
                          onSaved: (value) => namaAyah = value,
                          validator: (value) => value!.isEmpty
                              ? 'Nama Ayah tidak boleh kosong'
                              : null,
                        ),
                        TextFormField(
                          initialValue: tmptLahirAyah,
                          decoration: const InputDecoration(
                              labelText: 'Tempat Lahir Ayah'),
                          onSaved: (value) => tmptLahirAyah = value,
                          validator: (value) => value!.isEmpty
                              ? 'Tempat Lahir Ayah tidak boleh kosong'
                              : null,
                        ),
                        TextFormField(
                          controller: _tglLahirAyahController,
                          readOnly: true,
                          decoration: const InputDecoration(
                              labelText: 'Tanggal Lahir Ayah'),
                          onTap: () => _selectDate(_tglLahirAyahController),
                        ),
                        DropdownButtonFormField<String>(
                          value: pendidikanAyah,
                          decoration: const InputDecoration(
                              labelText: 'Pendidikan Ayah'),
                          items: const [
                            DropdownMenuItem(value: '-', child: Text('-')),
                            DropdownMenuItem(value: 'sd', child: Text('SD')),
                            DropdownMenuItem(value: 'smp', child: Text('SMP')),
                            DropdownMenuItem(
                                value: 'sma', child: Text('SMA/SMK')),
                            DropdownMenuItem(value: 's1', child: Text('S1')),
                            DropdownMenuItem(value: 's2', child: Text('S2')),
                            DropdownMenuItem(value: 's3', child: Text('S3')),
                          ],
                          onChanged: (value) {
                            pendidikanAyah = value;
                          },
                        ),
                        DropdownButtonFormField<String>(
                          value: pekerjaanAyah,
                          decoration: const InputDecoration(
                              labelText: 'Pekerjaan Ayah'),
                          items: const [
                            DropdownMenuItem(value: '-', child: Text('-')),
                            DropdownMenuItem(
                                value: 'karyawan', child: Text('karyawan')),
                            DropdownMenuItem(value: 'pns', child: Text('pns')),
                            DropdownMenuItem(
                                value: 'tni/polisi', child: Text('tni/polisi')),
                            DropdownMenuItem(
                                value: 'wiraswasta', child: Text('wiraswasta')),
                            DropdownMenuItem(
                                value: 'guru', child: Text('guru')),
                            DropdownMenuItem(
                                value: 'ibu rumah tangga',
                                child: Text('ibu rumah tangga')),
                            DropdownMenuItem(
                                value: 'lainnya', child: Text('lainnya')),
                          ],
                          onChanged: (value) {
                            pekerjaanAyah = value;
                          },
                        ),
                        DropdownButtonFormField<String>(
                          value: penghasilanAyah,
                          decoration: const InputDecoration(
                              labelText: 'Penghasilan Ayah'),
                          items: const [
                            DropdownMenuItem(value: '-', child: Text('-')),
                            DropdownMenuItem(
                                value: 'Rp.500.000 - Rp 2.000.000',
                                child: Text('Rp.500.000 - Rp 2.000.000')),
                            DropdownMenuItem(
                                value: 'Rp.2.100.000 - Rp 3.000.000',
                                child: Text('Rp.2.100.000 - Rp 3.000.000')),
                            DropdownMenuItem(
                                value: 'Rp.3.100.000 - Rp 4.000.000',
                                child: Text('Rp.3.100.000 - Rp 4.000.000')),
                            DropdownMenuItem(
                                value: 'Rp.4.100.000 - Rp 5.000.000',
                                child: Text('Rp.4.100.000 - Rp 5.000.000')),
                            DropdownMenuItem(
                                value: '>Rp 5.000.000',
                                child: Text('>Rp 5.000.000')),
                          ],
                          onChanged: (value) {
                            penghasilanAyah = value;
                          },
                        ),
                        TextFormField(
                          initialValue: nikIbu,
                          decoration:
                              const InputDecoration(labelText: 'NIK Ibu'),
                          onSaved: (value) => nikIbu = value,
                          validator: (value) => value!.isEmpty
                              ? 'NIK Ibu tidak boleh kosong'
                              : null,
                        ),
                        TextFormField(
                          initialValue: namaIbu,
                          decoration:
                              const InputDecoration(labelText: 'Nama Ibu'),
                          onSaved: (value) => namaIbu = value,
                          validator: (value) => value!.isEmpty
                              ? 'Nama Ibu tidak boleh kosong'
                              : null,
                        ),
                        TextFormField(
                          initialValue: tmptLahirIbu,
                          decoration: const InputDecoration(
                              labelText: 'Tempat Lahir Ibu'),
                          onSaved: (value) => tmptLahirIbu = value,
                          validator: (value) => value!.isEmpty
                              ? 'Tempat Lahir Ibu tidak boleh kosong'
                              : null,
                        ),
                        TextFormField(
                          controller: _tglLahirIbuController,
                          readOnly: true,
                          decoration: const InputDecoration(
                              labelText: 'Tanggal Lahir Ibu'),
                          onTap: () => _selectDate(_tglLahirIbuController),
                        ),
                        DropdownButtonFormField<String>(
                          value: pendidikanIbu,
                          decoration: const InputDecoration(
                              labelText: 'Pendidikan Ibu'),
                          items: const [
                            DropdownMenuItem(value: '-', child: Text('-')),
                            DropdownMenuItem(value: 'sd', child: Text('SD')),
                            DropdownMenuItem(value: 'smp', child: Text('SMP')),
                            DropdownMenuItem(
                                value: 'sma', child: Text('SMA/SMK')),
                            DropdownMenuItem(value: 's1', child: Text('S1')),
                            DropdownMenuItem(value: 's2', child: Text('S2')),
                            DropdownMenuItem(value: 's3', child: Text('S3')),
                          ],
                          onChanged: (value) {
                            pendidikanIbu = value;
                          },
                        ),
                        DropdownButtonFormField<String>(
                          value: pekerjaanIbu,
                          decoration:
                              const InputDecoration(labelText: 'Pekerjaan Ibu'),
                          items: const [
                            DropdownMenuItem(value: '-', child: Text('-')),
                            DropdownMenuItem(
                                value: 'karyawan', child: Text('karyawan')),
                            DropdownMenuItem(value: 'pns', child: Text('pns')),
                            DropdownMenuItem(
                                value: 'tni/polisi', child: Text('tni/polisi')),
                            DropdownMenuItem(
                                value: 'wiraswasta', child: Text('wiraswasta')),
                            DropdownMenuItem(
                                value: 'guru', child: Text('guru')),
                            DropdownMenuItem(
                                value: 'ibu rumah tangga',
                                child: Text('ibu rumah tangga')),
                            DropdownMenuItem(
                                value: 'lainnya', child: Text('lainnya')),
                          ],
                          onChanged: (value) {
                            pekerjaanIbu = value;
                          },
                        ),
                        DropdownButtonFormField<String>(
                          value: penghasilanIbu,
                          decoration: const InputDecoration(
                              labelText: 'Penghasilan Ibu'),
                          items: const [
                            DropdownMenuItem(value: '-', child: Text('-')),
                            DropdownMenuItem(
                                value: 'Rp.500.000 - Rp 2.000.000',
                                child: Text('Rp.500.000 - Rp 2.000.000')),
                            DropdownMenuItem(
                                value: 'Rp.2.100.000 - Rp 3.000.000',
                                child: Text('Rp.2.100.000 - Rp 3.000.000')),
                            DropdownMenuItem(
                                value: 'Rp.3.100.000 - Rp 4.000.000',
                                child: Text('Rp.3.100.000 - Rp 4.000.000')),
                            DropdownMenuItem(
                                value: 'Rp.4.100.000 - Rp 5.000.000',
                                child: Text('Rp.4.100.000 - Rp 5.000.000')),
                            DropdownMenuItem(
                                value: '>Rp 5.000.000',
                                child: Text('>Rp 5.000.000')),
                          ],
                          onChanged: (value) {
                            penghasilanIbu = value;
                          },
                        ),
                      ],
                    ),
                  ),
                  Form(
                    key: _waliFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: nikWali,
                          decoration:
                              const InputDecoration(labelText: 'NIK Wali'),
                          onSaved: (value) => nikWali = value,
                          validator: (value) => value!.isEmpty
                              ? 'NIK Wali tidak boleh kosong'
                              : null,
                        ),
                        TextFormField(
                          initialValue: namaWali,
                          decoration:
                              const InputDecoration(labelText: 'Nama Wali'),
                          onSaved: (value) => namaWali = value,
                          validator: (value) => value!.isEmpty
                              ? 'Nama Wali tidak boleh kosong'
                              : null,
                        ),
                        TextFormField(
                          initialValue: tmptLahirWali,
                          decoration: const InputDecoration(
                              labelText: 'Tempat Lahir Wali'),
                          onSaved: (value) => tmptLahirWali = value,
                          validator: (value) => value!.isEmpty
                              ? 'Tempat Lahir Wali tidak boleh kosong'
                              : null,
                        ),
                        TextFormField(
                          controller: _tglLahirWaliController,
                          readOnly: true,
                          decoration: const InputDecoration(
                              labelText: 'Tanggal Lahir Wali'),
                          onTap: () => _selectDate(_tglLahirWaliController),
                        ),
                        DropdownButtonFormField<String>(
                          value: pendidikanWali,
                          decoration: const InputDecoration(
                              labelText: 'Pendidikan Wali'),
                          items: const [
                            DropdownMenuItem(value: '-', child: Text('-')),
                            DropdownMenuItem(value: 'sd', child: Text('SD')),
                            DropdownMenuItem(value: 'smp', child: Text('SMP')),
                            DropdownMenuItem(
                                value: 'sma', child: Text('SMA/SMK')),
                            DropdownMenuItem(value: 's1', child: Text('S1')),
                            DropdownMenuItem(value: 's2', child: Text('S2')),
                            DropdownMenuItem(value: 's3', child: Text('S3')),
                          ],
                          onChanged: (value) {
                            pendidikanWali = value;
                          },
                        ),
                        DropdownButtonFormField<String>(
                          value: pekerjaanWali,
                          decoration: const InputDecoration(
                              labelText: 'Pekerjaan Wali'),
                          items: const [
                            DropdownMenuItem(value: '-', child: Text('-')),
                            DropdownMenuItem(
                                value: 'karyawan', child: Text('karyawan')),
                            DropdownMenuItem(value: 'pns', child: Text('pns')),
                            DropdownMenuItem(
                                value: 'tni/polisi', child: Text('tni/polisi')),
                            DropdownMenuItem(
                                value: 'wiraswasta', child: Text('wiraswasta')),
                            DropdownMenuItem(
                                value: 'guru', child: Text('guru')),
                            DropdownMenuItem(
                                value: 'ibu rumah tangga',
                                child: Text('ibu rumah tangga')),
                            DropdownMenuItem(
                                value: 'lainnya', child: Text('lainnya')),
                          ],
                          onChanged: (value) {
                            pekerjaanWali = value;
                          },
                        ),
                        DropdownButtonFormField<String>(
                          value: penghasilanWali,
                          decoration: const InputDecoration(
                              labelText: 'Penghasilan Wali'),
                          items: const [
                            DropdownMenuItem(value: '-', child: Text('-')),
                            DropdownMenuItem(
                                value: 'Rp.500.000 - Rp 2.000.000',
                                child: Text('Rp.500.000 - Rp 2.000.000')),
                            DropdownMenuItem(
                                value: 'Rp.2.100.000 - Rp 3.000.000',
                                child: Text('Rp.2.100.000 - Rp 3.000.000')),
                            DropdownMenuItem(
                                value: 'Rp.3.100.000 - Rp 4.000.000',
                                child: Text('Rp.3.100.000 - Rp 4.000.000')),
                            DropdownMenuItem(
                                value: 'Rp.4.100.000 - Rp 5.000.000',
                                child: Text('Rp.4.100.000 - Rp 5.000.000')),
                            DropdownMenuItem(
                                value: '>Rp 5.000.000',
                                child: Text('>Rp 5.000.000')),
                          ],
                          onChanged: (value) {
                            penghasilanWali = value;
                          },
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      getIdSiswa().then((idSiswa) {
                        if (idSiswa != null) {
                          _ubahDataDiri(idSiswa);
                        }
                      });
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ),
    );
  }
}

Widget _buildTitle(String text) {
  return Container(
    padding: const EdgeInsets.only(top: 15),
    child: Text(
      text,
      maxLines: 2,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.black,
      ),
    ),
  );
}
