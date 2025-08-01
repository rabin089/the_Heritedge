// lib/common/widgets/map/location_picker.dialog.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'custom.map.widget.dart';

class LocationPickerDialog extends StatefulWidget {
  const LocationPickerDialog({super.key});

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  LatLng? _pickedLatLng;
  String? _pickedAddress;

  @override
  Widget build(BuildContext context) {
    final mediaHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        height: mediaHeight * 0.75,
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text("Pick a Location", style: TextStyle(color: Colors.black)),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            Expanded(
              child: Stack(
                children: [
                  CustomGoogleMapWidget(
                    allowLocationPicking: true,
                    allowMarkerPlacement: false,
                    showUserLocation: true,
                    onLocationPicked: (latLng) {
                      _pickedLatLng = latLng;
                    },
                    onAddressChanged: (address) {
                      setState(() => _pickedAddress = address);
                    },
                  ),
                  if (_pickedAddress != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _pickedAddress!,
                            style: const TextStyle(fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text("Confirm Location",),
                onPressed: () {
                  if (_pickedLatLng != null) {
                    Navigator.pop(context, {
                      'latLng': _pickedLatLng,
                      'address': _pickedAddress,
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: const Color(0xFF56CCF2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
