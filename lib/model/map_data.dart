import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';


class MapData extends ChangeNotifier {

  static final MapData _sharedMapData = MapData._internal();

  factory MapData() {
    return _sharedMapData;
  }

  MapData._internal();

  SharedPreferences? _sharedPrefs;
  String? _mapResourcesPath;

  Future<void> initialize() async {
    _mapResourcesPath ??= (await getApplicationSupportDirectory()).path;
    print('MapData: initialize mapResources is ${_mapResourcesPath!}');
    _sharedPrefs ??= await SharedPreferences.getInstance();
    print('MapData: sharedPrefs is $_sharedPrefs');

    bool? styleLoaded = _sharedPrefs!.getBool("map_style_loaded");
    print('MapData: styleLoaded is $styleLoaded');
    if ((styleLoaded == null) || (!(styleLoaded))) {
      print("MapData: loading font and style");
      _loadStyleData();
      _sharedPrefs!.setBool("map_style_loaded", true);
    } else {
      print("MapData: font and style already loaded");
    }
    List<String>? loadedMaps = _sharedPrefs!.getStringList("loaded_maps");
    if ((loadedMaps == null) || (loadedMaps.isEmpty)) {
      print("MapData: loading cologne map");
      _sharedPrefs!.setStringList("loaded_maps", []);
      _loadVectorMapFromAssets("cologne");
    } else {
      print("MapData: cologne map already loaded");
    }
    print("MapData: initialize done");
  }

  void resetAssets() {
    _sharedPrefs!.setStringList("loaded_maps", []);
    _sharedPrefs!.setBool("map_style_loaded", false);
  }

  String get styleJsonPath {
    assert(_mapResourcesPath != null, "MapData: not initialized!");
    File f = File('$_mapResourcesPath/map-style.json');
    print('MapData: Style File ${'$_mapResourcesPath/map-style.json'} exists ${f.existsSync()} length ${f.lengthSync()}');
    return '${_mapResourcesPath}/map-style.json';
  }

  List<String> get loadedMaps {
    assert(_mapResourcesPath != null, "MapData: not initialized!");
    assert(_sharedPrefs != null, "MapData: not initialized!");
    List<String>? loadedMaps = _sharedPrefs!.getStringList('loaded_maps');
    return loadedMaps ?? [];
  }

  String urlForMap(String basename) {
    assert(_mapResourcesPath != null, "MapData: not initialized!");
    File f = File('$_mapResourcesPath/$basename.mbtiles');
    print('MapData: File ${'$_mapResourcesPath/$basename.mbtiles'} exists ${f.existsSync()} length ${f.lengthSync()}');
    return 'mbtiles://$_mapResourcesPath/$basename.mbtiles';
  }

  Future<void> _loadStyleData() async {
    assert (_mapResourcesPath != null, "MapData: not initialized!");
    _unzipAssetToMapDir("map-font.zip");
    print('MapData: copy map font done');
    String style = await rootBundle.loadString('assets/map-style.json');
    style = style.replaceAll('***PATH***', _mapResourcesPath!);
    print('MapData: style json is $style}');
    final file = File('${_mapResourcesPath!}/map-style.json');
    await file.create(recursive: true);
    await file.writeAsString(style);
  }

  Future<void> _loadVectorMapFromAssets(String basename) async {
    assert (_sharedPrefs != null, "MapData: not initialized!");
    await _unzipAssetToMapDir('$basename.zip');
    List<String> loadedMaps = _sharedPrefs!.getStringList("loaded_maps")!;
    loadedMaps.add(basename);
    print("MapData: adding $basename to loaded maps");
    _sharedPrefs!.setStringList('loaded_maps', loadedMaps);
  }

  Future<void> _unzipAssetToMapDir(String assetName) async {
    assert (_mapResourcesPath != null, "MapData: not initialized!");
    ByteData value = await rootBundle.load('assets/$assetName');
    Uint8List zipfile = value.buffer.asUint8List(
      value.offsetInBytes, value.lengthInBytes);
    InputStream ifs = InputStream(zipfile);
    final archive = ZipDecoder().decodeBuffer(ifs);
    // Extract the contents of the Zip archive to disk.
    for (final file in archive) {
      final filename = file.name;
      final path = '${_mapResourcesPath!}/$filename';
      print("MapData: unzipping $path");
      if (file.isFile) {
        final data = file.content as List<int>;
        File(path)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(path).create(recursive: true);
      }
    }
  }

}