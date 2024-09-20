import 'dart:io'; // File 클래스를 사용하기 위한 라이브러리
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  bool isCameraReady = false;
  XFile? imageFile;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    // 카메라 목록을 가져옵니다.
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      controller = CameraController(cameras![0], ResolutionPreset.high);
      await controller!.initialize();
      setState(() {
        isCameraReady = true;
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> captureImage() async {
    if (controller != null && controller!.value.isInitialized) {
      final image = await controller!.takePicture();
      setState(() {
        imageFile = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Camera Example"),
      ),
      body: isCameraReady
          ? Column(
        children: [
          Expanded(
            flex: 3,
            child: CameraPreview(controller!),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: captureImage,
                  child: Text("Capture Image"),
                ),
                imageFile != null
                    ? Image.file(
                  File(imageFile!.path),
                  height: 200,
                )
                    : Container(),
              ],
            ),
          ),
        ],
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
