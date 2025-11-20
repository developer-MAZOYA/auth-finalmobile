import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  // Take single picture using camera
  static Future<File?> takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }

  // Take multiple pictures sequentially using camera
  static Future<List<File>> takeMultiplePictures(int count) async {
    List<File> images = [];

    for (int i = 0; i < count; i++) {
      try {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 90,
          preferredCameraDevice: CameraDevice.rear,
        );

        if (image != null) {
          images.add(File(image.path));
        } else {
          // User canceled or failed to take picture
          break;
        }
      } catch (e) {
        print('Error taking picture ${i + 1}: $e');
        break;
      }
    }

    return images;
  }
}
