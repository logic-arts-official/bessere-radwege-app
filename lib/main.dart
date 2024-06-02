import 'package:bessereradwege/view/first_boot_screen.dart';
import 'package:bessereradwege/view/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bessereradwege/model/user.dart';
import 'package:bessereradwege/model/ride.dart';

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

  late Future<void> _initApp;

  MyAppState() {
    _initApp = initAppAsync();
  }

  static Future<void> initAppAsync() async {
    await User().initialize();
    //TODO: Load map assets
    await Future.delayed(Duration(milliseconds: 2000), () {
      // Do something
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bessere Radwege',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.tealAccent,
        ),
        useMaterial3: true,
      ),
      home: FutureBuilder<void>(
        future: _initApp,
        builder:(BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator()
              )
            );
          }
          if (Provider.of<User>(context).firstStart) {
            return const FirstBootScreen(title: 'Bessere Radwege');
          } else {
            return const MainScreen(title: 'Bessere Radwege');
          }
        }
      )
    );
  }
}

