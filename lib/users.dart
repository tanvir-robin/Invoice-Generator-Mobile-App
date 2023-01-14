import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:gsheets/gsheets.dart';
import './gsheet.dart';

class UserProfiles extends StatefulWidget {
  //var List<Map<String, String>> _items = [];
  // UserProfiles(this._items);
  static const routeName = '/users';

  @override
  State<UserProfiles> createState() => _UserProfilesState();
}

class _UserProfilesState extends State<UserProfiles> {
  var _items;

  var isLoad = true;
  final ff = GSheets(gsheet.credintial);
  Future<void> refresh() async {
    final sheet = await ff.spreadsheet(gsheet.sheetID);
    var sheet1 = sheet.worksheetByTitle('Sheet1');
    final xx = await sheet1!.values.map.allRows();
    setState(() {
      _items = xx;
    });
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  // @override
  // void didChangeDependencies() {
  //   if (isLoad) {
  //     refresh();
  //   }
  //   isLoad = false;
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    // _items =
    //     ModalRoute.of(context)!.settings.arguments as List<Map<String, String>>;
    return Scaffold(
      appBar: AppBar(title: Text('Users')),
      body: _items == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: refresh,
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(
                      '${_items[index]['Name']} - ${_items[index]['Degree']}'),
                ),
              ),
            ),
    );
  }
}
