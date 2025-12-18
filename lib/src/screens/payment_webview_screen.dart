import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart';

/// Payment WebView Screen
/// Shows Pesapal payment page in-app and handles callbacks
class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String callbackUrl;
  final Function(String orderTrackingId)? onPaymentSuccess;
  final Function(String? error)? onPaymentError;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.callbackUrl,
    this.onPaymentSuccess,
    this.onPaymentError,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            
            // Check if this is a callback URL
            _handleCallbackUrl(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            
            // Check if this is a callback URL
            _handleCallbackUrl(url);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _error = error.description;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handleCallbackUrl(String url) {
    try {
      // Handle custom app scheme callback (e.g., myapp://payment-callback?orderTrackingId=xxx)
      if (url.startsWith('myapp://')) {
        final uri = Uri.parse(url);
        final orderTrackingId = uri.queryParameters['orderTrackingId'];
        final status = uri.queryParameters['status'];
        
        if (orderTrackingId != null) {
          if (status == 'COMPLETED' || status == 'success' || status == null) {
            // If status is null, assume success if we have orderTrackingId
            widget.onPaymentSuccess?.call(orderTrackingId);
            Navigator.of(context).pop(true);
          } else if (status == 'FAILED' || status == 'failed') {
            widget.onPaymentError?.call('Payment failed');
            Navigator.of(context).pop(false);
          }
        }
        return;
      }
      
      // Handle Pesapal callback URL format
      // Pesapal redirects to callback URL with orderTrackingId parameter
      final uri = Uri.parse(url);
      final orderTrackingId = uri.queryParameters['orderTrackingId'];
      final orderMerchantReference = uri.queryParameters['OrderMerchantReference'];
      
      // If URL contains orderTrackingId, it's a callback
      if (url.contains(widget.callbackUrl) && orderTrackingId != null) {
        // Payment callback received - extract order tracking ID
        widget.onPaymentSuccess?.call(orderTrackingId);
        Navigator.of(context).pop(true);
        return;
      }
      
      // Alternative: Check if URL contains callback indicators
      if (url.contains('orderTrackingId') || url.contains('OrderTrackingId')) {
        final trackingId = orderTrackingId ?? uri.queryParameters['OrderTrackingId'];
        if (trackingId != null && trackingId.isNotEmpty) {
          widget.onPaymentSuccess?.call(trackingId);
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      debugPrint('Error handling callback URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Show confirmation dialog before closing
          _showExitDialog();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complete Payment'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showExitDialog(),
          ),
        ),
        body: Stack(
          children: [
            if (_error != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Payment Error',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              )
            else
              WebViewWidget(controller: _controller),
            if (_isLoading && _error == null)
              Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Payment?'),
        content: const Text('Are you sure you want to cancel this payment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue Payment'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              widget.onPaymentError?.call('Payment cancelled by user');
              Navigator.of(context).pop(false); // Close payment screen
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Payment'),
          ),
        ],
      ),
    );
  }
}
