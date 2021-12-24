import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/DBItems/BaseUser/diary_page.dart';
import 'package:sApport/Views/Diary/components/diary_body.dart';
import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';

/// Source of data for the [SfCalendar] of the [DiaryBody].
///
/// It sets the appointments that the calendar has to show in the correct format by
/// taking the [docs] retrieved from the Firebase DB.
///
/// It also sets the [hasDiaryPageToday] field of the [diaryViewModel].
class DiaryPageDataSource extends CalendarDataSource {
  /// Source of data for the [SfCalendar] of the [DiaryBody].
  ///
  /// It sets the appointments that the calendar has to show in the correct format by
  /// taking the [docs] retrieved from the Firebase DB.
  ///
  /// It also sets the [hasDiaryPageToday] field of the [diaryViewModel].
  DiaryPageDataSource(List<DocumentSnapshot> docs, DiaryViewModel diaryViewModel) {
    List<DiaryPage> source = List.from([]);
    for (DocumentSnapshot doc in docs) {
      DiaryPage n = DiaryPage.fromDocument(doc);
      source.add(n);
      if (Utils.isToday(n.dateTime)) {
        diaryViewModel.hasDiaryPageToday = true;
      }
    }
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    DateTime date = appointments![index].dateTime;
    return DateTime(date.year, date.month, date.day);
  }

  @override
  DateTime getEndTime(int index) {
    DateTime date = appointments![index].dateTime;
    return DateTime(date.year, date.month, date.day);
  }
}
