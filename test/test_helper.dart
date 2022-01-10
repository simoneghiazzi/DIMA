import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sApport/Model/Chat/active_chat.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/Chat/request.dart';
import 'package:sApport/Model/Chat/expert_chat.dart';
import 'package:sApport/Model/Chat/pending_chat.dart';
import 'package:sApport/Model/Chat/anonymous_chat.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Model/DBItems/BaseUser/report.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Model/DBItems/BaseUser/diary_page.dart';

class DatabaseNotAttachedException implements Exception {}

class TestHelper {
  /// Fake Firebase
  FakeFirebaseFirestore? fakeFirebase;

  /// Logged User
  late BaseUser loggedUser;
  late Expert loggedExpert;

  /// Base Users
  late BaseUser baseUser;
  late BaseUser baseUser2;
  late BaseUser baseUser3;
  late BaseUser baseUser4;
  late BaseUser baseUser5;
  late BaseUser baseUser6;

  /// Experts
  late Expert expert;
  late Expert expert2;
  late Expert expert3;
  List<Expert> get experts => [expert, expert2, expert3];
  LinkedHashMap<String, Expert> get expertsLinkedHashMap {
    var linkedHashMap = LinkedHashMap<String, Expert>();
    linkedHashMap[expert.id] = expert;
    linkedHashMap[expert2.id] = expert2;
    linkedHashMap[expert3.id] = expert3;
    return linkedHashMap;
  }

  Future<QuerySnapshot> get expertsFuture {
    if (fakeFirebase != null) {
      return fakeFirebase!.collection(Expert.COLLECTION).get();
    } else {
      throw DatabaseNotAttachedException();
    }
  }

  /// Anonymous Chats
  late AnonymousChat anonymousChat;
  late AnonymousChat anonymousChat2_2;
  late AnonymousChat anonymousChat3_3;
  List<AnonymousChat> get anonymousChats => [anonymousChat, anonymousChat2_2, anonymousChat3_3];
  Stream<QuerySnapshot> get anonymousChatsStream {
    if (fakeFirebase != null) {
      return fakeFirebase!.collection(BaseUser.COLLECTION).doc(loggedUser.id).collection(AnonymousChat.COLLECTION).snapshots();
    } else {
      throw DatabaseNotAttachedException();
    }
  }

  /// Expert Chats
  late ExpertChat expertChat;
  late ExpertChat expertChat2_2;
  List<ExpertChat> get expertsChats => [expertChat, expertChat2_2];
  Stream<QuerySnapshot> get expertsChatsStream {
    if (fakeFirebase != null) {
      return fakeFirebase!.collection(BaseUser.COLLECTION).doc(loggedUser.id).collection(ExpertChat.COLLECTION).snapshots();
    } else {
      throw DatabaseNotAttachedException();
    }
  }

  /// Anonymous Chats
  late ActiveChat activeChat;
  late ActiveChat activeChat2_2;
  late ActiveChat activeChat3_3;
  List<ActiveChat> get activeChats => [activeChat, activeChat2_2, activeChat3_3];
  Stream<QuerySnapshot> get activeChatsStream {
    if (fakeFirebase != null) {
      return fakeFirebase!.collection(Expert.COLLECTION).doc(loggedExpert.id).collection(ActiveChat.COLLECTION).snapshots();
    } else {
      throw DatabaseNotAttachedException();
    }
  }

  /// Request
  late Request request_4;

  /// Pending Chats
  late PendingChat pendingChat_5;
  late PendingChat pendingChat2_6;
  List<PendingChat> get pendingChats => [pendingChat_5, pendingChat2_6];
  Stream<QuerySnapshot> get pendingChatsStream {
    if (fakeFirebase != null) {
      return fakeFirebase!.collection(BaseUser.COLLECTION).doc(loggedUser.id).collection(PendingChat.COLLECTION).snapshots();
    } else {
      throw DatabaseNotAttachedException();
    }
  }

  /// Reports
  late Report report;
  late Report report2;
  late Report report3;
  List<Report> get reports => [report, report2, report3];
  Future<QuerySnapshot> get reportsFuture {
    if (fakeFirebase != null) {
      return fakeFirebase!.collection(Report.COLLECTION).doc(loggedUser.id).collection("reportList").orderBy(FieldPath.documentId).get();
    } else {
      throw DatabaseNotAttachedException();
    }
  }

  /// Diary Pages
  late DiaryPage diaryPage;
  late DiaryPage diaryPage2;
  late DiaryPage diaryPage3;
  List<DiaryPage> get diaryPages => [diaryPage, diaryPage2, diaryPage3];
  Stream<QuerySnapshot> get diaryPagesStream {
    if (fakeFirebase != null) {
      return fakeFirebase!.collection(DiaryPage.COLLECTION).doc(loggedUser.id).collection("diaryPages").orderBy(FieldPath.documentId).snapshots();
    } else {
      throw DatabaseNotAttachedException();
    }
  }

