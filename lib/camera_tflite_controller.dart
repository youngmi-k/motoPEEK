import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'api/TFLite_service.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final TfliteService _classifier = TfliteService();
  String _result = "No results yet"; // 예측 결과를 저장할 변수
  bool _isModelLoaded = false; // 모델 로드 여부

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadTFLiteModel(); // 모델 로드 호출
  }

  // 카메라 초기화
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      _controller = CameraController(firstCamera, ResolutionPreset.high);
      _initializeControllerFuture = _controller.initialize();
      setState(() {}); // 카메라가 초기화되면 UI를 업데이트합니다.
    } catch (e) {
      print('카메라 초기화 오류: $e');
    }
  }

  // TFLite 모델 로드
  Future<void> _loadTFLiteModel() async {
    try {
      await _classifier.initialize(); // 모델 초기화
      setState(() {
        _isModelLoaded = true; // 모델 로드 완료
      });
    } catch (e) {
      print('TFLite 모델 로드 오류: $e');
    }
  }

  // 사진 촬영 및 예측 수행
  Future<void> _takePictureAndClassify() async {
    if (!_isModelLoaded) {
      setState(() {
        _result = "Model not loaded"; // 모델이 로드되지 않은 경우 메시지 표시
      });
      return;
    }

    try {
      await _initializeControllerFuture; // 카메라가 초기화될 때까지 대기
      final XFile image = await _controller.takePicture(); // 사진 촬영
      final inputImage = File(image.path).readAsBytesSync(); // 이미지를 파일로 변환

      // 모델을 사용해 예측 수행
      final result = await _classifier.predict(inputImage); // TFLite 예측
      setState(() {
        _result = result != null ? result.toString() : "No prediction"; // 결과가 있으면 출력, 없으면 메시지 표시
      });
    } catch (e) {
      print('예측 오류: $e');
      setState(() {
        _result = "Prediction failed"; // 에러가 발생한 경우 메시지 표시
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vehicle Recognition')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller); // 카메라 프리뷰
                } else {
                  return Center(child: CircularProgressIndicator()); // 카메라가 초기화되지 않았을 때 로딩 표시
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '예측 결과: $_result', // 예측 결과 표시
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePictureAndClassify,
        child: Icon(Icons.camera),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // 카메라 컨트롤러 해제
    super.dispose();
  }
}
