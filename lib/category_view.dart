import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import './map_view.dart';
import './model/place.dart';
import 'location.dart';
import 'main_view_un.dart';

Set<String> globalSelectedItems = {};

class CategoryView extends StatefulWidget {
  CategoryView({Key? key}) : super(key: key);
  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  Set<String> _selectedItems = {};
  bool _categoryView = true;
  num _distanceFilter = 0;
  List<Place> _filteredPlaces = [];
  List<Place> _allPlaces = [];

  @override
  void initState() {
    super.initState();
    getPlaces().then((data) {
      setState(() {
        _allPlaces = data;
        // print(_allPlaces.first.tags);
      });
    });
    fetchLocation();
  }

  void fetchLocation() {
    determinePosition().then((data) {
      setState(() {
        location = data;
        print(location);
      });
    });
  }

  List<Place> FilterPlaces(Set<String> selectedCategories) {
    return _allPlaces
        .where((element) =>
            element.tags.any((tag) => selectedCategories.contains(tag)))
        .toList();
  }

  List<Place> FilterPlacesByDistance(List<Place> places) {
    return places
        .where((element) =>
            Geolocator.distanceBetween(location!.latitude, location!.longitude,
                    element.y, element.x) /
                1000 <=
            _distanceFilter)
        .toList();
  }

  void _showMultiSelect(int index) async {
    // a list of selectable items
    // these items can be hard-coded or dynamically fetched from a database/API
    final List<List<String>> _items = [
      ['Medicine', 'Food', 'Fuel', 'Water', 'Clothing', 'Beer'],
      ['Hostel', 'Hotel', 'Apartment', 'Flat'],
      ['Bus station', 'Train station', 'Airport'],
      ['Charities', 'Church', 'UA embassy', 'City council']
    ];

    final Set<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(items: _items[index]);
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        _selectedItems = Set.from(results);
        globalSelectedItems = Set.from(results);
        //_categoryView = false;
      });
      setState(() {
        _filteredPlaces = FilterPlaces(globalSelectedItems);
        print("Is location null?");
        print(location);
        if (_distanceFilter > 0 && location != null) {
          _filteredPlaces = FilterPlacesByDistance(_filteredPlaces);
          print("Filtering by distance");
        }
        print(_filteredPlaces);
      });
    }
    print(globalSelectedItems);
  }

  void saveDistanceFilter(String distance) {
    setState(() {
      _distanceFilter = num.parse(distance);
      if (_distanceFilter < 0) _distanceFilter = 0;
      print(_distanceFilter);
    });
  }

  void toggleCategories() {
    setState(() {
      _categoryView = !_categoryView;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> categories = <String>[
      'supplies',
      'accomodation',
      'transport',
      'social help',
      'distance',
    ];

    return Scaffold(
        floatingActionButtonLocation: !_categoryView
            ? FloatingActionButtonLocation.startDocked
            : FloatingActionButtonLocation.endDocked,
        floatingActionButton: !_categoryView
            ? Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: FloatingActionButton(
                  elevation: 0,
                  hoverElevation: 0,
                  onPressed: () => toggleCategories(),
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.arrow_back),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: FloatingActionButton(
                  elevation: 0,
                  hoverElevation: 0,
                  onPressed: toggleCategories,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.save),
                ),
              ),
        body: _categoryView
            ? ListView.builder(
                itemCount: categories.length * 2,
                padding: const EdgeInsets.all(16.0),
                itemBuilder: (context, i) {
                  if (i.isOdd) return const Divider();
                  if (i > 6) {
                    return ListTile(
                        title: Row(
                          children: <Widget>[
                            Expanded(
                                child: Text(
                              'Distance Radius',
                              style: const TextStyle(
                                  fontSize: 18, color: Color(0xFF000000)),
                            )),
                            Expanded(
                              child: TextField(
                                obscureText: false,
                                onSubmitted: saveDistanceFilter,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: false, signed: false),
                                // inputFormatters: [BlacklistingTextInputFormatter(new RegExp('[\\-|\\ ]'))],
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'eg. 50 km',
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: new Icon(Icons.check),
                          color: Colors.black26,
                          onPressed:
                              null, // TO DO: This should save a filter by distance radius
                        ));
                  } else {
                    final index = i ~/ 2;
                    return ListTile(
                        title: Text(
                          categories[index],
                          style: const TextStyle(
                              fontSize: 18, color: Color(0xFF000000)),
                        ),
                        leading: const Icon(
                          Icons.keyboard_double_arrow_right_sharp,
                          color: Colors.blueAccent,
                          semanticLabel: 'Filter Categories',
                        ),
                        onTap: () => _showMultiSelect(index));
                  }
                },
              )
            : ListView.builder(
                itemCount: _filteredPlaces.length * 2,
                padding: const EdgeInsets.all(16.0),
                itemBuilder: (context, i) {
                  if (i.isOdd) return const Divider();

                  final index = i ~/ 2;

                  return ListTile(
                      title: Text(
                        _filteredPlaces[index].name,
                        style: const TextStyle(
                            fontSize: 18, color: Color(0xFF000000)),
                      ),
                      onTap:
                          null); // TO DO: clicking this should bring info about the location
                }));
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
  final Set<String> _selectedItems = Set.from(globalSelectedItems);

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
