import 'package:dima_colombo_ghiazzi/ViewModel/Expert/expert_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/Expert/components/expert_home_page_body.dart';
import 'package:dima_colombo_ghiazzi/Views/Settings/user_profile_screen.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpertHomePageScreen extends StatefulWidget {
  static const route = '/expertHomePageScreen';
  final int pageIndex;

  ExpertHomePageScreen({Key key, @required this.pageIndex}) : super(key: key);

  @override
  _ExpertHomePageScreenState createState() => _ExpertHomePageScreenState();
}

class _ExpertHomePageScreenState extends State<ExpertHomePageScreen> {
  int _currentIndex;

  @override
  void initState() {
    _currentIndex = widget.pageIndex ?? 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var expertViewModel = Provider.of<ExpertViewModel>(context, listen: false);
    var authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    authViewModel.setNotification(expertViewModel.loggedUser);
    final List<Widget> _pages = [
      ExpertHomePageBody(),
      //Claendar(),
      UserProfileScreen(user: expertViewModel.loggedUser)
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
                  icon: Icon(Icons.chat),
                  label: 'Chats',
                ),
                // BottomNavigationBarItem(
                //     icon: Icon(Icons.menu_book), label: 'Diary'),
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
