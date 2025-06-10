

import 'package:geolocator/geolocator.dart' as geo;

class LocationService {
  Future<geo.Position> getCurrentPosition() async {
    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        throw Exception("Location permissions are denied.");
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }

    return await geo.Geolocator.getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.high);
  }
}
