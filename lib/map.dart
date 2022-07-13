import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(51.11090780609161, 17.053179152853453),
    zoom: 14.4746,
  );

  static final Marker _kCSInstitute = Marker(
    markerId: MarkerId('_kCSInstitute'),
    infoWindow: InfoWindow(title: 'Institute of Computer Science'),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(51.11090780609161, 17.053179152853453),
  );

  static final Marker _kMInstitute = Marker(
    markerId: MarkerId('_kMInstitute'),
    infoWindow: InfoWindow(title: 'Institute of Mathematics'),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    position: LatLng(51.1101851799257, 17.05400886656973),
  );

  @override
  Widget build(BuildContext context) {
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
        markers: {_kCSInstitute, _kMInstitute},
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
