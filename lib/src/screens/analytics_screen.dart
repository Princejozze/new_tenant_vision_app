import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/services/house_service.dart';
import 'package:myapp/src/models/tenant.dart';
import 'package:myapp/src/widgets/simple_chart.dart';
import 'package:myapp/src/widgets/grouped_bar_chart.dart';
import 'package:myapp/src/widgets/pie_chart.dart';
import 'package:myapp/src/services/expense_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _yearly = false; // false = monthly, true = yearly

  @override
  Widget build(BuildContext context) {
    return Consumer<HouseService>(
      builder: (context, houseService, _) {
        try {
          final houses = houseService.houses;
          final monthlyNet = _computeMonthlyNetProfit(houses, months: 12);
          final yearlyNet = _computeYearlyNetProfit(houses, years: 3);
          final currency = NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0);

          // Expense Category Breakdown (last 12 months)
          final now = DateTime.now();
          final start = DateTime(now.year, now.month - 11, 1);
          Map<String, double> categorySums = {};
          try {
            final expenseService = context.watch<ExpenseService>();
            categorySums = expenseService.sumByCategory(start: start, end: now);
          } catch (e) {
            print('Error accessing ExpenseService: $e');
            categorySums = {};
          }

        final totalIncomeLast12 = _sum(monthlyNet.map((e) => e.income).toList());
        final totalExpensesLast12 = _sum(monthlyNet.map((e) => e.expenses).toList());
        final totalNetLast12 = totalIncomeLast12 - totalExpensesLast12;

        final chartData = _yearly
            ? yearlyNet.map((e) => e.net.toDouble()).toList()
            : monthlyNet.map((e) => e.net.toDouble()).toList();

        // Average monthly rent calculations
        final avgOverall = _computeAverageRentOverall(houses);
        final avgByProperty = _computeAverageRentByProperty(houses);

        final chartTitle = _yearly
            ? 'Net Profit (Last ${yearlyNet.length} Years)'
            : 'Net Profit (Last 12 Months)';

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Analytics'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Toggle
                Row(
                  children: [
                    FilterChip(
                      label: const Text('Monthly'),
                      selected: !_yearly,
                      onSelected: (_) => setState(() => _yearly = false),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Yearly'),
                      selected: _yearly,
                      onSelected: (_) => setState(() => _yearly = true),
                    ),
                    const Spacer(),
                    const Tooltip(
                      message: 'Expenses tracking not configured yet. Net Profit = Income for now.',
                      child: Icon(Icons.info_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Rent Averages (overall & per property)
                _rentAverages(context, avgOverall, avgByProperty),
                const SizedBox(height: 16),

                // Summary cards
                Row(
                  children: [
                    Expanded(child: _metricCard(context, 'Total Income (12m)', currency.format(totalIncomeLast12), Icons.trending_up, Colors.green)),
                    const SizedBox(width: 12),
                    Expanded(child: _metricCard(context, 'Total Expenses (12m)', currency.format(totalExpensesLast12), Icons.trending_down, Colors.red)),
                    const SizedBox(width: 12),
                    Expanded(child: _metricCard(context, 'Net Profit (12m)', currency.format(totalNetLast12), Icons.show_chart, Colors.blue)),
                  ],
                ),
                const SizedBox(height: 16),

                // Net Profit chart
                SimpleChart(
                  title: chartTitle,
                  data: chartData,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(height: 24),

                // Income vs Expenses (Monthly)
                if (!_yearly)
                  GroupedBarChart(
                    title: 'Income vs Expenses (Monthly)',
                    seriesA: monthlyNet.map((e) => e.income).toList(),
                    seriesB: monthlyNet.map((e) => e.expenses).toList(),
                    colorA: Colors.green,
                    colorB: Colors.red,
                    labels: monthlyNet.map((e) => e.label).toList(),
                  ),

                // Income vs Expenses (Yearly)
                if (_yearly)
                  GroupedBarChart(
                    title: 'Income vs Expenses (Yearly)',
                    seriesA: yearlyNet.map((e) => e.income).toList(),
                    seriesB: yearlyNet.map((e) => e.expenses).toList(),
                    colorA: Colors.green,
                    colorB: Colors.red,
                    labels: yearlyNet.map((e) => e.year.toString()).toList(),
                  ),

                const SizedBox(height: 24),

                // Expense Category Breakdown (Pie)
                PieChartWidget(
                  title: 'Expense Category Breakdown (Last 12 Months)',
                  data: categorySums,
                ),

                const SizedBox(height: 24),

                // Tabular (monthly) breakdown
                if (!_yearly) _monthlyTable(context, monthlyNet),
                if (_yearly) _yearlyTable(context, yearlyNet),
              ],
            ),
          ),
        );
        } catch (e, stackTrace) {
          print('Error in AnalyticsScreen: $e');
          print('Stack trace: $stackTrace');
          return Scaffold(
            appBar: AppBar(
              title: const Text('Analytics'),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading analytics',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      e.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _metricCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  // Compute monthly net profit for last [months] months
  List<_MonthlyNet> _computeMonthlyNetProfit(List houses, {int months = 12}) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - (months - 1), 1);
    final Map<String, _MonthlyNet> map = {};
    final monthFmt = DateFormat('MMM yy');

    // initialize months
    for (int i = 0; i < months; i++) {
      final dt = DateTime(start.year, start.month + i, 1);
      final key = monthFmt.format(dt);
      map[key] = _MonthlyNet(label: key, income: 0, expenses: 0);
    }

    // income from tenant payments
    for (final house in houses) {
      for (final room in house.rooms) {
        final Tenant? t = room.tenant;
        if (t == null) continue;
        for (final Payment p in t.payments) {
          if (p.date.isBefore(start) || p.date.isAfter(now)) continue;
          final key = monthFmt.format(DateTime(p.date.year, p.date.month, 1));
          map[key] = map[key]!.copyWith(income: map[key]!.income + p.amount);
        }
      }
    }

    // expenses: not tracked yet, keep 0

    return map.values.map((e) => e.withNet()).toList();
  }

  List<_YearlyNet> _computeYearlyNetProfit(List houses, {int years = 3}) {
    final now = DateTime.now();
    final startYear = now.year - (years - 1);
    final Map<int, _YearlyNet> map = { for (int y = startYear; y <= now.year; y++) y: _YearlyNet(year: y, income: 0, expenses: 0) };

    for (final house in houses) {
      for (final room in house.rooms) {
        final Tenant? t = room.tenant;
        if (t == null) continue;
        for (final Payment p in t.payments) {
          if (p.date.year < startYear || p.date.year > now.year) continue;
          final y = p.date.year;
          final cur = map[y]!;
          map[y] = cur.copyWith(income: cur.income + p.amount);
        }
      }
    }

    return map.values.map((e) => e.withNet()).toList();
  }

  double _sum(List<double> values) => values.fold(0.0, (a, b) => a + b);

  Widget _monthlyTable(BuildContext context, List<_MonthlyNet> items) {
    final currency = NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly Breakdown', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            DataTable(columns: const [
              DataColumn(label: Text('Month')),
              DataColumn(label: Text('Income')),
              DataColumn(label: Text('Expenses')),
              DataColumn(label: Text('Net Profit')),
            ], rows: [
              for (final m in items)
                DataRow(cells: [
                  DataCell(Text(m.label)),
                  DataCell(Text(currency.format(m.income))),
                  DataCell(Text(currency.format(m.expenses))),
                  DataCell(Text(currency.format(m.net))),
                ])
            ]),
          ],
        ),
      ),
    );
  }

  Widget _yearlyTable(BuildContext context, List<_YearlyNet> items) {
    final currency = NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Yearly Breakdown', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            DataTable(columns: const [
              DataColumn(label: Text('Year')),
              DataColumn(label: Text('Income')),
              DataColumn(label: Text('Expenses')),
              DataColumn(label: Text('Net Profit')),
            ], rows: [
              for (final y in items)
                DataRow(cells: [
                  DataCell(Text(y.year.toString())),
                  DataCell(Text(currency.format(y.income))),
                  DataCell(Text(currency.format(y.expenses))),
                  DataCell(Text(currency.format(y.net))),
                ])
            ]),
          ],
        ),
      ),
    );
  }

  Widget _rentAverages(BuildContext context, double overall, Map<String, double> byProperty) {
    final currency = NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Average Monthly Rent', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _metricChip(context, 'Overall', currency.format(overall), Icons.payments, Colors.indigo),
                for (final entry in byProperty.entries)
                  _metricChip(context, entry.key, currency.format(entry.value), Icons.home_work, Colors.teal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricChip(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  double _computeAverageRentOverall(List houses) {
    double sum = 0;
    int count = 0;
    for (final h in houses) {
      for (final r in h.rooms) {
        if (r.status.toString().contains('occupied') && r.rentAmount > 0) {
          sum += r.rentAmount;
          count++;
        }
      }
    }
    return count == 0 ? 0 : sum / count;
  }

  Map<String, double> _computeAverageRentByProperty(List houses) {
    final mapSum = <String, double>{};
    final mapCount = <String, int>{};
    for (final h in houses) {
      for (final r in h.rooms) {
        if (r.status.toString().contains('occupied') && r.rentAmount > 0) {
          mapSum[h.name] = (mapSum[h.name] ?? 0) + r.rentAmount;
          mapCount[h.name] = (mapCount[h.name] ?? 0) + 1;
        }
      }
    }
    final result = <String, double>{};
    for (final name in mapSum.keys) {
      final c = mapCount[name] ?? 1;
      result[name] = mapSum[name]! / c;
    }
    return result;
  }
}

class _MonthlyNet {
  final String label;
  final double income;
  final double expenses;
  final double net;
  _MonthlyNet({required this.label, required this.income, required this.expenses}) : net = income - expenses;
  _MonthlyNet copyWith({double? income, double? expenses}) => _MonthlyNet(label: label, income: income ?? this.income, expenses: expenses ?? this.expenses);
  _MonthlyNet withNet() => _MonthlyNet(label: label, income: income, expenses: expenses);
}

class _YearlyNet {
  final int year;
  final double income;
  final double expenses;
  final double net;
  _YearlyNet({required this.year, required this.income, required this.expenses}) : net = income - expenses;
  _YearlyNet copyWith({double? income, double? expenses}) => _YearlyNet(year: year, income: income ?? this.income, expenses: expenses ?? this.expenses);
  _YearlyNet withNet() => _YearlyNet(year: year, income: income, expenses: expenses);
}
