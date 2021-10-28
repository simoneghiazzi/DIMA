import 'dart:async';

import 'package:dima_colombo_ghiazzi/Model/BaseUser/Diary/entry.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/firestore_service.dart';
import 'package:dima_colombo_ghiazzi/Model/random_id.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/ObserverForms/diary_form.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class DiaryViewModel {
  FirestoreService _firestoreService = FirestoreService();
  final DiaryForm diaryForm = DiaryForm();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  var isPageCorrectlyAdded = StreamController<bool>.broadcast();
  var isPageUncorrectlyAdded = StreamController<bool>.broadcast();

  final String loggedId;

  DiaryViewModel(this.loggedId) {
    titleController
        .addListener(() => diaryForm.titleText.add(titleController.text));
    contentController
        .addListener(() => diaryForm.contentText.add(contentController.text));
  }

  Future<void> submitPage() async {
    _firestoreService
        .addDiaryPageIntoDB(
            loggedId,
            Entry(
                id: RandomId.generate(idLength: 20),
                title: titleController.text,
                content: contentController.text,
                date: DateTime.now()))
        .then((value) {
      isPageCorrectlyAdded.add(true);
    }).catchError((error) {
      isPageUncorrectlyAdded.add(true);
    });
  }

  Stream<bool> get isPageAdded => isPageCorrectlyAdded.stream;
  Stream<bool> get isPageNotAdded => isPageUncorrectlyAdded.stream;
}
