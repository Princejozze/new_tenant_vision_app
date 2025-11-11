import 'package:flutter/material.dart';

class PieChartWidget extends StatelessWidget {
  final String title;
  final Map<String, double> data; // category -> sum
  final List<Color>? colors;

  const PieChartWidget({super.key, required this.title, required this.data, this.colors});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text('No expenses recorded', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    final colorList = colors ?? [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
    ];

    final total = data.values.fold<double>(0, (a, b) => a + b);
    final entries = data.entries.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: CustomPaint(
                painter: _PiePainter(entries: entries, colors: colorList),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                for (int i = 0; i < entries.length; i++)
                  _Legend(
                    color: colorList[i % colorList.length],
                    label: '${entries[i].key} (${((entries[i].value / total) * 100).toStringAsFixed(1)}%)',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<MapEntry<String, double>> entries;
  final List<Color> colors;

  _PiePainter({required this.entries, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..style = PaintingStyle.fill;

    final total = entries.fold<double>(0, (a, b) => a + b.value);
    double startAngle = -90 * (3.14159 / 180); // start at top

    for (int i = 0; i < entries.length; i++) {
      final sweepAngle = ((entries[i].value / total) * 360) * (3.14159 / 180);
      paint.color = colors[i % colors.length];
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }

    // Draw inner circle for donut style
    final holePaint = Paint()..color = Colors.white;
    final holeRadius = size.width * 0.25;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), holeRadius, holePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
