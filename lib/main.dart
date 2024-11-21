import 'package:bessereradwege/view/first_boot_screen.dart';
import 'package:bessereradwege/view/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bessereradwege/model/user.dart';
import 'package:bessereradwege/model/map_data.dart';
import 'package:bessereradwege/model/rides.dart';

void main() {
  runApp(
      MultiProvider(providers: [
        ChangeNotifierProvider(create: (_) => User()),
        ChangeNotifierProvider(create: (_) => Rides())
      ], child: const MyApp()));

}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  bool _initialized = false;

  Future<void> initAppAsync() async {
    await Future.wait([
      User().initialize(),
      MapData().initialize(),
      Rides().initialize(),
    ]);
    setState(() {
      _initialized = true;
    });
  }

  @override initState () {
    super.initState();
    initAppAsync();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    Widget contents;
    if (!_initialized) {
      contents = const Scaffold(
          body: Center(
              child: CircularProgressIndicator()
          )
      );
    } else if (Provider.of<User>(context).firstStart) {
      contents = const FirstBootScreen(title: 'Bessere Radwege');
    } else {
      contents = const MainScreen(title: 'Bessere Radwege');
    }

    return MaterialApp(
      title: 'Bessere Radwege',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.tealAccent,
        ),
        useMaterial3: true,
      ),
      home: contents,
    );
  }
}

