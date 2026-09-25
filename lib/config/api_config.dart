import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  ApiConfig._();

  static const defaultBaseUrl =
      'https://shame-downloads-featured-intellectual.trycloudflare.com';
  static const _baseUrlKey = 'academic_mentor_backend_url';

  static String baseUrl = defaultBaseUrl;

  static Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    baseUrl = _normalise(preferences.getString(_baseUrlKey) ?? defaultBaseUrl);
  }

  static Future<void> saveBaseUrl(String value) async {
    final normalised = _normalise(value);
    if (Uri.tryParse(normalised)?.hasScheme != true) {
      throw const FormatException('Enter a valid HTTPS backend URL.');
    }
    if (Uri.parse(normalised).scheme != 'https') {
      throw const FormatException('Backend URL must use HTTPS.');
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_baseUrlKey, normalised);
    baseUrl = normalised;
  }

  static String _normalise(String value) =>
      value.trim().replaceFirst(RegExp(r'/+$'), '');
}
