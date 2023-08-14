import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import './pdf.dart';
import './globals.dart';
import './screens/drawer.dart';
import './screens/snackbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: FormWidget()));
}

class FormWidget extends StatefulWidget {
  @override
  _FormWidgetState createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  String _customerName = 'Choose Customer Name-';
  String _productName = 'Choose Product';
  String signURL = '';
  var _quantity = '';
  var _invoiceNo = '';
  var _bonus = '0';
  var items = [];
  var Customers = [];
  List<Map<String, String>> invoiceP = [];
  final db = FirebaseFirestore.instance;
  final DateTime date = DateTime.now();

  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _bonus_controller = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  var data;
  double totalSum() {
    double x = 0;
    invoiceP.forEach((element) {
      x += double.parse(element['price'].toString()) *
          double.parse(element['quantity'].toString());
    });
    return x + (x * .15);
  }

  Future<bool> trigger() async {
    try {
      var url = Uri.parse(
          'Your Firebase ID');
      var response = await http.get(url);
      data = json.decode(response.body);
    } catch (e) {
      SnackbarGlobal.show('No Internet Connection');
    }

    (data["Products"] as List<dynamic>).forEach((element) {
      items.add(element['Product Name']);
    });

    (data["Customers"] as List<dynamic>).forEach((element) {
      Customers.add('${element['Party Name']}-${element['Address']}');
    });

    signURL = data["Resources"][0]["signURL"];

    return true;
  }

  var typeD = TextEditingController();
  var it;
  void getData() {
    it = (data['Products'] as List)
        .firstWhere((element) => element['Product Name'] == _productName);
    print(it['Pack size']);
    setState(() {
      typeD.text =
          '${it['Type']} - ${it['Pack size']}    |    Price: ${it['Unit Price']}';
    });
  }

  var myF;
  @override
  void initState() {
    super.initState();
    myF = trigger();
    _bonus_controller.text = '0';
  }

  Future addDataToFireStore() async {
    String encodedData = base64.encode(utf8
        .encode('${_invoiceNo}|${_customerName}|${date.toIso8601String()}'));
    final url = Uri.parse(
        'https://invoice-maker-283c8-default-rtdb.asia-southeast1.firebasedatabase.app/past-order/${_invoiceNo}.json');
    await http.put(url, body: json.encode({'path': encodedData}));
    invoiceP.forEach(
      (e) async {
        await db.collection(encodedData).doc(e['name']).set({
          'name': e['name'],
          'type': e['type'],
          'pack': e['pack'],
          'price': e['price'],
          'quantity': e['quantity'],
          'bonus': e['bonus']
        });
      },
    );
    print('Executed');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: SnackbarGlobal.key,
      home: Scaffold(
        drawer: AppDrawer(signURL),
        appBar: AppBar(
          title: const Text('Invoice Generator'),
          actions: [
            IconButton(
                onPressed: () {
                  if (_invoiceNo.isEmpty) {
                    SnackbarGlobal.show('Invoice number can\'t be empty');
                  } else {
                    addDataToFireStore();
                    pdf.doIt(
                        context,
                        _customerName.split('-')[0],
                        _customerName.split('-')[1],
                        invoiceP,
                        false,
                        _invoiceNo,
                        signURL);
                  }
                },
                icon: const Icon(Icons.share)),
            IconButton(
                onPressed: () {
                  if (_invoiceNo.isEmpty) {
                    SnackbarGlobal.show('Invoice number can\'t be empty');
                  } else {
                    addDataToFireStore();
                    pdf.doIt(
                        context,
                        _customerName.split('-')[0],
                        _customerName.split('-')[1],
                        invoiceP,
                        true,
                        _invoiceNo,
                        signURL);
                  }
                },
                icon: const Icon(Icons.picture_as_pdf)),
          ],
        ),
        body: FutureBuilder(
          future: myF,
          builder: (context, snapshot) => snapshot.connectionState ==
                  ConnectionState.waiting
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : AnimatedContainer(
                  duration: Duration(milliseconds: 100),
                  padding: EdgeInsets.all(15),
                  child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            DropdownButtonFormField(
                              isExpanded: true,
                              value: _customerName,
                              items: Customers.map(
                                (e) => DropdownMenuItem(
                                  child: Text(e),
                                  value: e,
                                ),
                              ).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _customerName = value.toString();
                                });
                              },
                              decoration: const InputDecoration(
                                  labelText: 'Customer Name'),
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Invoice No.'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty)
                                  return 'Invoice No. Can\'t be empty';
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _invoiceNo = (value);
                                });
                              },
                            ),
                            DropdownButtonFormField(
                              value: _productName,
                              items: items
                                  .map(
                                    (e) => DropdownMenuItem(
                                      child: Text(e),
                                      value: e,
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _productName = value.toString();
                                  getData();
                                });
                              },
                              decoration: const InputDecoration(
                                  labelText: 'Product Name'),
                            ),
                            TextFormField(
                              controller: typeD,
                              decoration:
                                  const InputDecoration(labelText: 'Type'),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: TextFormField(
                                    controller: _quantityController,
                                    decoration: const InputDecoration(
                                        labelText: 'Quantity'),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value!.isEmpty ||
                                          int.tryParse(value) == null)
                                        return 'Please enter a valid quanitity';

                                      return null;
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        _quantity = (value);
                                      });
                                    },
                                  ),
                                ),
                                VerticalDivider(
                                  width: 30,
                                ),
                                Flexible(
                                  child: TextFormField(
                                    // initialValue: str,
                                    controller: _bonus_controller,
                                    decoration: const InputDecoration(
                                        labelText: 'Bonus'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      if (value.isEmpty)
                                        _bonus = '0';
                                      else
                                        _bonus = (value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  final tempData = {
                                    'name': _productName.toString(),
                                    'type': it['Type'].toString(),
                                    'pack': it['Pack size'].toString(),
                                    'price': it['Unit Price'].toString(),
                                    'quantity': _quantity,
                                    'bonus': _bonus
                                  };

                                  setState(() {
                                    _quantityController.clear();
                                    _bonus_controller.clear();
                                    _bonus_controller.text = '0';
                                    _bonus = '0';
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();

                                    invoiceP.add(tempData);
                                  });
                                  SnackbarGlobal.show('Item added');
                                }
                              },
                              child: const Text('Submit'),
                            ),
                            if (invoiceP.length > 0)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration:
                                    BoxDecoration(border: Border.all(width: 1)),
                                height: min(300, (invoiceP.length) * 42),
                                child: ListView.builder(
                                    itemCount: invoiceP.length,
                                    itemBuilder: (context, index) => ListTile(
                                          visualDensity:
                                              const VisualDensity(vertical: -4),
                                          key: ValueKey('$index'),
                                          title: Text(
                                              '${invoiceP[index]['name']}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          leading: CircleAvatar(
                                            radius: 15,
                                            child: Text(
                                                '${invoiceP[index]['quantity']}'),
                                          ),
                                          trailing: IconButton(
                                              onPressed: () {
                                                var name =
                                                    invoiceP[index]['name'];
                                                invoiceP.removeWhere(
                                                    (element) =>
                                                        element['name'] ==
                                                        name);

                                                setState(() {
                                                  SnackbarGlobal.show(
                                                      'Item Deleted');
                                                });
                                              },
                                              icon: const Icon(Icons.delete)),
                                        )),
                              ),
                            const Divider(),
                            Text(
                              'Total Payble: ${totalSum().toStringAsFixed(2)} TK',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )),
                ),
        ),
      ),
      initialRoute: '/',
      // routes: {PastOrders.routeName: (context) => new PastOrders()},
    );
  }
}
