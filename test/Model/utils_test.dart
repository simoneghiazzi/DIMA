import 'package:sApport/Model/utils.dart';
import 'package:test/test.dart';

void main() async {
  /// Test Fields
  var id1 = "AAA";
  var id2 = "BBB";
  var todayDate = DateTime.now();

  group("Utils static randomId methods", () {
    test("Check that randomId returns a string of the given length", () {
      int length = 15;
      var randomId = Utils.randomId(idLength: length);
      expect(randomId, isA<String>());
      expect(randomId.length, length);
    });

    test("Check that randomId returns a string of the default length if it is not explicitly setted", () {
      var randomId = Utils.randomId();
      expect(randomId, isA<String>());
      expect(randomId.length, 28);
    });
  });

  group("Utils static pairChatId methods", () {
    test("Check that pairChatId returns a string that contains the two IDs in the correct order whatever is the input order", () {
      var pairId = Utils.pairChatId(id1, id2);
      expect(pairId, isA<String>());
      expect(pairId, id1 + "-" + id2);

      pairId = Utils.pairChatId(id2, id1);
      expect(pairId, isA<String>());
      expect(pairId, id1 + "-" + id2);
    });
  });

  group("Utils static isToday methods", () {
    test("Check that isToday returns true if the input date time is the date of today", () {
      expect(Utils.isToday(todayDate), true);
    });

    test("Check that isToday returns false if the input date time has the day different from today", () {
      var notTodayDate = DateTime(todayDate.year, todayDate.month, todayDate.day + 1);

      expect(Utils.isToday(notTodayDate), false);
    });

    test("Check that isToday returns false if the input date time has the month different from today", () {
      var notTodayDate = DateTime(todayDate.year, todayDate.month + 1, todayDate.day);

      expect(Utils.isToday(notTodayDate), false);
    });

    test("Check that isToday returns false if the input date time has the year different from today", () {
      var notTodayDate = DateTime(todayDate.year + 1, todayDate.month, todayDate.day);

      expect(Utils.isToday(notTodayDate), false);
    });
  });
}
