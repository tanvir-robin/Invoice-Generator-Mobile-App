import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class InitSc extends StatefulWidget {
  Function trigger;

  InitSc(this.trigger);
  @override
  State<InitSc> createState() => _InitScState();
}

class _InitScState extends State<InitSc> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: ElevatedButton(
      child: const Text(
        'Create Invoice',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        widget.trigger(context);
      },
    ));
  }
}
