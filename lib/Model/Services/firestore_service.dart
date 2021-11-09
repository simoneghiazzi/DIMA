import 'dart:collection';
import 'package:collection/collection.dart';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/Diary/note.dart';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/base_user.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/active_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/conversation.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/pending_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/request.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/collections.dart';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/report.dart';
import 'package:dima_colombo_ghiazzi/Model/user.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Service used by the view models to interact with the Firestore DB
class FirestoreService {
  // Firestore instance
  final _firestore = FirebaseFirestore.instance;
  // Limit of returned instances from the DB by the queries
  int _limit = 30;

  /***************************************** USERS *****************************************/

  /// Add a user into the firestore DB.
  /// It takes the [user] and based on the type it adds him/her to the list of experts or to the list
  /// of users and it increments the collection counter.
  Future<void> addUserIntoDB(User user) async {
    var userReference =
        _firestore.collection(user.collection.value).doc(user.id);
    await _firestore.runTransaction((transaction) async {
      transaction.set(userReference, user.getData());
      await _incrementBaseUsersCounter(transaction, 1);
    });
  }

  /// Delete a user from the firestore DB.
  /// It takes the [user] and based on the type it deletes him/her from the list of experts or from the list
  /// of users and it decrements the collection counter.
  Future<void> removeUserFromDB(User user) async {
    var userReference =
        _firestore.collection(user.collection.value).doc(user.id);
    await _firestore.runTransaction((transaction) async {
      transaction.delete(userReference);
      await _incrementBaseUsersCounter(transaction, -1);
    });
  }

  /// It takes a [user] and updates the specified [field] with the [newValue] into the DB
  Future<void> updateUserFieldIntoDB(User user, String field, newValue) async {
    await _firestore
        .collection(user.collection.value)
        .doc(user.id)
        .update({field: newValue});
  }

  /// Get the list of all the doc in [collection] from the DB
  Future<QuerySnapshot> getBaseCollectionFromDB(Collection collection) async {
    return await _firestore.collection(collection.value).get();
  }

  /// It takes the [id] and the [collection] and returns a doc instance with
  /// all the information of the retrieved user
  Future<DocumentSnapshot> getUserByIdFromDB(
      Collection collection, String id) async {
    var snap = await _firestore
        .collection(collection.value)
        .where(FieldPath.documentId, isEqualTo: id)
        .get();
    if (snap.docs.isNotEmpty) return snap.docs[0];
    return null;
  }

  /// It takes the [list] of ids and the [collection] (users/experts)
  /// and returns a list of docs with all the information of the retrieved users
  Future<List> _getUsersByList(Collection collection, List list) async {
    var snap = await _firestore
        .collection(collection.value)
        .where(FieldPath.documentId, whereIn: list)
        .get();
    return List.from(snap.docs);
  }

  /// It takes the [increment] amount and increments the user's counter into the DB
  /// within the [transaction]
  Future<void> _incrementBaseUsersCounter(
      Transaction transaction, int increment) async {
    var utilsReference = _firestore
        .collection(Collection.BASE_USERS.value)
        .doc(Collection.UTILS.value);
    var utils = await transaction.get(utilsReference);
    int counter;
    utils.data() != null ? counter = utils.get('userCounter') : counter = 0;
    transaction.set(utilsReference, {'userCounter': counter + increment});
  }

  /// Get the counter of the intances of base users from the DB
  Future<int> _getBaseUsersCounter() async {
    var utils = await _firestore
        .collection(Collection.BASE_USERS.value)
        .doc(Collection.UTILS.value)
        .get();
    return utils.get('userCounter');
  }

