import 'package:test/test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sApport/Model/Map/place.dart';
import 'package:sApport/ViewModel/map_view_model.dart';
import 'package:sApport/Model/Services/map_service.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../service.mocks.dart';
import '../test_helper.dart';

void main() async {
  /// Fake Firebase
  final fakeFirebase = FakeFirebaseFirestore();

  /// Mock Services
  final mockFirestoreService = MockFirestoreService();
  final mockMapService = MockMapService();
  final mockUserService = MockUserService();

  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(mockFirestoreService);
  getIt.registerSingleton<UserService>(mockUserService);
  getIt.registerSingleton<MapService>(mockMapService);

  /// Test Helper
  final testHelper = TestHelper();
  testHelper.attachDB(fakeFirebase);

  final mapViewModel = MapViewModel(isTesting: true);

  /// Mock User Service responses
  when(mockUserService.loggedUser).thenAnswer((_) => testHelper.loggedUser);

  var autocompletePlacesList = [
    Place(address: "Piazza Leonardo da Vince, Milano, Italia", placeId: "ChIJUxfRffbGhkcRdzNKd-H6MI4"),
    Place(address: "Melegnano, Italia", placeId: "ChIJ_Wz1geXRhkcR4XMu69B1g3w"),
    Place(address: "Pavia, Italia", placeId: "ChIJSQD6dUwmh0cRjoLPs7y0tfU")
  ];
  var placeSearched = Place(address: "Piazza Leonardo da Vince, Milano, Italia", lat: 45.478195, lng: 9.2256787);
  var currentPosition =
      Position(accuracy: 0.0, altitude: 0.0, heading: 0.0, latitude: 0.0, longitude: 0.0, speed: 0.0, speedAccuracy: 0.0, timestamp: DateTime.now());

  /// Mock Map Service responses
  when(mockMapService.autocomplete(any)).thenAnswer((_) => Future.value(autocompletePlacesList));
  when(mockMapService.searchPlace(any)).thenAnswer((_) => Future.value(placeSearched));
  when(mockMapService.getCurrentPosition()).thenAnswer((_) => Future.value(currentPosition));

  /// Mock FirestoreService responses
  when(mockFirestoreService.getExpertCollectionFromDB()).thenAnswer((_) => testHelper.expertsFuture);

  group("MapViewModel initialization:", () {
    test("Check that the search text controller is correctly initialized", () {
      expect(mapViewModel.searchTextCtrl, isA<TextEditingController>());
    });
  });

  group("MapViewModel interaction with services:", () {
    setUp(() {
      mapViewModel.searchTextCtrl.clear();
      clearInteractions(mockFirestoreService);
      clearInteractions(mockMapService);
    });
    group("Autocomplete searched place:", () {
      test("Autocomplete searched place should call the autocomplete method of the map service", () async {
        mapViewModel.searchTextCtrl.text = "Piazza Leonardo";
        await mapViewModel.autocompleteSearchedPlace();

        verify(mockMapService.autocomplete(mapViewModel.searchTextCtrl.text)).called(1);
      });

      test("Autocomplete searched place should add the results to the autocompleted places controller", () async {
        expect(mapViewModel.autocompletedPlaces, emits(autocompletePlacesList));

        mapViewModel.searchTextCtrl.text = "Piazza Leonardo";
        await mapViewModel.autocompleteSearchedPlace();
      });
    });

    group("First similar place:", () {
      test("First similar place should call the autocomplete method of the map service", () async {
        mapViewModel.searchTextCtrl.text = "Piazza Leonardo";
        await mapViewModel.autocompleteSearchedPlace();

        verify(mockMapService.autocomplete(mapViewModel.searchTextCtrl.text)).called(1);
      });

      test("Check that first similar place returns the first element of the autocompletePlacesList", () async {
        var res = await mapViewModel.firstSimilarPlace("Piazza Leonardo");

        expect(res, autocompletePlacesList[0]);
      });
    });

    group("Search place:", () {
      test("Search place should call the searchPlace method of the map service", () async {
        await mapViewModel.searchPlace("fake_place_id");

        verify(mockMapService.searchPlace("fake_place_id")).called(1);
      });

      test("Check that search place add null to the autocompleted places controller", () async {
        expect(mapViewModel.autocompletedPlaces, emits(null));

        await mapViewModel.searchPlace("fake_place_id");
      });

      test("Search place should add the results to the selected place controller", () async {
        expect(mapViewModel.selectedPlace, emits(placeSearched));

        await mapViewModel.searchPlace("fake_place_id");
      });

      test("Search place should set the address of the returned place to the search text controller", () async {
        await mapViewModel.searchPlace("fake_place_id");

        expect(mapViewModel.searchTextCtrl.text, placeSearched.address);
      });

      test("Check that if the returned searched place is null, it doesn't set the search text controller", () async {
        /// Mock Map Service response
        when(mockMapService.searchPlace(any)).thenAnswer((_) => Future.value(null));

        await mapViewModel.searchPlace("fake_place_id");

        expect(mapViewModel.searchTextCtrl.text, isNot(placeSearched.address));
      });
    });

    group("Load current position:", () {
      test("Load current position should call the getCurrentPosition method of the map service", () async {
        await mapViewModel.loadCurrentPosition();

        verify(mockMapService.getCurrentPosition()).called(1);
      });

      test("Check that load current position returns the correct value", () async {
        var pos = await mapViewModel.loadCurrentPosition();

        expect(pos, currentPosition);
      });
    });

    group("Load experts:", () {
      setUp(() => mapViewModel.experts.clear());

      test("Load experts should call the getExpertCollection method of the firestore service", () async {
        await mapViewModel.loadExperts();

        verify(mockFirestoreService.getExpertCollectionFromDB()).called(1);
      });

      test("Check that the experts are correctly parsed and added to the linked HashMap of experts", () async {
        /// Load the experts
        await mapViewModel.loadExperts();

        for (int i = 0; i < testHelper.experts.length; i++) {
          expect(mapViewModel.experts.values.elementAt(i).id, testHelper.experts[i].id);
          expect(mapViewModel.experts.values.elementAt(i).name, testHelper.experts[i].name);
          expect(mapViewModel.experts.values.elementAt(i).surname, testHelper.experts[i].surname);
          expect(mapViewModel.experts.values.elementAt(i).birthDate, testHelper.experts[i].birthDate);
          expect(mapViewModel.experts.values.elementAt(i).email, testHelper.experts[i].email);
          expect(mapViewModel.experts.values.elementAt(i).address, testHelper.experts[i].address);
          expect(mapViewModel.experts.values.elementAt(i).latitude, testHelper.experts[i].latitude);
          expect(mapViewModel.experts.values.elementAt(i).longitude, testHelper.experts[i].longitude);
          expect(mapViewModel.experts.values.elementAt(i).phoneNumber, testHelper.experts[i].phoneNumber);
          expect(mapViewModel.experts.values.elementAt(i).profilePhoto, testHelper.experts[i].profilePhoto);
        }
      });

      test("Check that if an error occurs when loading the experts it catches the error and return null", () async {
        /// Mock Firebase exception
        when(mockFirestoreService.getExpertCollectionFromDB()).thenAnswer((_) async {
          return Future.error(Error);
        });

        await mapViewModel.loadExperts();
      });
    });
  });

  group("MapViewModel internal managment:", () {
    group("Clear controllers:", () {
      test("Clear controllers should clear the search text controller and add null to the stream controllers", () async {
        mapViewModel.searchTextCtrl.text = "Some text";
        expect(mapViewModel.autocompletedPlaces, emits(null));
        expect(mapViewModel.selectedPlace, emits(null));

        mapViewModel.clearControllers();

        expect(mapViewModel.searchTextCtrl.text, isEmpty);
      });
    });

    group("Close listeners:", () {
      test("Close listeners should clear the old values of the experts linked HashMap", () async {
        await mapViewModel.loadExperts();
        mapViewModel.resetViewModel();

        expect(mapViewModel.experts, isEmpty);
      });
    });
  });
}
