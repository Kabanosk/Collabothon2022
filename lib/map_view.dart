import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabothon/chat_view.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'model/place.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

CollectionReference _placesRef =
    FirebaseFirestore.instance.collection('places');

CollectionReference _usersRef = FirebaseFirestore.instance.collection('users');

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

Future<List<String>> getUsernames() async {
  List<String> listOfUsers = [];
  var querySnapshot = await _usersRef.get();
  for (var queryDocumentSnapshot in querySnapshot.docs) {
    Map<String, dynamic> data =
        queryDocumentSnapshot.data() as Map<String, dynamic>;
    listOfUsers.add(data['name']);
  }
  return listOfUsers;
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

  Set<Marker> updateMarkers(List<Place> map, List<String> names) {
    Set<Marker> _markers = {};
    int i = 0;
    for (var element in map) {
      _markers.add(createMarker(
          element.id,
          element.name,
          element.descryption,
          element.x,
          element.y,
          element.type,
          element.number,
          element.uid,
          names[i]));
      i++;
    }
    return _markers;
  }

  _callNumber(String phoneNumber) async {
    String number = phoneNumber;
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  Widget chatmateConversation(
      String chatmate, String uid, BuildContext context) {
    TextEditingController fieldController = TextEditingController();
    final GlobalKey<DashChatState> _chatViewKey = GlobalKey<DashChatState>();

    List<ChatMessage> messages = <ChatMessage>[];

    void onSend(ChatMessage message) {
      print(message.toJson());
      message.customProperties = {'messageTo': uid};
      FirebaseFirestore.instance
          .collection('messages')
          .doc(DateTime.now().millisecondsSinceEpoch.toString())
          .set(message.toJson());

      setState(() {
        messages.add(ChatMessage(
          text: message.text,
          createdAt: DateTime.now(),
          user: message.user,
        ));

        messages = [...messages];
      });
    }

    return Scaffold(
      appBar: AppBar(title: Row(children: [Text(chatmate)])),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('messages')
              .orderBy("createdAt")
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              );
            } else {
              List<DocumentSnapshot> items = snapshot.data!.docs;
              messages = items
                  .map((i) =>
                      ChatMessage.fromJson(i.data()! as Map<dynamic, dynamic>))
                  .toList()
                  .where((i) =>
                      (i.user.uid == user.uid &&
                          i.customProperties!['messageTo'] == uid) ||
                      (i.user.uid == uid &&
                          i.customProperties!['messageTo'] == user.uid))
                  .toList();
              return DashChat(
                key: _chatViewKey,
                inverted: false,
                onSend: onSend,
                sendOnEnter: true,
                textInputAction: TextInputAction.send,
                user: user,
                inputDecoration:
                    InputDecoration.collapsed(hintText: "Add message here..."),
                dateFormat: DateFormat('yyyy-MMM-dd'),
                timeFormat: DateFormat('HH:mm'),
                messages: messages,
                showUserAvatar: false,
                showAvatarForEveryMessage: false,
                scrollToBottom: false,
                inputMaxLines: 5,
                messageContainerPadding: EdgeInsets.only(left: 5.0, right: 5.0),
                alwaysShowSend: true,
                inputTextStyle: TextStyle(fontSize: 16.0),
                inputContainerStyle: BoxDecoration(
                  border: Border.all(width: 0.0),
                  color: Colors.white,
                ),
                onQuickReply: (Reply reply) {
                  setState(() {
                    messages.add(ChatMessage(
                        text: reply.value,
                        createdAt: DateTime.now(),
                        user: user));

                    messages = [...messages];
                  });
                },
                onLoadEarlier: () {
                  print("laoding...");
                },
                shouldShowLoadEarlier: false,
                showTraillingBeforeSend: true,
              );
            }
          }),
    );
  }

  _openChat(String uid, String name) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return chatmateConversation(name, uid, context);
        },
      ),
    );
  }

  Marker createMarker(String id, String name, String desc, double X, double Y,
      String type, String phoneNumber, String uid, String uname) {
    return Marker(
        markerId: MarkerId(id),
        position: LatLng(X, Y),
        icon: BitmapDescriptor.defaultMarkerWithHue(typeToHue[type] as double),
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
                            image: AssetImage('assets/images/tlo.jpg'),
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
                          Spacer(),
                          SizedBox(
                            width: 80,
                            height: 30,
                            child: ElevatedButton(
                              child: const Text("Chat"),
                              onPressed: () {
                                _openChat(uid, uname);
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
      getUsernames().then((names) {
        setState(() {
          _markers = updateMarkers(data, names);
        });
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
