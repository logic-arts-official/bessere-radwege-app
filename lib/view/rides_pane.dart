import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bessereradwege/model/ride.dart';


class RidesPane extends StatelessWidget {
  const RidesPane({super.key});

  @override
  Widget build(BuildContext context) {
    List<Ride> rides = Provider.of<Rides>(context).pastRides;
    int totalNumRides = rides.length;
    double totalDistanceM = 0;
    Duration duration = Duration();
    for (Ride ride in rides) {
      totalDistanceM += ride.lengthM;
      duration += ride.duration;
    }
    double avgSpeed = 3600.0 * totalDistanceM / duration.inMilliseconds;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('Deine Statistik', style: Theme.of(context).textTheme.titleLarge),
        ),
        Table(
          border: TableBorder(
              horizontalInside: BorderSide(width: 1, style: BorderStyle.solid),
              top: BorderSide(width: 1, style: BorderStyle.solid),
              bottom: BorderSide(width: 1, style: BorderStyle.solid)),
          columnWidths: const <int, TableColumnWidth>{
            0: IntrinsicColumnWidth(),
            1: IntrinsicColumnWidth(),
          },
          children:<TableRow>[
            TableRow(
                children:[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Deine Fahrten', style: Theme.of(context).textTheme.labelLarge, textAlign: TextAlign.right),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('$totalNumRides', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ]
            ),
            TableRow(
                children:[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Strecke gesamt', style: Theme.of(context).textTheme.labelLarge, textAlign: TextAlign.right,),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${NumberFormat.decimalPatternDigits(decimalDigits:1).format(totalDistanceM/1000)} km', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ]
            ),
            TableRow(
                children:[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Durchschnittsgeschwindigkeit', style: Theme.of(context).textTheme.labelLarge, textAlign: TextAlign.right,),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${NumberFormat.decimalPatternDigits(decimalDigits:1).format(avgSpeed)} km/h', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ]
            ),
            TableRow(
                children:[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Zeit gesamt', style: Theme.of(context).textTheme.labelLarge, textAlign: TextAlign.right,),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${duration.inHours}h ${duration.inMinutes.remainder(60).toString().padLeft(2,"0")}m ${duration.inSeconds.remainder(60).toString().padLeft(2,"0")}s', style: Theme.of(context).textTheme.bodyMedium),

                  ),
                ]
            ),
/*            TableRow(
                children:[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Bewegungszeit', style: Theme.of(context).textTheme.labelLarge, textAlign: TextAlign.right,),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('1:23:45', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ]
            ),
*/
          ]
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('Deine Fahrten', style: Theme.of(context).textTheme.titleLarge),
        ),
        Text('Hier kommt eine Liste der Fahrten hin'),
      ],
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }
}
