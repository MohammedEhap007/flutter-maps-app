# 🗺️📱 Flutter Maps App

A Flutter app that displays a map using **OpenStreetMap** with the following features:

- 📍 Real-time location tracking
- 🔍 Search by place name using Nominatim API
- 📌 Place destination markers
- 🚗 Draw driving routes between current and searched locations using OSRM
- 🌐 Fully open-source map and routing stack

---

## 📸 Screenshots

![Group 1](https://github.com/user-attachments/assets/e7b8c151-d00d-4591-9e14-bcd64bab00d6)



---

## 🚀 Features

- **OpenStreetMap Integration** via `flutter_map`
- **User Location Detection** using `location` package
- **Live Location Marker** using `flutter_map_location_marker`
- **Search and Geocoding** with [Nominatim API](https://nominatim.org/)
- **Routing and Polylines** with [OSRM API](http://project-osrm.org/)
- **Marker Placement** on destination search
- **Dynamic Polyline Drawing** from current location to destination

---

## 📦 Packages Used

| Package | Purpose |
|--------|--------|
| [`flutter_map`](https://pub.dev/packages/flutter_map) | Displaying OpenStreetMap tiles |
| [`flutter_map_location_marker`](https://pub.dev/packages/flutter_map_location_marker) | Real-time location marker |
| [`location`](https://pub.dev/packages/location) | Accessing device GPS |
| [`http`](https://pub.dev/packages/http) | Calling external APIs |
| [`flutter_polyline_points`](https://pub.dev/packages/flutter_polyline_points) | Decoding route geometry |
| [`latlong2`](https://pub.dev/packages/latlong2) | Coordinate handling |

---
