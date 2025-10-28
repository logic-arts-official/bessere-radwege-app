import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPane extends StatelessWidget {
  const InfoPane({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView(
        padding:const EdgeInsets.only(top:10.0,bottom:100.0),
        children: [
          Text('Über das Projekt', style: Theme.of(context).textTheme.titleLarge),
          const Text('''
          
Unser Plan: Wir sammeln und analysieren Bewegungsdaten von und mit Radfahrenden automatisch bei jeder Fahrt. Die daraus gewonnenen Informationen sollen helfen, die Fahrradinfrastruktur zu verbessern.
          
Durch automatische Analyse der Fahrtdaten werden Umwege, schlechte Untergründe und Gefahrenstellen erkannt. Die ausgewerteten Informationen stehen anonymisiert im Internet bereit und sind als offene Daten für alle Interessierte nutzbar.
          
Die Stadtplanung bekommt dadurch Einblicke in die reale Wegenutzung und Probleme von Radfahrenden und kann so bessere Wege für alle schaffen.

Dieses Projekt basiert auf dem Bessere Radwege Projekt von Matthias Krauss (© 2024), lizenziert unter BSD-3 Clause.

Dieser Fork wird unabhängig betrieben und gewartet.
          '''),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            onPressed: () { launchUrl(Uri.parse('https://github.com/logic-arts-official/bessere-radwege-app')); },
            child: const Text("GitHub Repository"),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(child: Text('App version 0.1.2, build 2024-12-03-02-15-00', style: Theme.of(context).textTheme.bodyMedium)),
          ),
        ],
      ),
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }
}
