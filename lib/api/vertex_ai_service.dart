import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class VertexAIService {
  // Google Cloud API 키와 Vertex AI 엔드포인트 URL
  final String apiKey = 'AIzaSyA9uz_E1Ec9bysgKutXk5MOGI8HEi8coeQ'; // Google Cloud API 키
  final String endpointUrl = 'https://us-central1-aiplatform.googleapis.com/v1/projects/motopeek-projects/locations/us-central1/endpoints/3379073010550964224:predict'; // Vertex AI 엔드포인트 URL

  // Vertex AI로 이미지 예측 요청
  Future<String> predict(String imagePath) async {
    try {
      // 이미지 파일을 Base64로 인코딩
      File imageFile = File(imagePath);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // 요청 바디 생성
      final body = jsonEncode({
        'instances': [
          {
            'image': {
              'bytesBase64': base64Image
            }
          }
        ]
      });

      // API 호출
      final response = await http.post(
        Uri.parse('$endpointUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 예측 결과에서 첫 번째 라벨 반환 (예시로 수정)
        return data['predictions'][0].toString(); // 원하는 형태로 가공 가능
      } else {
        print('Error: ${response.statusCode}');
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      print('Exception occurred: $e');
      return 'Exception occurred: $e';
    }
  }
}