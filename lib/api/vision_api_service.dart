import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class VisionApiService {
  final String apiKey;

  VisionApiService(this.apiKey);

  Future<void> analyzeImage(File imageFile) async {
    final bytes = imageFile.readAsBytesSync();
    final base64Image = base64Encode(bytes);

    final url = 'https://vision.googleapis.com/v1/images:annotate?key=$apiKey';
    final body = jsonEncode({
      "requests": [
        {
          "image": {
            "content": base64Image
          },
          "features": [
            {
              "type": "LABEL_DETECTION",
              "maxResults": 10
            }
          ]
        }
      ]
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("분석 결과: ${data['responses'][0]['labelAnnotations']}");
    } else {
      print("API 호출 실패: ${response.body}");
    }
  }
}