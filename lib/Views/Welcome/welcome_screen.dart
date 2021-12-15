import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:sApport/Views/Welcome/components/welcome_body.dart';

class WelcomeScreen extends StatefulWidget {
  static const route = '/welcomeScreen';

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with WidgetsBindingObserver {
  // Router
  AppRouterDelegate routerDelegate;

  // View Models
  ChatViewModel chatViewModel;
  ReportViewModel reportViewModel;
  DiaryViewModel diaryViewModel;

  bool _first;
  bool _keyboardPreviouslyOpened;

  @override
  void initState() {
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    reportViewModel = Provider.of<ReportViewModel>(context, listen: false);
    diaryViewModel = Provider.of<DiaryViewModel>(context, listen: false);
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _first = true;
    _keyboardPreviouslyOpened = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      body: WelcomeBody(),
    );
  }

  // Handle the orientation changes of the device
  // This method is called BEFORE build, so the _previosKeyboardState contains the value of the state of the
  // keyboard before the rebuild
  @override
  void didChangeMetrics() {
    if (_first && WidgetsBinding.instance.window.viewInsets.bottom == 0.0 && !_keyboardPreviouslyOpened) {
      // ** The MediaQuery.orientation value is the one before the rotation
      // since the didChangeMetrics is called before the value in the MediaQuery is updated **
      if (routerDelegate.getLastRoute() == ChatPageScreen.route) {
        routerDelegate.pop();
      } else if (MediaQuery.of(context).orientation == Orientation.landscape && chatViewModel.currentChat != null) {
        routerDelegate.pushPage(name: ChatPageScreen.route);
      }
      _first = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
