import 'dart:async';
import 'package:rxdart/rxdart.dart';

abstract class DiaryFormInterface {
  Sink get titleText;
  Sink get contentText;
  Stream<bool> get isButtonEnabled;

  void dispose();
}

class DiaryForm implements DiaryFormInterface {
  var _titleStream = StreamController<String>.broadcast();
  var _contentStream = StreamController<String>.broadcast();

  @override
  Sink get titleText => _titleStream;

  @override
  Sink get contentText => _contentStream;

  Stream<bool> get _titleController =>
      _titleStream.stream.map((title) => title.isNotEmpty);

  Stream<bool> get _contentController =>
      _contentStream.stream.map((content) => content.isNotEmpty);

  @override
  Stream<bool> get isButtonEnabled =>
      Rx.combineLatest2(_titleController, _contentController, (a, b) => a && b);

  @override
  void dispose() {
    _titleStream.close();
    _contentStream.close();
  }
}
