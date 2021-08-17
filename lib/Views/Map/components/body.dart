import 'dart:async';

import 'package:dima_colombo_ghiazzi/Model/Map/place.dart';
import 'package:dima_colombo_ghiazzi/Model/Map/place_search.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/map_view_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;

class Body extends StatefulWidget {
  final MapViewModel mapViewModel;

  Body({Key key, @required this.mapViewModel}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  //StreamSubscription<Position> subscriber;
  Position userLocation;
  StreamSubscription<Place> subscriber;

  //For setting the map style as specified in assets/map_style.txt
  String _mapStyle;

  //For placing custom markers on the map
  BitmapDescriptor pinLocationIcon;

  @override
  void initState() {
    super.initState();
    subscriber = subscribeToViewModel();
    widget.mapViewModel.uploadPosition();

    //For setting the map style
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });

    //Icon used for custom markers
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 1, size: Size(2, 2)),
            'assets/icons/pin.png')
        .then((onValue) {
      pinLocationIcon = onValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Center(
          child: StreamBuilder<Position>(
              stream: widget.mapViewModel.position,
              builder: (context, snapshot) {
                return snapshot.data == null
                    ? Center(child: CircularProgressIndicator())
                    : FutureBuilder(
                        future: widget.mapViewModel.getMarkers(pinLocationIcon),
                        builder: (BuildContext context,
                            AsyncSnapshot<Set<Marker>> snap) {
                          if (!snap.hasData) {
                            return GoogleMap(
                              mapType: MapType.normal,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(snapshot.data.latitude,
                                    snapshot.data.longitude),
                                zoom: 16,
                              ),
                              mapToolbarEnabled: false,
                              myLocationButtonEnabled: false,
                              myLocationEnabled: true,
                              zoomControlsEnabled: false,
                              onMapCreated: (GoogleMapController controller) {
                                widget.mapViewModel.mapController
                                    .complete(controller);
                                removeMarkers();
                              },
                            );
                          } else {
                            return GoogleMap(
                              mapType: MapType.normal,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(snapshot.data.latitude,
                                    snapshot.data.longitude),
                                zoom: 16,
                              ),
                              mapToolbarEnabled: false,
                              markers: snap.data,
                              myLocationButtonEnabled: false,
                              myLocationEnabled: true,
                              zoomControlsEnabled: false,
                              onMapCreated: (GoogleMapController controller) {
                                widget.mapViewModel.mapController
                                    .complete(controller);
                                removeMarkers();
                              },
                            );
                          }
                        });
              })),
      Positioned(
          top: 60,
          right: 15,
          left: 15,
          child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Row(children: <Widget>[
                IconButton(
                  splashColor: Colors.grey,
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: TextField(
                    cursorColor: Colors.black,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.go,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        //contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        hintText: "Search place",
                        suffixIcon: Icon(Icons.search)),
                    onChanged: (value) =>
                        widget.mapViewModel.searchPlaces(value),
                  ),
                ),
              ]))),
      StreamBuilder<List<PlaceSearch>>(
          stream: widget.mapViewModel.places,
          builder: (context, snapshot) {
            return (snapshot.data == null || snapshot.data.length == 0)
                ? Container(width: 0.0, height: 0.0)
                : Column(children: [
                    Expanded(
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(.6),
                                backgroundBlendMode: BlendMode.darken),
                            child: ListView.builder(
                                padding: EdgeInsets.only(top: 100),
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                      contentPadding: EdgeInsets.only(
                                          top: 10, left: 15, right: 5),
                                      title: Text(
                                        snapshot.data[index].description,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onTap: () {
                                        widget.mapViewModel.setSelectedLocation(
                                            snapshot.data[index].placeId);
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      });
                                })))
                  ]);
          }),
    ]);
  }

  Future<void> removeMarkers() async {
    final GoogleMapController controller =
        await widget.mapViewModel.mapController.future;
    controller.setMapStyle(_mapStyle);
  }

  StreamSubscription<Place> subscribeToViewModel() {
    return widget.mapViewModel.location.listen((place) {
      if (place != null) {
        _goToPlace(place);
      } else {
        print("Error, search again");
      }
    });
  }

  Future<void> _goToPlace(Place place) async {
    final GoogleMapController controller =
        await widget.mapViewModel.mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
                place.geometry.location.lat, place.geometry.location.lng),
            zoom: 15),
      ),
    );
    widget.mapViewModel.searchPlaces("");
  }

  @override
  void dispose() {
    subscriber.cancel();
    super.dispose();
  }
}
