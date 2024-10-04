import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'dart:typed_data';

class TfliteService {
  Interpreter? _interpreter; // Interpreter를 nullable로 설정

  // 모델 로드
  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('model.tflite');
      print("모델 로드 완료");
    } catch (e) {
      print("모델 로드 실패: $e");
    }
  }

  // 예측 수행
  Future<List<dynamic>?> predict(Uint8List inputImage) async {
    // Interpreter가 로드되었는지 확인
    if (_interpreter == null) {
      print("Interpreter가 초기화되지 않았습니다.");
      return null;
    }

    // 예측을 수행하기 위한 배열 생성 (6개의 차량 클래스를 예시로 설정)
    var output = List.filled(6, 0).reshape([1, 6]);

    try {
      _interpreter!.run(inputImage, output); // 예측 수행
      return output;
    } catch (e) {
      print("예측 실패: $e");
      return null;
    }
  }
  // 외부에서 모델 로드를 호출할 수 있도록 추가
  Future<void> initialize() async {
    await _loadModel();
  }
}