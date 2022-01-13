import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/ViewModel/map_view_model.dart';
import 'package:sApport/Views/Map/map_screen.dart';
import 'package:sApport/Views/Login/login_screen.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Welcome/welcome_screen.dart';
import 'package:sApport/Views/Diary/diary_page_screen.dart';
import 'package:sApport/Views/Signup/credential_screen.dart';
import 'package:sApport/Views/Report/reports_list_screen.dart';
import 'package:sApport/Views/Report/create_report_screen.dart';
import 'package:sApport/Views/Report/report_details_screen.dart';
import 'package:sApport/Views/Login/forgot_password_screen.dart';
import 'package:sApport/Views/Profile/expert_profile_screen.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';
import 'package:sApport/Views/Chat/ChatList/chat_list_screen.dart';
import 'package:sApport/Views/Home/Expert/expert_home_page_screen.dart';
import 'package:sApport/Views/Signup/Expert/experts_signup_screen.dart';
import 'package:sApport/ViewModel/BaseUser/Diary/diary_view_model.dart';
import 'package:sApport/Views/Signup/BaseUser/base_users_signup_screen.dart';
import 'package:sApport/Views/Home/BaseUser/base_user_home_page_screen.dart';

class AppRouterDelegate extends RouterDelegate<List<RouteSettings>> with ChangeNotifier, PopNavigatorRouterDelegateMixin<List<RouteSettings>> {
  // Stack of pages
  final _pages = <Page>[];

  // Flag that indicates if a dialog is open
  bool hasDialog = false;

  @override
  final navigatorKey = GlobalKey<NavigatorState>();

  late BuildContext buildContext;

  late ChatViewModel chatViewModel;
  late MapViewModel mapViewModel;
  late ReportViewModel reportViewModel;
  late DiaryViewModel diaryViewModel;

  @override
  Widget build(BuildContext context) {
    buildContext = context;
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    mapViewModel = Provider.of<MapViewModel>(context, listen: false);
    reportViewModel = Provider.of<ReportViewModel>(context, listen: false);
    diaryViewModel = Provider.of<DiaryViewModel>(context, listen: false);

    return Navigator(
      key: navigatorKey,
      pages: List.of(_pages),
      onPopPage: _onPopPage,
    );
  }

  /// Checks if the router can handle the pop: if yes, it calls [popRoute]
  bool _onPopPage(Route route, dynamic result) {
    if (!route.didPop(result)) {
      return false;
    }
    popRoute();
    return true;
  }

  @override
  Future<bool> popRoute() {
    if (_pages.length <= 1 ||
        (_pages.last.name == BaseUserHomePageScreen.route && diaryViewModel.currentDiaryPage.value == null) ||
        _pages.last.name == ExpertHomePageScreen.route) {
      return Future.value(false);
    }
    if (mapViewModel.currentExpert.value != null && _pages.last.name != ExpertProfileScreen.route) {
      mapViewModel.resetCurrentExpert();
    } else if (mapViewModel.currentExpert.value == null && chatViewModel.currentChat.value != null && _pages.last.name != ChatPageScreen.route) {
      chatViewModel.resetCurrentChat();
      if (MediaQuery.of(buildContext).orientation == Orientation.landscape) {
        _pages.removeLast();
        notifyListeners();
      }
    } else if (reportViewModel.currentReport.value != null && _pages.last.name != ReportDetailsScreen.route) {
      reportViewModel.resetCurrentReport();
      if (MediaQuery.of(buildContext).orientation == Orientation.landscape) {
        _pages.removeLast();
        notifyListeners();
      }
    } else if (diaryViewModel.currentDiaryPage.value != null && _pages.last.name != DiaryPageScreen.route) {
      diaryViewModel.resetCurrentDiaryPage();
    } else {
      if (mapViewModel.currentExpert.value != null) {
        mapViewModel.resetCurrentExpert();
      } else if (chatViewModel.currentChat.value != null) {
        chatViewModel.resetCurrentChat();
      } else if (reportViewModel.currentReport.value != null) {
        reportViewModel.resetCurrentReport();
      } else if (diaryViewModel.currentDiaryPage.value != null) {
        diaryViewModel.resetCurrentDiaryPage();
      }
      if (!hasDialog) {
        _pages.removeLast();
        notifyListeners();
      }
    }
    return Future.value(true);
  }

