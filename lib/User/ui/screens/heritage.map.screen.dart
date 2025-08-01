import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../Common/Screens/heritage_detail_screen.dart';
import '../../../Common/services/bookmarks_services.dart';
import '../../../Common/widgets/nearby.site.card.dart';

class HeritageMapScreen extends StatefulWidget {
  final String siteName;
  final double latitude;
  final double longitude;
  final List<Map<String, dynamic>> allSites;

  const HeritageMapScreen({
    Key? key,
    required this.siteName,
    required this.latitude,
    required this.longitude,
    required this.allSites,
  }) : super(key: key);

  @override
  State<HeritageMapScreen> createState() => _HeritageMapScreenState();
}

class _HeritageMapScreenState extends State<HeritageMapScreen> {
  GoogleMapController? _mapController;
  LatLng? _userLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  static const String _googleApiKey = 'AIzaSyCGnusGppsu00mCgFIfsDbSFvC7JGkgeJY';
  bool _isLoadingRoute = false;
  bool isBookmarked = false;
  final bookmarkService = BookmarkService();
  final user = FirebaseAuth.instance.currentUser;


  @override
  void initState() {
    super.initState();
    _initMap();
  }

  Future<void> _initMap() async {
    await _getCurrentLocation();
    _setSiteMarkers();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position pos = await Geolocator.getCurrentPosition();
      _userLocation = LatLng(pos.latitude, pos.longitude);
      _addMarker(_userLocation!, 'Your Location', Colors.blue);
      setState(() {});
    } catch (e) {
      debugPrint("Could not get user location: $e");
    }
  }

  void _setSiteMarkers() {
    _markers.clear(); // clear existing markers first

    LatLng selectedSite = LatLng(widget.latitude, widget.longitude);
    _addMarker(selectedSite, widget.siteName, Colors.red);  // selected site in red

    for (var site in widget.allSites) {
      if (site['id'] == null || site['name'] == widget.siteName) continue;

      LatLng pos = LatLng(site['latitude'], site['longitude']);

      if (_calculateDistance(widget.latitude, widget.longitude, pos.latitude, pos.longitude) <= 20) {
        _addMarker(pos, site['name'], Colors.green);  // nearby sites in green
      }
    }

    setState(() {});
  }


  double _calculateDistance(lat1, lon1, lat2, lon2) =>
      Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;

  void _addMarker(LatLng pos, String title, Color hueColor) {
    _markers.add(Marker(
      markerId: MarkerId(title + pos.toString()),
      position: pos,
      icon: BitmapDescriptor.defaultMarkerWithHue(
        hueColor == Colors.red
            ? BitmapDescriptor.hueRed
            : hueColor == Colors.blue
            ? BitmapDescriptor.hueBlue
            : BitmapDescriptor.hueGreen,
      ),
      infoWindow: InfoWindow(title: title),
      onTap: () {
        if (hueColor == Colors.green) {
          _showBottomOptions(title);
        }
      },
    ));
  }

  Future<void> _toggleBookmark() async {

    final site = widget.allSites.firstWhere((s) => s['name'] == widget.siteName);
    final siteId = site["id"];
    if (siteId != null) {
      if (isBookmarked) {
        await bookmarkService.removeBookmark(siteId);
      } else {
        await bookmarkService.addBookmark(siteId, site);
      }
      setState(() {
        isBookmarked = !isBookmarked;
      });
    }
  }



  void _showBottomOptions(String siteName) {

    final site = widget.allSites.firstWhere((s) => s['name'] == siteName);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SiteActionBottomSheet(
          siteName: siteName,
          onSave: _toggleBookmark,
          onViewDetails: () {
            if (site != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HeritageDetailScreen(site: site, allSites: [site]),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Site details not found')),
              );
            }
          },
        );
      },
    );
  }

  // Future<void> _drawRoute() async {
  //   if (_userLocation == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('User location not available')),
  //     );
  //     return;
  //   }
  //   print('Origin: ${_userLocation!.latitude}, ${_userLocation!.longitude}');
  //   print('Destination: ${widget.latitude}, ${widget.longitude}');
  //
  //
  //   setState(() {
  //     _isLoadingRoute = true;
  //   });
  //
  //   // Clear existing polylines to redraw
  //   _polylines.clear();
  //
  //   var uri = Uri.parse(
  //     'https://maps.googleapis.com/maps/api/directions/json'
  //         '?origin=${_userLocation!.latitude},${_userLocation!.longitude}'
  //         '&destination=${widget.latitude},${widget.longitude}'
  //         '&mode=driving&key=$_googleApiKey',
  //   );
  //   try {
  //     var res = await http.get(uri);
  //     var data = json.decode(res.body);
  //
  //     print('Directions API response status: ${data['status']}');
  //     print('Directions API response error_message: ${data['error_message']}');
  //     print('Directions API response routes length: ${data['routes'].length}');
  //     print('Response body snippet: ${res.body.substring(0, 200)}');
  //
  //
  //     if (data['routes'].isNotEmpty) {
  //       var points = PolylinePoints().decodePolyline(
  //         data['routes'][0]['overview_polyline']['points'],
  //       );
  //       _polylines.add(Polyline(
  //         polylineId: const PolylineId('route'),
  //         points: points.map((p) => LatLng(p.latitude, p.longitude)).toList(),
  //         color: Colors.blue,
  //         width: 5,
  //       ));
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('No routes found')),
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint('Error fetching directions: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Failed to fetch directions')),
  //     );
  //   }
  //
  //   setState(() {
  //     _isLoadingRoute = false;
  //   });
  // }

  void _launchUrlWithFallback(BuildContext context, String url) async {
    try {
      bool launched = await launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) _showFallbackDialog(context, url);
    } catch (_) {
      _showFallbackDialog(context, url);
    }
  }
  void _openGoogleMapsDirections() {
    final lat = widget.latitude.toString();
    final lon = widget.longitude.toString();
    final url =
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=driving";
    _launchUrlWithFallback(context, url);
  }
  void _showFallbackDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
        title: Text('Open in Browser?'),
        content: Text('Could not open the app. Open in browser instead?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (await canLaunchUrlString(url)) {
                await launchUrlString(
                  url,
                  mode: LaunchMode.platformDefault,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not open link.')),
                );
              }
            },
            child: Text('Open Browser'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    LatLng initialPos = LatLng(widget.latitude, widget.longitude);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.siteName),
          backgroundColor: Colors.brown,
        ),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(target: initialPos, zoom: 12),
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: true,
          onMapCreated: (ctrl) => _mapController = ctrl,
        ),
        // floatingActionButton: FloatingActionButton.extended(
        //   onPressed: _openGoogleMapsDirections,
        //   label: _isLoadingRoute
        //       ? const CircularProgressIndicator(
        //     color: Colors.white,
        //   )
        //       : const Text('Get Directions'),
        //   icon: const Icon(Icons.directions),
        //   backgroundColor: Colors.brown,
        //   foregroundColor: Colors.white,
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
}


