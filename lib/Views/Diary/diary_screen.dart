import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Views/Diary/components/diary_body.dart';
import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';
import 'package:sApport/Views/components/vertical_split_view.dart';
import 'package:sApport/Views/Diary/components/diary_page_body.dart';

/// Page of the diary of the user.
///
/// It shows the [SfCalendar] that contains all the diary pages of the user.
///
/// It contains the [OrientationBuilder] that checks the orientation of the device and
/// rebuilds the page when the orientation changes. If it is:
/// - portrait: it displays the [DiaryBody].
/// - landscape: it uses the [VerticalSplitView] for displayng the [DiaryBody] on the left and the
/// [DiaryPageBody] (if it is not null) on the right, otherwise it sets the ratio = 1 and it shows
/// only the [DiaryBody]. It also checks the [isEditing] flag: if it is true, it sets the ratio = 0
/// and it shows only the [DiaryPageBody].
///
/// It subscribes to the diary view model currentDiaryPage value notifier in order to rebuild the right hand side of the page
/// when a new current diary page is selected.
class DiaryScreen extends StatefulWidget {
  /// Route of the page used by the Navigator.
  static const route = "/diaryScreen";

  /// Page of the diary of the user.
  ///
  /// It shows the [SfCalendar] that contains all the diary pages of the user.
  ///
  /// It contains the [OrientationBuilder] that checks the orientation of the device and
  /// rebuilds the page when the orientation changes. If it is:
  /// - portrait: it displays the [DiaryBody].
  /// - landscape: it uses the [VerticalSplitView] for displayng the [DiaryBody] on the left and the
  /// [DiaryPageBody] (if it is not null) on the right, otherwise it sets the ratio = 1 and it shows
  /// only the [DiaryBody]. It also checks the [isEditing] flag: if it is true, it sets the ratio = 0
  /// and it shows only the [DiaryPageBody].
  ///
  /// It subscribes to the diary view model currentDiaryPage value notifier in order to rebuild the right hand side of the page
  /// when a new current diary page is selected.
  const DiaryScreen({Key? key}) : super(key: key);

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  // View Models
  late DiaryViewModel diaryViewModel;

  @override
  void initState() {
    diaryViewModel = Provider.of<DiaryViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            // If the orientation is protrait, shows the DiaryBody
            return DiaryBody();
          } else {
            // If the orientation is landscape, shows the ValueListenableBuilder listener that builds the VerticalSplitView
            // with the DiaryBody on the left and, if the current diary page is not null, the DiaryPage on the right,
            // otherwise sets the ration = 1 (it shows only the left widget).
            // If isEditing is true, set the ratio = 0 (shows only the right widget)
            return Consumer<DiaryViewModel>(
              builder: (context, diaryViewModel, child) {
                var _ratio = diaryViewModel.currentDiaryPage != null
                    ? diaryViewModel.isEditing
                        ? 0.0
                        : 0.50
                    : 1.0;
                return VerticalSplitView(
                  left: DiaryBody(),
                  right: diaryViewModel.currentDiaryPage != null ? DiaryPageBody() : Container(),
                  ratio: _ratio,
                  dividerWidth: 2.0,
                  dividerColor: kPrimaryColor,
                );
              },
            );
          }
        },
      ),
    );
  }
}
