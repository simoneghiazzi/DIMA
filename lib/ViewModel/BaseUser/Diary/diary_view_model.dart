import 'dart:async';
import 'dart:developer';
import 'package:get_it/get_it.dart';
import 'package:flutter/widgets.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/DBItems/BaseUser/diary_page.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/ViewModel/BaseUser/Diary/diary_form.dart';

class DiaryViewModel with ChangeNotifier {
  // Services
  final FirestoreService _firestoreService = GetIt.I<FirestoreService>();
  final UserService _userService = GetIt.I<UserService>();

  // Diary Form
  DiaryForm diaryForm = DiaryForm();

  // Text Controllers
  final TextEditingController titleTextCtrl = TextEditingController();
  final TextEditingController contentTextCtrl = TextEditingController();

  // Stream Controllers
  var _isPageAddedCtrl = StreamController<bool>.broadcast();

  // Stream Subscriptions
  StreamSubscription? _diaryPagesSubscriber;

  // Current opened diary page of the user
  ValueNotifier<DiaryPage?> _currentDiaryPage = ValueNotifier(null);

  // List of the diary pages of the user
  ValueNotifier<List<DiaryPage>> _diaryPages = ValueNotifier<List<DiaryPage>>(<DiaryPage>[]);

  bool _isEditing = false;

  DiaryViewModel() {
    // Register the listeners for the input text field
    titleTextCtrl.addListener(() => diaryForm.title.add(titleTextCtrl.text));
    contentTextCtrl.addListener(() => diaryForm.content.add(contentTextCtrl.text));
  }

  /// Add a new [DiaryPage] into the DB
  Future<void> submitPage() async {
    var now = DateTime.now();
    _currentDiaryPage.value = DiaryPage(
      id: now.millisecondsSinceEpoch.toString(),
      title: titleTextCtrl.text.trim(),
      content: contentTextCtrl.text.trim(),
      dateTime: now,
    );
    _isEditing = false;
    return _firestoreService.addDiaryPageIntoDB(_userService.loggedUser!.id, _currentDiaryPage.value!).then((value) {
      _isPageAddedCtrl.add(true);
      log("Diary page submitted");
    }).catchError((error) {
      _isPageAddedCtrl.add(false);
      log("Error in submitting the diary page: $error");
    });
  }

  /// Update the already existing [_currentDiaryPage] into the DB.
  Future<void> updatePage() async {
    if (_currentDiaryPage.value != null) {
      var now = DateTime.now();
      _currentDiaryPage.value!.title = titleTextCtrl.text.trim();
      _currentDiaryPage.value!.content = contentTextCtrl.text.trim();
      _currentDiaryPage.value!.dateTime = now;
      _isEditing = false;
      return _firestoreService.updateDiaryPageIntoDB(_userService.loggedUser!.id, _currentDiaryPage.value!).then((value) {
        _isPageAddedCtrl.add(true);
        log("Diary page updated");
      }).catchError((error) {
        _isPageAddedCtrl.add(false);
        log("Error in updating the diary page: $error");
      });
    }
  }

  /// Set the [isFavourite] parameter of the [_currentDiaryPage] into the DB.
  Future<void> setFavourite(bool isFavourite) async {
    _currentDiaryPage.value!.favourite = isFavourite;
    return _firestoreService
        .setDiaryPageAsFavouriteIntoDB(_userService.loggedUser!.id, _currentDiaryPage.value!)
        .then((value) => log("Diary page favourite flag updated"))
        .catchError((error) {
      _currentDiaryPage.value!.favourite = !isFavourite;
      log("Error in updating the diary page favourite flag");
    });
  }

  /// Subscribe to the diary pages stream of the [loggedUser] from the Firebase DB and
  /// update the [_diaryPages] list with the diary pages.
  ///
  /// Finally it calls the [notifyListeners] on the [_diaryPages] value notifier to notify the changes
  /// to all the listeners.
  Future<void> loadDiaryPages() async {
    _diaryPagesSubscriber = _firestoreService.getDiaryPagesStreamFromDB(_userService.loggedUser!.id).listen(
      (snapshot) {
        for (var docChange in snapshot.docChanges) {
          var _diaryPage = DiaryPage.fromDocument(docChange.doc);
          // If oldIndex == -1, the document is added, so its new and it has to be added to the list
          if (docChange.oldIndex == -1) {
            _diaryPages.value.add(_diaryPage);
            _diaryPages.notifyListeners();
          } else {
            // Otherwise, update the diary page at the oldIndex position
            _diaryPages.value[docChange.oldIndex] = _diaryPage;
            _diaryPages.notifyListeners();
          }
        }
      },
      onError: (error) => log("Failed to get the stream of diary pages: $error"),
      cancelOnError: true,
    );
  }

  /// Modify the [_currentDiaryPage].
  void editPage() {
    _isEditing = true;
  }

  /// Set the current diary page to `null` and isEditing flag to `true`.
  /// 
  /// It also clear the text controllers.
  void addNewPage() {
    _currentDiaryPage.value = null;
    _isEditing = true;
    titleTextCtrl.clear();
    contentTextCtrl.clear();
  }

  /// Set the [diaryPage] as the [_currentDiaryPage].
  ///
  /// It also sets the [titleTextController] and the [contentTextController]
  /// with the title and the content of the [diaryPage].
  void setCurrentDiaryPage(DiaryPage diaryPage) {
    _currentDiaryPage.value = diaryPage;
    titleTextCtrl.text = diaryPage.title;
    contentTextCtrl.text = diaryPage.content;
    log("Current diary page setted");
  }

  /// Reset the [_currentDiaryPage], clear the [titleTextController] and
  /// the [contentTextController], reset the [diaryForm] and sets the
  /// [isEditing] flag to `false`.
  ///
  /// It must be called after all the other reset methods.
  void resetCurrentDiaryPage() {
    _currentDiaryPage.value = null;
    titleTextCtrl.clear();
    contentTextCtrl.clear();
    diaryForm.resetControllers();
    _isEditing = false;
    log("Current diary page resetted");
  }

  /// Cancel all the value listeners and clear their contents.
  void resetViewModel() {
    _diaryPagesSubscriber?.cancel();
    _diaryPages.value.clear();
    _currentDiaryPage = ValueNotifier(null);
    log("Diary Page listeners closed");
  }

  /// Get the [_currentDiaryPage] instance.
  ValueNotifier<DiaryPage?> get currentDiaryPage => _currentDiaryPage;

  /// Get the [_diaryPages] value notifier.
  ///
  /// **The function [loadDiaryPages] must be called before getting
  /// the [diaryPages].**
  ValueNotifier<List<DiaryPage>> get diaryPages => _diaryPages;

  /// Get the [_isEditing] flag.
  bool get isEditing => _isEditing;

  /// Stream of the succesfully addition of the diary page
  Stream<bool> get isPageAdded => _isPageAddedCtrl.stream;

  /// Get the [_diaryPagesSubscriber].
  StreamSubscription? get diaryPagesSubscriber => _diaryPagesSubscriber;
}
