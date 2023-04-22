import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

import './snackbar.dart';

class ManageProducts extends StatefulWidget {
  const ManageProducts({super.key});

  @override
  State<ManageProducts> createState() => _ManageProductsState();
}

class _ManageProductsState extends State<ManageProducts> {
  List datas = [];

  Future getData() async {
    final url = Uri.parse(
        'https://invoice-maker-283c8-default-rtdb.asia-southeast1.firebasedatabase.app/Products.json');
    var res = await http.get(url);
    datas = json.decode(res.body);
    ;
    return true;
  }

  void deleteItem(int i, String index) {
    BuildContext dialogContext = context;
    showDialog(
        context: context,
        builder: (context) {
          dialogContext = context;
          return AlertDialog(
            content: Text('Are you sure want to delete the item?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('No')),
              TextButton(
                  onPressed: () async {
                    try {
                      final url = Uri.parse(
                          'https://invoice-maker-283c8-default-rtdb.asia-southeast1.firebasedatabase.app/Products/${index}.json');
                      var res = await http.delete(url);
                      if (res.statusCode == 200) {
                        SnackbarGlobal.show('Item Deleted');

                        Navigator.of(context).pop(true);
                        setState(() {
                          datas.removeWhere(
                              (element) => element['index'] == index);
                        });
                      }
                    } catch (e) {
                      SnackbarGlobal.show('Something went wrong');
                    }
                  },
                  child: Text('Yes')),
            ],
          );
        }).then((value) {
      if (value == null)
        return;
      else if (value) Navigator.of(dialogContext).pop(true);
    });
  }

  void updateData(int i) async {
    TextEditingController name = TextEditingController();
    TextEditingController size = TextEditingController();
    TextEditingController price = TextEditingController();
    TextEditingController type = TextEditingController();

    name.text = datas[i]["Product Name"];
    size.text = datas[i]["Pack size"];
    price.text = datas[i]["Unit Price"].toString();
    type.text = datas[i]["Type"];

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Text('Update Information'),
                  SizedBox(
                    width: 40,
                  ),
                  IconButton(
                      onPressed: () {
                        deleteItem(i, datas[i]['index']);
                      },
                      icon: Icon(Icons.delete))
                ],
              ),
              content: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: 250,
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                      ),
                      controller: name,
                      onChanged: (value) {
                        name.text = value;
                        name.selection =
                            TextSelection.collapsed(offset: name.text.length);
                      },
                    ),
                    DropdownButtonFormField(
                      value: type.text,
                      decoration: InputDecoration(labelText: 'Type'),
                      items: <String>[
                        'Unselected',
                        'Tablet',
                        'Suspention',
                        'Syrup',
                        'PFS',
                        'Capsul',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          type.text = newValue!;
                        });
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Pack Size'),
                      controller: size,
                      onChanged: (value) {
                        size.text = value;
                        size.selection =
                            TextSelection.collapsed(offset: size.text.length);
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Unit Price'),
                      controller: price,
                      onChanged: (value) {
                        price.text = value;
                        price.selection =
                            TextSelection.collapsed(offset: price.text.length);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel')),
                TextButton(
                    onPressed: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      try {
                        final url = Uri.parse(
                            'https://invoice-maker-283c8-default-rtdb.asia-southeast1.firebasedatabase.app/Products.json');
                        var res = await http.patch(url,
                            body: json.encode({
                              i.toString(): {
                                'Product Name': name.text,
                                'Type': type.text,
                                'Pack size': size.text,
                                'Unit Price': price.text
                              }
                            }));
                        if (res.statusCode == 200) {
                          SnackbarGlobal.show('Information Updated');

                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        {
                          SnackbarGlobal.show('Something went wrong');
                        }
                      }
                    },
                    child: Text('Update')),
              ],
            ));
  }

  void addProduct(BuildContext context) async {
    TextEditingController name = TextEditingController();
    TextEditingController size = TextEditingController();
    TextEditingController price = TextEditingController();
    TextEditingController type = TextEditingController();

    type.text = 'Unselected';
    int target = datas.length;
    final url = Uri.parse(
        'https://invoice-maker-283c8-default-rtdb.asia-southeast1.firebasedatabase.app/Products.json');
    var res = await http.get(url);
    target = json.decode(res.body).length;
    print('target $target');
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Add new product'),
              content: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: 250,
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                      ),
                      controller: name,
                      onChanged: (value) {
                        name.text = value;
                        name.selection =
                            TextSelection.collapsed(offset: name.text.length);
                      },
                    ),
                    DropdownButtonFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Can\'t be empty';
                        }
                      },
                      value: 'Unselected',
                      decoration: InputDecoration(labelText: 'Type'),
                      items: <String>[
                        'Unselected',
                        'Tablet',
                        'Suspention',
                        'Syrup',
                        'PFS',
                        'Capsul',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          type.text = newValue!;
                        });
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Pack Size'),
                      controller: size,
                      onChanged: (value) {
                        size.text = value;
                        size.selection =
                            TextSelection.collapsed(offset: size.text.length);
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Unit Price'),
                      controller: price,
                      onChanged: (value) {
                        price.text = value;
                        price.selection =
                            TextSelection.collapsed(offset: price.text.length);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel')),
                TextButton(
                    onPressed: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      try {
                        final addedP = {
                          'Product Name': name.text,
                          'Type': type.text,
                          'Pack size': size.text,
                          'Unit Price': price.text,
                          'index': target.toString()
                        };
                        final url = Uri.parse(
                            'https://invoice-maker-283c8-default-rtdb.asia-southeast1.firebasedatabase.app/Products/${target}.json');
                        var res =
                            await http.put(url, body: json.encode(addedP));
                        if (res.statusCode == 200) {
                          SnackbarGlobal.show('Product Added');
                          Navigator.of(context).pop();

                          setState(() {
                            datas.add(addedP);
                          });
                        }
                      } catch (e) {
                        {
                          SnackbarGlobal.show('Something went wrong');
                        }
                      }
                    },
                    child: Text('Add')),
              ],
            ));
  }

  var myF;
  @override
  void initState() {
    myF = getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Products'),
        actions: [
          IconButton(
              onPressed: () {
                addProduct(context);
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: FutureBuilder(
        future: myF,
        builder: (context, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: datas.length,
                itemBuilder: (context, i) => AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey,
                      ),
                      alignment: Alignment.center,
                      margin: datas[i] == null
                          ? null
                          : EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      width: double.infinity,
                      child: i == 0 || datas[i] == null
                          ? null
                          : ListTile(
                              visualDensity:
                                  VisualDensity(horizontal: 0, vertical: -4),
                              style: ListTileStyle.drawer,
                              title: Text(datas[i]["Product Name"].toString()),
                              subtitle: Text(datas[i]["Type"].toString()),
                              trailing: AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                width: 120,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        '${datas[i]["Unit Price"].toString()} TK'),
                                    IconButton(
                                        onPressed: () {
                                          updateData(i);
                                          print(
                                              'Pressed of ${datas[i]["Product Name"].toString()}');
                                        },
                                        icon: Icon(Icons.edit))
                                  ],
                                ),
                              ),
                              leading: AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                alignment: Alignment.center,
                                width: 40,
                                child: Text(
                                  datas[i]["Pack size"].toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                    )),
      ),
    );
  }
}
