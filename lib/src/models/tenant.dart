import 'package:flutter/material.dart';

class Tenant {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? jobTitle;
  final String? photoUrl;
  final double monthlyRent;
  final DateTime startDate;
  final List<Payment> payments;
  final DateTime createdAt;

  Tenant({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.jobTitle,
    this.photoUrl,
    required this.monthlyRent,
    required this.startDate,
    List<Payment>? payments,
    DateTime? createdAt,
  }) : payments = payments ?? [],
        createdAt = createdAt ?? DateTime.now();

  String get fullName => '$firstName $lastName';

  // Calculate total amount paid
  double get totalPaid => payments.fold(0.0, (sum, payment) => sum + payment.amount);

  // Calculate how many months of rent have been paid
  int get monthsPaidCount => (totalPaid / monthlyRent).floor();
  
  // Calculate the coverage date - up to which date the payments cover
  // Example: Start June 25, paid 3 months → coverage is June 25 to September 25
  DateTime get coverageUntilDate {
    return DateTime(
      startDate.year,
      startDate.month + monthsPaidCount,
      startDate.day,
    );
  }
  
  // Calculate next due date - when will the tenant become overdue next
  DateTime get nextDueDate {
    final now = DateTime.now();
    final coverageUntil = coverageUntilDate;
    
    // If we're still within the coverage period, next due is when coverage ends
    if (now.isBefore(coverageUntil)) {
      return coverageUntil;
    }
    
    // If coverage has ended, calculate the next billing cycle
    // Example: Coverage ended Sept 25, today Oct 26
    // Next billing cycle should be Oct 25 (same day each month)
    int monthsBeyondCoverage = (now.year - coverageUntil.year) * 12 + 
                               (now.month - coverageUntil.month);
    
    // Add one month because we're calculating when the NEXT payment is due
    monthsBeyondCoverage += 1;
    
    return DateTime(
      coverageUntil.year,
      coverageUntil.month + monthsBeyondCoverage,
      startDate.day,
    );
  }

  // Calculate expected rent based on how many months have passed since start date
  // This calculates what the tenant SHOULD have paid based on the start date
  // regardless of whether they actually paid or not
  // Key rule: Any part of a month counts as a full month
  double get expectedRent {
    final now = DateTime.now();
    
    // If start date is in the future, no rent expected
    if (now.isBefore(startDate)) {
      return 0;
    }
    
    // Calculate how many months have passed since the start date
    int monthsDiff = (now.year - startDate.year) * 12 + (now.month - startDate.month);
    
    // CRITICAL: If today is ANY day on or after the start date day, count that month
    // Example: Start Aug 6, today Oct 7
    // - Aug 6: First month starts
    // - Sep 6: Second month starts  
    // - Oct 6: Third month starts
    // - Oct 7+: Third month is owed (counted even though only 1 day has passed)
    if (now.day >= startDate.day) {
      monthsDiff += 1;
    }
    
    // Expected rent is the number of months since start date
    // Example: Start Aug 6, today Oct 7
    // - monthsDiff = (Oct - Aug) = 2
    // - Since now.day (7) >= startDate.day (6), add 1
    // - Total months = 2 + 1 = 3 months due
    return monthlyRent * monthsDiff;
  }

  // Calculate balance (expected - paid)
  double get balance {
    final expected = expectedRent;
    final paid = totalPaid;
    return expected - paid;
  }

  // Check if payment is overdue
  // Tenant is overdue if expected rent exceeds what they've paid
  bool get isOverdue {
    // If expected rent is greater than what they've paid, they're overdue
    return balance > 0;
  }

  // Get payment status with detailed message
  // Shows grey badge when no payment made yet
  String get paymentStatus {
    // If no payments made yet, show grey badge
    if (totalPaid == 0) {
      return 'Add payment'; // Will show in grey badge
    }
    
    // Calculate months overdue (any part of month counts as full month)
    if (isOverdue) {
      final monthsOverdue = (balance / monthlyRent).ceil(); // Use ceil() to count partial months as full
      if (monthsOverdue == 1) {
        return 'Overdue (1 month)';
      } else {
        return 'Overdue ($monthsOverdue months)';
      }
    } else {
      return 'Payment on track';
    }
  }

  // Calculate how many months of rent have been covered by payments
  int get _monthsPaid {
    return (totalPaid / monthlyRent).floor();
  }

  // Add a new payment
  Tenant addPayment(Payment payment) {
    return Tenant(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      jobTitle: jobTitle,
      photoUrl: photoUrl,
      monthlyRent: monthlyRent,
      startDate: startDate,
      payments: [...payments, payment],
      createdAt: createdAt,
    );
  }

  // Update tenant information
  Tenant updateInfo({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? jobTitle,
    String? photoUrl,
    double? monthlyRent,
    DateTime? startDate,
  }) {
    return Tenant(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      jobTitle: jobTitle ?? this.jobTitle,
      photoUrl: photoUrl ?? this.photoUrl,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      startDate: startDate ?? this.startDate,
      payments: payments,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'jobTitle': jobTitle,
      'photoUrl': photoUrl,
      'monthlyRent': monthlyRent,
      'startDate': startDate.toIso8601String(),
      'payments': payments.map((p) => p.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      jobTitle: json['jobTitle'],
      photoUrl: json['photoUrl'],
      monthlyRent: json['monthlyRent'].toDouble(),
      startDate: DateTime.parse(json['startDate']),
      payments: (json['payments'] as List?)
          ?.map((p) => Payment.fromJson(p))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Payment {
  final String id;
  final double amount;
  final DateTime date;
  final String? notes;
  final String? receiptPath; // Path to saved receipt file

  Payment({
    required this.id,
    required this.amount,
    required this.date,
    this.notes,
    this.receiptPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
      'receiptPath': receiptPath,
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      receiptPath: json['receiptPath'],
    );
  }
}

