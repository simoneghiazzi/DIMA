import 'package:sApport/Model/user.dart';
import 'package:sApport/Model/Expert/expert.dart';
import 'package:sApport/Model/BaseUser/base_user.dart';
import 'package:sApport/Views/Home/Expert/expert_home_page_screen.dart';
import 'package:sApport/Views/Home/BaseUser/base_user_home_page_screen.dart';

// DB Collections
enum Collection {
  BASE_USERS,
  EXPERTS,
  REPORTS,
  MESSAGES,
  UTILS,
  ACTIVE_CHATS,
  PENDING_CHATS,
  REQUESTS_CHATS,
  EXPERT_CHATS,
  DIARY,
}

extension Utils on Collection {
  /// Returns the name of the collection saved into the DB
  String get value {
    switch (this) {
      case Collection.BASE_USERS:
        return "users";
        break;
      case Collection.EXPERTS:
        return "experts";
        break;
      case Collection.REPORTS:
        return "reports";
        break;
      case Collection.MESSAGES:
        return "messages";
        break;
      case Collection.UTILS:
        return "utils";
        break;
      case Collection.ACTIVE_CHATS:
        return "anonymousActiveChats";
        break;
      case Collection.PENDING_CHATS:
        return "anonymousPendingChats";
        break;
      case Collection.REQUESTS_CHATS:
        return "anonymousRequestChats";
        break;
      case Collection.EXPERT_CHATS:
        return "expertChats";
        break;
      case Collection.DIARY:
        return "diary";
        break;
      default:
        return "";
        break;
    }
  }

  /// Returns the [User] model of the relative user collections
  User get userModel {
    switch (this) {
      case Collection.BASE_USERS:
        return BaseUser();
        break;
      case Collection.EXPERTS:
        return Expert();
        break;
      default:
        return null;
        break;
    }
  }

  /// Returns the home page route of the relative user collections
  String get homePageRoute {
    switch (this) {
      case Collection.BASE_USERS:
        return BaseUserHomePageScreen.route;
        break;
      case Collection.EXPERTS:
        return ExpertHomePageScreen.route;
        break;
      default:
        return "";
        break;
    }
  }
}
