import 'dart:async';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Model/Map/place.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/Map/components/map_marker.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:sApport/ViewModel/map_view_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

class MapBody extends StatefulWidget {
  @override
  _MapBodyState createState() => _MapBodyState();
}

class _MapBodyState extends State<MapBody> {
  GoogleMapController mapController;
  MapViewModel mapViewModel;
  StreamSubscription<Place> subscriber;
  AppRouterDelegate routerDelegate;
  var isPositionSearched = false;

  Set<Marker> _markers = Set<Marker>();

  CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();

  //For setting the map style as specified in assets/map_style.txt
  String _mapStyle;

  //For placing custom markers on the map
  BitmapDescriptor pinLocationIcon;

  var _loadCurrentPositionFuture;

  @override
  void initState() {
    mapViewModel = Provider.of<MapViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);

    subscriber = subscribeToViewModel();
    // For setting the map style
    rootBundle.loadString("assets/map_style.txt").then((string) {
      _mapStyle = string;
    });

    // Icon used for custom markers
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 1, size: Size(2, 2)), "assets/icons/pin.png").then((onValue) {
      pinLocationIcon = onValue;
    });

    getMarkers();

    if (!mapViewModel.positionPermission.isGranted) {
      mapViewModel.askPermission().then((permission) {
        if (permission) {
          setState(() {
            _loadCurrentPositionFuture = mapViewModel.loadCurrentPosition();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(mapViewModel.positionPermission.isPermanentlyDenied
                ? "You cannot access your current position. Enable the location permission in the device settings."
                : "You cannot access your current position."),
            duration: const Duration(seconds: 5),
          ));
        }
      });
    } else {
      _loadCurrentPositionFuture = mapViewModel.loadCurrentPosition();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(children: <Widget>[
      if (mapViewModel.positionPermission.isGranted) ...[
        Center(
          child: FutureBuilder<Position>(
              future: _loadCurrentPositionFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return buildMap(lat: snapshot.data.latitude, lng: snapshot.data.longitude);
                } else {
                  return LoadingDialog().widget(context);
                }
              }),
        ),
        // Button My Position
        Align(
          alignment: Alignment.lerp(Alignment.bottomRight, Alignment.center, 0.1),
          child: FloatingActionButton(
            onPressed: () async {
              mapViewModel.clearControllers();
              var pos = await mapViewModel.loadCurrentPosition();
              _goToPlace(LatLng(pos.latitude, pos.longitude));
            },
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: kPrimaryColor,
            child: const Icon(
              Icons.my_location,
              size: 30.0,
              color: Colors.white,
            ),
          ),
        ),
      ] else ...[
        buildMap(),
      ],
      buildSearchBar(),
      StreamBuilder(
          stream: mapViewModel.autocompletedPlaces,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var height = snapshot.data.length * 62.0;
              return Stack(children: [
                AnimatedContainer(
                  height: height,
                  duration: Duration(milliseconds: snapshot.data.length > 0 ? 500 : 200),
                  // Provide an optional curve to make the animation feel smoother.
                  curve: Curves.fastOutSlowIn,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0)),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      )
                    ],
                    border: Border.all(color: kPrimaryDarkColor.withOpacity(0.1)),
                  ),
                  margin: EdgeInsets.only(top: 100, left: 20, right: 20),
                  child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => Divider(height: 1, color: kPrimaryDarkColor.withOpacity(0.2)),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                            contentPadding: EdgeInsets.only(top: 2, bottom: 2, left: 15, right: 5),
                            title: Text(
                              snapshot.data[index].address,
                              style: TextStyle(color: kPrimaryColor),
                            ),
                            onTap: () {
                              isPositionSearched = true;
                              mapViewModel.searchPlace(snapshot.data[index].placeId);
                              FocusManager.instance.primaryFocus?.unfocus();
                            });
                      }),
                ),
              ]);
            } else {
              return Container();
            }
          }),
      CustomInfoWindow(
        controller: _customInfoWindowController,
        height: size.height * 0.15,
        width: Device.get().isTablet
            ? (MediaQuery.of(context).orientation == Orientation.portrait)
                ? size.width * 0.5
                : size.width * 0.35
            : size.width * 0.65,
        offset: (MediaQuery.of(context).orientation == Orientation.portrait) ? 10 : 30,
      ),
    ]);
  }

  Future<void> setMapStyle() async {
    mapController.setMapStyle(_mapStyle);
  }

  void getMarkers() {
    mapViewModel.loadExperts().then((snapshot) {
      for (var doc in snapshot.docs) {
        Expert expert = Expert.fromDocument(doc);
        _markers.add(
          Marker(
            markerId: MarkerId(expert.data["surname"].toString() + expert.data["lat"].toString() + expert.data["lng"].toString()),
            position: LatLng(expert.data["lat"], expert.data["lng"]),
            icon: pinLocationIcon,
            onTap: () {
              _customInfoWindowController.addInfoWindow(
                MapMarker(expert: expert),
                LatLng(expert.data["lat"], expert.data["lng"]),
              );
            },
          ),
        );
      }
      setState(() {});
    });
  }

  StreamSubscription<Place> subscribeToViewModel() {
    return mapViewModel.selectedPlace.listen((place) {
      if (place != null) {
        _goToPlace(LatLng(place.lat, place.lng));
      } else {
        print("Error, search again");
      }
    });
  }

  Future<void> _goToPlace(LatLng latLng) async {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 15),
      ),
    );
  }

  Widget buildMap({lat = 45.478195, lng = 9.2256787}) {
    return GoogleMap(
      onTap: (position) {
        _customInfoWindowController.hideInfoWindow();
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      onCameraMove: (position) {
        _customInfoWindowController.onCameraMove();
      },
      onMapCreated: (GoogleMapController controller) async {
        mapController = controller;
        _customInfoWindowController.googleMapController = controller;
        setMapStyle();
      },
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: LatLng(lat, lng),
        zoom: 15,
      ),
      compassEnabled: true,
      mapToolbarEnabled: false,
      markers: _markers,
      myLocationButtonEnabled: false,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
    );
  }

  Widget buildSearchBar() {
    return StreamBuilder(
        stream: mapViewModel.autocompletedPlaces,
        builder: (context, snapshot) {
          return Positioned(
            top: 50,
            right: 20,
            left: 20,
            child: AnimatedContainer(
              duration: Duration(milliseconds: (snapshot.hasData && snapshot.data.length > 0) ? 100 : 500),
              // Provide an optional curve to make the animation feel smoother.
              curve: Curves.fastOutSlowIn,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: snapshot.hasData && snapshot.data.length > 0
                      ? BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))
                      : BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    )
                  ],
                  border: Border.all(color: kPrimaryDarkColor.withOpacity(0.1))),
              child: Row(children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: kPrimaryColor,
                  ),
                  onPressed: () {
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                    routerDelegate.pop();
                  },
                ),
                Expanded(
                  child: TextField(
                    textCapitalization: TextCapitalization.sentences,
                    textAlignVertical: TextAlignVertical.center,
                    cursorColor: kPrimaryColor,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.go,
                    controller: mapViewModel.searchTextCtrl,
                    decoration: InputDecoration(
                        fillColor: kPrimaryColor,
                        border: InputBorder.none,
                        hintText: "Search place",
                        suffixIcon: IconButton(
                          icon: (mapViewModel.searchTextCtrl.text.trim() != "") ? Icon(Icons.cancel) : Icon(Icons.search_rounded),
                          color: kPrimaryColor,
                          onPressed: () {
                            if (mapViewModel.searchTextCtrl.text.trim() != "") {
                              mapViewModel.clearControllers();
                              FocusScopeNode currentFocus = FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                            }
                          },
                        )),
                    onChanged: (value) => mapViewModel.autocompleteSearchedPlace(),
                    onTap: () {
                      _customInfoWindowController.hideInfoWindow();
                      if (isPositionSearched) {
                        mapViewModel.searchTextCtrl.clear();
                        isPositionSearched = false;
                      }
                    },
                    onSubmitted: (value) async => mapViewModel.searchPlace((await mapViewModel.firstSimilarPlace(value)).placeId),
                  ),
                ),
              ]),
            ),
          );
        });
  }

  @override
  void dispose() {
    subscriber.cancel();
    _customInfoWindowController.dispose();
    super.dispose();
  }
}
