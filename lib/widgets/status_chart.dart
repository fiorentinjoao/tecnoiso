import 'package:flutter/material.dart';

class StatusChart extends StatelessWidget {
  final int total;
  final int ok;
  final int urgent;
  final int overdue;

  const StatusChart({
    super.key,
    required this.total,
    required this.ok,
    required this.urgent,
    required this.overdue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBar('Total', total, Colors.white, 1.0),
        _buildBar('Em dia', ok, const Color(0xFF22C55E), ok / (total == 0 ? 1 : total)),
        _buildBar('Urgente', urgent, const Color(0xFFF59E0B), urgent / (total == 0 ? 1 : total)),
        _buildBar('Atrasado', overdue, const Color(0xFFDC2626), overdue / (total == 0 ? 1 : total)),
      ],
    );
  }

  Widget _buildBar(String label, int value, Color color, double ratio) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: ratio),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return Container(
              width: 32,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 32,
                  height: 80 * value,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Colors.white24,
          ),
        ),
      ],
    );
  }
}
