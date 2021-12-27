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

/// It contains the [WelcomeBody] that is used as the first screen for non-signed in users.
///
/// **It handles the device orientation changes by subscribing to the [didChangeMetrics].
/// This listener is active in the entire application since this page is always at the bottom of the stack.**
class WelcomeScreen extends StatefulWidget {
  /// Route of the page used by the Navigator.
  static const route = "/welcomeScreen";

  /// It contains the [WelcomeBody] that is used as the first screen for non-signed in users.
  ///
  /// **It handles the device orientation changes by subscribing to the [didChangeMetrics].
  /// This listener is active in the entire application since this page is always at the bottom of the stack.**
  const WelcomeScreen({Key? key}) : super(key: key);

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

  late double _width;

  @override
  void initState() {
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    reportViewModel = Provider.of<ReportViewModel>(context, listen: false);
    diaryViewModel = Provider.of<DiaryViewModel>(context, listen: false);

    // Add a the interceptor for listening to the did change metrics
    WidgetsBinding.instance!.addObserver(this);

    // Get the width because the did change metrics is triggered also when the keyboard is opened
    _width = WidgetsBinding.instance!.window.physicalSize.width;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const WelcomeBody(),
    );
  }

  /// Handle the orientation changes of the device.
  /// It is triggered by the [onChangeMetrics] listener.
  ///
  /// - If the last route is the one between the [ChatPageScreen], the [ReportDetailsScreen]
  /// or the [DiaryPageScreen], when the function is triggered, it pop the page.
  /// - If the orientation change from landscape to portrait and the current value of one of
  /// the view models is not null, it pushes the relative page.
  void handleOrientationChanges() {
    print("handleOrientationChanges");
    String lastRoute = routerDelegate.getLastRoute();
    if (lastRoute == ChatPageScreen.route || lastRoute == ReportDetailsScreen.route || lastRoute == DiaryPageScreen.route) {
      routerDelegate.pop();
    } else if (MediaQuery.of(context).orientation == Orientation.landscape) {
      if (chatViewModel.currentChat.value != null) {
        routerDelegate.pushPage(name: ChatPageScreen.route);
      } else if (reportViewModel.currentReport.value != null) {
        routerDelegate.pushPage(name: ReportDetailsScreen.route);
      } else if (diaryViewModel.currentDiaryPage.value != null) {
        routerDelegate.pushPage(name: DiaryPageScreen.route);
      }
    }
  }

  @override
  void didChangeMetrics() {
    // Check if the callback is not triggered by the keyboard
    if (_width != WidgetsBinding.instance!.window.physicalSize.width) {
      handleOrientationChanges();
      _width = WidgetsBinding.instance!.window.physicalSize.width;
    }
    super.didChangeMetrics();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
}
