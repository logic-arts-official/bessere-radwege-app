import 'package:flutter/material.dart';

class SettingsPane extends StatelessWidget {
  const SettingsPane({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text('Es gibt noch keine Einstellungen'),
      ],
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }
}
