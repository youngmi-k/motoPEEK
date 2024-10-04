import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'dart:typed_data';

class TfliteService {
  late Interpreter _interpreter;

  // 모델 로드
  VehicleClassifier() {
    _loadModel();
  }

  void _loadModel() async {
    _interpreter = await Interpreter.fromAsset('model.tflite');
  }

  // 예측 수행
  List<dynamic> predict(Uint8List inputImage) {
    var output = List.filled(6, 0).reshape([1, 6]);  // 5개의 차량 클래스를 예시로 함
    _interpreter.run(inputImage, output);
    return output;
  }
}
