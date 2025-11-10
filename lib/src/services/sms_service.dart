import 'package:url_launcher/url_launcher.dart';

class SmsService {
  static Future<bool> sendSms({
    required String phoneNumber,
    required String message,
  }) async {
    final uri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {
        'body': message,
      },
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<bool> sendGroupSms({
    required List<String> phoneNumbers,
    required String message,
  }) async {
    if (phoneNumbers.isEmpty) return false;
    // Many Android devices accept comma-separated recipients
    final recipients = phoneNumbers.join(',');
    final uri = Uri(
      scheme: 'sms',
      path: recipients,
      queryParameters: {
        'body': message,
      },
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}


