import 'dart:math';

class IdGenerator {
  static const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static final Random _random = Random.secure();

  static String generateID() {
    return List.generate(
      6,
      (_) => _chars[_random.nextInt(_chars.length)],
    ).join();
  }
}
