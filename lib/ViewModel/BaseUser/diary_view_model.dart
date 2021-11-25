import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/BaseUser/Diary/note.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/ViewModel/ObserverForms/diary_form.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class DiaryViewModel {
  FirestoreService _firestoreService = GetIt.I<FirestoreService>();
  final DiaryForm diaryForm = DiaryForm();
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController contentCtrl = TextEditingController();
  Note submittedNote;
  var hasNoteToday = false;
  var isPageCorrectlyAdded = StreamController<bool>.broadcast();

  String loggedId;

  DiaryViewModel() {
    titleCtrl.addListener(() => diaryForm.title.add(titleCtrl.text));
    contentCtrl.addListener(() => diaryForm.content.add(contentCtrl.text));
  }

  Future<void> submitPage({String pageId, bool isFavourite = false}) {
    var now = DateTime.now();
    var date = DateTime(now.year, now.month, now.day);
    submittedNote = Note(
      id: pageId ?? now.millisecondsSinceEpoch.toString(),
      title: titleCtrl.text,
      content: contentCtrl.text,
      date: date,
      favourite: isFavourite,
    );
    return _firestoreService.addDiaryNoteIntoDB(loggedId, submittedNote).then((value) {
      print("Diary note added");
      isPageCorrectlyAdded.add(true);
    }).catchError((error) {
      print("Failed to add the diary note: $error");
      isPageCorrectlyAdded.add(false);
    });
  }

  void clearControllers() {
    titleCtrl.clear();
    contentCtrl.clear();
    diaryForm.title.add(null);
    diaryForm.content.add(null);
  }

  /// Set the text data
  void setTextContent(String title, String content) {
    titleCtrl.text = title;
    contentCtrl.text = content;
  }

  Future<void> setFavourite(String pageId, bool isFavourite) {
    return _firestoreService.setFavouriteDiaryNotesIntoDB(loggedId, Note(id: pageId, favourite: isFavourite));
  }

  Stream<QuerySnapshot> loadPagesStream() {
    return _firestoreService.getDiaryNotesStreamFromDB(loggedId);
    // for (var doc in data.docs) {
    //   Note n = Note();
    //   n.setFromDocument(doc);
    //   pages.add(n);
    //   if (now.isAfter(startDate) && now.isBefore(endDate) && n.date == DateTime(now.year, now.month, now.day)) {
    //     hasNoteToday = true;
    //   }
    // }
    // return pages;
  }

  Stream<bool> get isPageAdded => isPageCorrectlyAdded.stream;
}
