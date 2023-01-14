import 'package:flutter/material.dart';
import 'package:gsheet/userdata.dart';
import 'package:gsheet/users.dart';
import 'package:gsheets/gsheets.dart';
import './gsheet.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'dart:math';
import './pdf.dart';
import './initSc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Invoice Generator',
        theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Cambria'),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
        routes: {
          UserProfiles.routeName: (context) => UserProfiles(),
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var checker = true;
  int rowCount = 17;
  int _counter = 0;
  final _formKey = GlobalKey<FormState>();
  var isLoading = false;
  var product = '';
  var tmpData = UserData('', 'name', 'email', 'degree', 'age');
  final ff = GSheets(gsheet.credintial);
  var partyName = '';

  var type = TextEditingController();
  var typeall = TextEditingController();
  var packsize = TextEditingController();
  var price = TextEditingController();
  var quantity = TextEditingController();
  var address = TextEditingController();
  var bonus = TextEditingController();
  var productList = [];
  var customerList = [];
  var CustomerName = [];
  var CustomerAdd = {};
  var pDet = {};
  var pData = [];
  var InvoiceNo;
  var cell;
  var isDone = false;

  void getCustomer() async {
    final sheet = await ff.spreadsheet(gsheet.sheetID);
    print('Sheet got of customer');
    var sheet1 = sheet.worksheetByTitle('Customer List');
    print('Sheet got of customer list');
    final customerList = await sheet1!.values.allRows();

    (customerList as List<List<String>>).forEach((element) {
      final newMap = {
        'display': '${element[1]} - ${element[2]}',
        'value': element[1],
      };

      CustomerName.add(newMap);
      CustomerAdd.putIfAbsent(
        element[1],
        () {
          return element[2];
        },
      );
    });

    sheet1 = sheet.worksheetByTitle('Sheet1');
    pData = await sheet1!.values.allRows();

    setState(() {
      print('Last setState');
    });
  }

  void getDataOfList() async {
    bonus.text = '0';
    final sheet = await ff.spreadsheet(gsheet.sheetID);
    var sheet1 = sheet.worksheetByTitle('Sheet1');
    final list = await sheet1!.values.columnByKey('Product Name');
    print(list);
    (list as List<String>).forEach((element) {
      final newMap = {
        'display': element,
        'value': element,
      };
      productList.add(newMap);
    });
    setState(() {
      print('fst setState');
    });
  }

  void fillUpForme(BuildContext ctx) async {
    print('Triggered');
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        content: Container(
            height: 100,
            width: 500,
            child: Center(
                child: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  width: 10,
                ),
                Text('Fetcing Data from server!')
              ],
            ))),
      ),
    );

    final sheetp = await ff.spreadsheet(gsheet.sheetID);
    var sheet1p = sheetp.worksheetByTitle('Sheet1');
    var sheet2p = sheetp.worksheetByTitle('No.');
    cell = await sheet2p!.cells.cell(column: 1, row: 1);
    print(cell.value);
    InvoiceNo = int.parse(cell.value);
    InvoiceNo++;
    await cell.post(InvoiceNo);
    pData = await sheet1p!.values.allRows();

    Navigator.of(context).pop();
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        duration: Duration(milliseconds: 1200),
        content: Text('Data fetched successfully!')));

    bonus.text = '0';
  }

  @override
  void initState() {
    getDataOfList();
    getCustomer();

    super.initState();
  }

  List<Map<String, String>> invoiceP = [];
  void triggerSheet(BuildContext ctx) async {
    _formKey.currentState!.save();
    final res = _formKey.currentState!.validate();
    if (res) {
      final tempData = {
        'name': product,
        'type': type.text,
        'pack': packsize.text,
        'price': price.text,
        'quantity': quantity.text,
        'bonus': bonus.text
      };

      invoiceP.add(tempData);

      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          duration: Duration(milliseconds: 200),
          content: Text('Submitted Succesfully!')));
      setState(() {
        isLoading = false;
      });
      print('Success');
    }
    setState(() {
      isLoading = false;
    });
  }

  void findAddress() {
    address.text = CustomerAdd[partyName];
    setState(() {});
  }

  void findDet() {
    (pData as List<dynamic>).forEach((element) {
      pDet.putIfAbsent(
        element[0],
        () {
          return [element[1], element[2], element[3]];
        },
      );
    });
    setState(() {
      packsize.text = pDet[product][1];
      type.text = pDet[product][0];
      price.text = pDet[product][2];
      typeall.text =
          '${pDet[product][0].toString()} - ${pDet[product][1].toString()}  (Price: ${pDet[product][2].toString()})';
    });
  }

  ShowModal(BuildContext ctx) async {
    InvoiceNo++;
    await cell.post(InvoiceNo);
  }

  void trigger(BuildContext ctx) {
    fillUpForme(ctx);
    setState(() {
      checker = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Generator'),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: Duration(milliseconds: 200),
                      content:
                          const Text('Refreshing! Do it again if needed!')));
                });
              },
              icon: const Icon(Icons.refresh)),
          IconButton(
              onPressed: () {
                ShowModal(context);

                pdf.doIt(context, partyName, address.text, invoiceP, false,
                    InvoiceNo);
              },
              icon: const Icon(Icons.share)),
          IconButton(
              onPressed: () {
                ShowModal(context);
                pdf.doIt(context, partyName, address.text, invoiceP, true,
                    InvoiceNo);
              },
              icon: const Icon(Icons.picture_as_pdf)),
        ],
      ),
      body: checker
          ? InitSc(trigger)
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          DropDownFormField(
                            titleText: 'Customer Name ',
                            hintText: 'Please choose',
                            value: partyName,
                            onChanged: (val) {
                              setState(() {
                                partyName = val;
                                findAddress();
                              });
                            },
                            onSaved: (newValue) {
                              setState(() {
                                partyName = newValue;
                              });
                            },
                            dataSource: CustomerName,
                            textField: 'display',
                            valueField: 'value',
                          ),
                          DropDownFormField(
                            titleText: 'Product Name ',
                            hintText: 'Please choose',
                            value: product,
                            onChanged: (val) {
                              product = val;
                              findDet();
                            },
                            onSaved: (newValue) {
                              setState(() {
                                product = newValue;
                              });
                            },
                            dataSource: productList,
                            textField: 'display',
                            valueField: 'value',
                          ),
                          TextFormField(
                            key: const ValueKey('Details'),
                            controller: typeall,
                            decoration:
                                const InputDecoration(labelText: 'Details'),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value!.isEmpty)
                                return 'Plese Select an Product';
                            },
                            onSaved: (newValue) {
                              typeall.text = newValue.toString();
                            },
                          ),
                          TextFormField(
                            key: const ValueKey('qn'),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(labelText: 'Quantity'),
                            textInputAction: TextInputAction.next,
                            controller: quantity,
                            validator: (value) {
                              if (value!.isEmpty || value.contains('.'))
                                return 'Enter an valid quantity';
                            },
                            onSaved: (newValue) {
                              quantity.text = newValue.toString();
                            },
                          ),
                          TextFormField(
                            key: const ValueKey('bonus'),
                            controller: bonus,
                            decoration: const InputDecoration(
                                labelText: 'Bonus Quantity'),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value!.isEmpty || value.contains('.'))
                                return 'Enter an valid bonus quantity';
                            },
                            onSaved: (newValue) {
                              bonus.text = newValue.toString();
                            },
                          ),
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isLoading = true;
                                });
                                triggerSheet(context);
                              },
                              child: isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text('Submit')),
                          if (invoiceP.length > 0)
                            Container(
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
                                              invoiceP.removeWhere((element) =>
                                                  element['name'] == name);
                                              setState(() {});
                                            },
                                            icon: const Icon(Icons.delete)),
                                      )),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
