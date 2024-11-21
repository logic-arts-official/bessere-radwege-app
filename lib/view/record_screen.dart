import 'package:bessereradwege/services/sensor_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:bessereradwege/model/rides.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:bessereradwege/model/map_data.dart';
import 'package:url_launcher/url_launcher.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => RecordScreenState();
}

class RecordScreenState extends State<RecordScreen> {

  MapLibreMapController? _mapController;
  final MapData _mapData = MapData();

  @override
  void initState() {
    super.initState();
    SensorService().checkPermissions();
  }

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
        title: const Text("Fahrtaufzeichnung"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:[
            Expanded(
              child:MapLibreMap(
                styleString: _mapData.styleJsonPath,
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(target: LatLng(50.9365, 6.9398), zoom: 16.0),
                zoomGesturesEnabled: true,
                trackCameraPosition: true,
                rotateGesturesEnabled: true,
                dragEnabled: true,
                myLocationEnabled: true,
                compassEnabled: true,
                myLocationTrackingMode: MyLocationTrackingMode.tracking,
                onStyleLoadedCallback: onStyleLoadedCallback,
              )
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                child: Text(
                    'OpenStreetMap 2024',
                    style: Theme.of(context).textTheme.bodySmall),
                onDoubleTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright'))
              ),
            ),
            ElevatedButton(
              onPressed: () {Provider.of<Rides>(context, listen: false).finishCurrentRide(); },
              child: const Text('Fahrt beenden'),
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.

    );
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
    print("MapData: map created!");
  }

  void onStyleLoadedCallback() {
    print("MapData: style loaded!");
    if (_mapController != null) {
      List<String> maps = _mapData.loadedMaps;
      print('MapData: loaded maps length ${maps.length}');
      for (final entry in maps) {
        print('MapData: adding source $entry -> ${_mapData.urlForMap(entry)}');
        _mapController!.addSource(entry,
            VectorSourceProperties(url: _mapData.urlForMap(entry))
        );
      }
      void doLater() async {
        final pos = await Geolocator.getCurrentPosition();
        print('MapData: current position: ${pos.toString()}');
      }
      doLater();
    } else {
      print("MapData: Style loaded but no mapController!");
    }

  }
}


