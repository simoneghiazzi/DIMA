import 'package:sApport/ViewModel/BaseUser/base_user_view_model.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/Views/Diary/diary_screen.dart';
import 'package:sApport/Views/Home/BaseUser/components/base_user_home_page_body.dart';
import 'package:sApport/Views/Settings/user_settings_screen.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BaseUserHomePageScreen extends StatefulWidget {
  static const route = '/baseUserHomePageScreen';
  final int pageIndex;

  BaseUserHomePageScreen({Key key, @required this.pageIndex}) : super(key: key);

  @override
  _BaseUserHomePageScreenState createState() => _BaseUserHomePageScreenState();
}

class _BaseUserHomePageScreenState extends State<BaseUserHomePageScreen> {
  BaseUserViewModel baseUserViewModel;
  AuthViewModel authViewModel;
  int _currentIndex;

  @override
  void initState() {
    baseUserViewModel = Provider.of<BaseUserViewModel>(context, listen: false);
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    authViewModel.setNotification(baseUserViewModel.loggedUser);
    _currentIndex = widget.pageIndex ?? 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var baseUserViewModel = Provider.of<BaseUserViewModel>(context, listen: false);
    var authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    authViewModel.setNotification(baseUserViewModel.loggedUser);
    final List<Widget> _pages = [BaseUserHomePageBody(), DiaryScreen(), UserSettingsScreen(user: baseUserViewModel.loggedUser)];
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
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
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Diary'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile')
              ]),
        ));
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      FocusScope.of(context).unfocus();
      _currentIndex = index;
    });
  }
}
