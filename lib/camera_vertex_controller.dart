import 'dart:io'; // File 클래스를 사용하기 위한 라이브러리
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'api/vertex_ai_service.dart'; // Vertex AI 서비스 클래스

Future<void> _requestPermission() async {
  var status = await Permission.camera.status;
  if (!status.isGranted) {
    await Permission.camera.request();
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final VertexAIService _vertexAIService = VertexAIService(); // Vertex AI 서비스 인스턴스

  // 예측 결과를 저장할 변수
  String? _predictionResult;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // 카메라 초기화
  void _initializeCamera() async {
    await _requestPermission(); // 권한 요청 후 초기화
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
    setState(() {}); // _initializeControllerFuture 변경을 알림
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 사진 촬영 및 Vertex AI로 전송
  Future<void> _takePictureAndAnalyze() async {
    try {
      // 카메라 초기화가 완료될 때까지 대기
      await _initializeControllerFuture;

      // 사진 촬영 후 XFile 객체 반환
      final XFile image = await _controller.takePicture();

      // 촬영된 이미지를 Vertex AI로 분석 요청
      final result = await _vertexAIService.predict(image.path); // 파일 경로 전달

      // 예측 결과를 상태에 저장하고 화면에 반영
      setState(() {
        _predictionResult = result; // 예측 결과를 업데이트
      });

    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera Test')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                // 카메라 화면
                Expanded(child: CameraPreview(_controller)),

                // 예측 결과를 표시
                if (_predictionResult != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '예측 결과: $_predictionResult',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePictureAndAnalyze,
        child: Icon(Icons.camera),
      ),
    );
  }
}