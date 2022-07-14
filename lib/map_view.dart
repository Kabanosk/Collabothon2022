import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'model/place.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

CollectionReference _placesRef =
    FirebaseFirestore.instance.collection('places');

Future<List<Place>> getPlaces() async {
  List<Place> listOfPlaces = [];
  var querySnapshot = await _placesRef.get();
  for (var queryDocumentSnapshot in querySnapshot.docs) {
    Map<String, dynamic> data =
        queryDocumentSnapshot.data() as Map<String, dynamic>;
    listOfPlaces.add(Place.fromJson(data));
  }
  return listOfPlaces;
}

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  State<MapView> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  Completer<GoogleMapController> _controller = Completer();

  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(51.11090780609161, 17.053179152853453),
    zoom: 14.4746,
  );

  Set<Marker> _markers = {};

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }

  final Map<String, double> typeToHue = {
    'supplies': 60.0,
    'accomodation': 120.0,
    'transport': 180.0,
    'social help': 0.0
  };

  Set<Marker> updateMarkers(List<Place> map) {
    Set<Marker> _markers = {};
    for (var element in map) {
      _markers.add(createMarker(
        element.id,
        element.name,
        element.descryption,
        element.x,
        element.y,
        element.type,
        element.number
      ));
    }
    return _markers;
  }

  _callNumber(String phoneNumber) async {
    String number = phoneNumber;
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  Marker createMarker(String id, String name, String desc, double X, double Y,
      String type, String phoneNumber) {
    return Marker(
        markerId: MarkerId(id),
        position: LatLng(X, Y),
        icon: BitmapDescriptor.defaultMarkerWithHue(typeToHue[type] as double),
        //infoWindow: InfoWindow(title: name),
        onTap: () {
          _customInfoWindowController.addInfoWindow!(
              Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 300,
                      height: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/komi.png'),
                            fit: BoxFit.fitWidth,
                            filterQuality: FilterQuality.high),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        color: Colors.red,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: Text(
                        desc,
                        maxLines: 2,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: Row(
                        children: [
                          Icon(IconData(0xe4a2, fontFamily: 'MaterialIcons')),
                          SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: 80,
                            height: 30,
                            child: ElevatedButton(
                              child: const Text("Call"),
                              onPressed: () {
                                _callNumber(phoneNumber);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              LatLng(X, Y));
        });
  }

  @override
  void initState() {
    super.initState();
    getPlaces().then((data) {
      setState(() {
        _markers = updateMarkers(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: const Text('An awesome map!'),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onTap: (position) {
              _customInfoWindowController.hideInfoWindow!();
            },
            onCameraMove: (position) {
              _customInfoWindowController.onCameraMove!();
            },
            mapType: MapType.normal,
            markers: _markers,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              _customInfoWindowController.googleMapController = controller;
            },
          ),
          CustomInfoWindow(
            controller: _customInfoWindowController,
            height: 200,
            width: 300,
            offset: 35,
          ),
        ],
      ),
    );
  }
}
