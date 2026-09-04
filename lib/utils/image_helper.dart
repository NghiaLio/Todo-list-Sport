import '../constants/app_config.dart';

class ImageHelper {
  static String getImageUrl(String? path) {
    if (path == null) return '';
    final basePath = AppConfig.baseUrlImage;
    return '$basePath$path';
  }
}
