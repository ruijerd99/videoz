import 'dart:io';

class FileHelper {
  FileHelper._();

  static Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<bool> checkFileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  static String getFileExtension(File file) {
    final fileName = file.path.split('/').last;
    return fileName.split('.').last;
  }

  static String getFileName({required File file, required String fileExtension}) {
    final fileName = file.path.split('/').last;
    return fileName.replaceAll('.$fileExtension', '');
  }
}
