import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_maps_app/widgets/functions/check_location_permission.dart';
import 'package:flutter_maps_app/widgets/functions/show_error_bar.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: currentLocation!,
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
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                    if (destinationLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 50,
                            height: 50,
                            point: destinationLocation!,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    if (currentLocation != null &&
                        destinationLocation != null &&
                        routeCoordinates.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routeCoordinates,
                            color: Colors.red,
                            strokeWidth: 5,
                          ),
                        ],
                      ),
                  ],
                ),
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Enter a location',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () {
                      final location = locationController.text.trim();
                      if (location.isNotEmpty) {
                        fetchCoordinatesPoints(location);
                      }
                    },
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
            ),
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
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
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

  Future<void> fetchRouteCoordinates() async {
    if (currentLocation == null || destinationLocation == null) return;
    final url = Uri.parse(
      'http://router.project-osrm.org/route/v1/driving/${currentLocation!.longitude},${currentLocation!.latitude};${destinationLocation!.longitude},${destinationLocation!.latitude}?overview=full&geometries=polyline',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry'];
      decodePolyline(geometry);
    } else {
      if (mounted) {
        showErrorBar(context, 'Failed to fetch route. Try again later');
      }
    }
  }

  void decodePolyline(String encodedPolyline) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePoints = polylinePoints.decodePolyline(
      encodedPolyline,
    );
    setState(() {
      routeCoordinates = decodedPolylinePoints
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    });
  }
}

// world view 0 -> 3
// country view 4 -> 6
// city view 10 -> 12
// street view 13 -> 17
// building view 18 -> 20
