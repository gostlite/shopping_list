import 'dart:convert';

import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/grocery_widget.dart';
import 'package:shopping_list/widgets/new_item.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  late Widget content;
  String? _error;

  void _loadItems() async {
    const urlLink = "shop-49730-default-rtdb.firebaseio.com";
    final url = Uri.https(urlLink, 'shopping-list.json');
    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _isLoading = false;
        });
        throw Exception("Something is wrong here");
      }
      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        throw Exception("The data is null");
      }

      final Map<String, dynamic> jsonData = json.decode(response.body);
      print(jsonData);
      final List<GroceryItem> loadedItemList = [];
      for (final item in jsonData.entries) {
        final category = categories.entries
            .firstWhere((val) => val.value.title == item.value['category'])
            .value;
        loadedItemList.add(GroceryItem(
            id: item.key,
            name: item.value['name'] as String,
            quantity: item.value['quantity'] as int,
            category: category));
      }
      setState(() {
        _groceryItems = loadedItemList;
        _isLoading = false;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        _error = e.toString().split(":")[1];
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
      // _isLoading = false;
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    const urlLink = "test-shop-49730-default-rtdb.firebaseio.com";
    final url = Uri.https(urlLink, 'shopping-list/${item.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      //optional to show a message with scaffold messenger
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    content = Center(
      child: Text("Sorry Your grocery list is empty",
          style: Theme.of(context).textTheme.headlineMedium),
    );
    if (_isLoading) {
      setState(() {
        content = const Center(
          child: CircularProgressIndicator(),
        );
      });
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (context, index) {
            final item = _groceryItems[index];
            return Dismissible(
                key: ValueKey(item),
                onDismissed: (direction) {
                  _removeItem(item);
                },
                child: GroceryWidegt(groceryItem: item));
          });
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!, style: Theme.of(context).textTheme.headlineSmall),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Grocries"),
          actions: [
            IconButton(onPressed: _addItem, icon: const Icon(Icons.add))
          ],
        ),
        body: content);
  }
}
