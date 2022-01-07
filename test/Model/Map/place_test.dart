import 'package:test/test.dart';
import 'package:sApport/Model/Map/place.dart';

void main() async {
  /// Test Fields
  var address = "Piazza Leonardo da Vince, Milano, Italia";
  var placeId = "ChIJUxfRffbGhkcRdzNKd-H6MI4";
  var lat = 45.478195;
  var lng = 9.2256787;

  group("Place data", () {
    test("Place factory from the autocomplete json response of the GoogleMaps API", () async {
      /// Mock the GoogleMaps API json response
      var json = {"description": address, "place_id": placeId};
      var place = Place.fromAutocompleteJson(json);

      expect(place.address, address);
      expect(place.placeId, placeId);

      /// The lat and lng fields are not provided by the autocomplete response of the GoogleMaps API
      expect(place.lat, null);
      expect(place.lng, null);
    });

    test("Place factory from the search json response of the GoogleMaps API", () async {
      /// Mock the GoogleMaps API json response
      var json = {
        "geometry": {
          "location": {"lat": lat, "lng": lng}
        },
        "formatted_address": address
      };
      var place = Place.fromSearchJson(json);

      expect(place.address, address);
      expect(place.lat, lat);
      expect(place.lng, lng);

      /// The place_id field is not provided by the search response of the GoogleMaps API
      expect(place.placeId, null);
    });
  });
}
