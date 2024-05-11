import 'package:flutter/material.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:siawi_app/app/modules/kalender/widget/event_data_source.dart';
import 'package:siawi_app/app/modules/kalender/widget/event.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class KalenderView extends StatefulWidget {
  final VoidCallback signOut;
  const KalenderView(this.signOut, {Key? key}) : super(key: key);

  @override
  State<KalenderView> createState() => _KalenderViewState();
}

class _KalenderViewState extends State<KalenderView> {
  List<Kegiatan> _getDataSource(List<Kegiatan> kegiatanList) {
    final List<Kegiatan> dataSource = <Kegiatan>[];
    for (var kegiatan in kegiatanList) {
      final DateTime startTime = kegiatan.from;
      final DateTime endTime = kegiatan.to;
      dataSource.add(Kegiatan(
        namaKegiatan: kegiatan.namaKegiatan,
        from: startTime,
        to: endTime,
        background: const Color(0xFF0f8644),
        isAllDay: false,
      ));
    }
    return dataSource;
  }

  @override
  void initState() {
    super.initState();
    _fetchKegiatan();
  }

  List<Kegiatan> kegiatanList = [];
  Future<void> _fetchKegiatan() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? idSiswa = preferences.getString('idSiswa');
    if (idSiswa != null) {
      final response =
          await http.get(Uri.parse('http://203.194.113.46/api/kalender/'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> kegiatanData = responseData['data'];
        setState(() {
          kegiatanList.clear();
          for (var item in kegiatanData) {
            Kegiatan kegiatan = Kegiatan.fromJson(item);
            kegiatanList.add(kegiatan);
          }
        });
      } else {
        print('Failed to load jadwal hari ini');
      }
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
      body: Padding(
        padding: EdgeInsets.only(top: 5),
        child: FutureBuilder(
          future: _fetchKegiatan(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return SfCalendar(
                view: CalendarView.month,
                headerStyle: const CalendarHeaderStyle(
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black, // Warna teks judul kalender
                  ),
                  textAlign: TextAlign.center,
                ),
                showNavigationArrow: true,
                initialSelectedDate: DateTime.now(),
                cellBorderColor: Colors.transparent,
                dataSource: KegiatanDataSource(_getDataSource(kegiatanList)),
                selectionDecoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.red, width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  shape: BoxShape.rectangle,
                ),
                monthViewSettings: const MonthViewSettings(
                  appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                  showAgenda: true,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