  /// Get random user from the DB. It takes the [user] and the auto-generated [randomId] and it returns a Future BaseUser instance
  // 1. Check if the number of chats of the user is less than the total number of users, if not return null
  // 2. Get all the active, pending and request chat ids set
  // 3. Take the list of the first _limit users with the id <= randomId and id > randomId and sample a random
  // user id that is not the sender him/herself or that is not in the list of active/pending chat ids
  Future<BaseUser> getRandomUserFromDB(BaseUser user, String randomId) async {
    if (await _getBaseUsersCounter() - 1 < await _getChatsCounterFromDB(user)) {
      return null;
    }
    HashSet<String> activeIds = await _getChatIdsSet(user, ActiveChat());
    HashSet<String> pendingIds = await _getChatIdsSet(user, PendingChat());
    HashSet<String> requests = await _getChatIdsSet(user, Request());
    var snapshotLess = await _firestore
        .collection(user.collection.value)
        .where('uid', isLessThanOrEqualTo: randomId)
        .orderBy('uid', descending: true)
        .limit(_limit)
        .get();
    var snapshotGreater = await _firestore
        .collection(user.collection.value)
        .where('uid', isGreaterThan: randomId)
        .orderBy('uid', descending: true)
        .limit(_limit)
        .get();
    Random rand = new Random();
    List randomUsers = new List.from(snapshotLess.docs);
    randomUsers.addAll(snapshotGreater.docs);
    while (randomUsers.length != 0) {
      var doc = randomUsers.removeAt(rand.nextInt(randomUsers.length));
      if (user.id != doc.get('uid') &&
          !activeIds.contains(doc.get('uid')) &&
          !pendingIds.contains(doc.get('uid')) &&
          !requests.contains(doc.get('uid'))) {
        var user = BaseUser();
        user.setFromDocument(doc);
        return user;
      }
    }
    return null;
  }

  /// Find the collection of the user [id] inside the base collections of the DB
  Future<Collection> findUsersCollection(String id) async {
    var baseCollections = [Collection.BASE_USERS, Collection.EXPERTS];
    for (var collection in baseCollections) {
      try {
        var snap = await _firestore
            .collection(collection.value)
            .where(FieldPath.documentId, isEqualTo: id)
            .get();
        if (snap.docs.isNotEmpty) return collection;
      } catch (e) {}
    }
    return null;
  }

  Future<void> uploadProfilePhoto(User user, File profilePhoto) async {
    var firebaseStorageRef =
        FirebaseStorage.instance.ref().child(user.id + '/profilePhoto');
    UploadTask uploadTask = firebaseStorageRef.putFile(profilePhoto);
    uploadTask.whenComplete(() async {
      updateUserFieldIntoDB(
          user, 'profilePhoto', await firebaseStorageRef.getDownloadURL());
    });
  }

  /***************************************** MESSAGES *****************************************/

  /// It updates within a [transaction] the field of the lastMessage of the sender and peer Users.
  /// If the chat is new, it   /// adds it to the list of chats of the 2 users in the collection specified
  /// into the [conversation] field and updates the chat counters
  Future<void> _updateChatInfo(
      Transaction transaction, Conversation conversation, timestamp) async {
    var senderUserRef = _firestore
        .collection(conversation.senderUser.collection.value)
        .doc(conversation.senderUser.id)
        .collection(conversation.senderUserChat.chatCollection.value)
        .doc(conversation.peerUser.id);
    var peerUserRef = _firestore
        .collection(conversation.peerUser.collection.value)
        .doc(conversation.peerUser.id)
        .collection(conversation.peerUserChat.chatCollection.value)
        .doc(conversation.senderUser.id);
    // Increments the counter only if the sender and the peer users are base users and if
    // this is their first message
    if (!(await transaction.get(senderUserRef)).exists &&
        conversation.senderUser.collection == Collection.BASE_USERS &&
        conversation.peerUser.collection == Collection.BASE_USERS) {
      await _incrementConversationCounter(transaction, conversation, 1);
    }
    transaction.set(senderUserRef, {'lastMessage': timestamp});
    transaction.set(peerUserRef, {'lastMessage': timestamp});
  }

