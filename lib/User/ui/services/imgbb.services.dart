import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImgBBService {
  final String _apiKey = "20a1e97b4c4cb6dcda85c0908fa56029";
  final String _uploadUrl = "https://api.imgbb.com/1/upload";

  Future<String?> uploadImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse("$_uploadUrl?key=$_apiKey"),
        body: {
          "image": base64Image,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final imageUrl = jsonResponse["data"]["url"];
        print("Upload Success: $imageUrl");
        return imageUrl;
      } else {
        print("Upload failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Upload Error: $e");
      return null;
    }
  }
}
