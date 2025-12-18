import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/services/auth_service.dart';
import 'package:myapp/src/services/pesapal_service.dart';
import 'package:myapp/src/screens/payment_webview_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late final PesapalService _pesapalService;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    // Initialize Pesapal service with your credentials
    _pesapalService = PesapalService(
      consumerKey: '0o3deOInEqar+7PwxKl4NS7i2i4hepBK',
      consumerSecret: 'tTWLKeu7NIGKTqTHgYD5fAbiuWE=',
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go('/dashboard');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/dashboard'),
          ),
          title: const Text('Subscription'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Plan Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Theme.of(context).colorScheme.primary,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Plan',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Free Plan',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildFeatureItem(context, Icons.check_circle, 'Up to 5 properties'),
                      _buildFeatureItem(context, Icons.check_circle, 'Up to 20 rooms'),
                      _buildFeatureItem(context, Icons.check_circle, 'Basic analytics'),
                      _buildFeatureItem(context, Icons.check_circle, 'Email support'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Available Plans
              Text(
                'Available Plans',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Premium Plan
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Premium Plan',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'TZS 50,000/month',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: _isProcessingPayment
                                ? null
                                : () => _handleUpgradeToPremium(context),
                            child: _isProcessingPayment
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Upgrade'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildFeatureItem(context, Icons.check_circle, 'Unlimited properties'),
                      _buildFeatureItem(context, Icons.check_circle, 'Unlimited rooms'),
                      _buildFeatureItem(context, Icons.check_circle, 'Advanced analytics'),
                      _buildFeatureItem(context, Icons.check_circle, 'Priority support'),
                      _buildFeatureItem(context, Icons.check_circle, 'Export reports'),
                      _buildFeatureItem(context, Icons.check_circle, 'Custom branding'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Enterprise Plan
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Enterprise Plan',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Custom pricing',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Contact us for enterprise pricing!')),
                              );
                            },
                            child: const Text('Contact Sales'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildFeatureItem(context, Icons.check_circle, 'Everything in Premium'),
                      _buildFeatureItem(context, Icons.check_circle, 'Dedicated account manager'),
                      _buildFeatureItem(context, Icons.check_circle, 'API access'),
                      _buildFeatureItem(context, Icons.check_circle, 'Custom integrations'),
                      _buildFeatureItem(context, Icons.check_circle, 'SLA guarantee'),
                      _buildFeatureItem(context, Icons.check_circle, 'Training & onboarding'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Billing Information
              Text(
                'Billing Information',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.payment),
                  title: const Text('Payment Methods'),
                  subtitle: const Text('No payment methods added'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment methods coming soon!')),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt),
                  title: const Text('Billing History'),
                  subtitle: const Text('View past invoices'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Billing history coming soon!')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleUpgradeToPremium(BuildContext context) async {
    final auth = context.read<AuthService>();
    final user = auth.user;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to upgrade')),
      );
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // Generate unique order reference
      const uuid = Uuid();
      final orderReference = 'premium-${uuid.v4()}';
      
      // Create callback URL - using custom app scheme
      // Pesapal will redirect here after payment
      final callbackUrl = 'myapp://payment-callback';
      
      // Create notification ID (you can register this in Pesapal dashboard)
      // For now using a placeholder
      final notificationId = 'notification-${uuid.v4()}';

      // Create payment order
      final redirectUrl = await _pesapalService.createPaymentOrder(
        amount: 50000.0, // TZS 50,000
        currency: 'TZS',
        description: 'Premium Plan Subscription - Monthly',
        callbackUrl: callbackUrl,
        notificationId: notificationId,
        reference: orderReference,
        customerEmail: user.email,
        customerFirstName: user.displayName?.split(' ').first ?? '',
        customerLastName: (user.displayName?.split(' ') ?? []).length > 1 
            ? user.displayName!.split(' ').last 
            : '',
        billingAddress: {
          'country_code': 'TZ',
        },
      );

      setState(() {
        _isProcessingPayment = false;
      });

      // Show payment webview
      if (context.mounted) {
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (context) => PaymentWebViewScreen(
              paymentUrl: redirectUrl,
              callbackUrl: callbackUrl,
              onPaymentSuccess: (orderTrackingId) async {
                await _handlePaymentSuccess(context, orderReference, orderTrackingId);
              },
              onPaymentError: (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error ?? 'Payment failed'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ),
        );

        // If payment was successful, result will be true
        if (result == true && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment successful! Your subscription has been upgraded.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isProcessingPayment = false;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handlePaymentSuccess(
    BuildContext context,
    String orderReference,
    String orderTrackingId,
  ) async {
    try {
      final auth = context.read<AuthService>();
      final user = auth.user;
      
      if (user == null) return;

      // Verify payment status with Pesapal
      final statusData = await _pesapalService.getTransactionStatus(orderTrackingId);
      final paymentStatus = statusData['payment_status_description'] as String?;

      if (paymentStatus == 'COMPLETED' || paymentStatus == 'Success') {
        // Update user's subscription in Firestore
        await FirebaseFirestore.instance
            .collection('landlords')
            .doc(user.uid)
            .set({
          'planType': 'Premium',
          'subscriptionStatus': 'active',
          'subscriptionStartDate': FieldValue.serverTimestamp(),
          'subscriptionEndDate': Timestamp.fromDate(
            DateTime.now().add(const Duration(days: 30)),
          ),
          'lastPayment': {
            'orderReference': orderReference,
            'orderTrackingId': orderTrackingId,
            'amount': 50000.0,
            'currency': 'TZS',
            'date': FieldValue.serverTimestamp(),
          },
        }, SetOptions(merge: true));

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription upgraded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment status: $paymentStatus'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating subscription: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

