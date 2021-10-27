import 'package:dima_colombo_ghiazzi/Model/BaseUser/Diary/entry.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/firestore_service.dart';
import 'package:dima_colombo_ghiazzi/Model/random_id.dart';
import 'package:flutter/foundation.dart';

class DiaryViewModel extends ChangeNotifier {
  FirestoreService _firestoreService = FirestoreService();
  final String loggedId;

  DiaryViewModel({@required this.loggedId});

  Future<bool> submitPage(Map<String, String> _formData) async {
    _firestoreService
        .addDiaryPageIntoDB(
            loggedId,
            Entry(
                id: RandomId.generate(idLength: 20),
                title: _formData['title'],
                content: _formData['content'],
                date: DateTime.now()))
        .then((value) {
      return true;
    }).catchError((error) {
      return false;
    });
    return false;
  }
}
