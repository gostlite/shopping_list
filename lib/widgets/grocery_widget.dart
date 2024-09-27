import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';

class GroceryWidegt extends StatelessWidget {
  const GroceryWidegt({required this.groceryItem, super.key});
  final GroceryItem groceryItem;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 15.0, // Set the width of the box
        height: 15.0, // Set the height of the box
        color: groceryItem.category.color,
      ),
      title: Text(groceryItem.name),
      trailing: Text(groceryItem.quantity.toString()),
    );
  }
}
