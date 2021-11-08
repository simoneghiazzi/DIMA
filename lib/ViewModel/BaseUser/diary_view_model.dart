import 'dart:async';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/Diary/note.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/firestore_service.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/ObserverForms/diary_form.dart';
import 'package:flutter/widgets.dart';

class DiaryViewModel {
  FirestoreService _firestoreService = FirestoreService();
  final DiaryForm diaryForm = DiaryForm();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  var isPageCorrectlyAdded = StreamController<bool>.broadcast();

  final String loggedId;

  DiaryViewModel(this.loggedId) {
    titleController
        .addListener(() => diaryForm.titleText.add(titleController.text));
    contentController
        .addListener(() => diaryForm.contentText.add(contentController.text));
  }

  Future<void> submitPage() async {
    var timestamp = DateTime.now();
    _firestoreService
        .addDiaryNotesIntoDB(
            loggedId,
            Note(
                id: timestamp.millisecondsSinceEpoch.toString(),
                title: titleController.text,
                content: contentController.text,
                date: timestamp,
                isFavourite: false))
        .then((value) {
      isPageCorrectlyAdded.add(true);
      titleController.clear();
      contentController.clear();
    }).catchError((error) {
      isPageCorrectlyAdded.add(false);
    });
  }

  Future<void> updatePage(String pageId, bool isFavourite) async {
    var timestamp = DateTime.now();
    _firestoreService
        .addDiaryNotesIntoDB(
            loggedId,
            Note(
                id: pageId,
                title: titleController.text,
                content: contentController.text,
                date: timestamp,
                isFavourite: isFavourite))
        .then((value) {
      isPageCorrectlyAdded.add(true);
      titleController.clear();
      contentController.clear();
    }).catchError((error) {
      isPageCorrectlyAdded.add(false);
    });
  }

  Future<void> favouritePage(Note note, bool isFavourite) async {
    _firestoreService
        .addDiaryNotesIntoDB(
            loggedId,
            Note(
                id: note.id,
                title: note.title,
                content: note.content,
                date: note.date,
                isFavourite: isFavourite))
        .then((value) {
      isPageCorrectlyAdded.add(true);
      titleController.clear();
      contentController.clear();
    }).catchError((error) {
      isPageCorrectlyAdded.add(false);
    });
  }

  Future<List<Note>> loadPages(DateTime startDate, DateTime endDate) async {
    final List<Note> pages = List.from([]);
    var data = await _firestoreService.getDiaryNotesFromDB(
      loggedId,
      startDate,
      endDate,
    );
    for (var doc in data.docs) {
      Note n = Note();
      n.setFromDocument(doc);
      pages.add(n);
    }
    return pages;
  }

  Stream<bool> get isPageAdded => isPageCorrectlyAdded.stream;
}
