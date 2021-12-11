import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split_view/split_view.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/Diary/diary_page_screen.dart';
import 'package:sApport/Views/Diary/components/diary_body.dart';
import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';
import 'package:sApport/Views/components/empty_page_portrait.dart';

class DiaryScreen extends StatefulWidget {
  static const route = '/diaryScreen';

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  DiaryViewModel diaryViewModel;
  bool isPageOpen = false;

  @override
  void initState() {
    diaryViewModel = Provider.of<DiaryViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //detectChangeOrientation();
    //diaryViewModel.checkOpenPage();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: //MediaQuery.of(context).orientation == Orientation.landscape
          // ? SplitView(
          //     controller: SplitViewController(weights: [0.6, 0.4]),
          //     children: [
          //       DiaryBody(
          //         diaryViewModel: diaryViewModel,
          //       ),
          //       StreamBuilder(
          //           stream: diaryViewModel.isPageOpen,
          //           builder: (context, snapshot) {
          //             if (snapshot.data == true) {
          //               isPageOpen = true;
          //               return DiaryPageScreen(
          //                 diaryViewModel: diaryViewModel,
          //                 startOrientation: true,
          //               );
          //             }
          //             return EmptyPagePortrait();
          //           })
          //     ],
          //     viewMode: SplitViewMode.Horizontal,
          //     gripSize: 1.0,
          //     gripColor: kPrimaryColor,
          //   )
          //: 
          DiaryBody(
              diaryViewModel: diaryViewModel,
            ),
    );
  }

  // Future<void> detectChangeOrientation() async {
  //   AppRouterDelegate routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
  //   await Future(() async {
  //     if ((MediaQuery.of(context).orientation == Orientation.portrait) && isPageOpen) {
  //       routerDelegate.pushPage(
  //         name: DiaryPageScreen.route,
  //         arguments: diaryViewModel,
  //       );
  //     }
  //   });
  // }
}
