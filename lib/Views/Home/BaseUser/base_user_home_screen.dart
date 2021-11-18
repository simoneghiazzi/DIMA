import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Diary/diary_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/BaseUser/components/base_user_home_page.dart';
import 'package:dima_colombo_ghiazzi/Views/Settings/user_profile_screen.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BaseUserHomeScreen extends StatefulWidget {
  static const route = '/baseUserHomeScreen';
  final int pageIndex;

  BaseUserHomeScreen({Key key, @required this.pageIndex}) : super(key: key);

  @override
  _BaseUserHomeScreenState createState() => _BaseUserHomeScreenState();
}

class _BaseUserHomeScreenState extends State<BaseUserHomeScreen> {
  int _currentIndex;

  @override
  void initState() {
    _currentIndex = widget.pageIndex ?? 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var baseUserViewModel =
        Provider.of<BaseUserViewModel>(context, listen: false);
    var authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    authViewModel.setNotification(baseUserViewModel.loggedUser);
    final List<Widget> _pages = [
      BaseUserHomePage(),
      DiaryScreen(),
      UserProfileScreen(user: baseUserViewModel.loggedUser)
    ];
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
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
                BottomNavigationBarItem(
                    icon: Icon(Icons.menu_book), label: 'Diary'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'Profile')
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
