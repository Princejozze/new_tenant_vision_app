import 'package:flutter/material.dart';

class SimpleChart extends StatelessWidget {
  final List<double> data;
  final String title;
  final Color color;

  const SimpleChart({
    super.key,
    required this.data,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No data available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: CustomPaint(
                painter: ChartPainter(
                  data: data,
                  color: color,
                  maxValue: maxValue,
                  minValue: minValue,
                  range: range,
                ),
                size: const Size(double.infinity, 100),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Min: ${minValue.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Max: ${maxValue.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double maxValue;
  final double minValue;
  final double range;

  ChartPainter({
    required this.data,
    required this.color,
    required this.maxValue,
    required this.minValue,
    required this.range,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (data.length - 1);
    final stepY = size.height;

    // Start the path
    path.moveTo(0, _getY(0, stepY));
    fillPath.moveTo(0, _getY(0, stepY));

    // Draw the line
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = _getY(i, stepY);
      
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Complete the fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    // Draw fill first
    canvas.drawPath(fillPath, fillPaint);
    
    // Draw line on top
    canvas.drawPath(path, paint);

    // Draw data points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = _getY(i, stepY);
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  double _getY(int index, double stepY) {
    if (range == 0) return stepY / 2;
    final normalizedValue = (data[index] - minValue) / range;
    return stepY - (normalizedValue * stepY);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

