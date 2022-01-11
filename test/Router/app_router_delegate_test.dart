import 'package:mockito/annotations.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Views/Chat/ChatList/components/expert_chat_list_body.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:sApport/Views/Login/forgot_password_screen.dart';
import 'package:sApport/Views/Profile/expert_profile_screen.dart';
import 'package:test/test.dart';
import 'package:flutter/material.dart';
import 'package:sApport/Views/Map/map_screen.dart';
import 'package:sApport/Views/Login/login_screen.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/Welcome/welcome_screen.dart';
import 'package:sApport/Views/Diary/diary_page_screen.dart';
import 'package:sApport/Views/Signup/credential_screen.dart';
import 'package:sApport/Views/Report/reports_list_screen.dart';
import 'package:sApport/Views/Report/create_report_screen.dart';
import 'package:sApport/Views/Chat/ChatList/chat_list_screen.dart';
import 'package:sApport/Views/Home/Expert/expert_home_page_screen.dart';
import 'package:sApport/Views/Signup/Expert/experts_signup_screen.dart';
import 'package:sApport/Views/Home/BaseUser/base_user_home_page_screen.dart';
import 'package:sApport/Views/Signup/BaseUser/base_users_signup_screen.dart';
import 'package:sApport/Views/Chat/ChatList/components/pending_chat_list_body.dart';
import 'package:sApport/Views/Chat/ChatList/components/anonymous_chat_list_body.dart';

