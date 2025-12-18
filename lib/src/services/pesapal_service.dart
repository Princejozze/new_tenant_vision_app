import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Pesapal Payment Service
/// Handles Pesapal API integration for payment processing
class PesapalService {
  // Sandbox URLs (change to production when ready)
  static const String _baseUrl = 'https://cybqa.pesapal.com/pesapalv3';
  static const String _apiBaseUrl = 'https://cybqa.pesapal.com/pesapalv3/api';
  
  // Production URLs (uncomment when ready for production)
  // static const String _baseUrl = 'https://pay.pesapal.com/v3';
  // static const String _apiBaseUrl = 'https://pay.pesapal.com/v3/api';
  
  final String consumerKey;
  final String consumerSecret;
  String? _accessToken;
  DateTime? _tokenExpiry;

  PesapalService({
    required this.consumerKey,
    required this.consumerSecret,
  });

  /// Authenticate and get access token
  Future<String> _getAccessToken() async {
    // Return cached token if still valid (tokens typically last 1 hour)
    if (_accessToken != null && _tokenExpiry != null) {
      if (DateTime.now().isBefore(_tokenExpiry!.subtract(const Duration(minutes: 5)))) {
        return _accessToken!;
      }
    }

    try {
      final url = Uri.parse('$_apiBaseUrl/Auth/RequestToken');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'consumer_key': consumerKey,
          'consumer_secret': consumerSecret,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['token'];
        // Set expiry to 1 hour from now (Pesapal tokens typically last 1 hour)
        _tokenExpiry = DateTime.now().add(const Duration(hours: 1));
        return _accessToken!;
      } else {
        throw Exception('Failed to authenticate: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Authentication error: $e');
    }
  }

  /// Create a payment order
  /// Returns the redirect URL where user should complete payment
  Future<String> createPaymentOrder({
    required double amount,
    required String currency,
    required String description,
    required String callbackUrl,
    required String notificationId,
    required String reference,
    String? customerEmail,
    String? customerFirstName,
    String? customerLastName,
    String? customerPhoneNumber,
    Map<String, String>? billingAddress,
  }) async {
    try {
      final token = await _getAccessToken();
      
      final url = Uri.parse('$_apiBaseUrl/Transactions/SubmitOrderRequest');
      
      final orderData = {
        'id': reference,
        'currency': currency,
        'amount': amount.toStringAsFixed(2),
        'description': description,
        'callback_url': callbackUrl,
        'notification_id': notificationId,
        'billing_address': {
          'email_address': customerEmail ?? '',
          'phone_number': customerPhoneNumber ?? '',
          'country_code': billingAddress?['country_code'] ?? 'TZ',
          'first_name': customerFirstName ?? '',
          'middle_name': '',
          'last_name': customerLastName ?? '',
          'line_1': billingAddress?['line_1'] ?? '',
          'line_2': billingAddress?['line_2'] ?? '',
          'city': billingAddress?['city'] ?? '',
          'state': billingAddress?['state'] ?? '',
          'postal_code': billingAddress?['postal_code'] ?? '',
          'zip_code': billingAddress?['zip_code'] ?? '',
        },
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(orderData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final redirectUrl = data['redirect_url'] as String?;
        if (redirectUrl != null) {
          return redirectUrl;
        } else {
          throw Exception('No redirect URL in response');
        }
      } else {
        throw Exception('Failed to create order: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Payment order creation error: $e');
    }
  }

  /// Get transaction status by order tracking ID
  Future<Map<String, dynamic>> getTransactionStatus(String orderTrackingId) async {
    try {
      final token = await _getAccessToken();
      
      final url = Uri.parse('$_apiBaseUrl/Transactions/GetTransactionStatus?orderTrackingId=$orderTrackingId');
      
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get transaction status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Transaction status error: $e');
    }
  }
}
