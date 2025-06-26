import 'package:flutter/material.dart';
import 'package:flutter_maps_app/widgets/custom_flutter_map.dart';

void main() {
  runApp(const FlutterMapsApp());
}

class FlutterMapsApp extends StatelessWidget {
  const FlutterMapsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Maps App',
      home: CustomFlutterMap(),
    );
  }
}
