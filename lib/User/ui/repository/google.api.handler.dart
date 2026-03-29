import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class GoogleDriveHelper {
  final String apiUrl = "https://script.google.com/macros/s/AKfycbzOzSsxabFDl_ylBEJqizV65GswK2cuA_h38YijzSekeb5KjDj0OpqtkwIdLS-ko2EH/exec"; 
  Future<String?> uploadImage(File imageFile) async {
    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      String fileName = imageFile.path.split('/').last;

      var response = await http.post(
        Uri.parse(apiUrl),
        body: {
          "file": base64Image,
          "fileName": fileName,
        },
      );

      if (response.statusCode == 200) {
        return response.body; // Google Drive Image Link
      }
    } catch (e) {
      print("Error uploading to Google Drive: $e");
    }
    return null;
  }
}
