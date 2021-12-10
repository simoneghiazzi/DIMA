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
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController contentCtrl = TextEditingController();

  // Stream Controllers
  var _isPageCorrectlyAdded = StreamController<bool>.broadcast();

  var hasNoteToday = false;

  DiaryViewModel() {
    // Register the listeners for the input text field
    titleCtrl.addListener(() => diaryForm.title.add(titleCtrl.text));
    contentCtrl.addListener(() => diaryForm.content.add(contentCtrl.text));
  }

  /// Add a new diary page into the DB
  Future<void> submitPage() {
    var now = DateTime.now();
    return _firestoreService
        .addDiaryPageIntoDB(
          _firebaseAuthService.userCredential.user.uid,
          DiaryPage(
            id: now.millisecondsSinceEpoch.toString(),
            title: titleCtrl.text,
            content: contentCtrl.text,
            date: DateTime(now.year, now.month, now.day),
            favourite: false,
          ),
        )
        .then((value) => _isPageCorrectlyAdded.add(true))
        .catchError((error) => _isPageCorrectlyAdded.add(false));
  }

  /// Update the already existing diary page identified by the [pageId] into the DB
  Future<void> updatePage(String pageId) {
    var now = DateTime.now();
    return _firestoreService
        .updateDiaryPageIntoDB(
          _firebaseAuthService.userCredential.user.uid,
          DiaryPage(
            id: pageId,
            title: titleCtrl.text,
            content: contentCtrl.text,
            date: DateTime(now.year, now.month, now.day),
          ),
        )
        .then((value) => _isPageCorrectlyAdded.add(true))
        .catchError((error) => _isPageCorrectlyAdded.add(false));
  }

  /// Set the [isFavourite] parameter of the diary page identified by the [pageId] into the DB
  Future<void> setFavourite(String pageId, bool isFavourite) {
    return _firestoreService.setFavouriteDiaryNotesIntoDB(
      _firebaseAuthService.userCredential.user.uid,
      DiaryPage(id: pageId, favourite: isFavourite),
    );
  }

  /// Get the stream of diary pages from the DB
  Stream<QuerySnapshot> loadPagesStream() {
    return _firestoreService.getDiaryPagesStreamFromDB(_firebaseAuthService.userCredential.user.uid);
  }

  /// Clear all the text and stream controllers and reset the diary form
  void clearControllers() {
    titleCtrl.clear();
    contentCtrl.clear();
    diaryForm.resetControllers();
  }

  /// Set the text controllers data
  void setTextContent(String title, String content) {
    titleCtrl.text = title;
    contentCtrl.text = content;
  }

  /// Stream of the succesfully addition of the diary page
  Stream<bool> get isPageAdded => _isPageCorrectlyAdded.stream;
}
