import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  // Take single picture using camera and save to permanent location
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
        // Copy to permanent location to avoid cache file issues
        File? permanentFile = await _copyToPermanentLocation(image);

        if (permanentFile != null) {
          // Verify the permanent file actually exists and is readable
          bool verified = await verifyFile(permanentFile);
          if (verified) {
            return permanentFile;
          } else {
            // If permanent file verification fails, try the original
            File originalFile = File(image.path);
            if (await originalFile.exists()) {
              return originalFile;
            }
          }
        }
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
          // Copy to permanent location
          File? permanentFile = await _copyToPermanentLocation(image);

          if (permanentFile != null) {
            // Verify the file before adding to list
            bool verified = await verifyFile(permanentFile);
            if (verified) {
              images.add(permanentFile);
            } else {
              // Fallback to original file
              File originalFile = File(image.path);
              if (await originalFile.exists()) {
                images.add(originalFile);
              }
            }
          }
        } else {
          // User canceled
          break;
        }
      } catch (e) {
        print('Error taking picture ${i + 1}: $e');
        break;
      }
    }

    return images;
  }

  // Copy file to permanent app directory to avoid cache file issues
  static Future<File?> _copyToPermanentLocation(XFile xfile) async {
    try {
      // First, verify the original file exists
      File originalFile = File(xfile.path);
      if (!await originalFile.exists()) {
        print('Original file does not exist: ${xfile.path}');
        return null;
      }

      // Get app documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String permanentPath = '${appDir.path}/evidence_images';

      // Create directory if it doesn't exist
      final Directory permanentDir = Directory(permanentPath);
      if (!await permanentDir.exists()) {
        await permanentDir.create(recursive: true);
      }

      // Generate unique filename
      final String filename =
          'evidence_${DateTime.now().millisecondsSinceEpoch}_${_getRandomString(6)}.jpg';
      final String newPath = '$permanentPath/$filename';

      // Read the original file bytes
      final List<int> imageBytes = await originalFile.readAsBytes();

      if (imageBytes.isEmpty) {
        print('Original file is empty: ${xfile.path}');
        return null;
      }

      // Write to new permanent location
      final File newFile = File(newPath);
      await newFile.writeAsBytes(imageBytes);

      // Verify the copy was successful
      bool newFileExists = await newFile.exists();
      int newFileSize = await newFile.length();

      if (newFileExists && newFileSize > 0) {
        print('Successfully stored image: $newPath ($newFileSize bytes)');
        return newFile;
      } else {
        print('Failed to create permanent file: $newPath');
        return null;
      }
    } catch (e) {
      print('Error copying file to permanent location: $e');

      // Fallback: try to return the original file
      try {
        File originalFile = File(xfile.path);
        if (await originalFile.exists()) {
          return originalFile;
        }
      } catch (e2) {
        print('Fallback also failed: $e2');
      }

      return null;
    }
  }

  // Helper method to generate random string for filename
  static String _getRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    final result = StringBuffer();

    for (int i = 0; i < length; i++) {
      result.write(chars[random % chars.length]);
    }

    return result.toString();
  }

  // Enhanced file verification with detailed diagnostics
  static Future<Map<String, dynamic>> verifyFileDetailed(File file) async {
    try {
      bool exists = await file.exists();

      if (!exists) {
        return {
          'valid': false,
          'error': 'File does not exist',
          'path': file.path,
          'size': 0,
          'exists': false
        };
      }

      final fileStat = await file.stat();

      if (fileStat.size == 0) {
        return {
          'valid': false,
          'error': 'File is empty (0 bytes)',
          'path': file.path,
          'size': 0,
          'exists': true
        };
      }

      // Try to read the file
      try {
        final bytes = await file.readAsBytes();

        return {
          'valid': true,
          'path': file.path,
          'size': fileStat.size,
          'exists': true,
          'bytesRead': bytes.length
        };
      } catch (e) {
        return {
          'valid': false,
          'error': 'Cannot read file: $e',
          'path': file.path,
          'size': fileStat.size,
          'exists': true
        };
      }
    } catch (e) {
      return {
        'valid': false,
        'error': 'Verification failed: $e',
        'path': file.path,
        'size': 0,
        'exists': false
      };
    }
  }

  // Verify file exists and is readable (simple version)
  static Future<bool> verifyFile(File file) async {
    try {
      if (!await file.exists()) {
        return false;
      }

      final fileStat = await file.stat();
      if (fileStat.size == 0) {
        return false;
      }

      // Try to read a small portion to verify it's accessible
      await file.open();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get all stored evidence images
  static Future<List<File>> getStoredEvidenceImages() async {
    List<File> images = [];
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String evidencePath = '${appDir.path}/evidence_images';
      final Directory evidenceDir = Directory(evidencePath);

      if (await evidenceDir.exists()) {
        final List<FileSystemEntity> files = await evidenceDir.list().toList();

        for (var file in files) {
          if (file is File && file.path.toLowerCase().endsWith('.jpg')) {
            bool isValid = await verifyFile(file);
            if (isValid) {
              images.add(file);
            }
          }
        }

        // Sort by modification time (newest first)
        images.sort((a, b) {
          return b.statSync().modified.compareTo(a.statSync().modified);
        });
      }
    } catch (e) {
      print('Error getting stored images: $e');
    }

    return images;
  }

  // Clean up temporary files
  static Future<void> cleanupTemporaryFiles() async {
    try {
      final Directory tempDir = Directory.systemTemp;
      if (await tempDir.exists()) {
        final List<FileSystemEntity> files = await tempDir.list().toList();

        for (var file in files) {
          if (file.path.contains('scaled_') ||
              file.path.contains('image_picker')) {
            try {
              await file.delete();
            } catch (e) {
              // Ignore deletion errors for temp files
            }
          }
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }
}
