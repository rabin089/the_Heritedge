import 'dart:math';
//Haversine Formula to calculate distance between user location and site location
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0;
  double toRadians(double degree) => degree * pi / 180;

  final dLat = toRadians(lat2 - lat1);
  final dLon = toRadians(lon2 - lon1);

  final lat1Rad = toRadians(lat1);
  final lat2Rad = toRadians(lat2);

  final a = pow(sin(dLat / 2), 2) +
      cos(lat1Rad) * cos(lat2Rad) * pow(sin(dLon / 2), 2);

  final c = 2 * asin(sqrt(a));

  return earthRadiusKm * c;
}
