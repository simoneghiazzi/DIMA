/*import 'package:dima_colombo_ghiazzi/Model/BaseUser/Diary/entry.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

enum ViewStatus { Loading, Ready }

const ERROR_MESSAGE = "😥 Something went wrong. Please try again later!";

class DiaryViewModel extends ChangeNotifier {
  ViewStatus _status;
  List<Entry> _entries = [];
  String _message;

  ViewStatus get viewStatus => _status;

  String get message => _message;

  List<Entry> get entries => _entries;

  EntryService _entryService = locator<EntryService>();
  DialogService _dialogService = locator<DialogService>();

  void setStatus(ViewStatus status) {
    _status = status;
    notifyListeners();
  }

  Future<void> getEntries() async {
    setStatus(ViewStatus.Loading);
    Response response;
    try {
      _message = '';
      response = await _entryService.getEntries();
      final List<dynamic> data = response.data['data'] ?? [];
      _entries = List<Entry>.from(data.map((entry) => Entry.fromJson(entry)));
    } on DioError catch (e) {
      final data = e.response?.data ?? {};
      _message = data['message'] ?? ERROR_MESSAGE;
    }
    setStatus(ViewStatus.Ready);
  }

  Future<bool> create(Map<String, String> formData) async {
    setStatus(ViewStatus.Loading);
    Response response;
    try {
      response = await _entryService.addEntry(formData);
      setStatus(ViewStatus.Ready);
      await _dialogService.showAlertDialog(
          'Gotcha 😎! Thanks for sharing your thoughts with me today!',
          barrierDismissible: false);
    } on DioError catch (e) {
      final data = e.response?.data ?? {};
      final message = data['message'] ?? ERROR_MESSAGE;
      setStatus(ViewStatus.Ready);
      _dialogService.showAlertDialog(message);
    }

    return response?.statusCode == 201;
  }

  Future<bool> update(Map<String, dynamic> formData) async {
    setStatus(ViewStatus.Loading);
    Response response;
    try {
      response = await _entryService.updateEntry(formData);
      setStatus(ViewStatus.Ready);
      await _dialogService.showAlertDialog(
          'Well recieved 😎! Thanks for the update',
          barrierDismissible: false);
    } on DioError catch (e) {
      final data = e.response?.data ?? {};
      final message = data['message'] ?? ERROR_MESSAGE;
      setStatus(ViewStatus.Ready);
      _dialogService.showAlertDialog(message);
    }

    return response?.statusCode == 200;
  }

  delete(int entryId) async {
    setStatus(ViewStatus.Loading);

    Response response;
    try {
      response = await _entryService.deleteEntry(entryId);
      await Future.delayed(Duration(seconds: 10));
      await _dialogService
          .showAlertDialog('Okay! here you go. Entry deleted successfully!');
      setStatus(ViewStatus.Ready);
    } on DioError catch (e) {
      final data = e.response?.data ?? {};
      final message = data['message'] ?? ERROR_MESSAGE;
      setStatus(ViewStatus.Ready);
      _dialogService.showAlertDialog(message);
    }

    return response?.statusCode == 204;
  }

  static String title(String value) {
    if (value.isEmpty) {
      return 'C\'mon, give me a headline!';
    }
    return null;
  }

  static String content(String value) {
    if (value.isEmpty) {
      return 'Hey! You haven\'t told me anything yet!';
    }
    return null;
  }
}*/
