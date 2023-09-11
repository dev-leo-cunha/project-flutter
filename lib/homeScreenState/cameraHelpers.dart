import 'package:camera/camera.dart';

class CameraHelper {
  CameraController? _controller;

  Future<void> initializeCamera(List<CameraDescription> cameras) async {
    if (cameras.isNotEmpty) {
      _controller = CameraController(cameras[0], ResolutionPreset.max);
      await _controller!.initialize();
    }
  }

  Future<void> openCamera() async {
    if (_controller != null) {
      await _controller!.initialize();
    }
  }

  Future<void> closeCamera() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
  }

  Future<XFile> capturePhoto() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        final XFile file = await _controller!.takePicture();
        return file;
      } catch (e) {
        throw e;
      }
    } else {
      throw 'Erro: A câmera não está inicializada.';
    }
  }

  bool isCameraOpen() {
    return _controller != null && _controller!.value.isInitialized;
  }

  bool isCameraReady() {
    return isCameraOpen() && !_controller!.value.isTakingPicture;
  }
}
