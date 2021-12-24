import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Views/Diary/diary_screen.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Views/Settings/user_settings_screen.dart';
import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';
import 'package:sApport/Views/Home/BaseUser/components/base_user_home_page_body.dart';

/// Home page of the [BaseUser].
///
/// It contains the [BottomNavigationBar] with 3 pages: the [BaseUserHomePageBody],
/// the [DiaryScreen] and the [UserSettingsScreen].
///
/// When it is initialized, it loads all the stream of the view models of the [BaseUser].
///
/// It also takes the [pageIndex] that indicates which pages of the navigation bar it has to show.
class BaseUserHomePageScreen extends StatefulWidget {
  /// Route of the page used by the Navigator.
  static const route = "/baseUserHomePageScreen";
  final int? pageIndex;

  /// Home page of the [BaseUser].
  ///
  /// It contains the [BottomNavigationBar] with 3 pages: the [BaseUserHomePageBody],
  /// the [DiaryScreen] and the [UserSettingsScreen].
  ///
  /// When it is initialized, it loads all the stream of the view models of the [BaseUser].
  ///
  /// It also takes the [pageIndex] that indicates which pages of the navigation bar it has to show.
  BaseUserHomePageScreen({Key? key, this.pageIndex}) : super(key: key);

  @override
  _BaseUserHomePageScreenState createState() => _BaseUserHomePageScreenState();
}

class _BaseUserHomePageScreenState extends State<BaseUserHomePageScreen> {
  // View Models
  late UserViewModel userViewModel;
  late AuthViewModel authViewModel;
  late DiaryViewModel diaryViewModel;
  late ChatViewModel chatViewModel;
  late ReportViewModel reportViewModel;

  // Router Delegate
  late AppRouterDelegate routerDelegate;

  // Pages of the bottom navigation bar initialization
  late List<Widget> _pages;

  late int _currentIndex;

  @override
  void initState() {
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    diaryViewModel = Provider.of<DiaryViewModel>(context, listen: false);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    reportViewModel = Provider.of<ReportViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);

    // Chat View Model streams initialization
    chatViewModel.loadAnonymousChats();
    chatViewModel.loadPendingChats();
    chatViewModel.loadExpertsChats();

    // Chat View Model stream initialization
    diaryViewModel.loadDiaryPages();

    // Report View Model stream initialization
    //reportViewModel.loadReports();

    // Register the notification service
    authViewModel.setNotification(userViewModel.loggedUser!);

    // Initialization of the pages of the bottom navigation bar
    _pages = const [BaseUserHomePageBody(), DiaryScreen(), UserSettingsScreen()];

    _currentIndex = widget.pageIndex ?? 0;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        unselectedItemColor: kPrimaryColor,
        selectedItemColor: kPrimaryMediumColor,
        onTap: _onBottomNavTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Diary"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Settings")
        ],
      ),
    );
  }

  /// Function called when the user change the current page from the the bottom navigation bar.
  ///
  /// It sets the new [_currentIndex] of the [IndexedStack].
  void _onBottomNavTapped(int index) {
    setState(() {
      FocusScope.of(context).unfocus();
      _currentIndex = index;
    });
  }
}
