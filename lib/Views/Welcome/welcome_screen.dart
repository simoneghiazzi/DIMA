import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:sApport/Views/Diary/diary_page_screen.dart';
import 'package:sApport/Views/Report/report_details_screen.dart';
import 'package:sApport/Views/Welcome/components/welcome_body.dart';
import 'package:sizer/sizer.dart';

class WelcomeScreen extends StatefulWidget {
  static const route = '/welcomeScreen';

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with WidgetsBindingObserver {
  // Router
  late AppRouterDelegate routerDelegate;

  // View Models
  late ChatViewModel chatViewModel;
  late ReportViewModel reportViewModel;
  late DiaryViewModel diaryViewModel;

  bool _first = true;
  var _width;

  @override
  void initState() {
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    reportViewModel = Provider.of<ReportViewModel>(context, listen: false);
    diaryViewModel = Provider.of<DiaryViewModel>(context, listen: false);
    _width = WidgetsBinding.instance!.window.physicalSize.width;
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WelcomeBody(),
    );
  }

  /// Handle the orientation changes of the device.
  ///
  /// The _previosKeyboardState contains the value of the state of the keyboard before the rebuild
  void handleOrientationChanges() {
    print("handleOrientationChanges");
    String lastRoute = routerDelegate.getLastRoute();
    if (lastRoute == ChatPageScreen.route || lastRoute == ReportDetailsScreen.route || lastRoute == DiaryPageScreen.route) {
      routerDelegate.pop();
    } else if (MediaQuery.of(context).orientation == Orientation.landscape) {
      if (chatViewModel.currentChat.value != null) {
        routerDelegate.pushPage(name: ChatPageScreen.route);
      } else if (reportViewModel.currentReport != null) {
        routerDelegate.pushPage(name: ReportDetailsScreen.route);
      } else if (diaryViewModel.currentDiaryPage != null) {
        routerDelegate.pushPage(name: DiaryPageScreen.route);
      }
    }
  }

  @override
  void didChangeMetrics() {
    if (_width != WidgetsBinding.instance!.window.physicalSize.width) {
      if (_first) {
        handleOrientationChanges();
      }
      _width = WidgetsBinding.instance!.window.physicalSize.width;
      _first = true;
    }
    super.didChangeMetrics();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
}
