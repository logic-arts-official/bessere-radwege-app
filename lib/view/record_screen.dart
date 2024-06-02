import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bessereradwege/model/ride.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:maplibre_gl/maplibre_gl.dart';


class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => RecordScreenState();
}

class RecordScreenState extends State<RecordScreen> {

  MaplibreMapController? _mapController;

  String? _mapResourcesPath;

  @override
  void initState() {
    super.initState();
    _copyResources(context);
  }

  @override
  Widget build(BuildContext context) {

    Widget contents;
    if (_mapResourcesPath == null) {
      contents = Center(child: Text('Karte laden...'));
    } else {
      final mapStylePath = '${_mapResourcesPath}/map-style.json';
      contents = Expanded(
          child:MaplibreMap(
            styleString: mapStylePath,
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(target: LatLng(50.9365, 6.9398), zoom: 16.0),
            zoomGesturesEnabled: true,
            trackCameraPosition: true,
            rotateGesturesEnabled: true,
            dragEnabled: true,
            myLocationEnabled: true,
            compassEnabled: true,
            myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
            onStyleLoadedCallback: onStyleLoadedCallback,
          )
      );
    }


    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.record_screen.dart
        title: Text("Fahrtaufzeichnung"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:[
            contents,
            ElevatedButton(
                onPressed: () {Provider.of<Rides>(context, listen: false).finishCurrentRide(); },
                child: const Text('Fahrt beenden'),
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.

/*      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {Provider.of<Rides>(context, listen: false).finishCurrentRide();},
          label: const Text("Fahrt beenden"),
          icon: const Icon(Icons.stop_rounded),
        )
*/
    );
  }


  void _copyResources(context) async {
    if (_mapResourcesPath == null) {
      final appDir = await getApplicationSupportDirectory();
      String mapResourcesPath = appDir.path;
      ByteData value = await DefaultAssetBundle.of(context).load(
            "assets/map-data.zip");
      Uint8List zipfile = value.buffer.asUint8List(
            value.offsetInBytes, value.lengthInBytes);
      InputStream ifs = InputStream(zipfile);
      final archive = ZipDecoder().decodeBuffer(ifs);
        // Extract the contents of the Zip archive to disk.
      for (final file in archive) {
        final filename = file.name;
        final path = '$mapResourcesPath/$filename';
        if (file.isFile) {
          final data = file.content as List<int>;
          File(path)
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory(path).create(recursive: true);
        }
      }
      print('copy resources done');
      mapResourcesPath = '$mapResourcesPath/map-data';
      String style = await DefaultAssetBundle
          .of(context).loadString('assets/map-style.json');
      style = style.replaceAll('***PATH***', mapResourcesPath);
      final file = await File('$mapResourcesPath/map-style.json');
      await file.create(recursive: true);
      await file.writeAsString(style);

      setState(() {
        _mapResourcesPath = mapResourcesPath;
      });
    }
  }

  void _onMapCreated(MaplibreMapController controller) {
    _mapController = controller;
    print("map created!");

  }

  void onStyleLoadedCallback() {
    print("style loaded!");
  }
}


