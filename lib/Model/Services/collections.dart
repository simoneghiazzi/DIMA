enum Collection {
  USERS,
  EXPERTS,
  REPORTS,
  MESSAGES,
  UTILS,
  ACTIVE_CHATS,
  PENDING_CHATS,
  REQUESTS_CHATS,
  EXPERT_CHATS
}

extension Utils on Collection {
  String get value {
    switch (this) {
      case Collection.USERS:
        return 'users';
        break;
      case Collection.EXPERTS:
        return 'experts';
        break;
      case Collection.REPORTS:
        return 'reports';
        break;
      case Collection.MESSAGES:
        return 'messages';
        break;
      case Collection.UTILS:
        return 'utils';
        break;
      case Collection.ACTIVE_CHATS:
        return 'anonymousActiveChats';
        break;
      case Collection.PENDING_CHATS:
        return 'anonymousPendingChats';
        break;
      case Collection.REQUESTS_CHATS:
        return 'anonymousRequestChats';
        break;
      case Collection.EXPERT_CHATS:
        return 'expertChats';
        break;
      default:
        return '';
        break;
    }
  }
}
