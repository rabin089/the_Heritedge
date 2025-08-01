import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:the_heritedge/Common/services/geolocator.service.dart';

class CustomGoogleMapWidget extends StatefulWidget {
  final LatLng? initialPosition;
  final bool allowLocationPicking;
  final bool showUserLocation;
  final bool allowMarkerPlacement;
  final List<Marker> predefinedMarkers;
  final Function(LatLng)? onLocationPicked;
  final Function(String?)? onAddressChanged;

  const CustomGoogleMapWidget({
    super.key,
    this.initialPosition,
    this.allowLocationPicking = true,
    this.showUserLocation = true,
    this.allowMarkerPlacement = false,
    this.predefinedMarkers = const [],
    this.onLocationPicked,
    this.onAddressChanged,
  });

  @override
  State<CustomGoogleMapWidget> createState() => _CustomGoogleMapWidgetState();
}

class _CustomGoogleMapWidgetState extends State<CustomGoogleMapWidget> {
  GoogleMapController? _mapController;
  LatLng _selectedPosition = const LatLng(27.7172, 85.3240); // Default to KTM
  String? _address;
  Set<Marker> _markers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _markers = widget.predefinedMarkers.toSet();

    if (widget.initialPosition != null) {
      _selectedPosition = widget.initialPosition!;

      if (!widget.allowLocationPicking && widget.allowMarkerPlacement) {
        _markers.add(
          Marker(
            markerId: const MarkerId("consultant_location"),
            position: _selectedPosition,
          ),
        );
      }

      if (widget.allowLocationPicking) {
        _getAddress(_selectedPosition);
      }
    } else {
      // No initial location provided, use user's current location
      _setUserLocationAsInitial();
    }
  }

  Future<void> _setUserLocationAsInitial() async {
    try {
      if (mounted) setState(() => _isLoading = true);

      final locationService = LocationService();
      final position = await locationService.getCurrentPosition();
      if (position == null) return;

      final myLocation = LatLng(position.latitude, position.longitude);
      if (mounted) setState(() => _selectedPosition = myLocation);

      if (widget.allowLocationPicking) {
        _getAddress(myLocation);
      }

      if (_mapController != null) {
        _mapController?.animateCamera(CameraUpdate.newLatLng(myLocation));
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onCameraIdle() {
    if (widget.allowLocationPicking) {
      _getAddress(_selectedPosition);
      widget.onLocationPicked?.call(_selectedPosition);
    }
  }

  void _onCameraMove(CameraPosition position) {
    if (widget.allowLocationPicking) {
      _selectedPosition = position.target;
    }
  }

  void _onTap(LatLng latLng) {
    if (widget.allowMarkerPlacement) {
      setState(() {
        _markers.add(
          Marker(markerId: MarkerId(latLng.toString()), position: latLng),
        );
      });
    }
  }

  Future<void> _goToMyLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final myLatLng = LatLng(position.latitude, position.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLng(myLatLng));
      setState(() => _selectedPosition = myLatLng);
      _getAddress(myLatLng);
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  Future<void> _getAddress(LatLng latLng) async {
    final String baseUrl= 'https://api-physiopal.ktmbees.dev/api/v1';
    String reverseGeocodingApi(double lat, double lon) => '/location/reverseGeocoding?lat=$lat&lon=$lon';
    try {
      final uri = Uri.parse(
          baseUrl+reverseGeocodingApi(latLng.latitude, latLng.longitude));
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = response.body is String
            ? json.decode(response.body)
            : response.body;

        final data = jsonResponse['data'];
        final displayName = data['display_name'] ?? 'Unknown';

        setState(() => _address = displayName);
        widget.onAddressChanged?.call(displayName);
      }
    } catch (e) {
      debugPrint("Reverse geocoding failed: $e");
      widget.onAddressChanged?.call(null);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _selectedPosition,
            zoom: 14,
          ),
          onCameraMove: widget.allowLocationPicking ? _onCameraMove : null,
          onCameraIdle: widget.allowLocationPicking ? _onCameraIdle : null,
          onTap: widget.allowMarkerPlacement ? _onTap : null,
          myLocationEnabled: widget.showUserLocation,
          myLocationButtonEnabled: false,
          markers: _markers,
        ),

        if (widget.allowLocationPicking)
          const Center(
            child: Icon(Icons.location_pin, size: 40, color: Colors.red),
          ),

        if (_isLoading) const Center(child: CircularProgressIndicator()),

        Positioned(
          top: 10,
          right: 10,
          child: FloatingActionButton(
            onPressed: _goToMyLocation,
            backgroundColor: Colors.white,
            mini: true,
            child: const Icon(Icons.my_location, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
