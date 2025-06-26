import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CustomFlutterMap extends StatefulWidget {
  const CustomFlutterMap({super.key});

  @override
  State<CustomFlutterMap> createState() => _CustomFlutterMapState();
}

class _CustomFlutterMapState extends State<CustomFlutterMap> {
  late LatLng initialCenter;
  @override
  void initState() {
    initialCenter = const LatLng(31.04089246932112, 31.37851020856105);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 12.0,
              // cameraConstraint: CameraConstraint.contain(
              //   bounds: LatLngBounds(
              //     //* southwest
              //     const LatLng(30.46646180488818, 31.185331542026894),
              //     //* northeast
              //     const LatLng(31.41770515009543, 31.81450591571051),
              //   ),
              // ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// world view 0 -> 3
// country view 4 -> 6
// city view 10 -> 12
// street view 13 -> 17
// building view 18 -> 20
