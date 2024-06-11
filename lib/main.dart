import 'package:flutter/material.dart';
import 'package:flutter_geo_location/googlemap_screen.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LocationPermissionScreen(),
    );
  }
}