import 'package:flutter/material.dart';
import 'package:siawi_app/app/modules/kalender/widget/event_data_source.dart';
import 'package:siawi_app/utils/colors.dart';
import 'package:siawi_app/app/modules/kalender/widget/event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class KalenderView extends StatefulWidget {
  const KalenderView({Key? key}) : super(key: key);

  @override
  State<KalenderView> createState() => _KalenderViewState();
}

class _KalenderViewState extends State<KalenderView> {
  List<Kegiatan> _getDataSource() {
    final List<Kegiatan> kegiatan = <Kegiatan>[];
    final DateTime today = DateTime.now();
    final DateTime startTime =
        DateTime(today.year, today.month, today.day, 9, 0, 0);
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    kegiatan.add(Kegiatan(
        "Ujian 1", startTime, endTime, const Color(0xFF0f8644), false));
    kegiatan.add(Kegiatan(
        "Ujian 2", startTime, endTime, const Color(0xFF0f8644), false));
    kegiatan.add(Kegiatan("Ujian 3", startTime.add(Duration(days: 2)), endTime,
        const Color(0xFF0f8644), false));

    return kegiatan;
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
        child: SfCalendar(
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
          dataSource: KegiatanDataSource(_getDataSource()),
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
        ),
      ),
    );
  }
}
