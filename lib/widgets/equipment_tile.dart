import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/equipment.dart';

class EquipmentTile extends StatelessWidget {
  final Equipment equipment;
  final VoidCallback? onTap;

  const EquipmentTile({super.key, required this.equipment, this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = equipment.isOverdue
        ? const Color(0xFFDC2626)
        : equipment.isUrgent
            ? const Color(0xFFF59E0B)
            : const Color(0xFF22C55E);

    final statusText = equipment.isOverdue
        ? 'ATRASADO'
        : equipment.isUrgent
            ? 'URGENTE'
            : 'EM DIA';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF18181B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  _getIconForType(equipment.type),
                  color: statusColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    equipment.name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        equipment.client,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white38,
                        ),
                      ),
                      Text(
                        '  •  ',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white12,
                        ),
                      ),
                      Text(
                        equipment.brand,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  equipment.isOverdue
                      ? '${equipment.daysUntilCalibration.abs()}d atraso'
                      : _formatDate(equipment.nextCalibration),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'medição dimensional':
        return Icons.straighten;
      case 'temperatura':
        return Icons.thermostat;
      case 'massa':
        return Icons.monitor_weight_outlined;
      case 'pressão':
        return Icons.speed;
      case 'força':
        return Icons.fitness_center;
      case 'umidade':
        return Icons.water_drop_outlined;
      default:
        return Icons.precision_manufacturing;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return '${date.day} ${months[date.month - 1]}';
  }
}
