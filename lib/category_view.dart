import 'package:flutter/material.dart';

List<String> selectedItems = [];

class CategoryView extends StatefulWidget {
  const CategoryView({Key? key}) : super(key: key);

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  List<String> _selectedItems = [];
  bool _categoryView = true;

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

  @override
  Widget build(BuildContext context) {
    List<String> categories = <String>[
      'supplies',
      'accomodation',
      'transport',
      'social help'
    ];

    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
        floatingActionButton: !_categoryView
            ? Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: FloatingActionButton(
                  elevation: 0,
                  hoverElevation: 0,
                  onPressed: () => goBack(),
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.arrow_back),
                ),
              )
            : null,
        body: _categoryView
            ? ListView.builder(
                itemCount: categories.length * 2,
                padding: const EdgeInsets.all(16.0),
                itemBuilder: (context, i) {
                  if (i.isOdd) return const Divider();

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
                        semanticLabel: 'Filter categories',
                      ),
                      onTap: () => _showMultiSelect(index));
                },
              )
            : ListView.builder(
                itemCount: _selectedItems.length * 2,
                padding: const EdgeInsets.all(16.0),
                itemBuilder: (context, i) {
                  if (i.isOdd) return const Divider();

                  final index = i ~/ 2;

                  return ListTile(
                      title: Text(
                        _selectedItems[index],
                        style: const TextStyle(
                            fontSize: 18, color: Color(0xFF000000)),
                      ),
                      trailing: const Icon(
                        Icons.add,
                        color: Colors.blueAccent,
                        semanticLabel: 'More',
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
