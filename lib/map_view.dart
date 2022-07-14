import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);
  @override
  State<MapView> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(51.11090780609161, 17.053179152853453),
    zoom: 14.4746,
  );

  Set<Marker> Markers = {};

  List<Map<String, Object>> test = [
    {'name': 'POGCHAMP', 'x': 51.1101851799257, 'y': 17.05400886656973},
    {'name': 'RACIBÓRZ', 'x': 50.110401, 'y': 18.186264}
  ];

  Set<Marker> _Update_Markers(List<Map<String, Object>> map) {
    Set<Marker> Markers = {};
    for (var element in map) {
      Markers.add(_Create_Marker(
          element['name'].toString(),
          element['name'].toString(),
          element['x'] as double,
          element['y'] as double,
          420));
    }
    return Markers;
  }

  Marker _Create_Marker(
      String ID, String name, double X, double Y, double kolor) {
    return Marker(
      markerId: MarkerId(ID),
      infoWindow: InfoWindow(title: name),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      position: LatLng(X, Y),
    );
  }

  @override
  Widget build(BuildContext context) {
    Markers = _Update_Markers(test);
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        markers: Markers,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
