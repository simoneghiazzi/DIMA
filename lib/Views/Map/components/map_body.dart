import 'dart:async';
import 'package:sApport/sizer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:custom_info_window/custom_info_window.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Model/Map/place.dart';
import 'package:sApport/Views/Map/map_screen.dart';
import 'package:sApport/ViewModel/map_view_model.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Views/Map/components/map_info_window.dart';

/// Body of the [MapScreen].
///
/// It contains the [GoogleMap] with the markers and the associated [MapInfoWindow]
/// relative to the experts provided by the [mapViewModel] and retrieved from the Firebase DB.
///
/// It also contains the search bar with the associated stream (for autocompletion)
/// to looking for a specific place and the button for moving to the current device position.
///
/// It manages also the permission of the current position of the device: if the permission is
/// not granted, it starts the map with the default position setted to the Polimi address.
class MapBody extends StatefulWidget {
  /// Body of the [MapScreen].
  ///
  /// It contains the [GoogleMap] with the markers and the associated [MapInfoWindow]
  /// relative to the experts provided by the [mapViewModel] and retrieved from the Firebase DB.
  ///
  /// It also contains the search bar with the associated stream (for autocompletion)
  /// to looking for a specific place and the button for moving to the current device position.
  ///
  /// It manages also the permission of the current position of the device: if the permission is
  /// not granted, it starts the map with the default position setted to the Polimi address.
  const MapBody({Key? key}) : super(key: key);

  @override
  _MapBodyState createState() => _MapBodyState();
}

class _MapBodyState extends State<MapBody> {
  // View Models
  late MapViewModel mapViewModel;

  // Router Delegate
  late AppRouterDelegate routerDelegate;

  // Map Markers
  Set<Marker> _markers = Set<Marker>();

  // Markers pin
  late BitmapDescriptor pinLocationIcon;

  // Info Window
  CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();

  // Map style specified in assets/map_style.txt
  late String _mapStyle;

  // Map Controller
  late GoogleMapController mapController;

  late StreamSubscription<Place?> subscriber;
  var isPositionSearched = false;
  var _loadCurrentPositionFuture;

