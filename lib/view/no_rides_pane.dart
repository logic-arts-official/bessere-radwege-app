import 'package:flutter/material.dart';

class NoRidesPane extends StatelessWidget {
  const NoRidesPane({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Tracke deine Fahrten und verbessere die Radwege mit uns',
                style: Theme.of(context).textTheme.headlineLarge
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image(image: AssetImage('assets/images/fahrradkatze.png'), ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Du hast noch keine Fahrten aufgenommen. Starte jetzt!',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ); // This trailing comma makes auto-formatting nicer for build methods.
  }
}
