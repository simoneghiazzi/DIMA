import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';

class ReportViewModel {
  // Services
  final FirestoreService _firestoreService = GetIt.I<FirestoreService>();
  final FirebaseAuthService _firebaseAuthService = GetIt.I<FirebaseAuthService>();

  /// Get the stream of reports.
  Stream<QuerySnapshot> loadReports() {
    try {
      return _firestoreService.getReportsFromDB(_firebaseAuthService.firebaseUser.uid);
    } catch (e) {
      print("Failed to get the stream of reports: $e");
      return null;
    }
  }
}
