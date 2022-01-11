import 'package:test/test.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/Chat/request.dart';
import 'package:sApport/Model/DBItems/message.dart';
import 'package:sApport/Model/Chat/active_chat.dart';
import 'package:sApport/Model/Chat/expert_chat.dart';
import 'package:sApport/Model/Chat/pending_chat.dart';
import 'package:sApport/Model/Chat/anonymous_chat.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Model/DBItems/BaseUser/report.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/DBItems/BaseUser/diary_page.dart';
import '../../service.mocks.dart';
import '../../test_helper.dart';

void main() async {
  /// Fake Firebase
  var fakeFirebase = FakeFirebaseFirestore();
  var fakeFirebaseStorage = MockFirebaseStorage();

  var firestoreService = FirestoreService(fakeFirebase, firebaseStorage: fakeFirebaseStorage);

  /// Register Services
  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(FirestoreService(fakeFirebase));
  getIt.registerSingleton<UserService>(MockUserService());

  /// Test Helper
  final testHelper = TestHelper();

  var message = Message(
    idFrom: testHelper.loggedUser.id,
    idTo: testHelper.baseUser.id,
    timestamp: DateTime(2021, 10, 19, 21, 10, 50),
    content: "Message content",
  );

  var message2 = Message(
    idFrom: testHelper.loggedUser.id,
    idTo: testHelper.baseUser2.id,
    timestamp: DateTime(2021, 12, 19, 12, 42, 22),
    content: "Message content 2",
  );

  var message3 = Message(
    idFrom: testHelper.loggedUser.id,
    idTo: testHelper.baseUser3.id,
    timestamp: DateTime(2021, 12, 19, 13, 00, 25),
    content: "Message content 3",
  );

  var messageToExpert = Message(
    idFrom: testHelper.loggedUser.id,
    idTo: testHelper.expert.id,
    timestamp: DateTime(2021, 10, 19, 21, 10, 50),
    content: "Message content",
  );

  var pendingChatOfUser4 = PendingChat(
    lastMessage: "Message pending chat",
    lastMessageDateTime: DateTime(2022, 1, 1, 8, 52, 24),
    peerUser: testHelper.loggedUser,
  );

  /***************************************** USERS *****************************************/

  group("Firestore user methods:", () {
    setUp(() async {
      /// Fake Firebase
      fakeFirebase = FakeFirebaseFirestore();
      firestoreService = FirestoreService(fakeFirebase, firebaseStorage: fakeFirebaseStorage);
    });

    group("Add a new base user:", () {
      test("Check that the DB contains the document with the base user information", () async {
        await firestoreService.addUserIntoDB(testHelper.loggedUser);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.loggedUser.id).get();
        BaseUser retrievedUser = BaseUser.fromDocument(res);

        expect(retrievedUser.id, testHelper.loggedUser.id);
        expect(retrievedUser.name, testHelper.loggedUser.name);
        expect(retrievedUser.surname, testHelper.loggedUser.surname);
        expect(retrievedUser.email, testHelper.loggedUser.email);
        expect(retrievedUser.birthDate, testHelper.loggedUser.birthDate);
      });

      test("Check that the base user counter is incremented", () async {
        await firestoreService.addUserIntoDB(testHelper.loggedUser);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(BaseUser.COLLECTION).doc("utils").get();
        var data = res.data();

        expect(data!["userCounter"], 1);

        /// Try to add another user
        await firestoreService.addUserIntoDB(testHelper.baseUser);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        /// Get the data from the fakeFirebase
        res = await fakeFirebase.collection(BaseUser.COLLECTION).doc("utils").get();
        data = res.data();

        expect(data!["userCounter"], 2);
      });
    });

    group("Add a new expert:", () {
      test("Check that the DB contains the document with the expert information", () async {
        await firestoreService.addUserIntoDB(testHelper.expert);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(Expert.COLLECTION).doc(testHelper.expert.id).get();
        Expert rerievedExpert = Expert.fromDocument(res);

        expect(rerievedExpert.id, testHelper.expert.id);
        expect(rerievedExpert.name, testHelper.expert.name);
        expect(rerievedExpert.surname, testHelper.expert.surname);
        expect(rerievedExpert.email, testHelper.expert.email);
        expect(rerievedExpert.birthDate, testHelper.expert.birthDate);
        expect(rerievedExpert.address, testHelper.expert.address);
        expect(rerievedExpert.latitude, testHelper.expert.latitude);
        expect(rerievedExpert.longitude, testHelper.expert.longitude);
        expect(rerievedExpert.phoneNumber, testHelper.expert.phoneNumber);
        expect(rerievedExpert.profilePhoto, testHelper.expert.profilePhoto);
      });

      test("Check that the base user counter is not incremented when inserting an expert", () async {
        await firestoreService.addUserIntoDB(testHelper.expert);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(BaseUser.COLLECTION).doc("utils").get();

        expect(res.exists, false);
      });

      test("Add a new expert should upload the profile photo into the firesbase storage", () async {
        await firestoreService.addUserIntoDB(testHelper.expert);

        expect(fakeFirebaseStorage.storedFilesMap["/${testHelper.expert.id}/profilePhoto"]!.path, testHelper.expert.profilePhoto);
      });
    });

    group("Remove a base user:", () {
      test("Check that the DB does not contain the document anymore after removing the user", () async {
        await firestoreService.addUserIntoDB(testHelper.loggedUser);
        await firestoreService.removeUserFromDB(testHelper.loggedUser);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.loggedUser.id).get();

        expect(res.exists, false);
      });

      test("Check that the base user counter is decremented when removing a base user", () async {
        await firestoreService.addUserIntoDB(testHelper.loggedUser);
        await firestoreService.removeUserFromDB(testHelper.loggedUser);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(BaseUser.COLLECTION).doc("utils").get();
        var data = res.data();

        expect(data!["userCounter"], 0);
      });
    });

    group("Remove an expert:", () {
      test("Check that the DB does not contain the document anymore after removing the expert", () async {
        await firestoreService.addUserIntoDB(testHelper.expert);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        await firestoreService.removeUserFromDB(testHelper.expert);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(Expert.COLLECTION).doc(testHelper.expert.id).get();

        expect(res.exists, false);
      });
    });

    group("Update user field:", () {
      test("Check that the DB contains the document with the updated fields", () async {
        var updatedName = "UpdatedName";
        var newField = "newField";

        await firestoreService.addUserIntoDB(testHelper.loggedUser);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        await firestoreService.updateUserFieldIntoDB(testHelper.loggedUser, "name", updatedName);
        await firestoreService.updateUserFieldIntoDB(testHelper.loggedUser, "newField", newField);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.loggedUser.id).get();
        var data = res.data()!;

        expect(data["name"], updatedName);
        expect(data["newField"], newField);
      });
    });

    group("Get expert collection:", () {
      test("Check that getExpertCollection returns the query snapshot of the searched collection", () async {
        await firestoreService.addUserIntoDB(testHelper.expert);

        var snapshot = await firestoreService.getExpertCollectionFromDB();

        /// Create the BaseUser instance
        Expert retrievedExpert;
        if (snapshot.docs.first.id != "utils") {
          retrievedExpert = Expert.fromDocument(snapshot.docs.first);
        } else {
          retrievedExpert = Expert.fromDocument(snapshot.docs.last);
        }

        expect(retrievedExpert.id, testHelper.expert.id);
        expect(retrievedExpert.name, testHelper.expert.name);
        expect(retrievedExpert.surname, testHelper.expert.surname);
        expect(retrievedExpert.email, testHelper.expert.email);
        expect(retrievedExpert.birthDate, testHelper.expert.birthDate);
        expect(retrievedExpert.address, testHelper.expert.address);
        expect(retrievedExpert.latitude, testHelper.expert.latitude);
        expect(retrievedExpert.longitude, testHelper.expert.longitude);
        expect(retrievedExpert.phoneNumber, testHelper.expert.phoneNumber);
        expect(retrievedExpert.profilePhoto, testHelper.expert.profilePhoto);
      });

      test("Check that getBaseCollection returns the correct number of documents of the searched collection", () async {
        await firestoreService.addUserIntoDB(testHelper.expert);
        await firestoreService.addUserIntoDB(testHelper.expert2);

        var snapshot = await firestoreService.getExpertCollectionFromDB();

        expect(snapshot.docs.length, 2);
      });
    });

    group("Get user by ID:", () {
      test("Check that getUserById returns the correct document of the base user", () async {
        await firestoreService.addUserIntoDB(testHelper.loggedUser);

        var snapshot = await firestoreService.getUserByIdFromDB(BaseUser.COLLECTION, testHelper.loggedUser.id);
        BaseUser retrievedUser = BaseUser.fromDocument(snapshot.docs[0]);

        expect(retrievedUser.id, testHelper.loggedUser.id);
        expect(retrievedUser.name, testHelper.loggedUser.name);
        expect(retrievedUser.surname, testHelper.loggedUser.surname);
        expect(retrievedUser.email, testHelper.loggedUser.email);
        expect(retrievedUser.birthDate, testHelper.loggedUser.birthDate);
      });

      test("Check that if the id of the user doesn not exit into the DB it returns an empty snapshot", () async {
        var snapshot = await firestoreService.getUserByIdFromDB(BaseUser.COLLECTION, testHelper.loggedUser.id);

        expect(snapshot.docs.isEmpty, true);
      });
    });

    group("Get random user:", () {
      test("Check that getRandomUser returns the document of a new user", () async {
        await firestoreService.addUserIntoDB(testHelper.loggedUser);
        await firestoreService.addUserIntoDB(testHelper.baseUser);

        var snapshot = await firestoreService.getRandomUserFromDB(testHelper.loggedUser, Utils.randomId());

        expect(snapshot!.exists, true);
        expect(snapshot.id, testHelper.baseUser.id);
      });

      test("Check that getRandomUser returns null if the number of anonymous chats of the user is not grater than the user counter + 1", () async {
        /// Only one user into the DB
        await firestoreService.addUserIntoDB(testHelper.loggedUser);

        var snapshot = await firestoreService.getRandomUserFromDB(testHelper.loggedUser, Utils.randomId());

        expect(snapshot, null);

        /// Two users but already that have a chat between them
        await firestoreService.addUserIntoDB(testHelper.loggedUser);
        await firestoreService.addMessageIntoDB(testHelper.loggedUser, testHelper.anonymousChat, message);

        snapshot = await firestoreService.getRandomUserFromDB(testHelper.loggedUser, Utils.randomId());

        expect(snapshot, null);
      });
    });

    group("Find user type:", () {
      test("Check that findUserType returns the correct instance of the user", () async {
        await firestoreService.addUserIntoDB(testHelper.loggedUser);
        await firestoreService.addUserIntoDB(testHelper.expert);

        var resultBaseUser = await firestoreService.findUserType(testHelper.loggedUser.id);
        var resultExpert = await firestoreService.findUserType(testHelper.expert.id);

        expect(resultBaseUser, isA<BaseUser>());
        expect(resultExpert, isA<Expert>());
      });

      test("Check that findUserType returns null if the user is not present into the DB", () async {
        var resultBaseUser = await firestoreService.findUserType(testHelper.loggedUser.id);
        var resultExpert = await firestoreService.findUserType(testHelper.expert.id);

        expect(resultBaseUser, null);
        expect(resultExpert, null);
      });
    });
  });

  /***************************************** MESSAGES *****************************************/

  group("Firestore message methods:", () {
    setUp(() async {
      /// Fake Firebase
      fakeFirebase = FakeFirebaseFirestore();
      firestoreService = FirestoreService(fakeFirebase, firebaseStorage: fakeFirebaseStorage);
    });

    group("Add message:", () {
      test("Check that the DB contains the document with the message information", () async {
        await firestoreService.addUserIntoDB(testHelper.loggedUser);
        await firestoreService.addUserIntoDB(testHelper.baseUser);
        await firestoreService.addMessageIntoDB(testHelper.loggedUser, testHelper.anonymousChat, message);

        /// Get the data from the fakeFirebase
        var pairChatId = Utils.pairChatId(testHelper.loggedUser.id, testHelper.baseUser.id);
        var res = await fakeFirebase.collection(Message.COLLECTION).doc(pairChatId).collection(pairChatId).get();

        Message retrievedMessage = Message.fromDocument(res.docs.first);

        expect(retrievedMessage.id, message.timestamp.millisecondsSinceEpoch.toString());
        expect(retrievedMessage.idFrom, message.idFrom);
        expect(retrievedMessage.idTo, message.idTo);
        expect(retrievedMessage.timestamp, message.timestamp);
        expect(retrievedMessage.content, message.content);
      });

      test("Check that addMessage with anonymousChat updates the chat info of both the users in the correct collection", () async {
        await firestoreService.addUserIntoDB(testHelper.loggedUser);
        await firestoreService.addUserIntoDB(testHelper.baseUser);
        await firestoreService.addMessageIntoDB(testHelper.loggedUser, testHelper.anonymousChat, message);

        /// Get the data from the fakeFirebase
        var resAnonymousChatUser =
            await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.loggedUser.id).collection(AnonymousChat.COLLECTION).get();
        var resAnonymousChatUser2 =
            await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.baseUser.id).collection(AnonymousChat.COLLECTION).get();
        var retrievedChatUser = AnonymousChat.fromDocument(resAnonymousChatUser.docs.first);
        var retrievedChatUser2 = AnonymousChat.fromDocument(resAnonymousChatUser2.docs.first);

        /// The id of the document in the collection of the logged user should be the id of base user 2
        expect(resAnonymousChatUser.docs.first.id, testHelper.baseUser.id);
        expect(retrievedChatUser.lastMessage, testHelper.anonymousChat.lastMessage);
        expect(retrievedChatUser.lastMessageDateTime, testHelper.anonymousChat.lastMessageDateTime);

        /// The notReadMessages of the sender user should be setted to 0
        expect(retrievedChatUser.notReadMessages, 0);

        /// The id of the document in the collection of base user 2 should be the id of the logged user
        expect(resAnonymousChatUser2.docs.first.id, testHelper.loggedUser.id);
        expect(retrievedChatUser2.lastMessage, testHelper.anonymousChat.lastMessage);
        expect(retrievedChatUser2.lastMessageDateTime, testHelper.anonymousChat.lastMessageDateTime);
        expect(retrievedChatUser2.notReadMessages, 1);
      });

      test("Check that addMessage with request updates the chat info of both the users in the correct collection", () async {
        await firestoreService.addUserIntoDB(testHelper.loggedUser);
        await firestoreService.addUserIntoDB(testHelper.baseUser4);
        await firestoreService.addMessageIntoDB(testHelper.loggedUser, testHelper.request_4, message);

        /// Get the data from the fakeFirebase
        var resRequest = await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.loggedUser.id).collection(Request.COLLECTION).get();
        var resPendingChat = await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.baseUser4.id).collection(PendingChat.COLLECTION).get();
        var retrievedRequest = Request.fromDocument(resRequest.docs.first);
        var retrievedPendingChat = PendingChat.fromDocument(resPendingChat.docs.first);

        /// The id of the document in the collection of the logged user should be the id of base user 4
        expect(resRequest.docs.first.id, testHelper.baseUser4.id);
        expect(retrievedRequest.lastMessage, testHelper.request_4.lastMessage);
        expect(retrievedRequest.lastMessageDateTime, message.timestamp);

        /// The notReadMessages of the sender user should be setted to 0
        expect(retrievedRequest.notReadMessages, 0);

        /// The id of the document in the collection of base user 4 should be the id of the logged user
        expect(resPendingChat.docs.first.id, testHelper.loggedUser.id);
        expect(retrievedPendingChat.lastMessage, testHelper.request_4.lastMessage);
        expect(retrievedPendingChat.lastMessageDateTime, message.timestamp);
        expect(retrievedPendingChat.notReadMessages, 1);
      });

      test("Check that addMessage with expertChat updates the chat info of both the users in the correct collection", () async {
        await firestoreService.addUserIntoDB(testHelper.loggedUser);
        await firestoreService.addUserIntoDB(testHelper.expert);

        await firestoreService.addMessageIntoDB(testHelper.loggedUser, testHelper.expertChat, messageToExpert);

        /// Get the data from the fakeFirebase
        var resExpertChat = await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.loggedUser.id).collection(ExpertChat.COLLECTION).get();
        var resActiveChat = await fakeFirebase.collection(Expert.COLLECTION).doc(testHelper.expert.id).collection(ActiveChat.COLLECTION).get();
        var retrievedExpertChat = ExpertChat.fromDocument(resExpertChat.docs.first);
        var retrievedActiveChat = ActiveChat.fromDocument(resActiveChat.docs.first);

        /// The id of the document in the collection of base user should be the id of base user 2
        expect(resExpertChat.docs.first.id, testHelper.expert.id);
        expect(retrievedExpertChat.lastMessage, testHelper.expertChat.lastMessage);
        expect(retrievedExpertChat.lastMessageDateTime, messageToExpert.timestamp);

        /// The notReadMessages of the sender user should be setted to 0
        expect(retrievedExpertChat.notReadMessages, 0);

        /// The id of the document in the collection of base user 2 should be the id of base user
        expect(resActiveChat.docs.first.id, testHelper.loggedUser.id);
        expect(retrievedActiveChat.lastMessage, testHelper.expertChat.lastMessage);
        expect(retrievedActiveChat.lastMessageDateTime, messageToExpert.timestamp);
        expect(retrievedActiveChat.notReadMessages, 1);
      });

      test("Add message should increment the anonymousChatCounter if the chat of the sender user is a Request and it is the first message", () async {
        await firestoreService.addUserIntoDB(testHelper.loggedUser);
        await firestoreService.addUserIntoDB(testHelper.baseUser4);
        await firestoreService.addMessageIntoDB(testHelper.loggedUser, testHelper.request_4, message);

        await Future.delayed(Duration.zero);

        /// Get the data from the fakeFirebase
        var resUtilsUser = await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.loggedUser.id).collection("utils").doc("utils").get();
        var resUtilsUser4 = await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.baseUser4.id).collection("utils").doc("utils").get();
        var dataUser = resUtilsUser.data()!;
        var dataUser4 = resUtilsUser4.data()!;

        expect(dataUser["anonymousChatCounter"], 1);
        expect(dataUser4["anonymousChatCounter"], 1);

        /// Try to add another message
        await firestoreService.addMessageIntoDB(testHelper.loggedUser, testHelper.request_4, message);

        /// Get the data from the fakeFirebase
        resUtilsUser = await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.loggedUser.id).collection("utils").doc("utils").get();
        resUtilsUser4 = await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.baseUser4.id).collection("utils").doc("utils").get();
        dataUser = resUtilsUser.data()!;
        dataUser4 = resUtilsUser4.data()!;

        /// Add another message should not incremente the counter
        expect(dataUser["anonymousChatCounter"], 1);
        expect(dataUser4["anonymousChatCounter"], 1);
      });

      test("Add message should not increment the anonymousChatCounter if the chat of the sender user is not a Request", () async {
        await firestoreService.addUserIntoDB(testHelper.loggedUser);
        await firestoreService.addUserIntoDB(testHelper.baseUser);
        await firestoreService.addUserIntoDB(testHelper.expert);

        /// Initially set the counter to 1
        await fakeFirebase
            .collection(BaseUser.COLLECTION)
            .doc(testHelper.loggedUser.id)
            .collection("utils")
            .doc("utils")
            .set({"anonymousChatCounter": 1});
        await fakeFirebase
            .collection(BaseUser.COLLECTION)
            .doc(testHelper.baseUser.id)
            .collection("utils")
            .doc("utils")
            .set({"anonymousChatCounter": 1});

        /// Send a message to another anonymous user
        await firestoreService.addMessageIntoDB(testHelper.loggedUser, testHelper.anonymousChat, message);

        /// Get the data from the fakeFirebase
        var resUtilsUser = await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.loggedUser.id).collection("utils").doc("utils").get();
        var resUtilsUser2 = await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.baseUser.id).collection("utils").doc("utils").get();
        var dataUser = resUtilsUser.data()!;
        var dataUser2 = resUtilsUser2.data()!;

        expect(dataUser["anonymousChatCounter"], 1);
        expect(dataUser2["anonymousChatCounter"], 1);

        /// Send a message to an expert
        await firestoreService.addMessageIntoDB(testHelper.loggedUser, testHelper.expertChat, messageToExpert);

        /// Get the data from the fakeFirebase
        resUtilsUser = await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.loggedUser.id).collection("utils").doc("utils").get();
        dataUser = resUtilsUser.data()!;

        expect(dataUser["anonymousChatCounter"], 1);
      });
    });

    group("Get messages stream:", () {
      test("Check that getMessagesStreamFromDB returns the correct stream of messages in descending order", () async {
        await firestoreService.addUserIntoDB(testHelper.loggedUser);
        await firestoreService.addUserIntoDB(testHelper.baseUser);
        var messages = [message, message2, message3];

        /// Send some messages to another anonymous user
        await firestoreService.addMessageIntoDB(testHelper.loggedUser, testHelper.anonymousChat, message);
        await firestoreService.addMessageIntoDB(testHelper.loggedUser, testHelper.anonymousChat, message2);
        await firestoreService.addMessageIntoDB(testHelper.loggedUser, testHelper.anonymousChat, message3);

        var stream = firestoreService.getMessagesStreamFromDB(Utils.pairChatId(testHelper.loggedUser.id, testHelper.baseUser.id));
        expect(stream, emits(isA<QuerySnapshot>()));

        var res = await stream.first;

        for (int i = 0; i < messages.length; i++) {
          Message m = Message.fromDocument(res.docs[i]);
          expect(m.timestamp, messages[messages.length - 1 - i].timestamp);
        }
      });
    });

    group("Remove messages:", () {
      test("Check that removeMessagesFromDB deletes all the messages between 2 users", () async {
        await firestoreService.addUserIntoDB(testHelper.loggedUser);
        await firestoreService.addUserIntoDB(testHelper.baseUser);

        /// Send some messages to another anonymous user
        await firestoreService.addMessageIntoDB(testHelper.loggedUser, testHelper.anonymousChat, message);
        await firestoreService.addMessageIntoDB(testHelper.loggedUser, testHelper.anonymousChat, message2);
        await firestoreService.addMessageIntoDB(testHelper.loggedUser, testHelper.anonymousChat, message3);

        var pairChatId = Utils.pairChatId(testHelper.loggedUser.id, testHelper.baseUser.id);
        await firestoreService.removeMessagesFromDB(pairChatId);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(Message.COLLECTION).doc(pairChatId).collection(pairChatId).get();
        expect(res.docs, isEmpty);
      });
    });

    group("Set messages has read:", () {
      test("Check that setMessagesHasRead sets the notReadMessages of the chat with a peer user to 0", () async {
        await firestoreService.addUserIntoDB(testHelper.loggedUser);
        await firestoreService.addUserIntoDB(testHelper.baseUser);
        await firestoreService.addMessageIntoDB(testHelper.loggedUser, testHelper.anonymousChat, message);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.baseUser.id).collection(AnonymousChat.COLLECTION).get();

        /// The notReadMessages of the peer user initially is 1
        expect(res.docs.first.data()["notReadMessages"], 1);

        AnonymousChat anonymousChatPeerUser = testHelper.anonymousChat;

        anonymousChatPeerUser.peerUser = testHelper.loggedUser;
        await firestoreService.setMessagesAsRead(testHelper.baseUser, anonymousChatPeerUser);

        /// Get the data from the fakeFirebase
        res = await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.baseUser.id).collection(AnonymousChat.COLLECTION).get();

        expect(res.docs.first.data()["notReadMessages"], 0);
      });
    });
  });

  /***************************************** CHATS *****************************************/

  group("Firestore chat methods:", () {
    setUp(() async {
      /// Fake Firebase
      fakeFirebase = FakeFirebaseFirestore();
      firestoreService = FirestoreService(fakeFirebase, firebaseStorage: fakeFirebaseStorage);
    });

    group("Upgrade pending to active chat:", () {
      test("Check that upgradePendingToActiveChatIntoDB remove the chat from the request and the pending list and add them to the anonymous lists",
          () async {
        await firestoreService.addUserIntoDB(testHelper.loggedUser);
        await firestoreService.addUserIntoDB(testHelper.baseUser4);
        await firestoreService.addMessageIntoDB(testHelper.loggedUser, testHelper.request_4, message);

        await firestoreService.upgradePendingToActiveChatIntoDB(testHelper.baseUser4, pendingChatOfUser4);

        /// Get the data from the fakeFirebase
        var resRequest = await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.loggedUser.id).collection(Request.COLLECTION).get();
        var resPending = await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.baseUser4.id).collection(PendingChat.COLLECTION).get();

        expect(resRequest.docs, isEmpty);
        expect(resPending.docs, isEmpty);

        /// Get the data from the fakeFirebase
        var resAnonymousChatUser =
            await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.loggedUser.id).collection(AnonymousChat.COLLECTION).get();
        var resAnonymousChatUser4 =
            await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.baseUser4.id).collection(AnonymousChat.COLLECTION).get();
        var retrievedChatUser = AnonymousChat.fromDocument(resAnonymousChatUser.docs.first);
        var retrievedChatUser4 = AnonymousChat.fromDocument(resAnonymousChatUser4.docs.first);

        /// The id of the document in the collection of the logged user should be the id of base user 4
        expect(resAnonymousChatUser.docs.first.id, testHelper.baseUser4.id);
        expect(retrievedChatUser.lastMessage, pendingChatOfUser4.lastMessage);
        expect(retrievedChatUser.lastMessageDateTime, pendingChatOfUser4.lastMessageDateTime);
        expect(retrievedChatUser.notReadMessages, 0);

        /// The id of the document in the collection of base user 4 should be the id of the logged user
        expect(resAnonymousChatUser4.docs.first.id, testHelper.loggedUser.id);
        expect(retrievedChatUser4.lastMessage, pendingChatOfUser4.lastMessage);
        expect(retrievedChatUser4.lastMessageDateTime, pendingChatOfUser4.lastMessageDateTime);
        expect(retrievedChatUser4.notReadMessages, 0);
      });

      test("Check that upgradePendingToActiveChatIntoDB does not increment the anonymousChatCounter", () async {
        await firestoreService.addUserIntoDB(testHelper.loggedUser);
        await firestoreService.addUserIntoDB(testHelper.baseUser4);
        await firestoreService.addMessageIntoDB(testHelper.loggedUser, testHelper.request_4, message);

        await Future.value(Duration.zero);

        await firestoreService.upgradePendingToActiveChatIntoDB(testHelper.baseUser4, pendingChatOfUser4);

        /// Get the data from the fakeFirebase
        var resUtilsUser = await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.loggedUser.id).collection("utils").doc("utils").get();
        var resUtilsUser4 = await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.baseUser4.id).collection("utils").doc("utils").get();
        var dataUser = resUtilsUser.data()!;
        var dataUser4 = resUtilsUser4.data()!;

        expect(dataUser["anonymousChatCounter"], 1);
        expect(dataUser4["anonymousChatCounter"], 1);
      });
    });

    group("Remove chat:", () {
      test("Check that removeChatFromDB deletes the chat for both the users", () async {
        await firestoreService.addUserIntoDB(testHelper.loggedUser);
        await firestoreService.addUserIntoDB(testHelper.baseUser4);
        await firestoreService.addMessageIntoDB(testHelper.loggedUser, testHelper.request_4, message);

        await firestoreService.removeChatFromDB(testHelper.baseUser4, pendingChatOfUser4);

        /// Get the data from the fakeFirebase
        var resRequest = await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.loggedUser.id).collection(Request.COLLECTION).get();
        var resPendingChat = await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.baseUser4.id).collection(PendingChat.COLLECTION).get();

        expect(resRequest.docs, isEmpty);
        expect(resPendingChat.docs, isEmpty);
      });

      test("Check that removeChatFromDB decrements the anonymousChatCounter for both the users", () async {
        await firestoreService.addUserIntoDB(testHelper.loggedUser);
        await firestoreService.addUserIntoDB(testHelper.baseUser4);
        await firestoreService.addMessageIntoDB(testHelper.loggedUser, testHelper.request_4, message);

        await Future.delayed(Duration.zero);

        await firestoreService.removeChatFromDB(testHelper.baseUser4, pendingChatOfUser4);

        await Future.delayed(Duration.zero);

        /// Get the data from the fakeFirebase
        var resUtilsUser = await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.loggedUser.id).collection("utils").doc("utils").get();
        var resUtilsUser4 = await fakeFirebase.collection(BaseUser.COLLECTION).doc(testHelper.baseUser4.id).collection("utils").doc("utils").get();
        var dataUser = resUtilsUser.data()!;
        var dataUser4 = resUtilsUser4.data()!;

        expect(dataUser["anonymousChatCounter"], 0);
        expect(dataUser4["anonymousChatCounter"], 0);
      });
    });

    group("Get chats stream:", () {
      test("Check that getChatsStreamFromDB returns the correct stream of chats ordered by lastMessageDateTime", () async {
        await firestoreService.addUserIntoDB(testHelper.loggedUser);
        await firestoreService.addUserIntoDB(testHelper.baseUser);
        await firestoreService.addUserIntoDB(testHelper.baseUser2);
        await firestoreService.addUserIntoDB(testHelper.baseUser3);

        /// Add the chats into the fakeFirebase
        await firestoreService.addMessageIntoDB(testHelper.loggedUser, testHelper.anonymousChat, message);
        await firestoreService.addMessageIntoDB(testHelper.loggedUser, testHelper.anonymousChat2_2, message2);
        await firestoreService.addMessageIntoDB(testHelper.loggedUser, testHelper.anonymousChat3_3, message3);

        /// Delay for awaiting that the transaction completes
        await Future.delayed(Duration.zero);

        var stream = firestoreService.getChatsStreamFromDB(testHelper.loggedUser, AnonymousChat.COLLECTION);
        expect(stream, emits(isA<QuerySnapshot>()));

        var res = await stream.first;

        for (int i = 0; i < testHelper.anonymousChats.length; i++) {
          AnonymousChat c = AnonymousChat.fromDocument(res.docs[i]);
          expect(c.peerUser!.id, testHelper.anonymousChats[i].peerUser!.id);
        }
      });
    });
  });

  /***************************************** REPORTS *****************************************/

  group("Firestore report methods:", () {
    setUp(() async {
      /// Fake Firebase
      fakeFirebase = FakeFirebaseFirestore();
      firestoreService = FirestoreService(fakeFirebase, firebaseStorage: fakeFirebaseStorage);
    });

    group("Add new report:", () {
      test("Check that the DB contains the document with the report information", () async {
        await firestoreService.addReportIntoDB(testHelper.loggedUser.id, testHelper.report);

        /// Get the data from the fakeFirebase
        var res =
            await fakeFirebase.collection(Report.COLLECTION).doc(testHelper.loggedUser.id).collection("reportList").doc(testHelper.report.id).get();
        Report retrievedReport = Report.fromDocument(res);

        expect(res.id, testHelper.report.id);
        expect(retrievedReport.category, testHelper.report.category);
        expect(retrievedReport.description, testHelper.report.description);
        expect(retrievedReport.dateTime, testHelper.report.dateTime);
      });
    });

    group("Get reports:", () {
      test("Check that getReportsFromDB returns the correct future of reports ordered by documentId", () async {
        /// Add the reports into the fakeFirebase
        await firestoreService.addReportIntoDB(testHelper.loggedUser.id, testHelper.report);
        await firestoreService.addReportIntoDB(testHelper.loggedUser.id, testHelper.report2);
        await firestoreService.addReportIntoDB(testHelper.loggedUser.id, testHelper.report3);

        var res = await firestoreService.getReportsFromDB(testHelper.loggedUser.id);
        expect(res, isA<QuerySnapshot>());

        for (int i = 0; i < testHelper.reports.length; i++) {
          Report r = Report.fromDocument(res.docs[i]);
          expect(r.id, testHelper.reports[i].id);
        }
      });
    });
  });

  /***************************************** DIARY *****************************************/

  group("Firestore diary methods:", () {
    setUp(() async {
      /// Fake Firebase
      fakeFirebase = FakeFirebaseFirestore();
      firestoreService = FirestoreService(fakeFirebase, firebaseStorage: fakeFirebaseStorage);
    });

    group("Add new diary page:", () {
      test("Check that the DB contains the document with the diary page information", () async {
        await firestoreService.addDiaryPageIntoDB(testHelper.loggedUser.id, testHelper.diaryPage);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase
            .collection(DiaryPage.COLLECTION)
            .doc(testHelper.loggedUser.id)
            .collection("diaryPages")
            .doc(testHelper.diaryPage.id)
            .get();
        DiaryPage retrieveDiaryPage = DiaryPage.fromDocument(res);

        expect(res.id, testHelper.diaryPage.id);
        expect(retrieveDiaryPage.title, testHelper.diaryPage.title);
        expect(retrieveDiaryPage.content, testHelper.diaryPage.content);
        expect(retrieveDiaryPage.dateTime, testHelper.diaryPage.dateTime);
        expect(retrieveDiaryPage.favourite, testHelper.diaryPage.favourite);
      });
    });

    group("Update diary page:", () {
      test("Check that the DB contains the document with the updated information of the diary page", () async {
        await firestoreService.addDiaryPageIntoDB(testHelper.loggedUser.id, testHelper.diaryPage);

        var diaryPageUpdated = testHelper.diaryPage;

        diaryPageUpdated.title = "Title updated";
        diaryPageUpdated.content = "Content updated";
        diaryPageUpdated.dateTime = DateTime(2022, 1, 8);

        await firestoreService.updateDiaryPageIntoDB(testHelper.loggedUser.id, diaryPageUpdated);

        /// Get the data from the fakeFirebase
        var res =
            await fakeFirebase.collection(DiaryPage.COLLECTION).doc(testHelper.loggedUser.id).collection("diaryPages").doc(diaryPageUpdated.id).get();
        DiaryPage retrieveDiaryPage = DiaryPage.fromDocument(res);

        expect(res.id, diaryPageUpdated.id);
        expect(retrieveDiaryPage.title, diaryPageUpdated.title);
        expect(retrieveDiaryPage.content, diaryPageUpdated.content);
        expect(retrieveDiaryPage.dateTime, diaryPageUpdated.dateTime);
        expect(retrieveDiaryPage.favourite, diaryPageUpdated.favourite);
      });
    });

    group("Set diary page as favourite:", () {
      test("Check that the DB contains the document with the updated information of the diary page", () async {
        await firestoreService.addDiaryPageIntoDB(testHelper.loggedUser.id, testHelper.diaryPage);

        testHelper.diaryPage.favourite = !testHelper.diaryPage.favourite;

        await firestoreService.setDiaryPageAsFavouriteIntoDB(testHelper.loggedUser.id, testHelper.diaryPage);

        /// Get the data from the fakeFirebase
        var res = await fakeFirebase
            .collection(DiaryPage.COLLECTION)
            .doc(testHelper.loggedUser.id)
            .collection("diaryPages")
            .doc(testHelper.diaryPage.id)
            .get();
        DiaryPage retrieveDiaryPage = DiaryPage.fromDocument(res);

        expect(res.id, testHelper.diaryPage.id);
        expect(retrieveDiaryPage.favourite, testHelper.diaryPage.favourite);
      });
    });

    group("Get diary pages:", () {
      test("Check that getDiaryPagesStreamFromDB returns the correct stream of diaryPages ordered by documentId", () async {
        /// Add the diary pages into the fakeFirebase
        await firestoreService.addDiaryPageIntoDB(testHelper.loggedUser.id, testHelper.diaryPage);
        await firestoreService.addDiaryPageIntoDB(testHelper.loggedUser.id, testHelper.diaryPage2);
        await firestoreService.addDiaryPageIntoDB(testHelper.loggedUser.id, testHelper.diaryPage3);

        var stream = firestoreService.getDiaryPagesStreamFromDB(testHelper.loggedUser.id);
        expect(stream, emits(isA<QuerySnapshot>()));

        var res = await stream.first;

        for (int i = 0; i < testHelper.diaryPages.length; i++) {
          DiaryPage d = DiaryPage.fromDocument(res.docs[i]);
          expect(d.id, testHelper.diaryPages[i].id);
        }
      });
    });
  });
}
