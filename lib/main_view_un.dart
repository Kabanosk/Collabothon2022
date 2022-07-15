import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import './location.dart';
import './category_view.dart';
import './profile_view.dart';
import './map_view.dart';
import './chat_view.dart';

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
  Position? location;

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
    determinePosition().then((data) {
      setState(() {
        location = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // const List<Widget> _widgetOptions = <Widget>[
    //   // CategoryView(),
    //   MapView(),
    //   ChatView(),
    //   ProfileView()
    // ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Google challenge'),
        // leading: Text(location!.longitude.toString()),
      ),
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
      body: CategoryView(location),
    );
  }
}