  /// It takes the [pairChatId] that is the composite id of the 2 users, the [senderUserChat],
  /// the [peerUserChat] and the [content] of message and adds a new message into the messages collection of the DB.
  /// Then it calls the updateChatInfo method
  Future<void> addMessageIntoDB(Conversation conversation, content) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    var messagesReference = _firestore
        .collection(Collection.MESSAGES.value)
        .doc(conversation.pairChatId)
        .collection(conversation.pairChatId)
        .doc(timestamp.toString());
    await _firestore.runTransaction((transaction) async {
      await _updateChatInfo(transaction, conversation, timestamp);
      transaction.set(
        messagesReference,
        {
          'idFrom': conversation.senderUser.id,
          'idTo': conversation.peerUser.id,
          'timestamp': timestamp,
          'content': content,
        },
      );
    });
  }

  /// It takes the [pairChatId] that is the composite id of the 2 users and
  /// returns the stream of all the messages between the pair of users from the DB
  Stream<QuerySnapshot> getStreamMessagesFromDB(String pairChatId) {
    return _firestore
        .collection(Collection.MESSAGES.value)
        .doc(pairChatId)
        .collection(pairChatId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// It takes the [pairChatId] and removes the messages between the 2 users from the DB
  Future<void> removeMessagesFromDB(String pairChatId) async {
    var messages = await _firestore
        .collection(Collection.MESSAGES.value)
        .doc(pairChatId)
        .collection(pairChatId)
        .get();
    await _firestore.runTransaction((transaction) async {
      for (var doc in messages.docs) {
        var messagesReference = _firestore
            .collection(Collection.MESSAGES.value)
            .doc(pairChatId)
            .collection(pairChatId)
            .doc(doc.id);
        transaction.delete(messagesReference);
      }
    });
  }

  /***************************************** CHATS *****************************************/

  /// Upgrade a [pendingUserChat] with a [peerUser] to an active chat for both the users.
  Future<void> upgradePendingToActiveChatIntoDB(
      Conversation conversation) async {
    if (conversation.senderUserChat.chatCollection !=
        Collection.PENDING_CHATS) {
      return;
    }
    var pendingChatsReference = _firestore
        .collection(conversation.senderUser.collection.value)
        .doc(conversation.senderUser.id)
        .collection(Collection.PENDING_CHATS.value)
        .doc(conversation.peerUser.id);
    var senderActiveChatsReference = _firestore
        .collection(conversation.senderUser.collection.value)
        .doc(conversation.senderUser.id)
        .collection(Collection.ACTIVE_CHATS.value)
        .doc(conversation.peerUser.id);
    var requestsReference = _firestore
        .collection(conversation.peerUser.collection.value)
        .doc(conversation.peerUser.id)
        .collection(Collection.REQUESTS_CHATS.value)
        .doc(conversation.senderUser.id);
    var peerActiveChatsReference = _firestore
        .collection(conversation.peerUser.collection.value)
        .doc(conversation.peerUser.id)
        .collection(Collection.ACTIVE_CHATS.value)
        .doc(conversation.senderUser.id);

    await _firestore.runTransaction((transaction) async {
      var pendingChats = await transaction.get(pendingChatsReference);
      var request = await transaction.get(requestsReference);
      // Pending chat of the sender user is moved into active chats
      transaction.delete(pendingChatsReference);
      transaction.set(senderActiveChatsReference,
          {'lastMessage': pendingChats.get('lastMessage')});
      // Request chat of the peer user is moved into active chats
      transaction.delete(requestsReference);
      transaction.set(peerActiveChatsReference,
          {'lastMessage': request.get('lastMessage')});
    });
  }

  /// Remove the [conversation] between the [peerUser] and the [senderUser]
  Future<void> removeChatFromDB(Conversation conversation) async {
    var senderUserReference = _firestore
        .collection(conversation.senderUser.collection.value)
        .doc(conversation.senderUser.id)
        .collection(conversation.senderUserChat.chatCollection.value)
        .doc(conversation.peerUser.id);
    var peerUserReference = _firestore
        .collection(conversation.peerUser.collection.value)
        .doc(conversation.peerUser.id)
        .collection(conversation.peerUserChat.chatCollection.value)
        .doc(conversation.senderUser.id);
    await _firestore.runTransaction((transaction) async {
      transaction.delete(senderUserReference);
      transaction.delete(peerUserReference);
      await _incrementConversationCounter(transaction, conversation, -1);
    });
  }

  /// It takes the [user] and returns the list of all the [chat] of the
  /// user based on the [chatCollection] field of the Chat.
  Future<PriorityQueue> getChatsFromDB(User user, Chat chat) async {
    var ids = await _getChatIdsList(user, chat);
    var chats =
        PriorityQueue((a, b) => ids.indexOf(b.id).compareTo(ids.indexOf(a.id)));
    List<List<String>> subList = [];
    for (var i = 0; i < ids.length; i += 10) {
      subList.add(ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10));
    }
    await Future.forEach(subList, (list) async {
      chats.addAll(await _getUsersByList(chat.targetCollection, list));
    });
    return chats;
  }

  /// It takes the [user] and returns the set of ids of all the [chat] of the
  /// user based on the [chatCollection] field of the Chat.
  Future<List> _getChatIdsList(User user, Chat chat) async {
    List<String> ids = [];
    var snap = await _firestore
        .collection(user.collection.value)
        .doc(user.id)
        .collection(chat.chatCollection.value)
        .orderBy('lastMessage')
        .limit(_limit)
        .get();
    for (var doc in snap.docs) {
      ids.add(doc.id);
    }
    return ids;
  }

  /// It takes the [user] and returns the set of ids of all the [chat] of the
  /// user based on the [chatCollection] field of the Chat.
  Future<HashSet> _getChatIdsSet(User user, Chat chat) async {
    HashSet<String> ids = new HashSet();
    var snap = await _firestore
        .collection(user.collection.value)
        .doc(user.id)
        .collection(chat.chatCollection.value)
        .orderBy('lastMessage')
        .limit(_limit)
        .get();
    for (var doc in snap.docs) {
      ids.add(doc.id);
    }
    return ids;
  }

  Future<bool> hasPendingChats(User user) async {
    var snap = await _firestore
        .collection(user.collection.value)
        .doc(user.id)
        .collection(Collection.PENDING_CHATS.value)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return false;
    return true;
  }

  /// It takes the [conversation] and the [increment] amount and increments the anonymous chat's counter of the users
  /// into the DB within the [transaction]
  Future<void> _incrementConversationCounter(
      Transaction transaction, Conversation conversation, int increment) async {
    var utilsSenderReference = _firestore
        .collection(conversation.senderUser.collection.value)
        .doc(conversation.senderUser.id)
        .collection(Collection.UTILS.value)
        .doc(Collection.UTILS.value);
    var utilsPeerReference = _firestore
        .collection(conversation.peerUser.collection.value)
        .doc(conversation.peerUser.id)
        .collection(Collection.UTILS.value)
        .doc(Collection.UTILS.value);
    var utilsSender = await transaction.get(utilsSenderReference);
    var utilsPeer = await transaction.get(utilsPeerReference);
    int oldCounterSender, oldCounterPeer;
    utilsSender.data() != null
        ? oldCounterSender = utilsSender.get('anonymousChatCounter')
        : oldCounterSender = 0;
    utilsPeer.data() != null
        ? oldCounterPeer = utilsPeer.get('anonymousChatCounter')
        : oldCounterPeer = 0;
    int newCounterSender = oldCounterSender + increment;
    int newCounterPeer = oldCounterPeer + increment;
    transaction.set(utilsSenderReference,
        {'anonymousChatCounter': newCounterSender < 0 ? 0 : newCounterSender});
    transaction.set(utilsPeerReference,
        {'anonymousChatCounter': newCounterPeer < 0 ? 0 : newCounterPeer});
  }

  /// It takes the [user] and returns the anonymous chat's counter from the DB
  Future<int> _getChatsCounterFromDB(User user) async {
    var utils = await _firestore
        .collection(Collection.BASE_USERS.value)
        .doc(user.id)
        .collection(Collection.UTILS.value)
        .doc(Collection.UTILS.value)
        .get();
    if (utils.data() != null)
      return utils.get('anonymousChatCounter');
    else
      return 0;
  }

  /***************************************** REPORTS *****************************************/

  /// It takes the [id] of an user and the [report]
  /// and adds it into the list of reports of the user into the DB
  Future<void> addReportIntoDB(String id, Report report) async {
    await _firestore
        .collection(report.collection.value)
        .doc(id)
        .collection('reportsList')
        .doc(report.id)
        .set(report.getData());
  }

  /// It takes the [id] of an user and return the stream of all the reports of the user from the DB
  Stream<QuerySnapshot> getReportsFromDB(String id) {
    return _firestore
        .collection(Collection.REPORTS.value)
        .doc(id)
        .collection('reportsList')
        .orderBy('date', descending: true)
        .snapshots();
  }

  /**************************************** DIARY ********************************************/

  /// It takes the [id] of an user and the [note]
  /// and adds it into the list of diaryPages of the user into the DB
  Future<void> addDiaryNotesIntoDB(String id, Note note) async {
    await _firestore
        .collection(note.collection.value)
        .doc(id)
        .collection('diaryPages')
        .doc(note.id)
        .set(note.getData());
  }

  /// It takes the [id] of an user and the [note] and set it as favourite or not
  Future<void> setFavouriteDiaryNotesIntoDB(String id, Note note) async {
    var data = note.getData();
    await _firestore
        .collection(note.collection.value)
        .doc(id)
        .collection('diaryPages')
        .doc(note.id)
        .update({
      'favourite': data['favourite'],
    });
  }

  /// It takes the [id] of an user and return the stream of all the diaryPages of the user from the DB
  Future<QuerySnapshot> getDiaryNotesFromDB(
      String id, DateTime startDate, DateTime endDate) async {
    return await _firestore
        .collection(Collection.DIARY.value)
        .doc(id)
        .collection('diaryPages')
        .orderBy('date')
        .startAt([startDate]).endAt([endDate]).get();
  }
}
