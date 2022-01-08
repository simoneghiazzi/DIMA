import 'package:test/test.dart';
import 'package:sApport/ViewModel/BaseUser/Diary/diary_form.dart';

void main() async {
  /// Test Fields
  var title = "Diary title";
  var content = "Diary content";

  var diaryForm = DiaryForm();

  group("Diary form data", () {
    setUp(() => diaryForm.resetControllers());
    test("Add a title and a content to the sinks and check that the button is enable", () {
      expect(diaryForm.isButtonEnabled, emits(true));

      diaryForm.title.add(title);
      diaryForm.content.add(content);
    });

    test("Add only the title to the sink and check that the button is disable", () {
      expect(diaryForm.isButtonEnabled, emits(false));

      diaryForm.title.add(title);
      diaryForm.content.add("");
    });

    test("Add only the content to the sink and check that the button is disable", () {
      expect(diaryForm.isButtonEnabled, emits(false));

      diaryForm.title.add("");
      diaryForm.content.add(content);
    });

    test("Reset controllers should emit add an empty text to the sinks and the button should be disable", () {
      expect(diaryForm.isButtonEnabled, emits(true));

      diaryForm.title.add(title);
      diaryForm.content.add(content);

      expect(diaryForm.isButtonEnabled, emits(false));

      diaryForm.resetControllers();
    });
  });
}
