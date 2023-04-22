import 'package:flutter/material.dart';

import './manageProducts.dart';
import './past.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer(this.signURL);
  final signURL;
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ), //BoxDecoration
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'asset/images/icons.png',
                  height: 50,
                ),
                Text(
                  "Invoice Generator",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.history,
            ),
            title: const Text(
              ' Past Invoices ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PastOrders(
                          signURL: widget.signURL,
                        )),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.edit_note_outlined,
            ),
            title: const Text(
              ' Manage Products ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageProducts()),
              );
            },
          ),
        ],
      ),
    );
  }
}
