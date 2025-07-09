import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';

class CustomFlutterMap extends StatefulWidget {
  const CustomFlutterMap({super.key});

  @override
  State<CustomFlutterMap> createState() => _CustomFlutterMapState();
}

class _CustomFlutterMapState extends State<CustomFlutterMap> {
  final MapController mapController = MapController();
  late LatLng initialCenter;
  @override
  void initState() {
    initialCenter = const LatLng(31.04089246932112, 31.37851020856105);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'OpenStreetMap 🗺️📌',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 12.0,
              minZoom: 3,
              maxZoom: 20,
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
              const CurrentLocationLayer(
                style: LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    child: Icon(Icons.location_pin, color: Colors.white),
                  ),
                  markerSize: Size(35, 35),
                  markerDirection: MarkerDirection.heading,
                ),
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
