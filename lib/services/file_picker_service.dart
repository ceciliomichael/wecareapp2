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
  // Static flag to track if file picker is currently active
  static bool _isPickerActive = false;

  static Future<ImagePickerResult?> pickImageWithBase64() async {
    // Prevent concurrent file picker operations
    if (_isPickerActive) {
      throw Exception('File picker is already open. Please wait for the current operation to complete.');
    }

    try {
      _isPickerActive = true;
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        allowedExtensions: null, // Allow all image types
      );

      if (result != null && result.files.single.bytes != null) {
        Uint8List fileBytes = result.files.single.bytes!;
        
        // Validate file size (max 5MB)
        if (fileBytes.length > 5 * 1024 * 1024) {
          throw Exception('File size too large. Please select an image smaller than 5MB.');
        }
        
        String base64String = base64Encode(fileBytes);
        String fileName = result.files.single.name;
        
        // Validate file type based on extension
        String fileExtension = fileName.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(fileExtension)) {
          throw Exception('Invalid file type. Please select a valid image file (JPG, PNG, GIF, BMP, WEBP).');
        }
        
        return ImagePickerResult(
          fileName: fileName,
          base64Data: base64String,
        );
      }
      
      // User cancelled the picker
      return null;
    } catch (e) {
      // Rethrow with more specific error messages
      if (e.toString().contains('already open')) {
        throw Exception('File picker is already open. Please close any open dialogs and try again.');
      } else if (e.toString().contains('permission')) {
        throw Exception('Permission denied. Please allow file access and try again.');
      } else {
        throw Exception('Failed to select image: ${e.toString()}');
      }
    } finally {
      // Always reset the flag
      _isPickerActive = false;
    }
  }

  static Future<String?> pickImageAsBase64() async {
    // Prevent concurrent file picker operations
    if (_isPickerActive) {
      throw Exception('File picker is already open. Please wait for the current operation to complete.');
    }

    try {
      _isPickerActive = true;
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        Uint8List fileBytes = result.files.single.bytes!;
        
        // Validate file size (max 5MB)
        if (fileBytes.length > 5 * 1024 * 1024) {
          throw Exception('File size too large. Please select an image smaller than 5MB.');
        }
        
        String base64String = base64Encode(fileBytes);
        return base64String;
      }
      return null;
    } catch (e) {
      // Rethrow with more specific error messages
      if (e.toString().contains('already open')) {
        throw Exception('File picker is already open. Please close any open dialogs and try again.');
      } else if (e.toString().contains('permission')) {
        throw Exception('Permission denied. Please allow file access and try again.');
      } else {
        throw Exception('Failed to select image: ${e.toString()}');
      }
    } finally {
      // Always reset the flag
      _isPickerActive = false;
    }
  }

  static Future<String?> pickImageFileName() async {
    // Prevent concurrent file picker operations
    if (_isPickerActive) {
      throw Exception('File picker is already open. Please wait for the current operation to complete.');
    }

    try {
      _isPickerActive = true;
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        return result.files.single.name;
      }
      return null;
    } catch (e) {
      // Rethrow with more specific error messages
      if (e.toString().contains('already open')) {
        throw Exception('File picker is already open. Please close any open dialogs and try again.');
      } else if (e.toString().contains('permission')) {
        throw Exception('Permission denied. Please allow file access and try again.');
      } else {
        throw Exception('Failed to select image: ${e.toString()}');
      }
    } finally {
      // Always reset the flag
      _isPickerActive = false;
    }
  }

  // Method to check if picker is currently active
  static bool get isPickerActive => _isPickerActive;

  // Method to force reset the picker state (for emergency cases)
  static void resetPickerState() {
    _isPickerActive = false;
  }
}
