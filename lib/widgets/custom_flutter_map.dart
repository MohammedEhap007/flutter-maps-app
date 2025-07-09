import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_maps_app/widgets/functions/check_location_permission.dart';
import 'package:flutter_maps_app/widgets/functions/show_error_bar.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class CustomFlutterMap extends StatefulWidget {
  const CustomFlutterMap({super.key});

  @override
  State<CustomFlutterMap> createState() => _CustomFlutterMapState();
}

class _CustomFlutterMapState extends State<CustomFlutterMap> {
  final MapController mapController = MapController();
  final Location location = Location();
  final TextEditingController locationController = TextEditingController();
  bool isLoading = true;
  late LatLng initialCenter;
  LatLng? currentLocation;
  LatLng? destinationLocation;
  List<LatLng> routeCoordinates = [];
  @override
  void initState() {
    super.initState();
    initializeLocation();
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
              initialCenter:
                  currentLocation ??
                  const LatLng(31.04089246932112, 31.37851020856105),
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
      floatingActionButton: FloatingActionButton(
        onPressed: moveToUserCurrentLocation,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.my_location, size: 28, color: Colors.white),
      ),
    );
  }

  Future<void> moveToUserCurrentLocation() async {
    if (currentLocation != null) {
      mapController.moveAndRotate(currentLocation!, 15, 0);
    } else {
      showErrorBar(context, 'Current location is not available');
    }
  }

  Future<void> initializeLocation() async {
    if (!await checkLocationPermission(location: location)) return;

    location.onLocationChanged.listen((locationData) {
      if (locationData.altitude != null && locationData.longitude != null) {
        setState(() {
          currentLocation = LatLng(
            locationData.latitude!,
            locationData.longitude!,
          );
          isLoading = false;
        });
      }
    });
  }

  Future<void> fetchCoordinatesPoints(String location) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$location&format=json&limit=1',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (response.body.isNotEmpty) {
        final lat = data[0]['lat'];
        final lon = data[0]['lon'];
        setState(() {
          destinationLocation = LatLng(lat, lon);
        });
        await fetchRouteCoordinates();
      } else {
        if (mounted) {
          showErrorBar(
            context,
            'Location not found. Please try another location',
          );
        }
      }
    } else {
      if (mounted) {
        showErrorBar(context, 'Failed to fetch location. Try again later');
      }
    }
  }

  Future<void> fetchRouteCoordinates() async {}
}

// world view 0 -> 3
// country view 4 -> 6
// city view 10 -> 12
// street view 13 -> 17
// building view 18 -> 20