  /// Returns the material page based on the [routeSettings.name].
  ///
  /// If [routeSettings.arguments] are present, it passes them to the material page.
  MaterialPage _createPage(RouteSettings routeSettings) {
    late Widget child;
    switch (routeSettings.name) {
      case WelcomeScreen.route:
        child = WelcomeScreen();
        break;
      case CredentialScreen.route:
        child = CredentialScreen();
        break;
      case ExpertsSignUpScreen.route:
        child = ExpertsSignUpScreen();
        break;
      case BaseUsersSignUpScreen.route:
        child = BaseUsersSignUpScreen();
        break;
      case ReportsListScreen.route:
        child = ReportsListScreen();
        break;
      case ReportDetailsScreen.route:
        child = ReportDetailsScreen();
        break;
      case CreateReportScreen.route:
        child = CreateReportScreen();
        break;
      case ExpertProfileScreen.route:
        child = ExpertProfileScreen();
        break;
      case MapScreen.route:
        child = MapScreen();
        break;
      case LoginScreen.route:
        child = LoginScreen();
        break;
      case ForgotPasswordScreen.route:
        child = ForgotPasswordScreen();
        break;
      case ExpertHomePageScreen.route:
        child = ExpertHomePageScreen(pageIndex: routeSettings.arguments as int?);
        break;
      case BaseUserHomePageScreen.route:
        child = BaseUserHomePageScreen(pageIndex: routeSettings.arguments as int?);
        break;
      case ChatPageScreen.route:
        child = ChatPageScreen();
        break;
      case ChatListScreen.route:
        child = ChatListScreen(chatListBody: routeSettings.arguments as Widget);
        break;
      case DiaryPageScreen.route:
        child = DiaryPageScreen();
        break;
    }
    return MaterialPage(
      child: child,
      key: Key(routeSettings.name! + routeSettings.arguments.toString()) as LocalKey?,
      name: routeSettings.name,
      arguments: routeSettings.arguments,
    );
  }

  /// Push the page specified by the [name] of the route on top of the navigator stack if
  /// the page or the arguments are not equal to the head of the stack.
  void pushPage({required String name, dynamic arguments}) {
    if (_pages.isEmpty || _pages.last.name != name || _pages.last.arguments.runtimeType != arguments.runtimeType) {
      _pages.add(_createPage(RouteSettings(name: name, arguments: arguments)));
      notifyListeners();
    }
  }

  /// It behaves exactly as [pushPage] but it doesn't call the [notifyListeners] method.
  void _addPage({required String name, dynamic arguments}) {
    if (_pages.isEmpty || _pages.last.name != name || _pages.last.arguments.runtimeType != arguments.runtimeType) {
      _pages.add(_createPage(RouteSettings(name: name, arguments: arguments)));
    }
  }

  /// Pop the top-most page off the navigator stack.
  void pop() {
    popRoute();
  }

  /// Get the top-most route of the navigator stack.
  Page getLastRoute() {
    return _pages.last;
  }

  /// Remove the top-most page of the navigator stack and the push the page specified by the [name] of the route.
  void replace({required String name, dynamic arguments}) {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    _addPage(name: name, arguments: arguments);
    notifyListeners();
  }

  /// Replace all the navigator stack with the pages specified by the [routeSettingsList].
  void replaceAll(List<RouteSettings> routeSettingsList) {
    if (routeSettingsList.isNotEmpty) {
      _pages.clear();
      for (var item in routeSettingsList) {
        _addPage(name: item.name!, arguments: item.arguments);
      }
      notifyListeners();
    }
  }

  /// Replace the navigator stack pages from [start] to the top with
  /// the pages specified by the [routeSettingsList].
  ///
  /// If the provided [start] is not valid, it only adds the pages of the [routeSettingsList]
  /// without removing any page ([start] is valid if 0 < start ≤ [length]).
  void replaceAllButNumber(int start, {List<RouteSettings> routeSettingsList = const []}) {
    if (start > 0 && start <= _pages.length && _pages.isNotEmpty) {
      _pages.removeRange(start, _pages.length);
    }
    for (var item in routeSettingsList) {
      _addPage(name: item.name!, arguments: item.arguments);
    }
    notifyListeners();
  }

  /// Function used only for testing purposes since it clears all the stack.
  ///
  /// **Do not call it outside the testing framework.**
  void clear() {
    _pages.clear();
    notifyListeners();
  }

  /// Return the navigator stack
  List<Page> get stack => _pages;

  @override
  Future<void> setNewRoutePath(configuration) async {/* Do Nothing */}
}
