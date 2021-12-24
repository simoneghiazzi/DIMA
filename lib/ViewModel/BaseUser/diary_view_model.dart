import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/ViewModel/Forms/Diary/diary_form.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/DBItems/BaseUser/diary_page.dart';
import 'package:sApport/Model/Services/firestore_service.dart';

class DiaryViewModel with ChangeNotifier {
  // Services
  final FirestoreService _firestoreService = GetIt.I<FirestoreService>();
  final UserService _userService = GetIt.I<UserService>();

  // Diary Form
  final DiaryForm diaryForm = DiaryForm();

  // Text Controllers
  final TextEditingController titleTextCtrl = TextEditingController();
  final TextEditingController contentTextCtrl = TextEditingController();

  // Stream Controllers
  var _isPageAddedCtrl = StreamController<bool>.broadcast();

  var hasDiaryPageToday = false;
  var isEditing = false;
  DiaryPage? _currentDiaryPage;

  DiaryViewModel() {
    // Register the listeners for the input text field
    titleTextCtrl.addListener(() => diaryForm.title.add(titleTextCtrl.text));
    contentTextCtrl.addListener(() => diaryForm.content.add(contentTextCtrl.text));
  }

  /// Add a new diary page into the DB
  Future<void> submitPage() {
    var now = DateTime.now();
    _currentDiaryPage!.id = now.millisecondsSinceEpoch.toString();
    _currentDiaryPage!.title = titleTextCtrl.text.trim();
    _currentDiaryPage!.content = contentTextCtrl.text.trim();
    isEditing = false;
    return _firestoreService
        .addDiaryPageIntoDB(
          _userService.loggedUser!.id,
          _currentDiaryPage!,
        )
        .then((value) => _isPageAddedCtrl.add(true))
        .catchError((error) => _isPageAddedCtrl.add(false));
  }

  /// Update the already existing [_currentDiaryPage] into the DB
  Future<void> updatePage() {
    var now = DateTime.now();
    _currentDiaryPage!.title = titleTextCtrl.text.trim();
    _currentDiaryPage!.content = contentTextCtrl.text.trim();
    _currentDiaryPage!.dateTime = now;
    isEditing = false;
    return _firestoreService
        .updateDiaryPageIntoDB(
          _userService.loggedUser!.id,
          _currentDiaryPage!,
        )
        .then((value) => _isPageAddedCtrl.add(true))
        .catchError((error) => _isPageAddedCtrl.add(false));
  }

  /// Set the [isFavourite] parameter of the [_currentDiaryPage] into the DB.
  Future<void> setFavourite(bool isFavourite) {
    _currentDiaryPage!.favourite = isFavourite;
    return _firestoreService.setFavouriteDiaryNotesIntoDB(
      _userService.loggedUser!.id,
      _currentDiaryPage!,
    );
  }

  /// Get the stream of diary pages from the DB
  Stream<QuerySnapshot>? loadDiaryPages() {
    try {
      return _firestoreService.getDiaryPagesStreamFromDB(_userService.loggedUser!.id);
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

  /// Add a new diary page into the diary.
  void addNewDiaryPage() {
    setCurrentDiaryPage(DiaryPage(dateTime: DateTime.now()));
    isEditing = true;
  }

  /// Set the [diaryPage] as the [_currentDiaryPage].
  void setCurrentDiaryPage(DiaryPage diaryPage) {
    _currentDiaryPage = diaryPage;
    titleTextCtrl.text = diaryPage.title;
    contentTextCtrl.text = diaryPage.content;
    print("Current diary page setted");
    notifyListeners();
  }

  /// Reset the [_currentDiaryPage].
  void resetCurrentDiaryPage() {
    _currentDiaryPage = null;
    print("Current diary page resetted");
    notifyListeners();
  }

  /// Get the [_currentDiaryPage] instance.
  DiaryPage? get currentDiaryPage => _currentDiaryPage;

  /// Stream of the succesfully addition of the diary page
  Stream<bool> get isPageAdded => _isPageAddedCtrl.stream;
}
