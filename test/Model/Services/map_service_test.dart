import 'package:test/test.dart';
import 'package:sApport/Model/Map/place.dart';
import 'package:sApport/Model/Services/map_service.dart';

void main() async {
  MapService mapService = MapService();

  group("MapService autocomplete", () {
    test("Autocomplete function returns a non-empty list of Place", () async {
      var places = await mapService.autocomplete("Milano");

      expect(places, isA<List<Place>>());
      expect(places, isNotEmpty);
    });

    test("Autocomplete function returns an empty list of Place when the URI request doesn't find a match", () async {
      var places = await mapService.autocomplete("Fake place that does not exists");

      expect(places, isA<List<Place>>());
      expect(places, isEmpty);
    });
  });

  group("MapService search place", () {
    test("Search place function returns a Place from the place_id", () async {
      /// Place_id of the Polimi address
      var place = await mapService.searchPlace("ChIJUxfRffbGhkcRdzNKd-H6MI4");

      expect(place, isA<Place>());
      expect(place!.address, isNotEmpty);
      expect(place.lat, isNonZero);
      expect(place.lng, isNonZero);
    });

    test("Search place function returns an empty Place when the URI request doesn't find a match", () async {
      var place = await mapService.searchPlace("Fake place_id that does not exists");

      expect(place, null);
    });
  });
}
