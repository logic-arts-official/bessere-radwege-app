import 'package:flutter/material.dart';
import 'package:bessereradwege/model/user.dart';
import 'package:bessereradwege/model/map_data.dart';
import 'package:provider/provider.dart';

class SettingsPane extends StatelessWidget {
  const SettingsPane({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            Provider.of<User>(context, listen: false).reset();
            MapData().resetAssets();
          },
          child: const Text('Einstellungen löschen')
        )
      ],
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }
}
