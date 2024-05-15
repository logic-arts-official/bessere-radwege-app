import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bessereradwege/model/ride.dart';

class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.record_screen.dart
        title: Text(title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:[
            const Text('Recording screen!'),
            ElevatedButton(
                onPressed: () {Provider.of<Rides>(context, listen: false).finishCurrentRide(); },
                child: const Text('Fahrt beenden'),
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
