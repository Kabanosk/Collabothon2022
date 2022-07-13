import 'package:flutter/material.dart';
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
  List<String> _selectedItems = [];
  bool _categoryView = true;
  int _selectedView = 0;

  void _showMultiSelect(int index) async {
    // a list of selectable items
    // these items can be hard-coded or dynamically fetched from a database/API
    final List<List<String>> _items = [
      ['Medicine', 'Food', 'Fuel', 'Water', 'Clothing', 'Beer'],
      ['Hostel', 'Hotel', 'Apartment', 'Flat'],
      ['Bus station', 'Train station', 'Airport'],
      ['Charities', 'Church', 'UA embassy', 'City council']
    ];

    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(items: _items[index]);
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        _selectedItems = results;
        selectedItems = results;
        _categoryView = false;
      });
    }
    print(results);
  }

  void goBack() async {
    setState(() {
      _categoryView = true;
    });
  }

  void changeView(int index) {
    setState(() {
      _selectedView = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> categories = <String>[
      'supplies',
      'accomodation',
      'transport',
      'social help'
    ];

    const TextStyle optionStyle =
        TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

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
        leading: !_categoryView
            ? IconButton(
                onPressed: goBack,
                icon: Icon(Icons.arrow_back),
                tooltip: 'Go back',
              )
            : null,
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

class MultiSelect extends StatefulWidget {
  final List<String> items;
  const MultiSelect({Key? key, required this.items}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  // this variable holds the selected items
  final List<String> _selectedItems = [];

// This function is triggered when a checkbox is checked or unchecked
  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
      }
    });
  }

  // this function is called when the Cancel button is pressed
  void _cancel() {
    Navigator.pop(context);
  }

// this function is called when the Submit button is tapped
  void _submit() {
    Navigator.pop(context, _selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Topics'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items
              .map((item) => CheckboxListTile(
                    value: _selectedItems.contains(item),
                    title: Text(item),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) => _itemChange(item, isChecked!),
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: _cancel,
        ),
        ElevatedButton(
          child: const Text('Submit'),
          onPressed: _submit,
        ),
      ],
    );
  }
}
