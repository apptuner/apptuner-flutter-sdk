import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'models/tuner_config.dart';

class ApptunerService {
  static const String _baseUrl = 'https://apptuner.dev/api/v1/config';
  final String apiKey;
  ApptunerService({required this.apiKey});

  Future<TunerConfig?> fetchConfig() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final String version = packageInfo.version;
      final String platform = Platform.isAndroid ? 'android' : 'ios';

      final Map<String, String> queryParams = {
        'platform': platform,
        'current_version': version,
      };

      final Uri uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'x-api-key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return TunerConfig.fromJson(data);
      } else {
        // Log error or handle gracefully
        return null;
      }
    } catch (e) {
      // Log error
      return null;
    }
  }
}
