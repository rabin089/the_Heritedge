import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/predictor.model.dart';

class PlaceService {
  final String apiKey = 'AIzaSyCGnusGppsu00mCgFIfsDbSFvC7JGkgeJY';  // <-- Replace this with your API Key

  Future<List<PlacePrediction>> fetchPlaceSuggestions(String input) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&types=geocode&language=en';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List predictions = jsonResponse['predictions'];

      return predictions
          .map((p) => PlacePrediction.fromJson(p))
          .toList();
    } else {
      throw Exception('Failed to fetch place suggestions');
    }
  }
}
