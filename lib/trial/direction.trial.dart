// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class MapScreen extends StatefulWidget {
//   @override
//   _MapScreenState createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   late GoogleMapController _mapController;
//   LatLng _destination = LatLng(27.5850,85.5155 ); // Change to your destination
//
//   @override
//   void initState() {
//     super.initState();
//     _requestPermissions();
//   }
//
//   Future<void> _requestPermissions() async {
//     await Permission.location.request();
//   }
//
//   Future<void> _openDirections() async {
//     final hasPermission = await Geolocator.checkPermission();
//
//     if (hasPermission == LocationPermission.denied) {
//       await Geolocator.requestPermission();
//     }
//
//     final position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//
//     final googleUrl =
//         'https://www.google.com/maps/dir/?api=1&origin=${position.latitude},${position.longitude}&destination=${_destination.latitude},${_destination.longitude}&travelmode=driving';
//
//     if (await canLaunch(googleUrl)) {
//       await launch(googleUrl);
//     } else {
//       throw 'Could not open Google Maps.';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Heritedge Destination')),
//       body: Stack(
//         children: [
//           GoogleMap(
//             onMapCreated: (controller) {
//               _mapController = controller;
//             },
//             initialCameraPosition: CameraPosition(
//               target: _destination,
//               zoom: 14,
//             ),
//             markers: {
//               Marker(
//                 markerId: MarkerId('destination'),
//                 position: _destination,
//                 infoWindow: InfoWindow(title: 'Heritage Site'),
//               )
//             },
//             myLocationEnabled: true,
//             myLocationButtonEnabled: true,
//           ),
//           Positioned(
//             bottom: 20,
//             left: 20,
//             right: 20,
//             child: ElevatedButton.icon(
//               onPressed: _openDirections,
//               icon: Icon(Icons.directions),
//               label: Text('Get Directions'),
//               style: ElevatedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(vertical: 16),
//                 textStyle: TextStyle(fontSize: 18),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