  @override
  void initState() {
    mapViewModel = Provider.of<MapViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    subscriber = subscribeToSelectedPlace();

    // Set the map style
    rootBundle.loadString("assets/map_style.txt").then((string) => _mapStyle = string);

    // Load the icon used for custom markers
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 1, size: Size(2, 2)), "assets/icons/pin.png").then((onValue) {
      pinLocationIcon = onValue;
    });

    // Load the experts and add the relative marker
    getMarkers();

    // Permission Handler
    if (!mapViewModel.positionPermission.isGranted) {
      // If the position permission is not granted, ask the permission
      mapViewModel.askPermission().then((permission) {
        if (permission) {
          // If permission granted, load the current position and recreate the map
          setState(() => _loadCurrentPositionFuture = mapViewModel.loadCurrentPosition());
        } else {
          // Otherwise, show the snack bar with the information based on if the permission is
          // permanently denied or not
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(mapViewModel.positionPermission.isPermanentlyDenied
                ? "You cannot access your current position. Enable the location permission in the device settings."
                : "You cannot access your current position."),
            duration: const Duration(seconds: 5),
          ));
        }
      });
    } else {
      // If the position permission is granted, load the current position of the user device
      _loadCurrentPositionFuture = mapViewModel.loadCurrentPosition();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        if (mapViewModel.positionPermission.isGranted) ...[
          // If position is granted, build the map with initial position equals to device position and
          // create the GPS button
          Center(
            child: FutureBuilder<Position>(
                future: _loadCurrentPositionFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return buildMap(lat: snapshot.data!.latitude, lng: snapshot.data!.longitude);
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
          ),
          // GPS Button
          Align(
            alignment: Alignment.lerp(Alignment.bottomRight, Alignment.center, 0.1)!,
            child: FloatingActionButton(
              onPressed: () async {
                mapViewModel.clearControllers();
                var pos = await mapViewModel.loadCurrentPosition();
                _goToPlace(LatLng(pos.latitude, pos.longitude));
              },
              materialTapTargetSize: MaterialTapTargetSize.padded,
              backgroundColor: kPrimaryColor,
              child: const Icon(Icons.my_location, size: 30.0, color: Colors.white),
            ),
          ),
        ] else ...[
          // Otherwise build only the map with the default position
          buildMap(),
        ],
        buildSearchBar(),
        // Stream of the places suggested by the autocompletion
        StreamBuilder(
          stream: mapViewModel.autocompletedPlaces,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              var height = snapshot.data.length * 62.0;
              return Stack(
                children: [
                  // Container animation under the search bar
                  AnimatedContainer(
                    height: height,
                    duration: Duration(milliseconds: snapshot.data.length > 0 ? 500 : 200),
                    // Provide an optional curve to make the animation feel smoother
                    curve: Curves.fastOutSlowIn,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0)),
                      boxShadow: [BoxShadow(color: kPrimaryColor.withOpacity(0.1), spreadRadius: 2, blurRadius: 6, offset: Offset(0, 3))],
                      border: Border.all(color: kPrimaryDarkColor.withOpacity(0.1)),
                    ),
                    margin: EdgeInsets.only(top: 100, left: 20, right: 20),
                    // List of suggested positions
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => Divider(height: 1, color: kPrimaryDarkColor.withOpacity(0.2)),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        // List item
                        return ListTile(
                          contentPadding: EdgeInsets.only(top: 2, bottom: 2, left: 15, right: 5),
                          title: Text(snapshot.data[index].address, style: TextStyle(color: kPrimaryColor, fontSize: 14.sp)),
                          onTap: () {
                            isPositionSearched = true;
                            mapViewModel.searchPlace(snapshot.data[index].placeId);
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            } else {
              return Container();
            }
          },
        ),
        // Custom Info Window of the Expert
        CustomInfoWindow(
          controller: _customInfoWindowController,
          height: 15.h,
          width: Device.get().isTablet
              ? (MediaQuery.of(context).orientation == Orientation.portrait)
                  ? 5.w
                  : 35.w
              : 65.w,
          offset: (MediaQuery.of(context).orientation == Orientation.portrait) ? 20 : 30,
        ),
      ],
    );
  }

  // DA RIFARE NEL VIEW MODEL
  void getMarkers() {
    mapViewModel.loadExperts().then((snapshot) {
      for (var doc in snapshot!.docs) {
        Expert expert = Expert.fromDocument(doc);
        _markers.add(
          Marker(
            markerId: MarkerId(expert.data["surname"].toString() + expert.data["lat"].toString() + expert.data["lng"].toString()),
            position: LatLng(expert.data["lat"] as double, expert.data["lng"] as double),
            icon: pinLocationIcon,
            onTap: () {
              _customInfoWindowController.addInfoWindow!(
                MapInfoWindow(expert: expert),
                LatLng(expert.data["lat"] as double, expert.data["lng"] as double),
              );
            },
          ),
        );
      }
      setState(() {});
    });
  }

  /// Subscriber to the stream of selected place. It returns a [StreamSubscription].
  ///
  /// When the user selects a new place, it moves the map to the selected place
  /// by providing the correct [LatLng] position.
  StreamSubscription<Place?> subscribeToSelectedPlace() {
    return mapViewModel.selectedPlace.listen((place) {
      if (place != null) {
        _goToPlace(LatLng(place.lat!, place.lng!));
      } else {
        print("Error, search again");
      }
    });
  }

  /// It moves the map to the [latLng] position by using a camera animation.
  Future<void> _goToPlace(LatLng latLng) async {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 15),
      ),
    );
  }

  /// Builder of the [GoogleMap].
  ///
  /// It sets the initial position to [lat] and [lng].
  /// If they are not provided, the default position is the Polimi address.
  Widget buildMap({lat = 45.478195, lng = 9.2256787}) {
    return GoogleMap(
      onTap: (position) {
        _customInfoWindowController.hideInfoWindow!();
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      onCameraMove: (position) => _customInfoWindowController.onCameraMove!(),
      onMapCreated: (GoogleMapController controller) async {
        mapController = controller;
        _customInfoWindowController.googleMapController = controller;
        mapController.setMapStyle(_mapStyle);
      },
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(target: LatLng(lat, lng), zoom: 15),
      compassEnabled: true,
      mapToolbarEnabled: false,
      markers: _markers,
      myLocationButtonEnabled: false,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
    );
  }

  /// Builder of the top search bar.
  ///
  /// It listens the the stream of the places suggested by the autocompletion
  /// for showing the animation of the bottom container.
  ///
  /// If the text is not null, it shows also the clear icon.
  Widget buildSearchBar() {
    return StreamBuilder(
        stream: mapViewModel.autocompletedPlaces,
        builder: (context, AsyncSnapshot snapshot) {
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
                  boxShadow: [BoxShadow(color: kPrimaryColor.withOpacity(0.1), spreadRadius: 2, blurRadius: 6, offset: Offset(0, 3))],
                  border: Border.all(color: kPrimaryDarkColor.withOpacity(0.1))),
              child: Row(children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: kPrimaryColor),
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
                    style: TextStyle(fontSize: 14.sp),
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
                      ),
                    ),
                    onChanged: (value) => mapViewModel.autocompleteSearchedPlace(),
                    onTap: () {
                      _customInfoWindowController.hideInfoWindow!();
                      // If the position is already searched, clear the text when the user tap the bar
                      if (isPositionSearched) {
                        mapViewModel.searchTextCtrl.clear();
                        isPositionSearched = false;
                      }
                    },
                    onSubmitted: (value) async => mapViewModel.searchPlace((await mapViewModel.firstSimilarPlace(value)).placeId!),
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
