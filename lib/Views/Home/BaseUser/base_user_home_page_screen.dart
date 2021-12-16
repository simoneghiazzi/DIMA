import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Views/Diary/diary_screen.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/Views/Settings/user_settings_screen.dart';
import 'package:sApport/Views/Home/BaseUser/components/base_user_home_page_body.dart';

class BaseUserHomePageScreen extends StatefulWidget {
  static const route = '/baseUserHomePageScreen';
  final int pageIndex;

  /// The [pageIndex] indicates the tab to show
  BaseUserHomePageScreen({Key key, @required this.pageIndex}) : super(key: key);

  @override
  _BaseUserHomePageScreenState createState() => _BaseUserHomePageScreenState();
}

class _BaseUserHomePageScreenState extends State<BaseUserHomePageScreen> {
  UserViewModel userViewModel;
  AuthViewModel authViewModel;
  DiaryViewModel diaryViewModel;
  int _currentIndex;

  @override
  void initState() {
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    diaryViewModel = Provider.of<DiaryViewModel>(context, listen: false);

    // Register the notification service
    authViewModel.setNotification(userViewModel.loggedUser);

    _currentIndex = widget.pageIndex ?? 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = const [
      const BaseUserHomePageBody(),
      const DiaryScreen(),
      const UserSettingsScreen(),
    ];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        unselectedItemColor: kPrimaryColor,
        selectedItemColor: kPrimaryMediumColor,
        onTap: _onBottomNavTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Diary'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile')
        ],
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    if (diaryViewModel.currentDiaryPage != null) {
      diaryViewModel.resetCurrentDiaryPage();
    }
    setState(() {
      FocusScope.of(context).unfocus();
      _currentIndex = index;
    });
  }
}
