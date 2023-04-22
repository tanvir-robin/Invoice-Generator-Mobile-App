import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../pdf.dart';
import './snackbar.dart';

class PastOrders extends StatefulWidget {
  PastOrders({
    required this.signURL,
  });
  static const routeName = '/past';

  final String signURL;

  @override
  State<PastOrders> createState() => _PastOrdersState();
}

class _PastOrdersState extends State<PastOrders> {
  final db = FirebaseFirestore.instance;
  final DateTime date = DateTime.now();

  void setErrorBuilder() {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return Scaffold(
          body: Center(
              child: Container(
        height: 5000,
        child: SingleChildScrollView(
          child: Column(
            children: [
              //  Text(errorDetails.stack.toString()),
              Text(errorDetails.summary.toString()),
              // Text(errorDetails.toString()),
            ],
          ),
        ),
      )));
    };
  }

  List<String> paths = [];
  Future<bool> getData() async {
    final url = Uri.parse(
        'https://invoice-maker-283c8-default-rtdb.asia-southeast1.firebasedatabase.app/past-order.json');
    final res = await http.get(url);

    var link = json.decode(res.body);
    link.entries.forEach((element) {
      paths.add((element.value['path']));
    });
    return true;
  }

  var myF;
  @override
  void initState() {
    setErrorBuilder();
    myF = getData();
    super.initState();
  }

  String decodeText(String x) {
    String decoded = utf8.decode(base64.decode(x));
    return decoded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Past Invoices'),
        ),
        body: FutureBuilder(
          future: myF,
          builder: (context, snapshot) =>
              snapshot.connectionState == ConnectionState.waiting
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Column(children: [
                          for (int i = 0; i < paths.length; i++) ...[
                            Orders(
                              signURL: widget.signURL,
                              paths: paths,
                              i: i,
                            )
                          ],
                        ]),
                      ),
                    ),
        ));
  }
}

class Orders extends StatefulWidget {
  Orders({required this.signURL, required this.paths, required this.i});
  final List<String> paths;
  final int i;
  final signURL;
  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final db = FirebaseFirestore.instance;
  final DateTime date = DateTime.now();
  var datas;
  List<Map<String, String>> invoiceP = [];

  void setErrorBuilder() {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return Scaffold(
          body: Center(
              child: Container(
        height: 5000,
        child: SingleChildScrollView(
          child: Column(
            children: [
              //  Text(errorDetails.stack.toString()),
              // Text(errorDetails.summary.toString()),
              Text(errorDetails.toString()),
            ],
          ),
        ),
      )));
    };
  }

  String decodeText(String x) {
    String decoded = utf8.decode(base64.decode(x));
    return decoded;
  }

  Future<bool> dataLoader() async {
    print('Data loader running');
    datas = await db.collection(widget.paths[widget.i]).get();
    for (int i = 0; i < datas.docs.length; i++) {
      var d = datas.docs[i];
      final Map<String, String> e = {
        'name': d["name"],
        'quantity': d["quantity"],
        'type': d["type"],
        'bonus': d["bonus"],
        'price': d["price"],
        'pack': d["pack"]
      };
      invoiceP.add(e);
    }
    return true;
  }

  var myF;
  @override
  void initState() {
    setErrorBuilder();
    myF = dataLoader();
    super.initState();
  }

  String getDate(String p) {
    DateTime data = DateTime.parse(p);
    var formatted = DateFormat.MMMd().format(data);
    return formatted;
  }

  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
        future: myF,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AnimatedContainer(
              color: Colors.brown.shade200,
              width: double.infinity,
              alignment: Alignment.center,
              duration: Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: EdgeInsets.all(10),
              child: Text(
                'Loading...',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            );
          } else
            return AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Card(
                      color: Colors.brown.shade200,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            expanded = !expanded;
                          });
                        },
                        child: ListTile(
                          style: ListTileStyle.drawer,
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'H${decodeText(widget.paths[widget.i]).split('|')[0]}',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                getDate(decodeText(widget.paths[widget.i])
                                    .split('|')[2]),
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          title: Text(
                            '${decodeText(widget.paths[widget.i]).split('|')[1].split('-')[0]}',
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          trailing: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      pdf.doIt(
                                          context,
                                          decodeText(widget.paths[widget.i])
                                              .split('|')[1]
                                              .split('-')[0],
                                          decodeText(widget.paths[widget.i])
                                              .split('|')[1]
                                              .split('-')[1],
                                          invoiceP,
                                          true,
                                          decodeText(widget.paths[widget.i])
                                              .split('|')[0],
                                          widget.signURL);
                                    },
                                    icon: const Icon(Icons.picture_as_pdf)),
                                IconButton(
                                    onPressed: () {
                                      pdf.doIt(
                                          context,
                                          decodeText(widget.paths[widget.i])
                                              .split('|')[1]
                                              .split('-')[0],
                                          decodeText(widget.paths[widget.i])
                                              .split('|')[1]
                                              .split('-')[1],
                                          invoiceP,
                                          false,
                                          decodeText(widget.paths[widget.i])
                                              .split('|')[0],
                                          widget.signURL);
                                    },
                                    icon: const Icon(Icons.share)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    AnimatedContainer(
                        // decoration: expanded
                        //     ? BoxDecoration(
                        //         border: Border.all(color: Colors.grey, width: 1))
                        //     : null,
                        duration: Duration(milliseconds: 200),
                        height: expanded ? datas.docs.length * 50.00 : 0,
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: datas.docs.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                style: ListTileStyle.drawer,
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),
                                title: Text(datas.docs[index]["name"]),
                                leading: CircleAvatar(
                                    radius: 15,
                                    child: Text(datas.docs[index]["quantity"])),
                              ),
                            );
                          },
                        ))
                  ],
                ));
        });
  }
}
