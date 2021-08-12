import 'package:dima_colombo_ghiazzi/Model/Map/place.dart';
import 'package:dima_colombo_ghiazzi/Model/Map/place_search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class PlaceService {
  final key = 'AIzaSyAarrZBb6KLQ3VbSdhHWnbzqcer0vlOacs';

  Future<List<PlaceSearch>> getAutocomplete(String search) async {
    Uri url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&types=geocode&key=$key');

    var response = await http.get(url);
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['predictions'] as List;

    return jsonResults.map((place) => PlaceSearch.fromJson(place)).toList();
  }

  Future<Place> getPlace(String placeId) async {
    Uri url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key');

    var response = await http.get(url);
    var json = convert.jsonDecode(response.body);
    var jsonResult = json['result'] as Map<String, dynamic>;

    return Place.fromJson(jsonResult);
  }
}
