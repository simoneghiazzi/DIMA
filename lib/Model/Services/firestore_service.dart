import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/BaseUser/Diary/diary_page.dart';
import 'package:sApport/Model/BaseUser/base_user.dart';
import 'package:sApport/Model/Chat/active_chat.dart';
import 'package:sApport/Model/Chat/conversation.dart';
import 'package:sApport/Model/Chat/message.dart';
import 'package:sApport/Model/Chat/pending_chat.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Model/Chat/request.dart';
import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/Model/BaseUser/report.dart';
import 'package:sApport/Model/user.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Service used by the view models to interact with the Firestore DB
class FirestoreService {
  // Firestore instance
  final FirebaseFirestore _firestore;
  // Limit of returned instances from the DB by the queries
  int _limit = 30;

  FirestoreService(this._firestore);

  /***************************************** USERS *****************************************/

  /// Add a user into the firestore DB.
  ///
  /// It takes the [user] and based on the type it adds him/her to the list of experts or to the list
  /// of users and it increments the collection counter.
  Future<void> addUserIntoDB(User user) {
    var userReference = _firestore.collection(user.collection.value).doc(user.id);
    if (user.collection == Collection.BASE_USERS) {
      _incrementBaseUsersCounter(1);
    }
    return userReference.set(user.getData()).then((value) => print("User added")).catchError((error) => print("Failed to add user: $error"));
  }

  /// Delete a user from the firestore DB.
  ///
  /// It takes the [user] and based on the type it deletes him/her from the list of experts or from the list
  /// of users and it decrements the collection counter.
  void removeUserFromDB(User user) {
    var userReference = _firestore.collection(user.collection.value).doc(user.id);
    if (user.collection == Collection.BASE_USERS) {
      userReference.delete().then((value) => print("User deleted")).catchError((error) => print("Failed to delete user: $error"));
      _incrementBaseUsersCounter(-1);
    }
  }

