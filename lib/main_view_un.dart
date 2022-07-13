import 'package:flutter/material.dart';

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

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  @override
  Widget build(BuildContext context) {
    List<String> categories = <String>[
      'food',
      'shower',
      'transport',
      'shop nearby'
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('ukrainian tinder'), actions: [
        const IconButton(
          onPressed: null,
          icon: Icon(Icons.list),
          tooltip: 'View Favourites',
        )
      ]),
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
      body: ListView.builder(
        itemCount: categories.length * 2,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return const Divider();

          final index = i ~/ 2;

          return ListTile(
              title: Text(
                categories[index],
                style: const TextStyle(fontSize: 18, color: Color(0xFF000000)),
              ),
              trailing: const Icon(
                Icons.add,
                color: Colors.red,
                semanticLabel: 'More',
              ),
              onTap: null);
        },
      ),
    );
  }
}
