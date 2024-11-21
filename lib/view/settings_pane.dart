import 'package:flutter/material.dart';
import 'package:bessereradwege/model/user.dart';
import 'package:bessereradwege/enums.dart';
import 'package:provider/provider.dart';

class SettingsPane extends StatelessWidget {
  const SettingsPane({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
            child: const Text("Standard-Fahrradtyp:"),
            padding: const EdgeInsets.only(
                top: 30, left: 10, right: 10, bottom: 10)),
        Padding(
            child: DropdownButton<int>(
                value: Provider.of<User>(context).defaultVehicleType,
                onChanged: (int? val) {
                  if (val != null) {
                    Provider.of<User>(context, listen: false)
                        .defaultVehicleType = val;
                  }
                },
                items: VehicleType.values.map((VehicleType t) {
                  return DropdownMenuItem<int>(
                      value: t.value, child: Text(t.label));
                }).toList()),
            padding: const EdgeInsets.all(10)),
        const Padding(
            child: const Text("Standardposition Handy:"),
            padding: const EdgeInsets.only(
                top: 30, left: 10, right: 10, bottom: 10)),
        Padding(
            child: DropdownButton<int>(
                value: Provider.of<User>(context).defaultMountType,
                onChanged: (int? val) {
                  if (val != null) {
                    Provider.of<User>(context, listen: false).defaultMountType =
                        val;
                  }
                },
                items: MountType.values.map((MountType t) {
                  return DropdownMenuItem<int>(
                      value: t.value, child: Text(t.label));
                }).toList()),
            padding: const EdgeInsets.all(10)),
        const Padding(
            child: const Text("Standard-Fahrtentyp:"),
            padding: const EdgeInsets.only(
                top: 30, left: 10, right: 10, bottom: 10)),
        Padding(
            child: DropdownButton<int>(
                value: Provider.of<User>(context).defaultRideType,
                onChanged: (int? val) {
                  if (val != null) {
                    Provider.of<User>(context, listen: false).defaultRideType =
                        val;
                  }
                },
                items: RideType.values.map((RideType t) {
                  return DropdownMenuItem<int>(
                      value: t.value, child: Text(t.label));
                }).toList()),
            padding: EdgeInsets.all(10)),
        /*        ElevatedButton(
            onPressed: () {
              Provider.of<User>(context, listen: false).reset();
              MapData().resetAssets();
              //TODO: Reset all rides
            },
            child: const Text('Einstellungen löschen')
          )
  */
      ],
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }
}
