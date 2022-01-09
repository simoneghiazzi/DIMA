import 'dart:async';
import 'package:test/test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Model/DBItems/BaseUser/diary_page.dart';
import 'package:sApport/ViewModel/BaseUser/Diary/diary_form.dart';
import 'package:sApport/ViewModel/BaseUser/Diary/diary_view_model.dart';
import '../../../service.mocks.dart';
import 'diary_view_model_test.mocks.dart';

@GenerateMocks([DiaryForm])
void main() async {
  /// Fake Firebase
  final fakeFirebase = FakeFirebaseFirestore();

  /// Mock Services
  final mockFirestoreService = MockFirestoreService();
  final mockUserService = MockUserService();
  final mockDiaryForm = MockDiaryForm();

  var loggedUser = BaseUser(
    id: Utils.randomId(),
    name: "Luca",
    surname: "Colombo",
    email: "luca.colombo@prova.it",
    birthDate: DateTime(1997, 10, 19),
  );

  /// Add some mock diary pages to the fakeFirebase
  var collectionReference = fakeFirebase.collection(DiaryPage.COLLECTION).doc(loggedUser.id).collection("diaryPages");

  /// Test Diary Pages
  var diaryPage = DiaryPage(
    id: DateTime(2021, 3, 19).millisecondsSinceEpoch.toString(),
    title: "Diary page title",
    content: "Diary page content",
    dateTime: DateTime(2021, 3, 19),
  );

  var diaryPage2 = DiaryPage(
    id: DateTime(2021, 3, 30).millisecondsSinceEpoch.toString(),
    title: "Diary page second title",
    content: "Diary page second content",
    dateTime: DateTime(2021, 3, 30),
  );

  var diaryPage3 = DiaryPage(
    id: DateTime(2022, 1, 5).millisecondsSinceEpoch.toString(),
    title: "Diary page third title",
    content: "Diary page third content",
    dateTime: DateTime(2022, 1, 5),
  );

  List<DiaryPage> diaryPages = [diaryPage, diaryPage2, diaryPage3];

  collectionReference.doc(diaryPage.id).set(diaryPage.data);
  collectionReference.doc(diaryPage2.id).set(diaryPage2.data);
  collectionReference.doc(diaryPage3.id).set(diaryPage3.data);

  /// Mock User Service responses
  when(mockUserService.loggedUser).thenAnswer((_) => loggedUser);

  /// Mock FirestoreService responses
  when(mockFirestoreService.getDiaryPagesStreamFromDB(loggedUser.id)).thenAnswer(
      (_) => fakeFirebase.collection(DiaryPage.COLLECTION).doc(loggedUser.id).collection("diaryPages").orderBy(FieldPath.documentId).snapshots());

  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(mockFirestoreService);
  getIt.registerSingleton<UserService>(mockUserService);

  final diaryViewModel = DiaryViewModel();
  var now = DateTime.now();

  group("DiaryViewModel initialization:", () {
    test("Check that the diary form is correctly initialized", () {
      expect(diaryViewModel.diaryForm, isA<DiaryForm>());
    });

    test("Check that the title text controller is correctly initialized and has the listener attached", () {
      expect(diaryViewModel.titleTextCtrl, isA<TextEditingController>());
      // ignore: invalid_use_of_protected_member
      expect(diaryViewModel.titleTextCtrl.hasListeners, true);
    });

    test("Check that the content text controller is correctly initialized", () {
      expect(diaryViewModel.contentTextCtrl, isA<TextEditingController>());
      // ignore: invalid_use_of_protected_member
      expect(diaryViewModel.contentTextCtrl.hasListeners, true);
    });

    test("Check that the current diary page is correctly initialized to the value notifier with null value", () {
      expect(diaryViewModel.currentDiaryPage, isA<ValueNotifier<DiaryPage?>>());
      expect(diaryViewModel.currentDiaryPage.value, isNull);
    });

    test("Check that the diary pages list is correctly initialized to the value notifier with an empty list", () {
      expect(diaryViewModel.diaryPages, isA<ValueNotifier<List<DiaryPage>>>());
      expect(diaryViewModel.diaryPages.value, isEmpty);
    });

    test("Check that is editing is correctly initialized to false", () {
      expect(diaryViewModel.isEditing, isFalse);
    });
  });

  group("DiaryViewModel interaction with services:", () {
    setUp(() => clearInteractions(mockFirestoreService));
    group("Load diary pages:", () {
      int counter = 0;
      diaryViewModel.diaryPages.addListener(() {
        counter++;
      });

      setUp(() {
        counter = 0;
        diaryViewModel.diaryPages.value.clear();
      });

      test("Check the subscription of the diaryPagesSubscriber to the diary page stream of the firestore service", () async {
        /// Load the diary pages
        diaryViewModel.loadDiaryPages();
        await Future.delayed(Duration.zero);

        expect(diaryViewModel.diaryPagesSubscriber, isA<StreamSubscription<QuerySnapshot>>());
      });

      test("Check that the value notifier notify the listeners every time a new diary page is added into the list of diary pages", () async {
        /// Load the diary pages
        diaryViewModel.loadDiaryPages();
        await Future.delayed(Duration.zero);

        expect(counter, diaryPages.length);
      });

      test("Check that the initially inserted diary pages are correctly parsed and added to the list of diary pages in the correct order", () async {
        /// Load the diary pages
        diaryViewModel.loadDiaryPages();
        await Future.delayed(Duration.zero);

        for (int i = 0; i < diaryPages.length; i++) {
          expect(diaryViewModel.diaryPages.value[i].id, diaryPages[i].id);
          expect(diaryViewModel.diaryPages.value[i].title, diaryPages[i].title);
          expect(diaryViewModel.diaryPages.value[i].content, diaryPages[i].content);
          expect(diaryViewModel.diaryPages.value[i].dateTime, diaryPages[i].dateTime);
          expect(diaryViewModel.diaryPages.value[i].favourite, diaryPages[i].favourite);
        }
      });

      test("Add a new diary page into the DB should trigger the listener in order to add this new diary page into the diary pages list", () async {
        /// Load the diary pages
        diaryViewModel.loadDiaryPages();
        await Future.delayed(Duration.zero);

        /// The fake firestore doc changes doesn't work properly, so we need to manually clear the previous list
        diaryViewModel.diaryPages.value.clear();

        var diaryPage4 = DiaryPage(
          id: DateTime(2022, 1, 8).millisecondsSinceEpoch.toString(),
          title: "Diary page fourth title",
          content: "Diary page fourth content",
          dateTime: DateTime(2022, 1, 8),
        );
        collectionReference.doc(diaryPage4.dateTime.millisecondsSinceEpoch.toString()).set(diaryPage4.data);
        await Future.delayed(Duration.zero);

        expect(diaryViewModel.diaryPages.value[3].id, diaryPage4.id);
        expect(diaryViewModel.diaryPages.value[3].title, diaryPage4.title);
        expect(diaryViewModel.diaryPages.value[3].content, diaryPage4.content);
        expect(diaryViewModel.diaryPages.value[3].dateTime, diaryPage4.dateTime);
        expect(diaryViewModel.diaryPages.value[3].favourite, diaryPage4.favourite);
      });

      test("Check that if an error occurs when loading the diary pages it catches the error", () {
        /// Mock Firebase exception
        when(mockFirestoreService.getDiaryPagesStreamFromDB(loggedUser.id)).thenThrow(Error);

        diaryViewModel.loadDiaryPages();
      });
    });

    group("Submit page:", () {
      test("Check that submit page sets the current diary page with the correct values", () {
        /// Test Fields
        var title = "Title";
        var content = "Content";

        diaryViewModel.titleTextCtrl.text = title;
        diaryViewModel.contentTextCtrl.text = content;

        diaryViewModel.submitPage();

        expect(diaryViewModel.currentDiaryPage.value, isNotNull);
        expect(diaryViewModel.currentDiaryPage.value!.title, title);
        expect(diaryViewModel.currentDiaryPage.value!.content, content);
        expect(diaryViewModel.currentDiaryPage.value!.dateTime.day, now.day);
        expect(diaryViewModel.currentDiaryPage.value!.dateTime.month, now.month);
        expect(diaryViewModel.currentDiaryPage.value!.dateTime.year, now.year);
      });

      test("Submit page should set the is editing flag to false", () {
        diaryViewModel.editPage();
        diaryViewModel.submitPage();

        expect(diaryViewModel.isEditing, isFalse);
      });

      test("Submit page should call the submit diary page method of the firestore service", () {
        /// Test Fields
        var title = "Title";
        var content = "Content";

        diaryViewModel.titleTextCtrl.text = title;
        diaryViewModel.contentTextCtrl.text = content;

        diaryViewModel.submitPage();

        var verification = verify(mockFirestoreService.addDiaryPageIntoDB(loggedUser.id, captureAny));
        verification.called(1);

        /// Parameter Verification
        expect(verification.captured[0].title, title);
        expect(verification.captured[0].content, content);
        expect(verification.captured[0].dateTime.day, now.day);
        expect(verification.captured[0].dateTime.month, now.month);
        expect(verification.captured[0].dateTime.year, now.year);
      });

      test("Submit page should add true to the isAddedPageController if the submission was successful", () {
        expect(diaryViewModel.isPageAdded, emits(isTrue));

        /// Test Fields
        var title = "Title";
        var content = "Content";

        diaryViewModel.titleTextCtrl.text = title;
        diaryViewModel.contentTextCtrl.text = content;

        diaryViewModel.submitPage();
      });

      test("Submit page should add false to the isAddedPageController if an error is occured", () {
        /// Mock Firebase error
        when(mockFirestoreService.addDiaryPageIntoDB(loggedUser.id, any)).thenThrow(Error);

        expect(diaryViewModel.isPageAdded, emits(isFalse));

        /// Test Fields
        var title = "Title";
        var content = "Content";

        diaryViewModel.titleTextCtrl.text = title;
        diaryViewModel.contentTextCtrl.text = content;

        diaryViewModel.submitPage();
      });
    });

    group("Update page:", () {
      setUp(() => diaryViewModel.setCurrentDiaryPage(diaryPage));

      test("Check that update page sets the current diary page with the correct values", () {
        /// Test Fields
        var title = "Title";
        var content = "Content";

        diaryViewModel.titleTextCtrl.text = title;
        diaryViewModel.contentTextCtrl.text = content;

        diaryViewModel.updatePage();

        expect(diaryViewModel.currentDiaryPage.value!.title, title);
        expect(diaryViewModel.currentDiaryPage.value!.content, content);
        expect(diaryViewModel.currentDiaryPage.value!.dateTime.day, now.day);
        expect(diaryViewModel.currentDiaryPage.value!.dateTime.month, now.month);
        expect(diaryViewModel.currentDiaryPage.value!.dateTime.year, now.year);
      });

      test("Update page should set the is editing flag to false", () {
        diaryViewModel.editPage();
        diaryViewModel.updatePage();

        expect(diaryViewModel.isEditing, isFalse);
      });

      test("Update page should call the update diary page method of the firestore service", () {
        /// Test Fields
        var title = "Title";
        var content = "Content";

        diaryViewModel.titleTextCtrl.text = title;
        diaryViewModel.contentTextCtrl.text = content;

        diaryViewModel.updatePage();

        var verification = verify(mockFirestoreService.updateDiaryPageIntoDB(loggedUser.id, captureAny));
        verification.called(1);

        /// Parameter Verification
        expect(verification.captured[0].title, title);
        expect(verification.captured[0].content, content);
        expect(verification.captured[0].dateTime.day, now.day);
        expect(verification.captured[0].dateTime.month, now.month);
        expect(verification.captured[0].dateTime.year, now.year);
      });

      test("Update page should add true to the isAddedPageController if the update was successful", () {
        expect(diaryViewModel.isPageAdded, emits(isTrue));

        /// Test Fields
        var title = "Title";
        var content = "Content";

        diaryViewModel.titleTextCtrl.text = title;
        diaryViewModel.contentTextCtrl.text = content;

        diaryViewModel.updatePage();
      });

      test("Submit page should add false to the isAddedPageController if an error is occured", () {
        /// Mock Firebase error
        when(mockFirestoreService.updateDiaryPageIntoDB(loggedUser.id, any)).thenThrow(Error);

        expect(diaryViewModel.isPageAdded, emits(isFalse));

        /// Test Fields
        var title = "Title";
        var content = "Content";

        diaryViewModel.titleTextCtrl.text = title;
        diaryViewModel.contentTextCtrl.text = content;

        diaryViewModel.updatePage();
      });
    });

    group("Set favourite:", () {
      var favourite = true;
      setUp(() => diaryViewModel.setCurrentDiaryPage(diaryPage));

      test("Check that set favourite sets the favourite flag of the current diary page", () {
        diaryViewModel.setFavourite(favourite);

        expect(diaryViewModel.currentDiaryPage.value!.favourite, favourite);
      });

      test("Set favourite should call the set diary page as favourite method of the firestore service", () {
        diaryViewModel.setFavourite(favourite);

        var verification = verify(mockFirestoreService.setDiaryPageAsFavouriteIntoDB(loggedUser.id, captureAny));
        verification.called(1);

        /// Parameter Verification
        expect(verification.captured[0].favourite, favourite);
      });

      test("Check that if an error occurs when setting the favourite flag it catches the error", () {
        /// Mock Firebase error
        when(mockFirestoreService.setDiaryPageAsFavouriteIntoDB(loggedUser.id, any)).thenThrow(Error);

        diaryViewModel.setFavourite(favourite);
      });
    });
  });

  group("DiaryViewModel internal managment:", () {
    group("Edit page:", () {
      test("Edit page should set to true the corresponding flag", () {
        diaryViewModel.editPage();

        expect(diaryViewModel.isEditing, isTrue);
      });
    });

    group("Set current diary page:", () {
      setUp(() => diaryViewModel.resetCurrentDiaryPage());

      test("Check that set current diary page sets the correct field of the value notifier", () {
        diaryViewModel.setCurrentDiaryPage(diaryPage);

        expect(diaryViewModel.currentDiaryPage.value, diaryPage);
      });

      test("Check that set current diary page sets the values of the text controllers", () {
        diaryViewModel.setCurrentDiaryPage(diaryPage);

        expect(diaryViewModel.titleTextCtrl.text, diaryPage.title);
        expect(diaryViewModel.contentTextCtrl.text, diaryPage.content);
      });
    });

    group("Reset current diary page:", () {
      test("Check that reset current diary page sets the field of the value notifier to null", () {
        diaryViewModel.currentDiaryPage.value = diaryPage;
        diaryViewModel.resetCurrentDiaryPage();

        expect(diaryViewModel.currentDiaryPage.value, isNull);
      });

      test("Check that reset current diary page clears the values of the text controllers", () {
        diaryViewModel.titleTextCtrl.text = diaryPage.title;
        diaryViewModel.contentTextCtrl.text = diaryPage.content;
        diaryViewModel.resetCurrentDiaryPage();

        expect(diaryViewModel.titleTextCtrl.text, isEmpty);
        expect(diaryViewModel.contentTextCtrl.text, isEmpty);
      });

      test("Check that reset current diary page calls the resetControllers of the diary form", () {
        diaryViewModel.diaryForm = mockDiaryForm;

        /// Mock DiaryForm responses
        when(mockDiaryForm.title).thenAnswer((_) => StreamController<String>.broadcast());
        when(mockDiaryForm.content).thenAnswer((_) => StreamController<String>.broadcast());

        diaryViewModel.resetCurrentDiaryPage();

        verify(mockDiaryForm.resetControllers()).called(1);
      });
    });

    group("Close listeners:", () {
      test("Close listeners should clear the old values of the diary pages value notifier", () {
        diaryViewModel.diaryPages.value = diaryPages;
        diaryViewModel.closeListeners();

        expect(diaryViewModel.diaryPages.value, isEmpty);
      });

      test("Close listener should reset the current diary page", () {
        diaryViewModel.currentDiaryPage.value = diaryPage;
        diaryViewModel.closeListeners();

        expect(diaryViewModel.currentDiaryPage.value, isNull);
      });
    });
  });
}
