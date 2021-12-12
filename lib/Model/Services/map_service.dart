import 'dart:convert' as converter;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:sApport/Model/BaseUser/Map/place.dart';

class MapService {
  static const _APIkey = "AIzaSyAarrZBb6KLQ3VbSdhHWnbzqcer0vlOacs";

  /// Returns the list of most probable places based on the [input].
  ///
  /// It returns a [Place] with the [address] and [placeId] varibles setted from the
  /// Google Map API request.
  Future<List<Place>> autocomplete(String input) async {
    Uri url = Uri.parse("https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=geocode&key=$_APIkey");
    var response = await http.get(url);
    var jsonResults = converter.jsonDecode(response.body)["predictions"] as List;
    return jsonResults.map((place) => Place.fromAutocompleteJson(place)).toList();
  }

  /// Searches a place based on the [placeId].
  ///
  /// It returns a [Place] with the [lat], [lng] and [address] varibles setted from the
  /// Google Map API request.
  Future<Place> searchPlace(String placeId) async {
    Uri url = Uri.parse("https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_APIkey");
    var response = await http.get(url);
    var jsonResult = converter.jsonDecode(response.body)["result"] as Map<String, dynamic>;
    return Place.fromSearchJson(jsonResult);
  }

  /// Returns the current position of the device.
  Future<Position> getCurrentPosition() {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }
}
