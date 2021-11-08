import 'dart:async';
import 'package:rxdart/rxdart.dart';

abstract class DiaryFormInterface {
  Sink get titleText;
  Sink get contentText;
  Stream<bool> get titleController;
  Stream<bool> get contentController;
  Stream<bool> get isButtonEnabled;
  Stream<String> get errorTitleText;
  Stream<String> get errorContentText;

  void dispose();
}

class DiaryForm implements DiaryFormInterface {
  var _titleStream = StreamController<String>.broadcast();
  var _contentStream = StreamController<String>.broadcast();

  @override
  Sink get titleText => _titleStream;

  @override
  Sink get contentText => _contentStream;

  @override
  Stream<bool> get titleController =>
      _titleStream.stream.map((title) => title.isNotEmpty);

  @override
  Stream<bool> get contentController =>
      _contentStream.stream.map((content) => content.isNotEmpty);

  @override
  Stream<String> get errorTitleText => titleController.map((isCorrect) =>
      isCorrect ? false : "You should give a title to this page!");

  @override
  Stream<String> get errorContentText => contentController.map((isCorrect) =>
      isCorrect ? false : "You should write something in this page!");

  @override
  Stream<bool> get isButtonEnabled =>
      Rx.combineLatest2(titleController, contentController, (a, b) => a && b);

  @override
  void dispose() {
    _titleStream.close();
    _contentStream.close();
  }
}