@GenerateMocks([AppRouterDelegate])
void main() async {
  final routerDelegate = AppRouterDelegate();
  int callbackCounter = 0;

  group("Router delegate initialization:", () {
    test("Check that hasDialog is initially set to false", () {
      expect(routerDelegate.hasDialog, false);
    });

    test("Check that the navigator key is initially setted", () {
      expect(routerDelegate.navigatorKey, isNotNull);
      expect(routerDelegate.navigatorKey, isA<GlobalKey>());
    });
  });

  group("Router delegate navigation methods:", () {
    setUp(() {
      routerDelegate.clear();
      callbackCounter = 0;
    });

    /// Add a listener counter to the routerDelegate
    routerDelegate.addListener(() => callbackCounter++);

    group("Push page:", () {
      test("Push page should add a new page on top of the stack", () {
        routerDelegate.pushPage(name: BaseUserHomePageScreen.route);

        expect(routerDelegate.stack.last.name, BaseUserHomePageScreen.route);
      });

      test("Push page should not add a page if the page or the arguments are equal to the page that is the head of the stack", () {
        /// Try to add the same page
        routerDelegate.pushPage(name: BaseUserHomePageScreen.route);
        routerDelegate.pushPage(name: BaseUserHomePageScreen.route);

        /// Only one page should be added
        expect(routerDelegate.stack.length, 1);

        /// Try to add the same page with the same arguments
        routerDelegate.pushPage(name: ChatListScreen.route, arguments: AnonymousChatListBody());
        routerDelegate.pushPage(name: ChatListScreen.route, arguments: AnonymousChatListBody());

        /// Only one page should be added
        expect(routerDelegate.stack.length, 2);

        /// Try to add the same page but with different arguments
        routerDelegate.pushPage(name: ChatListScreen.route, arguments: PendingChatListBody());

        /// Both the pages are added
        expect(routerDelegate.stack.length, 3);
      });

      test("Push page should notify the listeners when a page is added", () {
        routerDelegate.pushPage(name: BaseUserHomePageScreen.route);
        routerDelegate.pushPage(name: ChatListScreen.route, arguments: AnonymousChatListBody());

        expect(callbackCounter, 2);
      });
    });

    group("Pop page:", () {
      test("Pop page should remove the head of the stack if it is not empty", () {
        routerDelegate.pushPage(name: BaseUserHomePageScreen.route);
        routerDelegate.pushPage(name: ChatListScreen.route, arguments: AnonymousChatListBody());

        routerDelegate.pop();

        expect(routerDelegate.stack.length, 1);
        expect(routerDelegate.stack.last.name, BaseUserHomePageScreen.route);
      });

      test("Pop page should not remove the head of the stack if there is only one page in the stack", () {
        routerDelegate.pushPage(name: WelcomeScreen.route);

        routerDelegate.pop();

        expect(routerDelegate.stack.length, 1);
        expect(routerDelegate.stack.last.name, WelcomeScreen.route);
      });

      test("Pop page should not remove the head of the stack if the page is the BaseUserHomePageScreen", () {
        routerDelegate.pushPage(name: WelcomeScreen.route);
        routerDelegate.pushPage(name: BaseUserHomePageScreen.route);

        routerDelegate.pop();

        expect(routerDelegate.stack.length, 2);
        expect(routerDelegate.stack.last.name, BaseUserHomePageScreen.route);
      });

      test("Pop page should not remove the head of the stack if the page is the ExpertHomePageScreen", () {
        routerDelegate.pushPage(name: WelcomeScreen.route);
        routerDelegate.pushPage(name: ExpertHomePageScreen.route);

        routerDelegate.pop();

        expect(routerDelegate.stack.length, 2);
        expect(routerDelegate.stack.last.name, ExpertHomePageScreen.route);
      });

      test("Pop page should notify the listeners when a page is removed", () {
        routerDelegate.pushPage(name: BaseUserHomePageScreen.route);
        routerDelegate.pushPage(name: ChatListScreen.route, arguments: AnonymousChatListBody());

        routerDelegate.pop();

        /// 3 = 2 push + 1 pop
        expect(callbackCounter, 3);
      });
    });

    group("Get last route:", () {
      test("Get last route should return the top-most page of the stack", () {
        var anonymousChatListBody = AnonymousChatListBody();
        routerDelegate.pushPage(name: BaseUserHomePageScreen.route);
        routerDelegate.pushPage(name: ChatListScreen.route, arguments: anonymousChatListBody);

        expect(routerDelegate.getLastRoute().name, ChatListScreen.route);
        expect(routerDelegate.getLastRoute().arguments, anonymousChatListBody);

        routerDelegate.pop();

        expect(routerDelegate.getLastRoute().name, BaseUserHomePageScreen.route);
      });
    });

    group("Replace:", () {
      test("Replace should remove the top-most page of the stack and then push the new page", () {
        routerDelegate.pushPage(name: BaseUserHomePageScreen.route);
        routerDelegate.pushPage(name: ChatListScreen.route, arguments: AnonymousChatListBody());

        routerDelegate.replace(name: CreateReportScreen.route);

        expect(routerDelegate.stack.length, 2);
        expect(routerDelegate.stack.last.name, CreateReportScreen.route);
      });

      test("Replace should not push the new page if the new head after the pop is equal to the new page", () {
        routerDelegate.pushPage(name: BaseUserHomePageScreen.route);
        routerDelegate.pushPage(name: ChatListScreen.route, arguments: AnonymousChatListBody());

        routerDelegate.replace(name: BaseUserHomePageScreen.route);

        expect(routerDelegate.stack.length, 1);
      });

      test("Replace should notify the listeners when the head of the stack is changed", () {
        routerDelegate.pushPage(name: BaseUserHomePageScreen.route);
        routerDelegate.pushPage(name: ChatListScreen.route, arguments: ExpertChatListBody());
        routerDelegate.pushPage(name: ExpertProfileScreen.route, arguments: Expert());

        routerDelegate.replace(name: MapScreen.route);

        /// 4 = 3 push + 1 replace
        expect(callbackCounter, 4);
      });
    });

    group("Replace all:", () {
      test("Replace all should clear all the stack and add the list of pages provided", () {
        routerDelegate.pushPage(name: WelcomeScreen.route);
        routerDelegate.pushPage(name: BaseUsersSignUpScreen.route);
        routerDelegate.pushPage(name: CredentialScreen.route);

        routerDelegate.replaceAll([
          RouteSettings(name: ExpertsSignUpScreen.route),
          RouteSettings(name: CredentialScreen.route),
        ]);

        var expectedRoutes = [ExpertsSignUpScreen.route, CredentialScreen.route];

        expect(routerDelegate.stack.length, 2);
        for (int i = 0; i < expectedRoutes.length; i++) {
          expect(routerDelegate.stack[i].name, expectedRoutes[i]);
        }
      });

      test("Replace all should not modify the stack if the list provided is empty", () {
        routerDelegate.pushPage(name: WelcomeScreen.route);
        routerDelegate.pushPage(name: BaseUsersSignUpScreen.route);
        routerDelegate.pushPage(name: CredentialScreen.route);

        routerDelegate.replaceAll([]);

        var expectedRoutes = [WelcomeScreen.route, BaseUsersSignUpScreen.route, CredentialScreen.route];

        expect(routerDelegate.stack.length, 3);
        for (int i = 0; i < expectedRoutes.length; i++) {
          expect(routerDelegate.stack[i].name, expectedRoutes[i]);
        }
      });

      test("Replace all should add only one page from the provided list if 2 pages are equals", () {
        routerDelegate.pushPage(name: WelcomeScreen.route);
        routerDelegate.pushPage(name: BaseUsersSignUpScreen.route);
        routerDelegate.pushPage(name: CredentialScreen.route);

        routerDelegate.replaceAll([RouteSettings(name: ExpertsSignUpScreen.route), RouteSettings(name: ExpertsSignUpScreen.route)]);

        expect(routerDelegate.stack.length, 1);
        expect(routerDelegate.stack.first.name, ExpertsSignUpScreen.route);
      });

      test("Replace all should notify the listeners when the stack is changed", () {
        routerDelegate.pushPage(name: BaseUserHomePageScreen.route, arguments: 1);
        routerDelegate.pushPage(name: DiaryPageScreen.route);

        routerDelegate.replaceAll([RouteSettings(name: WelcomeScreen.route)]);

        /// 3 = 2 push + 1 replace all
        expect(callbackCounter, 3);
      });
    });

    group("Replace all but number:", () {
      test("Replace all but number should remove all the pages from start to the head of the stack and add the list of pages provided", () {
        routerDelegate.pushPage(name: WelcomeScreen.route);
        routerDelegate.pushPage(name: BaseUserHomePageScreen.route);
        routerDelegate.pushPage(name: CreateReportScreen.route);
        routerDelegate.pushPage(name: ReportsListScreen.route);
        routerDelegate.pushPage(name: ReportsListScreen.route);

        routerDelegate.replaceAllButNumber(2, routeSettingsList: [RouteSettings(name: ChatPageScreen.route)]);

        var expectedRoutes = [WelcomeScreen.route, BaseUserHomePageScreen.route, ChatPageScreen.route];

        expect(routerDelegate.stack.length, 3);
        for (int i = 0; i < expectedRoutes.length; i++) {
          expect(routerDelegate.stack[i].name, expectedRoutes[i]);
        }
      });

      test("Replace all but number should return without changing the stack if the start index is not valid", () {
        routerDelegate.pushPage(name: WelcomeScreen.route);
        routerDelegate.pushPage(name: LoginScreen.route);
        routerDelegate.pushPage(name: ForgotPasswordScreen.route);

        routerDelegate.replaceAllButNumber(2, routeSettingsList: []);

        var expectedRoutes = [WelcomeScreen.route, LoginScreen.route];

        expect(routerDelegate.stack.length, 2);
        for (int i = 0; i < expectedRoutes.length; i++) {
          expect(routerDelegate.stack[i].name, expectedRoutes[i]);
        }

        routerDelegate.replaceAllButNumber(0, routeSettingsList: []);

        expect(routerDelegate.stack.length, 2);
        for (int i = 0; i < expectedRoutes.length; i++) {
          expect(routerDelegate.stack[i].name, expectedRoutes[i]);
        }

        routerDelegate.replaceAllButNumber(-1, routeSettingsList: []);

        expect(routerDelegate.stack.length, 2);
        for (int i = 0; i < expectedRoutes.length; i++) {
          expect(routerDelegate.stack[i].name, expectedRoutes[i]);
        }
      });

      test("Replace all but number should add only one page from the provided list if 2 pages are equals", () {
        routerDelegate.pushPage(name: WelcomeScreen.route);
        routerDelegate.pushPage(name: BaseUsersSignUpScreen.route);
        routerDelegate.pushPage(name: CredentialScreen.route);

        routerDelegate.replaceAllButNumber(1, routeSettingsList: [
          RouteSettings(name: ExpertsSignUpScreen.route),
          RouteSettings(name: ExpertsSignUpScreen.route),
        ]);

        var expectedRoutes = [WelcomeScreen.route, ExpertsSignUpScreen.route];

        expect(routerDelegate.stack.length, 2);
        for (int i = 0; i < expectedRoutes.length; i++) {
          expect(routerDelegate.stack[i].name, expectedRoutes[i]);
        }
      });

      test("Replace all but number should not add a page from the list if the new head of the stack is equal to that page", () {
        routerDelegate.pushPage(name: WelcomeScreen.route);
        routerDelegate.pushPage(name: BaseUsersSignUpScreen.route);
        routerDelegate.pushPage(name: CredentialScreen.route);

        routerDelegate.replaceAllButNumber(1, routeSettingsList: [
          RouteSettings(name: WelcomeScreen.route),
          RouteSettings(name: ExpertsSignUpScreen.route),
        ]);

        var expectedRoutes = [WelcomeScreen.route, ExpertsSignUpScreen.route];

        expect(routerDelegate.stack.length, 2);
        for (int i = 0; i < expectedRoutes.length; i++) {
          expect(routerDelegate.stack[i].name, expectedRoutes[i]);
        }
      });

      test("Replace all but number should notify the listeners when the stack is changed", () {
        routerDelegate.pushPage(name: WelcomeScreen.route);
        routerDelegate.pushPage(name: BaseUserHomePageScreen.route);
        routerDelegate.pushPage(name: CreateReportScreen.route);
        routerDelegate.pushPage(name: ReportsListScreen.route);

        routerDelegate.replaceAllButNumber(2, routeSettingsList: [RouteSettings(name: MapScreen.route)]);

        /// 5 = 4 push + 1 replace all but number
        expect(callbackCounter, 5);
      });
    });
  });
}
