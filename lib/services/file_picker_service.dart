import 'package:file_picker/file_picker.dart';

class FilePickerService {
  static Future<String?> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        return result.files.single.name;
      }
      return null;
    } catch (e) {
      throw Exception('Error picking file: $e');
    }
  }
}
