import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Views/Settings/user_settings_screen.dart';
import 'package:sApport/Views/Chat/ChatList/chat_list_screen.dart';
import 'package:sApport/Views/Chat/ChatList/components/active_chat_list_body.dart';

/// Home page of the [Expert].
///
/// It contains the [BottomNavigationBar] with 2 pages: the [ChatListScreen] with
/// the [ActiveChatListBody] and the [UserSettingsScreen].
///
/// When it is initialized, it loads all the stream of the view models of the [Expert].
///
/// It also takes the [pageIndex] that indicates which pages of the navigation bar it has to show.
class ExpertHomePageScreen extends StatefulWidget {
  /// Route of the page used by the Navigator.
  static const route = "/expertHomePageScreen";
  final int? pageIndex;

  /// Home page of the [Expert].
  ///
  /// It contains the [BottomNavigationBar] with 2 pages: the [ChatListScreen] with
  /// the [ActiveChatListBody] and the [UserSettingsScreen].
  ///
  /// When it is initialized, it loads all the stream of the view models of the [Expert].
  ///
  /// It also takes the [pageIndex] that indicates which pages of the navigation bar it has to show.
  const ExpertHomePageScreen({Key? key, required this.pageIndex}) : super(key: key);

  @override
  _ExpertHomePageScreenState createState() => _ExpertHomePageScreenState();
}

class _ExpertHomePageScreenState extends State<ExpertHomePageScreen> {
  // View Models
  late ChatViewModel chatViewModel;

  // Pages of the bottom navigation bar initialization
  late List<Widget> _pages;

  late int _currentIndex;

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);

    // Chat View Model stream initialization
    chatViewModel.loadActiveChats();

    // Initialization of the pages of the bottom navigation bar
    _pages = [ChatListScreen(chatListBody: ActiveChatListBody()), const UserSettingsScreen()];

    _currentIndex = widget.pageIndex ?? 0;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        unselectedItemColor: kPrimaryColor,
        selectedItemColor: kPrimaryMediumColor,
        onTap: _onBottomNavTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chats"),
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
