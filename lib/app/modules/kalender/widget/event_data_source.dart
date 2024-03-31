import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'dart:ui';
import 'event.dart';

class KegiatanDataSource extends CalendarDataSource {
  KegiatanDataSource(List<Kegiatan> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].namaKegiatan;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}
