import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tenant.dart';
import '../models/room.dart';
import '../services/receipt_service.dart';

class PaymentRowWidget extends StatefulWidget {
  final Payment payment;
  final Tenant tenant;
  final Room room;
  final String propertyName;

  const PaymentRowWidget({
    super.key,
    required this.payment,
    required this.tenant,
    required this.room,
    required this.propertyName,
  });

  @override
  State<PaymentRowWidget> createState() => _PaymentRowWidgetState();
}

class _PaymentRowWidgetState extends State<PaymentRowWidget> {
  bool _isDownloading = false;

  Future<void> _downloadReceipt() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final success = await ReceiptService.downloadReceipt(
        payment: widget.payment,
        tenant: widget.tenant,
        room: widget.room,
        propertyName: widget.propertyName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                ? 'Receipt downloaded successfully!' 
                : 'Failed to download receipt. Please try again.',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading receipt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Payment info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy').format(widget.payment.date),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0)
                          .format(widget.payment.amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                if (widget.payment.notes != null && widget.payment.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.payment.notes!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.receipt,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Receipt: ${widget.payment.id}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Download button
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isDownloading ? null : _downloadReceipt,
            icon: _isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            tooltip: 'Download Receipt',
            color: Colors.blue,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}