  TestHelper() {
    _createInstances();
  }

  void _createInstances() {
    /// Logged User
    loggedUser = BaseUser(id: Utils.randomId(), name: "Logged", surname: "Test", email: "l.t@sApport.it", birthDate: DateTime(2022, 1, 13));
    loggedExpert = Expert(
        id: Utils.randomId(),
        name: "Logged",
        surname: "Test",
        email: "logged.test@sApport.it",
        birthDate: DateTime(1981, 7, 12),
        address: "Piazza Leonardo da Vinci, Milano, Italia",
        latitude: 45.478195,
        longitude: 9.2256787,
        phoneNumber: "331331331",
        profilePhoto: "image.png");

    /// Base Users
    baseUser = BaseUser(id: Utils.randomId(), name: "Luca", surname: "Colombo", email: "l.c@sApport.it", birthDate: DateTime(1997, 10, 19));
    baseUser2 = BaseUser(id: Utils.randomId(), name: "Simone", surname: "Ghiazzi", email: "s.g@sApport.it", birthDate: DateTime(1997, 02, 26));
    baseUser3 = BaseUser(id: Utils.randomId(), name: "Pippo", surname: "Pluto", email: "p.p@sApport.it", birthDate: DateTime(1980, 12, 5));
    baseUser4 = BaseUser(id: Utils.randomId(), name: "Sofia", surname: "Verdi", email: "s.v@sApport.it", birthDate: DateTime(1985, 5, 15));
    baseUser5 = BaseUser(id: Utils.randomId(), name: "Marta", surname: "Blu", email: "m.b@sApport.it", birthDate: DateTime(1972, 4, 3));
    baseUser6 = BaseUser(id: Utils.randomId(), name: "Franco", surname: "Paperino", email: "f.p@sApport.it", birthDate: DateTime(2000, 6, 13));

    /// Experts
    expert = Expert(
        id: Utils.randomId(),
        name: "Mattia",
        surname: "Rossi",
        email: "mattia.rossi@sApport.it",
        birthDate: DateTime(1995, 5, 12),
        address: "Piazza Leonardo da Vinci, Milano, Italia",
        latitude: 45.478195,
        longitude: 9.2256787,
        phoneNumber: "331331331",
        profilePhoto: "image.png");
    expert2 = Expert(
        id: Utils.randomId(),
        name: "Sara",
        surname: "Bianchi",
        email: "sara.bianchi@sApport.it",
        birthDate: DateTime(1997, 8, 1),
        address: "Piazza Leonardo da Vinci, Milano, Italia",
        latitude: 45.478195,
        longitude: 9.2256787,
        phoneNumber: "331331331",
        profilePhoto: "image.png");
    expert3 = Expert(
        id: Utils.randomId(),
        name: "Francesco",
        surname: "Tondi",
        email: "francesco.tondi@sApport.it",
        birthDate: DateTime(1972, 7, 1),
        address: "Piazza Leonardo da Vinci, Milano, Italia",
        latitude: 45.478195,
        longitude: 9.2256787,
        phoneNumber: "331331331",
        profilePhoto: "image.png");

    /// Anonymous Chats
    anonymousChat = AnonymousChat(lastMessage: "Message user 1", lastMessageDateTime: DateTime(2021, 10, 19, 21, 10, 50), peerUser: baseUser);
    anonymousChat2_2 = AnonymousChat(lastMessage: "Message user 2", lastMessageDateTime: DateTime(2022, 1, 8, 13, 10, 50), peerUser: baseUser2);
    anonymousChat3_3 = AnonymousChat(lastMessage: "Message user 3", lastMessageDateTime: DateTime(2022, 1, 8, 13, 11, 20), peerUser: baseUser3);

    /// Expert Chats
    expertChat = ExpertChat(lastMessage: "Message expert 1", lastMessageDateTime: DateTime(2021, 11, 15, 21, 10, 50), peerUser: expert);
    expertChat2_2 = ExpertChat(lastMessage: "Message expert 2", lastMessageDateTime: DateTime(2021, 12, 8, 2, 10, 50), peerUser: expert2);

    /// Request
    request_4 = Request(lastMessage: "Message request", lastMessageDateTime: DateTime(2021, 09, 10, 15, 10, 34), peerUser: baseUser4);

    /// Pending Chats
    pendingChat_5 = PendingChat(lastMessage: "Message pending chat", lastMessageDateTime: DateTime(2022, 1, 1, 8, 52, 24), peerUser: baseUser5);
    pendingChat2_6 = PendingChat(lastMessage: "Message pending chat 2", lastMessageDateTime: DateTime(2022, 1, 5, 22, 21, 12), peerUser: baseUser6);

    /// Active Chats
    activeChat = ActiveChat(lastMessage: "Message user 1", lastMessageDateTime: DateTime(2021, 10, 19, 21, 10, 50), peerUser: baseUser);
    activeChat2_2 = ActiveChat(lastMessage: "Message user 2", lastMessageDateTime: DateTime(2022, 1, 8, 13, 10, 50), peerUser: baseUser2);
    activeChat3_3 = ActiveChat(lastMessage: "Message user 3", lastMessageDateTime: DateTime(2022, 1, 8, 13, 11, 20), peerUser: baseUser3);

    /// Reports
    var reportDate = DateTime(2021, 8, 5, 13, 00, 25);
    var reportTimestamp = reportDate.millisecondsSinceEpoch;
    report = Report(id: reportTimestamp.toString(), category: "Report category", description: "Report description", dateTime: reportDate);

    var report2Date = DateTime(2021, 10, 5, 13, 00, 25);
    var report2Timestamp = report2Date.millisecondsSinceEpoch;
    report2 = Report(id: report2Timestamp.toString(), category: "Report category 2", description: "Report description 2", dateTime: report2Date);

    var report3Date = DateTime(2022, 1, 5, 13, 00, 25);
    var report3Timestamp = report3Date.millisecondsSinceEpoch;
    report3 = Report(id: report3Timestamp.toString(), category: "Report category 3", description: "Report description 3", dateTime: report3Date);

    /// Diary Pages
    var diaryPageDate = DateTime(2021, 3, 19);
    var diaryPageTimestamp = diaryPageDate.millisecondsSinceEpoch;
    diaryPage = DiaryPage(id: diaryPageTimestamp.toString(), title: "Diary page title", content: "Diary page content", dateTime: diaryPageDate);

    var diaryPage2Date = DateTime(2021, 3, 30);
    var diaryPage2Timestamp = diaryPage2Date.millisecondsSinceEpoch;
    diaryPage2 =
        DiaryPage(id: diaryPage2Timestamp.toString(), title: "Diary page title 2", content: "Diary page content 2", dateTime: diaryPage2Date);

    var diaryPage3Date = DateTime(2022, 1, 5);
    var diaryPage3Timestamp = diaryPage3Date.millisecondsSinceEpoch;
    diaryPage3 =
        DiaryPage(id: diaryPage3Timestamp.toString(), title: "Diary page title 3", content: "Diary page content 3", dateTime: diaryPage3Date);
  }