  /// It takes a [user] and updates the specified [field] with the [newValue] into the DB
  Future<void> updateUserFieldIntoDB(User user, String field, newValue) {
    return _firestore
        .collection(user.collection.value)
        .doc(user.id)
        .update({field: newValue})
        .then((value) => print("User updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  /// Get the list of all the doc in [collection] from the DB
  Future<QuerySnapshot> getBaseCollectionFromDB(Collection collection) {
    return _firestore.collection(collection.value).get();
  }

  /// It takes the [id] and the [collection] and returns a doc instance with
  /// all the information of the retrieved user
  Future<QuerySnapshot> getUserByIdFromDB(Collection collection, String id) {
    return _firestore.collection(collection.value).where(FieldPath.documentId, isEqualTo: id).get();
  }

  /// It takes the [increment] amount and increments the user's counter into the DB
  Future<void> _incrementBaseUsersCounter(int increment) async {
    var utilsReference = _firestore.collection(Collection.BASE_USERS.value).doc(Collection.UTILS.value);
    await _firestore
        .runTransaction((transaction) async {
          var utils = await transaction.get(utilsReference);
          int counter;
          utils.data() != null ? counter = utils.get('userCounter') : counter = 0;
          transaction.set(utilsReference, {'userCounter': counter + increment});
        })
        .then((value) => print("Base user counter incremented"))
        .catchError((error) => print("Failed to increment the base user counter: $error"));
  }

  /// Get the counter of the intances of base users from the DB
  Future<DocumentSnapshot> _getBaseUsersCounter() {
    return _firestore.collection(Collection.BASE_USERS.value).doc(Collection.UTILS.value).get();
  }

  /// Get random user from the DB. It takes the [user] and the auto-generated [randomId] and it returns a Future BaseUser instance
  /// 1. Check if the number of chats of the user is less than the total number of users, if not return null
  /// 2. Get all the active, pending and request chat ids set
  /// 3. Take the list of the first _limit users with the id <= randomId and id > randomId and sample a random
  /// user id that is not the sender him/herself or that is not in the list of active/pending chat ids
  Future<BaseUser> getRandomUserFromDB(BaseUser user, String randomId) async {
    var baseUserCounter = (await _getBaseUsersCounter()).get('userCounter');
    var res = (await _getChatsCounterFromDB(user));
    var chatsCounter = res.exists ? res.get('anonymousChatCounter') : 0;
    if (baseUserCounter - 1 > chatsCounter) {
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
        var uid = doc.get('uid');
        if (user.id != uid && !activeIds.contains(uid) && !pendingIds.contains(uid) && !requests.contains(uid)) {
          var user = BaseUser();
          user.setFromDocument(doc);
          return user;
        }
      }
    }
    return null;
  }

  /// Find the collection of the user [id] inside the base collections of the DB
  Future<Collection> findUserCollection(String id) async {
    for (var collection in [Collection.BASE_USERS, Collection.EXPERTS]) {
      try {
        var snap = await _firestore.collection(collection.value).doc(id).get();
        if (snap.exists) {
          return collection;
        }
      } catch (e) {}
    }
    return null;
  }

  /// Upload the [profilePhoto] of the [user] into FirebaseStorage and add the url into the user
  /// doc in the DB
  void uploadProfilePhoto(User user, File profilePhoto) {
    var firebaseStorageRef = FirebaseStorage.instance.ref().child(user.id + '/profilePhoto');
    UploadTask uploadTask = firebaseStorageRef.putFile(profilePhoto);
    uploadTask.whenComplete(() async {
      updateUserFieldIntoDB(user, 'profilePhoto', await firebaseStorageRef.getDownloadURL());
    });
  }

  /***************************************** MESSAGES *****************************************/

  /// It updates within a [batch] the field of the lastMessage of the sender and peer Users.
  ///
  /// If the chat is new, it adds it to the list of chats of the 2 users in the collection specified
  /// into the [conversation] field and updates the chat counters
  void _updateChatInfo(Conversation conversation, int timestamp) async {
    DocumentReference senderUserRef = _firestore
        .collection(conversation.senderUser.collection.value)
        .doc(conversation.senderUser.id)
        .collection(conversation.senderUserChat.chatCollection.value)
        .doc(conversation.peerUser.id);
    DocumentReference peerUserRef = _firestore
        .collection(conversation.peerUser.collection.value)
        .doc(conversation.peerUser.id)
        .collection(conversation.peerUserChat.chatCollection.value)
        .doc(conversation.senderUser.id);

    // Increments the counter only if the sender and the peer users are base users and if
    // this is their first message
    if (conversation.senderUser.collection == Collection.BASE_USERS &&
        conversation.peerUser.collection == Collection.BASE_USERS &&
        !(await senderUserRef.get()).exists) {
      _incrementConversationCounter(conversation, 1);
    }
    WriteBatch batch = FirebaseFirestore.instance.batch();
    batch.set(senderUserRef, {'lastMessage': timestamp});
    batch.set(peerUserRef, {'lastMessage': timestamp});
    batch.commit().then((value) => print("Chat info updated")).catchError((error) => print("Failed to update the chat info: $error"));
  }

  /// It takes the [conversation] between the 2 users and the message and adds it into the messages collection of the DB.
  /// Then it calls the updateChatInfo method
  void addMessageIntoDB(Conversation conversation, Message message) {
    var messagesReference = _firestore
        .collection(Collection.MESSAGES.value)
        .doc(conversation.pairChatId)
        .collection(conversation.pairChatId)
        .doc(message.timestamp.millisecondsSinceEpoch.toString());
    messagesReference.set(message.getData());
    _updateChatInfo(conversation, message.timestamp.millisecondsSinceEpoch);
  }

  /// It takes the [pairChatId] that is the composite id of the 2 users and
  /// returns the stream of all the messages between the pair of users from the DB
  Stream<QuerySnapshot> getStreamMessagesFromDB(String pairChatId) {
    return _firestore.collection(Collection.MESSAGES.value).doc(pairChatId).collection(pairChatId).orderBy('timestamp', descending: true).snapshots();
  }

  /// It takes the [pairChatId] and removes the messages between the 2 users from the DB
  void removeMessagesFromDB(String pairChatId) {
    var messages = _firestore.collection(Collection.MESSAGES.value).doc(pairChatId).collection(pairChatId).get();
    WriteBatch batch = FirebaseFirestore.instance.batch();
    messages.then((documentSnapshot) {
      documentSnapshot.docs.forEach((doc) {
        batch.delete(doc.reference);
      });
      batch.commit().then((value) => print("Messages removed")).catchError((error) => print("Failed to remove the messages: $error"));
    });
  }

  /// It takes the [user] and listen for new messages
  /// It is used in order to update the list of chats when a new message arrives
  Stream<QuerySnapshot> listenToNewMessages(User user, Chat chat) {
    return _firestore.collection(user.collection.value).doc(user.id).collection(chat.chatCollection.value).snapshots();
  }

  /***************************************** CHATS *****************************************/

  /// Upgrade a [pendingUserChat] with a [peerUser] to an active chat for both the users.
  void upgradePendingToActiveChatIntoDB(Conversation conversation) {
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    if (conversation.senderUserChat.chatCollection == Collection.PENDING_CHATS) {
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

      WriteBatch batch = FirebaseFirestore.instance.batch();
      // Pending chat of the sender user is moved into active chats
      batch.delete(pendingChatsReference);
      batch.set(senderActiveChatsReference, {'lastMessage': timestamp});
      // Request chat of the peer user is moved into active chats
      batch.delete(requestsReference);
      batch.set(peerActiveChatsReference, {'lastMessage': timestamp});

      batch.commit().then((value) => print("Chats upgraded")).catchError((error) => print("Failed to upgrade the chats: $error"));
    }
  }

  /// Remove the [conversation] between the [peerUser] and the [senderUser]
  void removeChatFromDB(Conversation conversation) {
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

    WriteBatch batch = FirebaseFirestore.instance.batch();
    batch.delete(senderUserReference);
    batch.delete(peerUserReference);
    batch.commit().then((value) => print("Chat removed")).catchError((error) => print("Failed to remove the chat: $error"));
    _incrementConversationCounter(conversation, -1);
  }

  /// It takes the [user] and returns the list of all the [chat] of the
  /// user based on the [chatCollection] field of the [chat] ordered by lastMessage.
  Stream<QuerySnapshot> getChatsFromDB(User user, Chat chat) {
    return _firestore
        .collection(user.collection.value)
        .doc(user.id)
        .collection(chat.chatCollection.value)
        .orderBy("lastMessage", descending: true)
        .limit(_limit)
        .snapshots();
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

  Stream<QuerySnapshot> hasPendingChats(User user) {
    return _firestore.collection(user.collection.value).doc(user.id).collection(Collection.PENDING_CHATS.value).snapshots();
  }

  /// It takes the [conversation] and the [increment] amount and increments the anonymous chat's counter of the users
  /// into the DB within the [transaction]
  void _incrementConversationCounter(Conversation conversation, int increment) {
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

    _firestore
        .runTransaction((transaction) async {
          var utilsSender = await transaction.get(utilsSenderReference);
          var utilsPeer = await transaction.get(utilsPeerReference);
          int oldCounterSender, oldCounterPeer;
          utilsSender.data() != null ? oldCounterSender = utilsSender.get('anonymousChatCounter') : oldCounterSender = 0;
          utilsPeer.data() != null ? oldCounterPeer = utilsPeer.get('anonymousChatCounter') : oldCounterPeer = 0;
          int newCounterSender = oldCounterSender + increment;
          int newCounterPeer = oldCounterPeer + increment;
          transaction.set(utilsSenderReference, {'anonymousChatCounter': newCounterSender < 0 ? 0 : newCounterSender});
          transaction.set(utilsPeerReference, {'anonymousChatCounter': newCounterPeer < 0 ? 0 : newCounterPeer});
        })
        .then((value) => print("Conversation counters incremented"))
        .catchError((error) => print("Failed to increment the conversation counters: $error"));
  }

  /// It takes the [user] and returns the anonymous chat's counter from the DB
  Future<DocumentSnapshot> _getChatsCounterFromDB(User user) async {
    return _firestore.collection(Collection.BASE_USERS.value).doc(user.id).collection(Collection.UTILS.value).doc(Collection.UTILS.value).get();
  }

  /***************************************** REPORTS *****************************************/

  /// It takes the [id] of an user and the [report]
  /// and adds it into the list of reports of the user into the DB
  Future<void> addReportIntoDB(String id, Report report) async {
    _firestore
        .collection(report.collection.value)
        .doc(id)
        .collection('reportsList')
        .doc(report.id)
        .set(report.getData())
        .then((value) => print("Report added"))
        .catchError((error) => print("Failed to add the report: $error"));
  }

  /// It takes the [id] of an user and return the reports of the user from the DB
  Stream<QuerySnapshot> getReportsFromDB(String id) {
    return _firestore.collection(Collection.REPORTS.value).doc(id).collection('reportsList').orderBy('date', descending: true).snapshots();
  }

  /**************************************** DIARY ********************************************/

  /// It takes the [id] of an user and the [note]
  /// and adds it into the list of diaryPages of the user into the DB
  Future<void> addDiaryNoteIntoDB(String id, DiaryPage note) {
    return _firestore.collection(note.collection.value).doc(id).collection('diaryPages').doc(note.id).set(note.getData());
  }

  /// It takes the [id] of an user and the [note] and set it as favourite or not
  Future<void> setFavouriteDiaryNotesIntoDB(String id, DiaryPage note) {
    var data = note.getData();
    return _firestore
        .collection(note.collection.value)
        .doc(id)
        .collection('diaryPages')
        .doc(note.id)
        .update({
          'favourite': data['favourite'],
        })
        .then((value) => print("Favourite note updated"))
        .catchError((error) => print("Failed to update the favourite note: $error"));
  }

  /// It takes the [id] of an user and return the stream of all the diaryPages of the user from the DB
  Stream<QuerySnapshot> getDiaryNotesStreamFromDB(String id) {
    return _firestore.collection(Collection.DIARY.value).doc(id).collection('diaryPages').orderBy('date').snapshots();
  }
}
