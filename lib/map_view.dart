import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapView(),
    );
  }
}

class MapView extends StatefulWidget {
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
    {
      'name': 'POGCHAMP',
      'x': 51.1101851799257,
      'y': 17.05400886656973,
      'hue': 60.0
    },
    {'name': 'RACIBÓRZ', 'x': 50.110401, 'y': 18.186264, 'hue': 120.0}
  ];

  Set<Marker> _Update_Markers(List<Map<String, Object>> map) {
    Set<Marker> Markers = {};
    for (var element in map) {
      Markers.add(_Create_Marker(
          element['name'].toString(),
          element['name'].toString(),
          element['x'] as double,
          element['y'] as double,
          element['hue'] as double));
    }
    return Markers;
  }

  Marker _Create_Marker(
      String ID, String name, double X, double Y, double hue) {
    return Marker(
      markerId: MarkerId(ID),
      infoWindow: InfoWindow(title: name),
      icon: BitmapDescriptor.defaultMarkerWithHue(hue),
      position: LatLng(X, Y),
    );
  }

  @override
  Widget build(BuildContext context) {
    Markers = _Update_Markers(test);
    return new Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Profile',
          ),
        ],
      ),
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