  Future<void> attachDB(FakeFirebaseFirestore fakeFirebase) async {
    this.fakeFirebase = fakeFirebase;

    /// Add the users to the fakeFirebase
    fakeFirebase.collection(BaseUser.COLLECTION).doc(loggedUser.id).set(loggedUser.data);
    fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser.id).set(baseUser.data);
    fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser2.id).set(baseUser2.data);
    fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser3.id).set(baseUser3.data);
    fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser4.id).set(baseUser4.data);
    fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser5.id).set(baseUser5.data);
    fakeFirebase.collection(BaseUser.COLLECTION).doc(baseUser6.id).set(baseUser6.data);

    /// Add the experts to the fakeFirebase
    fakeFirebase.collection(Expert.COLLECTION).doc(expert.id).set(expert.data);
    fakeFirebase.collection(Expert.COLLECTION).doc(expert2.id).set(expert2.data);
    fakeFirebase.collection(Expert.COLLECTION).doc(expert3.id).set(expert3.data);

    /// Add the anonymous chats of the logged user to the fakeFirebase
    fakeFirebase.collection(BaseUser.COLLECTION).doc(loggedUser.id).collection(AnonymousChat.COLLECTION).doc(anonymousChat.peerUser!.id).set({
      "lastMessageTimestamp": anonymousChat.lastMessageDateTime!.millisecondsSinceEpoch,
      "notReadMessages": anonymousChat.notReadMessages,
      "lastMessage": anonymousChat.lastMessage
    });
    fakeFirebase.collection(BaseUser.COLLECTION).doc(loggedUser.id).collection(AnonymousChat.COLLECTION).doc(anonymousChat2_2.peerUser!.id).set({
      "lastMessageTimestamp": anonymousChat2_2.lastMessageDateTime!.millisecondsSinceEpoch,
      "notReadMessages": anonymousChat2_2.notReadMessages,
      "lastMessage": anonymousChat2_2.lastMessage
    });
    fakeFirebase.collection(BaseUser.COLLECTION).doc(loggedUser.id).collection(AnonymousChat.COLLECTION).doc(anonymousChat3_3.peerUser!.id).set({
      "lastMessageTimestamp": anonymousChat3_3.lastMessageDateTime!.millisecondsSinceEpoch,
      "notReadMessages": anonymousChat3_3.notReadMessages,
      "lastMessage": anonymousChat3_3.lastMessage
    });

    /// Add the expert chats of the logged user to the fakeFirebase
    fakeFirebase.collection(BaseUser.COLLECTION).doc(loggedUser.id).collection(ExpertChat.COLLECTION).doc(expertChat.peerUser!.id).set({
      "lastMessageTimestamp": expertChat.lastMessageDateTime!.millisecondsSinceEpoch,
      "notReadMessages": expertChat.notReadMessages,
      "lastMessage": expertChat.lastMessage
    });
    fakeFirebase.collection(BaseUser.COLLECTION).doc(loggedUser.id).collection(ExpertChat.COLLECTION).doc(expertChat2_2.peerUser!.id).set({
      "lastMessageTimestamp": expertChat2_2.lastMessageDateTime!.millisecondsSinceEpoch,
      "notReadMessages": expertChat2_2.notReadMessages,
      "lastMessage": expertChat2_2.lastMessage
    });

    /// Add the active chats of the logged expert to the fakeFirebase
    fakeFirebase.collection(Expert.COLLECTION).doc(loggedExpert.id).collection(ActiveChat.COLLECTION).doc(activeChat.peerUser!.id).set({
      "lastMessageTimestamp": activeChat.lastMessageDateTime!.millisecondsSinceEpoch,
      "notReadMessages": activeChat.notReadMessages,
      "lastMessage": activeChat.lastMessage
    });
    fakeFirebase.collection(Expert.COLLECTION).doc(loggedExpert.id).collection(ActiveChat.COLLECTION).doc(activeChat2_2.peerUser!.id).set({
      "lastMessageTimestamp": activeChat2_2.lastMessageDateTime!.millisecondsSinceEpoch,
      "notReadMessages": activeChat2_2.notReadMessages,
      "lastMessage": activeChat2_2.lastMessage
    });
    fakeFirebase.collection(Expert.COLLECTION).doc(loggedExpert.id).collection(ActiveChat.COLLECTION).doc(activeChat3_3.peerUser!.id).set({
      "lastMessageTimestamp": activeChat3_3.lastMessageDateTime!.millisecondsSinceEpoch,
      "notReadMessages": activeChat3_3.notReadMessages,
      "lastMessage": activeChat3_3.lastMessage
    });

    /// Add the requests of the logged user to the fakeFirebase
    fakeFirebase.collection(BaseUser.COLLECTION).doc(loggedUser.id).collection(Request.COLLECTION).doc(request_4.peerUser!.id).set({
      "lastMessageTimestamp": request_4.lastMessageDateTime!.millisecondsSinceEpoch,
      "notReadMessages": request_4.notReadMessages,
      "lastMessage": request_4.lastMessage
    });

    /// Add the pending chats of the logged user to the fakeFirebase
    fakeFirebase.collection(BaseUser.COLLECTION).doc(loggedUser.id).collection(PendingChat.COLLECTION).doc(pendingChat_5.peerUser!.id).set({
      "lastMessageTimestamp": pendingChat_5.lastMessageDateTime!.millisecondsSinceEpoch,
      "notReadMessages": pendingChat_5.notReadMessages,
      "lastMessage": pendingChat_5.lastMessage
    });
    fakeFirebase.collection(BaseUser.COLLECTION).doc(loggedUser.id).collection(PendingChat.COLLECTION).doc(pendingChat2_6.peerUser!.id).set({
      "lastMessageTimestamp": pendingChat2_6.lastMessageDateTime!.millisecondsSinceEpoch,
      "notReadMessages": pendingChat2_6.notReadMessages,
      "lastMessage": pendingChat2_6.lastMessage
    });

    /// Add the reports of the logged user to the fakeFirebase
    fakeFirebase.collection(Report.COLLECTION).doc(loggedUser.id).collection("reportList").doc(report.id).set(report.data);
    fakeFirebase.collection(Report.COLLECTION).doc(loggedUser.id).collection("reportList").doc(report2.id).set(report2.data);
    fakeFirebase.collection(Report.COLLECTION).doc(loggedUser.id).collection("reportList").doc(report3.id).set(report3.data);

    /// Add the diary pages of the logged user to the fakeFirebase
    fakeFirebase.collection(DiaryPage.COLLECTION).doc(loggedUser.id).collection("diaryPages").doc(diaryPage.id).set(diaryPage.data);
    fakeFirebase.collection(DiaryPage.COLLECTION).doc(loggedUser.id).collection("diaryPages").doc(diaryPage2.id).set(diaryPage2.data);
    fakeFirebase.collection(DiaryPage.COLLECTION).doc(loggedUser.id).collection("diaryPages").doc(diaryPage3.id).set(diaryPage3.data);
  }
}
