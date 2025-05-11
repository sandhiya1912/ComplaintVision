import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  late String baseUrl;

  ApiService(String baseUrl) {
    // Ensure the base URL does not end with "/"
    this.baseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
  }

  Future<Map<String, dynamic>> classifyImage(Uint8List imageBytes) async {
    try {
      var uri = Uri.parse('$baseUrl/predict');
      var request = http.MultipartRequest('POST', uri);

      // Attach the image file
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'complaint_image.png',
        ),
      );

      // Send request and get response
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Debugging logs
      print('Request to: ${uri.toString()}');
      print('Response Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to classify image: ${response.statusCode}, Response: ${response.body}');
      }
    } catch (e) {
      print('Classification error: $e');
      throw Exception('Classification error: $e');
    }
  }
}
