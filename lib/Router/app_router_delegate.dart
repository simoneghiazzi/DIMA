import 'package:flutter/material.dart';
import 'package:sApport/ViewModel/Forms/base_user_signup_form.dart';
import 'package:sApport/Views/Map/map_screen.dart';
import 'package:sApport/Views/Diary/diary_screen.dart';
import 'package:sApport/Views/Login/login_screen.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Views/Welcome/welcome_screen.dart';
import 'package:sApport/Views/Diary/diary_page_screen.dart';
import 'package:sApport/Views/Signup/credential_screen.dart';
import 'package:sApport/Views/Report/reports_list_screen.dart';
import 'package:sApport/Views/Report/create_report_screen.dart';
import 'package:sApport/Views/Report/report_details_screen.dart';
import 'package:sApport/Views/Login/forgot_password_screen.dart';
import 'package:sApport/Views/Profile/expert_profile_screen.dart';
import 'package:sApport/Views/Settings/user_settings_screen.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:sApport/Views/Chat/ChatList/chat_list_screen.dart';
import 'package:sApport/Views/Home/Expert/expert_home_page_screen.dart';
import 'package:sApport/Views/Signup/Expert/experts_signup_screen.dart';
import 'package:sApport/Views/Signup/BaseUser/base_users_signup_screen.dart';
import 'package:sApport/Views/Home/BaseUser/base_user_home_page_screen.dart';

class AppRouterDelegate extends RouterDelegate<List<RouteSettings>> with ChangeNotifier, PopNavigatorRouterDelegateMixin<List<RouteSettings>> {
  // Stack of pages
  final _pages = <Page>[];

  @override
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
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
    if (_pages.length > 1 && _pages.last.name != BaseUserHomePageScreen.route && _pages.last.name != ExpertHomePageScreen.route) {
      _pages.removeLast();
      notifyListeners();
      return Future.value(true);
    }
    return Future.value(false);
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
        child = ExpertProfileScreen(expert: routeSettings.arguments as Expert);
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
      case UserSettingsScreen.route:
        child = UserSettingsScreen();
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
      case DiaryScreen.route:
        child = DiaryScreen();
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

  /// Push the page specified by the [name] of the route on top of the navigator stack.
  void pushPage({required String name, dynamic arguments}) {
    if (_pages.isEmpty || _pages.last.name != name || _pages.last.arguments != arguments) {
      _pages.add(_createPage(RouteSettings(name: name, arguments: arguments)));
      notifyListeners();
    }
  }

  /// Pop the top-most page off the navigator stack.
  void pop() {
    popRoute();
  }

  /// Get the top-most route of the navigator stack.
  String getLastRoute() {
    return _pages.last.name!;
  }

  /// Replace the top-most page of the navigator stack with the page specified by the [name] of the route.
  void replace({required String name, dynamic arguments}) {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    _pages.add(_createPage(RouteSettings(name: name, arguments: arguments)));
    notifyListeners();
  }

  /// Replace all the navigator stack with the page specified by the [name] of the route.
  void replaceAll({required String name, dynamic arguments}) {
    if (_pages.isNotEmpty) {
      _pages.clear();
    }
    _pages.add(_createPage(RouteSettings(name: name, arguments: arguments)));
    notifyListeners();
  }

  /// Replace the navigator stack pages from [start] to the top with the pages specified by the [routeSettingsList] of RouteSettings.
  void replaceAllButNumber(int start, {List<RouteSettings> routeSettingsList = const []}) {
    if (_pages.isNotEmpty) {
      _pages.removeRange(start, _pages.length);
    }
    if (routeSettingsList.isNotEmpty) {
      routeSettingsList.forEach((item) {
        _pages.add(_createPage(RouteSettings(name: item.name, arguments: item.arguments)));
      });
    }
    notifyListeners();
  }

  /// Replace all the navigator stack with the pages specified by the [list] of RouteSettings.
  void addAll(List<RouteSettings> list) {
    _pages.clear();
    list.forEach((item) {
      _pages.add(_createPage(RouteSettings(name: item.name, arguments: item.arguments)));
    });
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(configuration) async {/* Do Nothing */}
}
