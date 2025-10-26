import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class CameraService {
  static CameraController? _controller;
  static Future<void>? _initializeControllerFuture;

  static Future<List<CameraDescription>> getAvailableCameras() async {
    return await availableCameras();
  }

  static Future<CameraController?> initializeCamera() async {
    try {
      final cameras = await getAvailableCameras();
      if (cameras.isEmpty) {
        return null;
      }

      // Get the first available camera (usually back camera)
      final firstCamera = cameras.first;

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      return _controller;
    } catch (e) {
      print('Error initializing camera: $e');
      return null;
    }
  }

  static Future<String?> takePicture() async {
    try {
      await _initializeControllerFuture;

      if (_controller == null || !_controller!.value.isInitialized) {
        throw Exception('Camera is not initialized');
      }

      if (_controller!.value.isTakingPicture) {
        throw Exception('Already taking a picture');
      }

      // Get the path where the image will be saved
      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/Pictures/flutter_test';
      await Directory(dirPath).create(recursive: true);
      final String filePath =
          join(dirPath, '${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Take the picture
      final XFile picture = await _controller!.takePicture();

      // Copy the picture to our desired location
      final File savedImage = await File(picture.path).copy(filePath);

      return savedImage.path;
    } catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }

  static void disposeCamera() {
    _controller?.dispose();
    _controller = null;
  }

  static Widget cameraPreview() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return CameraPreview(_controller!);
  }
}
