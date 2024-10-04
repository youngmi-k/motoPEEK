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
            'image_bytes': {
              'b64': base64Image
            }
          }
        ]
      });

      final accessToken = "ya29.c.c0ASRK0Ga719IF4JBzL-ShQlkICjd7656EpfStnEEvwREm4zY5FvESR8yC5oRYGHYkravAHtc3kRcrpWjHuWb_GTGcVLGGRNr4WAek2uRr6gZfIk35LapAhNFLwb0h5NwYxibzmOxFAQw8GyJ9xNMoKf7hZh7GErebJ5kB8eVXTwdMsQ5tPD8MY3EZmx7N2UnVYWADQJf_B6cy_P982-snZ4BD1Kt8aRYvRRD_lj8IQ8Z-AXA23I9lYsG_pz0TuFjT62Lvtbrj_CZ_BDMhVliEJyR-RUnKv_UKT7XItRCJ49ZjUelJZcWv_7J8TS27qImmE6FnyHfDNhWo0ktyD8oA7UMh8jwbhKsOZrwuG7MILNY8bz--MtRfO5XST385D8uJXMXW-lmvOd7iavJsyWmXdu2RRZ-Oskl0rgBuQuVos1v5Y1SFvcUq7JmwOjMRdshhM_Q5tMdaVVpI9jnuxBhg89aqa1vnXe1F4zfn4zXqWrSo6-kou3X33lzUla091w5IBpJqYBZ1zyuoe_6yRJyRa4nJ-6Me7y_y_hMhnMbs1Z4XIgFhwgfWsZiBznQ7fXbeRMvRwkxeyIYbM9fe6_vt2hvOtU16Q0_it6jQM_8oF0xZZ5Ji0h2elbjfoIIhYyt045VOY_FsxZindVcVm33B9-J44UftpUxo7wYoh37ubwU14z640zu3qbnb5mhhsq5ZuBMMdluyYs69hVkyXgYgdgiVazmxcvs7jRdZ9bgF3Xr9J11-6mpgcI2M9hvjFju6oBn3RaBXvFSJyzZwp_dg21QzgYdlkoe_QwM5t362Rcgs2csz12VnddWe-gJw8q5Z5Ju4yxgFYOUtMbadUx0nmb_10lcUwkl3FByivc-7xxxeic_un1h8X-VQr9vYJhe_RWv3qSdZQjVhlx-rsoajVj0lRiYrIS_z5Ukh7wY_7yFs875hV_OtrOQw3IV74o2MZdw_Yj7w-iW96cjR72l2XO6552c7SjxX-2b9Q2S7UXfnXtVBheryWeQ";
      // API 호출
      final response = await http.post(
        //Uri.parse('$endpointUrl?key=$apiKey'),
        Uri.parse('$endpointUrl'),
        headers: {
          'Authorization': 'Bearer $accessToken',
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