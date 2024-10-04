import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class VisionApiService {
  final String _apiKey = 'AIzaSyA9uz_E1Ec9bysgKutXk5MOGI8HEi8coeQ';  // Google Cloud API 키

  Future<String> analyzeImage(String imagePath) async {
    // 이미지 파일을 읽어서 Base64로 인코딩
    File imageFile = File(imagePath);
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    // 요청 바디 생성
    final body = jsonEncode({
      'requests': [
        {
          'image': {
            'content': base64Image
          },
          'features': [
            {
              'type': 'LABEL_DETECTION',
              'maxResults': 5  // 최대 5개의 라벨 반환
            }
          ]
        }
      ]
    });

    // API 호출
    final response = await http.post(
      Uri.parse('https://vision.googleapis.com/v1/images:annotate?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final label = data['responses'][0]['labelAnnotations'][0]['description'];
      return label;
    } else {
      throw Exception('Failed to analyze image: ${response.statusCode}');
    }
  }
}