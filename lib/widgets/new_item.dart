import 'package:flutter/material.dart';
import 'package:udemy_grocery_app/models/category.dart';
import 'package:udemy_grocery_app/models/grocery_item.dart';
import '../data/categories.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  //easy access to widget- if build is executed again it keeps its internal state
  final _formKey = GlobalKey<FormState>();

  var _enteredName = "";
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetable]!;
  var _isSending = false;

  void _saveItem() async {
    //this will validate and return a bool a value
    //and save value the current state
    //and go back
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final url = Uri.https(
        "groceryapp-4ea49-default-rtdb.firebaseio.com",
        'shopping-list.json',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "name": _enteredName,
          "quantity": _enteredQuantity,
          "category": _selectedCategory.title,
        }),
      );

      setState(() {
        _isSending = true;
      });
      //decode json response= map value
      final Map<String, dynamic> resData = json.decode(response.body);

      if (!context.mounted) {
        return;
      }

      // now I am passing data back to homeScreen
      // we use the model here
      Navigator.of(context).pop(
        GroceryItem(
          id: resData['name'],
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add a new item')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: InputDecoration(label: Text('Name')),
                //takes a string and returns a string
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value
                          .trim()
                          .length <= 1 ||
                      value
                          .trim()
                          .length > 50) {
                    return 'Must be between 1 and 50 characters';
                  }

                  return null;
                },
                //value = received value
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      //takes a string and returns a string
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            //tryParse returns null if it fails to convert string to number
                            int.tryParse(value) == null ||
                            //value wont be null
                            int.tryParse(value)! <= 0) {
                          return 'Must be a valid number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                      keyboardType: TextInputType.number,

                      decoration: InputDecoration(label: Text('Quantity')),
                      //number as string
                      initialValue: _enteredQuantity.toString(),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      onChanged: (value) {
                        //to update UI when selected
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },

                      items: [
                        //gives iterable Map of key value pairs in list
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                SizedBox(width: 6),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending ? null : () {
                      _formKey.currentState!.reset();
                    },
                    child: Text("Reset"),
                  ),
                  ElevatedButton(onPressed: _isSending ? null : _saveItem,
                      child: _isSending ? SizedBox(height: 16,
                        width: 16,
                        child: CircularProgressIndicator(),): Text("Save")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
