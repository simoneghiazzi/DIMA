import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:sApport/Views/Diary/components/diary_body.dart';
import 'package:sApport/Model/DBItems/BaseUser/diary_page.dart';

/// Source of data for the [SfCalendar] of the [DiaryBody].
///
/// It sets the appointments that the calendar has to show in the correct format by
/// taking the list of diary pages of the [diaryViewModel] retrieved from the Firebase DB.
class DiaryPageDataSource extends CalendarDataSource {
  /// Source of data for the [SfCalendar] of the [DiaryBody].
  ///
  /// It sets the appointments that the calendar has to show in the correct format by
  /// taking the list of diary pages of the [diaryViewModel] retrieved from the Firebase DB.
  DiaryPageDataSource(List<DiaryPage> diaryPages) {
    appointments = diaryPages;
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
