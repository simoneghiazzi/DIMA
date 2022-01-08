import 'dart:async';
import 'dart:developer';
import 'package:rxdart/rxdart.dart';

abstract class DiaryFormInterface {
  /// Title sink for inserting the text stream
  Sink get title;

  /// Content sink for inserting the text stream
  Sink get content;

  /// Enable the submit button by checking the title controller and the content controller
  Stream<bool> get isButtonEnabled;

  void dispose();
}

class DiaryForm implements DiaryFormInterface {
  // Stream controllers
  var _titleStream = StreamController<String?>.broadcast();
  var _contentStream = StreamController<String?>.broadcast();

  // Sinks
  @override
  Sink get title => _titleStream;

  @override
  Sink get content => _contentStream;

  /// Validate the title by checking if it is not empty
  Stream<bool> get _titleController => _titleStream.stream.map((title) => title!.isNotEmpty);

  /// Validate the content by checking if it is not empty
  Stream<bool> get _contentController => _contentStream.stream.map((content) => content!.isNotEmpty);

  // Stream
  @override
  Stream<bool> get isButtonEnabled => Rx.combineLatest2(_titleController, _contentController, (dynamic a, dynamic b) => a && b);

  /// Reset all the sink controllers
  void resetControllers() {
    title.add("");
    content.add("");
    log("Sinks resetted");
  }

  @override
  void dispose() {
    _titleStream.close();
    _contentStream.close();
  }
}
