import 'dart:async';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/Diary/note.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/firestore_service.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/ObserverForms/diary_form.dart';
import 'package:flutter/widgets.dart';

class DiaryViewModel {
  FirestoreService _firestoreService = FirestoreService();
  final DiaryForm diaryForm = DiaryForm();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  Note submittedNote;
  var hasNoteToday = false;
  var isPageCorrectlyAdded = StreamController<bool>.broadcast();

  String loggedId;

  DiaryViewModel() {
    _titleController
        .addListener(() => diaryForm.titleText.add(_titleController.text));
    _contentController
        .addListener(() => diaryForm.contentText.add(_contentController.text));
  }

  Future<void> submitPage({String pageId, bool isFavourite = false}) async {
    var timestamp = DateTime.now();
    var date = DateTime(timestamp.year, timestamp.month, timestamp.day);
    submittedNote = Note(
        id: pageId ?? timestamp.millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        content: _contentController.text,
        date: date,
        favourite: isFavourite);
    await _firestoreService
        .addDiaryNotesIntoDB(loggedId, submittedNote)
        .then((value) {
      isPageCorrectlyAdded.add(true);
    }).catchError((error) {
      isPageCorrectlyAdded.add(false);
    });
  }

  void clearControllers() {
    _titleController.clear();
    _contentController.clear();
    diaryForm.titleText.add(null);
    diaryForm.contentText.add(null);
  }

  /// Set the text data
  void setTextContent(String title, String content) {
    _titleController.text = title;
    _contentController.text = content;
  }

  Future<void> setFavourite(String pageId, bool isFavourite) async {
    await _firestoreService.setFavouriteDiaryNotesIntoDB(
        loggedId, Note(id: pageId, favourite: isFavourite));
  }

  Future<List<Note>> loadPages(DateTime startDate, DateTime endDate) async {
    final List<Note> pages = List.from([]);
    var now = DateTime.now();
    var data = await _firestoreService.getDiaryNotesFromDB(
      loggedId,
      startDate,
      endDate,
    );
    for (var doc in data.docs) {
      Note n = Note();
      n.setFromDocument(doc);
      pages.add(n);
      if (now.isAfter(startDate) &&
          now.isBefore(endDate) &&
          n.date == DateTime(now.year, now.month, now.day)) {
        hasNoteToday = true;
      }
    }
    return pages;
  }

  Stream<bool> get isPageAdded => isPageCorrectlyAdded.stream;
  TextEditingController get titleController => _titleController;
  TextEditingController get contentController => _contentController;
}
