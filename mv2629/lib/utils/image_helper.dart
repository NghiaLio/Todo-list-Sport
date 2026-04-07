import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageHelper {
  static String getImageUrl(String? path) {
    if (path == null) return '';
    final basePath = dotenv.env['BASE_URL_IMAGE'] ?? "";
    return '$basePath$path';
  }
}