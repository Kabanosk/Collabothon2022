import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import './map_view.dart';
import './model/place.dart';
import 'location.dart';
import 'main_view_un.dart';
import 'start.dart';

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
  bool _inputViability = false;
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
    return places.where((element) {
      double distance = Geolocator.distanceBetween(
              location!.latitude, location!.longitude, element.x, element.y) /
          1000;
      return distance <= _distanceFilter;
    }).toList();
  }

  void _showMultiSelect(int index) async {
    // a list of selectable items
    // these items can be hard-coded or dynamically fetched from a database/API
    final List<List<String>> _items = [
      ['medicine', 'food', 'fuel', 'water', 'clothing', 'beer'],
      ['hostel', 'hotel', 'apartment', 'flat'],
      ['bus station', 'train station', 'airport'],
      ['charities', 'church', 'ua embassy', 'city council']
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

  void checkInputViability(String input) {
    setState(() {
      num? number = num.tryParse(input);
      if (number != null && number > 0)
        _inputViability = true;
      else
        _inputViability = false;
    });
  }

  void toggleCategories() {
    setState(() {
      _categoryView = !_categoryView;
    });
  }

  void showFilteredPlaces() {
    toggleCategories();
    setState(() {
      if (globalSelectedItems.isNotEmpty) {
        _filteredPlaces = FilterPlaces(globalSelectedItems);
        if (_distanceFilter > 0 && location != null) {
          _filteredPlaces = FilterPlacesByDistance(_filteredPlaces);
          print("Filtering by distance");
        }
      } else {
        _filteredPlaces = _allPlaces;
        if (_distanceFilter > 0 && location != null) {
          _filteredPlaces = FilterPlacesByDistance(_filteredPlaces);
        }
      }
      print(_filteredPlaces);
    });
  }

  void _pushPlaceInfo(int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return placeInfo(context, _filteredPlaces[index]);
        },
      ),
    );
  }

  Widget placeInfo(BuildContext context, Place place) {
    return Scaffold(
      appBar: AppBar(),
    );
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
                  onPressed: toggleCategories,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.arrow_back),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: FloatingActionButton(
                  elevation: 0,
                  hoverElevation: 0,
                  onPressed: showFilteredPlaces,
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
                              onChanged: checkInputViability,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false, signed: false),
                              // inputFormatters: [BlacklistingTextInputFormatter(new RegExp('[\\-|\\ ]'))],
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText:
                                    "Currently: " + _distanceFilter.toString(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: new Icon(
                        _inputViability ? Icons.check : Icons.close,
                        color: _inputViability ? Colors.green : Colors.red,
                      ),
                    );
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
                      onTap: () => _pushPlaceInfo(
                          index)); // TO DO: clicking this should bring info about the location
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
