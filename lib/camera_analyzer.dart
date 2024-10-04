import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'vision_api_service.dart';

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
  String? _result;  // 분석 결과
  final VisionApiService _visionApiService = VisionApiService();  // Vision API 서비스

  @override
  void initState() {
    super.initState();
    _initializeCamera();  // 카메라 초기화
  }

  // 카메라 초기화 함수
  void _initializeCamera() async {
    await _requestPermission(); // 권한 요청 후 초기화
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  // 사진 촬영 및 분석 함수
  Future<void> _takePictureAndAnalyze() async {
    try {
      await _initializeControllerFuture;

      // 사진 촬영
      final XFile image = await _controller.takePicture();

      // 촬영한 이미지를 저장할 경로 지정
      final directory = await getTemporaryDirectory();
      final path = join(directory.path, '${DateTime.now()}.png');

      // 파일로 저장
      File imageFile = File(image.path);
      imageFile.copy(path);

      // 촬영한 이미지를 Google Cloud Vision API로 분석
      final result = await _visionApiService.analyzeImage(imageFile.path);
      setState(() {
        _result = result;  // 분석 결과 저장
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _controller.dispose();  // 카메라 리소스 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vehicle Recognition')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // 카메라 화면 미리보기
            return Column(
              children: [
                Expanded(
                  child: CameraPreview(_controller),
                ),
                Text(
                  _result == null ? 'No result yet.' : 'Result: $_result',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _takePictureAndAnalyze,
                  child: Text('Capture and Analyze'),
                ),
              ],
            );
          } else {
            // 카메라 초기화 중 로딩 표시
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
