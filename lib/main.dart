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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: Provider.of<User>(context).firstStart ?
        const FirstBootScreen(title: 'Bessere Radwege') :
        const MainScreen(title: 'Bessere Radwege')
    );
  }
}

