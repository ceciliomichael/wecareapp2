import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class ImagePickerResult {
  final String fileName;
  final String base64Data;

  ImagePickerResult({
    required this.fileName,
    required this.base64Data,
  });
}

class FilePickerService {
  static Future<ImagePickerResult?> pickImageWithBase64() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        Uint8List fileBytes = result.files.single.bytes!;
        String base64String = base64Encode(fileBytes);
        String fileName = result.files.single.name;
        
        return ImagePickerResult(
          fileName: fileName,
          base64Data: base64String,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Error picking image: $e');
    }
  }

  static Future<String?> pickImageAsBase64() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        Uint8List fileBytes = result.files.single.bytes!;
        String base64String = base64Encode(fileBytes);
        return base64String;
      }
      return null;
    } catch (e) {
      throw Exception('Error picking image: $e');
    }
  }

  static Future<String?> pickImageFileName() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        return result.files.single.name;
      }
      return null;
    } catch (e) {
      throw Exception('Error picking image: $e');
    }
  }
}
