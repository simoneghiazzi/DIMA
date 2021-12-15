import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Views/Diary/components/diary_page_body.dart';
import 'package:split_view/split_view.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/Diary/diary_page_screen.dart';
import 'package:sApport/Views/Diary/components/diary_body.dart';
import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';
import 'package:sApport/Views/components/empty_landscape_body.dart';

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
      body: MediaQuery.of(context).orientation == Orientation.portrait || diaryViewModel.currentDiaryPage == null
          ? DiaryBody()
          : SplitView(
              controller: SplitViewController(weights: [0.35, 0.65]),
              children: [
                DiaryBody(),
                DiaryPageBody(),
              ],
              viewMode: SplitViewMode.Horizontal,
              gripSize: 0.3,
              gripColor: kPrimaryGreyColor,
            ),
    );
  }
}
