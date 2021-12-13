import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/ViewModel/Forms/diary_form.dart';
import 'package:sApport/Model/BaseUser/Diary/diary_page.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';

class DiaryViewModel {
  // Services
  final FirestoreService _firestoreService = GetIt.I<FirestoreService>();
  final FirebaseAuthService _firebaseAuthService = GetIt.I<FirebaseAuthService>();

  // Diary Form
  final DiaryForm diaryForm = DiaryForm();

  // Text Controllers
  final TextEditingController titleTextCtrl = TextEditingController();
  final TextEditingController contentTextCtrl = TextEditingController();

  // Stream Controllers
  var _isPageAddedCtrl = StreamController<bool>.broadcast();

  var hasNoteToday = false;

  DiaryViewModel() {
    // Register the listeners for the input text field
    titleTextCtrl.addListener(() => diaryForm.title.add(titleTextCtrl.text));
    contentTextCtrl.addListener(() => diaryForm.content.add(contentTextCtrl.text));
  }

  /// Add a new diary page into the DB
  Future<void> submitPage() {
    var now = DateTime.now();
    return _firestoreService
        .addDiaryPageIntoDB(
          _firebaseAuthService.firebaseUser.uid,
          DiaryPage(
            id: now.millisecondsSinceEpoch.toString(),
            title: titleTextCtrl.text,
            content: contentTextCtrl.text,
            dateTime: now,
            favourite: false,
          ),
        )
        .then((value) => _isPageAddedCtrl.add(true))
        .catchError((error) => _isPageAddedCtrl.add(false));
  }

  /// Update the already existing diary page identified by the [pageId] into the DB
  Future<void> updatePage(String pageId) {
    var now = DateTime.now();
    return _firestoreService
        .updateDiaryPageIntoDB(
          _firebaseAuthService.firebaseUser.uid,
          DiaryPage(
            id: pageId,
            title: titleTextCtrl.text,
            content: contentTextCtrl.text,
            dateTime: now,
          ),
        )
        .then((value) => _isPageAddedCtrl.add(true))
        .catchError((error) => _isPageAddedCtrl.add(false));
  }

  /// Set the [isFavourite] parameter of the diary page identified by the [pageId] into the DB
  Future<void> setFavourite(String pageId, bool isFavourite) {
    return _firestoreService.setFavouriteDiaryNotesIntoDB(
      _firebaseAuthService.firebaseUser.uid,
      DiaryPage(id: pageId, favourite: isFavourite),
    );
  }

  /// Get the stream of diary pages from the DB
  Stream<QuerySnapshot> loadDiaryPages() {
    try {
      return _firestoreService.getDiaryPagesStreamFromDB(_firebaseAuthService.firebaseUser.uid);
    } catch (e) {
      print("Failed to get the stream of diary pages: $e");
      return null;
    }
  }

  /// Clear all the text and stream controllers and reset the diary form
  void clearControllers() {
    titleTextCtrl.clear();
    contentTextCtrl.clear();
    diaryForm.resetControllers();
  }

  /// Set the text controllers data
  void setTextContent(String title, String content) {
    titleTextCtrl.text = title;
    contentTextCtrl.text = content;
  }

  /// Stream of the succesfully addition of the diary page
  Stream<bool> get isPageAdded => _isPageAddedCtrl.stream;
}
