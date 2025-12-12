import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  // Take single picture using camera and save to permanent location
  static Future<File?> takePicture() async {
    try {
      print('📸 Taking picture with camera...');

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        print('✅ Picture captured: ${image.path}');

        // Copy to permanent location to avoid cache file issues
        File? permanentFile = await _copyToPermanentLocation(image);

        if (permanentFile != null) {
          // Verify the permanent file actually exists and is readable
          bool verified = await verifyFile(permanentFile);
          if (verified) {
            print('✅ Permanent file created: ${permanentFile.path}');
            return permanentFile;
          } else {
            print('⚠️ Permanent file verification failed, using original');
            // If permanent file verification fails, try the original
            File originalFile = File(image.path);
            if (await originalFile.exists()) {
              return originalFile;
            }
          }
        }
      } else {
        print('❌ User canceled picture taking');
      }
      return null;
    } catch (e) {
      print('❌ Error taking picture: $e');
      return null;
    }
  }

  // Take multiple pictures sequentially using camera
  static Future<List<File>> takeMultiplePictures(int count) async {
    List<File> images = [];
    print('📸 Taking $count pictures...');

    for (int i = 0; i < count; i++) {
      print('📸 Picture ${i + 1}/$count');

      try {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 90,
          preferredCameraDevice: CameraDevice.rear,
        );

        if (image != null) {
          print('✅ Picture ${i + 1} captured');

          // Copy to permanent location
          File? permanentFile = await _copyToPermanentLocation(image);

          if (permanentFile != null) {
            // Verify the file before adding to list
            bool verified = await verifyFile(permanentFile);
            if (verified) {
              images.add(permanentFile);
              print('✅ Added to images list');
            } else {
              print(
                  '⚠️ Verification failed for picture ${i + 1}, using original');
              // Fallback to original file
              File originalFile = File(image.path);
              if (await originalFile.exists()) {
                images.add(originalFile);
              }
            }
          }
        } else {
          // User canceled
          print('❌ User canceled at picture ${i + 1}');
          break;
        }
      } catch (e) {
        print('❌ Error taking picture ${i + 1}: $e');
        break;
      }
    }

    print('📋 Total pictures captured: ${images.length}');
    return images;
  }

  // Copy file to permanent app directory to avoid cache file issues
  static Future<File?> _copyToPermanentLocation(XFile xfile) async {
    try {
      // First, verify the original file exists
      File originalFile = File(xfile.path);
      if (!await originalFile.exists()) {
        print('❌ Original file does not exist: ${xfile.path}');
        return null;
      }

      // Get app documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String permanentPath = '${appDir.path}/evidence_images';

      // Create directory if it doesn't exist
      final Directory permanentDir = Directory(permanentPath);
      if (!await permanentDir.exists()) {
        await permanentDir.create(recursive: true);
        print('📁 Created directory: $permanentPath');
      }

      // Generate unique filename
      final String filename =
          'evidence_${DateTime.now().millisecondsSinceEpoch}_${_getRandomString(6)}.jpg';
      final String newPath = '$permanentPath/$filename';

      // IMPORTANT: Create a proper File copy to ensure the file is fully saved
      print('📋 Copying file to: $newPath');
      await originalFile.copy(newPath);

      // Verify the copy was successful
      final File newFile = File(newPath);
      bool newFileExists = await newFile.exists();
      int newFileSize = await newFile.length();

      if (newFileExists && newFileSize > 0) {
        print('✅ Successfully stored image: $newPath ($newFileSize bytes)');

        // Verify we can read it
        try {
          final bytes = await newFile.readAsBytes();
          print('✅ File verification: ${bytes.length} bytes read');
        } catch (e) {
          print('⚠️ File reading test failed: $e');
        }

        return newFile;
      } else {
        print('❌ Failed to create permanent file: $newPath');
        // Fallback to original
        if (await originalFile.exists()) {
          print('↩️ Falling back to original file');
          return originalFile;
        }
        return null;
      }
    } catch (e) {
      print('❌ Error copying file: $e');
      // Fallback: try to return the original file
      try {
        File originalFile = File(xfile.path);
        if (await originalFile.exists()) {
          print('↩️ Falling back to original file after error');
          return originalFile;
        }
      } catch (e2) {
        print('❌ Fallback also failed: $e2');
      }
      return null;
    }
  }

  // Helper method to generate random string for filename
  static String _getRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final result = StringBuffer();

    for (int i = 0; i < length; i++) {
      result.write(chars[random.nextInt(chars.length)]);
    }

    return result.toString();
  }

  // Enhanced file verification with detailed diagnostics
  static Future<Map<String, dynamic>> verifyFileDetailed(File file) async {
    try {
      bool exists = await file.exists();

      if (!exists) {
        print('❌ File does not exist: ${file.path}');
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
        print('❌ File is empty (0 bytes): ${file.path}');
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
        print('✅ File verified: ${file.path} (${bytes.length} bytes)');

        return {
          'valid': true,
          'path': file.path,
          'size': fileStat.size,
          'exists': true,
          'bytesRead': bytes.length
        };
      } catch (e) {
        print('❌ Cannot read file: ${file.path}, error: $e');
        return {
          'valid': false,
          'error': 'Cannot read file: $e',
          'path': file.path,
          'size': fileStat.size,
          'exists': true
        };
      }
    } catch (e) {
      print('❌ Verification failed: ${file.path}, error: $e');
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
        print('❌ File does not exist: ${file.path}');
        return false;
      }

      final fileStat = await file.stat();
      if (fileStat.size == 0) {
        print('❌ File is empty: ${file.path}');
        return false;
      }

      // Try to read a small portion to verify it's accessible
      await file.readAsBytes();
      return true;
    } catch (e) {
      print('❌ File verification failed: ${file.path}, error: $e');
      return false;
    }
  }

  // Get all stored evidence images
  static Future<List<File>> getStoredEvidenceImages() async {
    List<File> images = [];
    print('📁 Getting stored evidence images...');

    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String evidencePath = '${appDir.path}/evidence_images';
      final Directory evidenceDir = Directory(evidencePath);

      if (await evidenceDir.exists()) {
        final List<FileSystemEntity> files = await evidenceDir.list().toList();
        print('📁 Found ${files.length} files in evidence directory');

        for (var file in files) {
          if (file is File && file.path.toLowerCase().endsWith('.jpg')) {
            bool isValid = await verifyFile(file);
            if (isValid) {
              images.add(file);
            } else {
              print('⚠️ Skipping invalid file: ${file.path}');
            }
          }
        }

        // Sort by modification time (newest first)
        images.sort((a, b) {
          return b.statSync().modified.compareTo(a.statSync().modified);
        });

        print('✅ Found ${images.length} valid evidence images');
      } else {
        print('📁 Evidence directory does not exist: $evidencePath');
      }
    } catch (e) {
      print('❌ Error getting stored images: $e');
    }

    return images;
  }

  // Clean up temporary files
  static Future<void> cleanupTemporaryFiles() async {
    print('🧹 Cleaning up temporary files...');

    try {
      final Directory tempDir = Directory.systemTemp;
      if (await tempDir.exists()) {
        final List<FileSystemEntity> files = await tempDir.list().toList();
        int deletedCount = 0;

        for (var file in files) {
          if (file.path.contains('scaled_') ||
              file.path.contains('image_picker')) {
            try {
              await file.delete();
              deletedCount++;
            } catch (e) {
              // Ignore deletion errors for temp files
            }
          }
        }

        print('✅ Deleted $deletedCount temporary files');
      }
    } catch (e) {
      print('⚠️ Error during cleanup: $e');
      // Ignore cleanup errors
    }
  }
}
