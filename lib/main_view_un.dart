import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import './location.dart';
import './category_view.dart';
import './profile_view.dart';
import './map_view.dart';
import './chat_view.dart';
import './start.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'model/place.dart';

Position? location;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => MainView(),
        '/map': (context) => MapView(),
        '/profil': (context) => ProfileView(),
        '/chat': (context) => ChatView(),
      },
      title: 'Google Challenge',
    );
  }
}

List<String> selectedItems = [];

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  // int _selectedView = 0;
  bool locationAvailable = false;

  // void changeView(int index) {
  //   setState(() {
  //     _selectedView = index;
  //   });
  // }

  List<String> screenOption = <String>[
    '/map',
    '/chat',
    '/profil',
  ];

  void navigateToNewScreen(int index) {
    String screen = screenOption[index];
    Navigator.pushNamed(context, screen);
  }

  @override
  void initState() {
    super.initState();
    fetchLocation();
  }

  void fetchLocation() {
    determinePosition().then((data) {
      setState(() {
        location = data;
        locationAvailable = true;
        print(location);
      });
    });
  }

  List<String> types = ['supplies', 'accomodation', 'transport', 'social help'];

  @override
  Widget build(BuildContext context) {
    // const List<Widget> _widgetOptions = <Widget>[
    //   // CategoryView(),
    //   MapView(),
    //   ChatView(),
    //   ProfileView()
    // ];
    showAddingDialog(BuildContext context) {
      TextEditingController nameController = new TextEditingController();
      TextEditingController descryptionController = new TextEditingController();
      TextEditingController numberController = new TextEditingController();
      String typeController = "transport";
      TextEditingController xController = new TextEditingController();
      TextEditingController yController = new TextEditingController();
      TextEditingController tagsController = new TextEditingController();

      // set up the button
      Widget saveButton = TextButton(
        child: Text("Save"),
        onPressed: () {
          Place place = Place(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            descryption: descryptionController.text,
            name: nameController.text,
            type: typeController,
            tags: tagsController.text.toLowerCase().split(','),
            x: double.parse(xController.text),
            y: double.parse(yController.text),
            number: numberController.text,
            uid: user.uid as String,
          );

          FirebaseFirestore.instance
              .collection('places')
              .doc(DateTime.now().millisecondsSinceEpoch.toString())
              .set(place.toJson());
        },
      );

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text("Add a new place"),
        content: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter a Name',
                  ),
                ),
                TextField(
                  controller: descryptionController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter a Descryption',
                  ),
                ),
                TextField(
                  controller: numberController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter a Number',
                  ),
                ),
                TextField(
                  controller: xController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter a Latency',
                  ),
                ),
                TextField(
                  controller: yController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter a Longitude',
                  ),
                ),
                TextField(
                  controller: tagsController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter a Tags',
                  ),
                ),
                Row(children: [
                  Text('Select Type '),
                  DropdownButton<String>(
                    //value: typeController,
                    onChanged: (String? data) {
                      setState(() {
                        typeController = data as String;
                      });
                    },
                    items: types.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ]),
              ],
            ),
          ),
        ),
        actions: [
          saveButton,
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
          title: const Text('Google challenge'),
          leading: IconButton(
            icon: Icon(Icons.gps_fixed),
            onPressed: fetchLocation,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => showAddingDialog(context),
            ),
          ]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        //currentIndex: 3,
        //backgroundColor: Colors.blueAccent,
        items: const <BottomNavigationBarItem>[
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.category),
          //   label: 'Categories',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        // currentIndex: _selectedView,
        // onTap: changeView,
        onTap: navigateToNewScreen,
        unselectedItemColor: Colors.blueAccent,
        selectedItemColor: Colors.blueAccent,
      ),
      // body: _widgetOptions[_selectedView],
      body: CategoryView(),
    );
  }
}
