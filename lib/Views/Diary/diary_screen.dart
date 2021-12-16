import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Views/Diary/components/diary_page_body.dart';
import 'package:sApport/Views/components/vertical_split_view.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/Diary/components/diary_body.dart';
import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';
import 'package:sApport/constants.dart';

class DiaryScreen extends StatefulWidget {
  static const route = '/diaryScreen';

  const DiaryScreen({Key key}) : super(key: key);

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  DiaryViewModel diaryViewModel;
  AppRouterDelegate routerDelegate;

  @override
  void initState() {
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    diaryViewModel = Provider.of<DiaryViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: MediaQuery.of(context).orientation == Orientation.portrait
          ? DiaryBody()
          : Consumer<DiaryViewModel>(
              builder: (context, diaryViewModel, child) {
                var _ratio = diaryViewModel.currentDiaryPage != null ? 0.50 : 1.0;
                return VerticalSplitView(
                  left: DiaryBody(),
                  right: diaryViewModel.currentDiaryPage != null ? DiaryPageBody(key: ValueKey(diaryViewModel.currentDiaryPage.id)) : Container(),
                  ratio: _ratio,
                  dividerWidth: 2.0,
                  dividerColor: kPrimaryColor,
                );
              },
            ),
    );
  }
}
