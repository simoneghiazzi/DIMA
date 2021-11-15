import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_info_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/user_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/BaseUser/AnonymousChat/ActiveChatsList/active_chats_list_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/BaseUser/AnonymousChat/PendingChatsList/pending_chats_list_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/BaseUser/ChatWithExperts/expert_chats_list_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/ExpertUser/active_chats_experts_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Diary/diary_page_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Diary/diary_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/BaseUser/base_user_home_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Login/login_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Map/map_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Profile/expert_profile_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Report/create_report_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Report/reports_list_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Settings/user_profile_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/BaseUser/base_users_signup_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/Expert/experts_signup_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/credential_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Welcome/welcome_screen.dart';

import 'package:flutter/material.dart';

class InfoArguments {
  final BaseUserInfoViewModel userInfoViewModel;
  final UserViewModel userViewModel;

  InfoArguments(this.userInfoViewModel, this.userViewModel);
}

class AppRouterDelegate extends RouterDelegate<List<RouteSettings>>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<List<RouteSettings>> {
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

  bool _onPopPage(Route route, dynamic result) {
    if (!route.didPop(result)) return false;
    popRoute();
    return true;
  }

  @override
  Future<bool> popRoute() {
    if (_pages.length > 1 &&
        _pages.last.name != BaseUserHomeScreen.route &&
        _pages.last.name != ActiveChatsExpertsScreen.route) {
      _pages.removeLast();
      notifyListeners();
      return Future.value(true);
    }
    return Future.value(false);
  }

  MaterialPage _createPage(RouteSettings routeSettings) {
    Widget child;
    switch (routeSettings.name) {
      case WelcomeScreen.route:
        child = WelcomeScreen();
        break;
      case CredentialScreen.route:
        child = CredentialScreen(
            infoViewModel:
                (routeSettings.arguments as InfoArguments).userInfoViewModel,
            userViewModel:
                (routeSettings.arguments as InfoArguments).userViewModel);
        break;
      case ExpertsSignUpScreen.route:
        child = ExpertsSignUpScreen();
        break;
      case BaseUsersSignUpScreen.route:
        child = BaseUsersSignUpScreen();
        break;
      case ReportsListScreen.route:
        child = ReportsListScreen(
          reportViewModel: routeSettings.arguments,
        );
        break;
      case CreateReportScreen.route:
        child = CreateReportScreen();
        break;
      case ExpertProfileScreen.route:
        child = ExpertProfileScreen(expert: routeSettings.arguments);
        break;
      case MapScreen.route:
        child = MapScreen();
        break;
      case LoginScreen.route:
        child = LoginScreen();
        break;
      case UserProfileScreen.route:
        child = UserProfileScreen(user: routeSettings.arguments);
        break;
      case ActiveChatsExpertsScreen.route:
        child = ActiveChatsExpertsScreen();
        break;
      case BaseUserHomeScreen.route:
        child = BaseUserHomeScreen(
          pageIndex: routeSettings.arguments,
        );
        break;
      case ChatPageScreen.route:
        child = ChatPageScreen();
        break;
      case ExpertChatsListScreen.route:
        child = ExpertChatsListScreen();
        break;
      case PendingChatsListScreen.route:
        child = PendingChatsListScreen();
        break;
      case ActiveChatsListScreen.route:
        child = ActiveChatsListScreen();
        break;
      case DiaryScreen.route:
        child = DiaryScreen();
        break;
      case DiaryPageScreen.route:
        child = DiaryPageScreen(
          diaryNote: routeSettings.arguments,
        );
        break;
    }
    return MaterialPage(
      child: child,
      key: Key(routeSettings.name),
      name: routeSettings.name,
      arguments: routeSettings.arguments,
    );
  }

  void pushPage({@required String name, dynamic arguments}) {
    if (_pages.isEmpty || _pages.last.name != name) {
      _pages.add(_createPage(RouteSettings(name: name, arguments: arguments)));
      notifyListeners();
    }
  }

  void pop() {
    popRoute();
  }

  void replace({@required String name, dynamic arguments}) {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    _pages.add(_createPage(RouteSettings(name: name, arguments: arguments)));
    notifyListeners();
  }

  void replaceAll({@required String name, dynamic arguments}) {
    if (_pages.isNotEmpty) {
      _pages.clear();
    }
    _pages.add(_createPage(RouteSettings(name: name, arguments: arguments)));
    notifyListeners();
  }

  void replaceAllButNumber(int start, List<RouteSettings> list) {
    if (_pages.isNotEmpty) {
      _pages.removeRange(start, _pages.length);
    }
    list.forEach((item) {
      _pages.add(_createPage(
          RouteSettings(name: item.name, arguments: item.arguments)));
    });
    notifyListeners();
  }

  void addAll(List<RouteSettings> list) {
    _pages.clear();
    list.forEach((item) {
      _pages.add(_createPage(
          RouteSettings(name: item.name, arguments: item.arguments)));
    });
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(configuration) async {/* Do Nothing */}
}
