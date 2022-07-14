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
    return const MaterialApp(
      // Remove the const from here
      title: 'Startup Name Generator',
      home: MainView(), // And add the const back here.
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
  int _selectedView = 0;
  bool locationAvailable = false;
  Position? location;

  void changeView(int index) {
    setState(() {
      _selectedView = index;
    });
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
    // TO-DO Use location context to fetch current location
    // Location location = Location.of(context);
    const List<Widget> _widgetOptions = <Widget>[
      CategoryView(),
      MapView(),
      ChatView(),
      ProfileView()
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ukrainian tinder'),
        actions: [
          const IconButton(
            onPressed: null,
            icon: Icon(Icons.list),
            tooltip: 'View Favourites',
          ),
        ],
        //leading: Text(location!.longitude.toString()),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        //currentIndex: 3,
        //backgroundColor: Colors.blueAccent,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
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
        currentIndex: _selectedView,
        onTap: changeView,
      ),
      body: _widgetOptions[_selectedView],
    );
  }
}
