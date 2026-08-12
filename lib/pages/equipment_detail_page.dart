import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../data/equipment_repository.dart';
import '../models/equipment.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/tap_scale.dart';
import 'equipment_form_page.dart';

class EquipmentDetailPage extends StatefulWidget {
  final Equipment equipment;

  const EquipmentDetailPage({super.key, required this.equipment});

  @override
  State<EquipmentDetailPage> createState() => _EquipmentDetailPageState();
}

class _EquipmentDetailPageState extends State<EquipmentDetailPage> {
  Color _statusColorFor(Equipment equipment) {
    switch (equipment.status) {
      case 'Atrasado':
        return const Color(0xFFDC2626);
      case 'Urgente':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF22C55E);
    }
  }

  void _openEdit(Equipment equipment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EquipmentFormPage(equipment: equipment),
      ),
    );
  }

  Future<void> _confirmDelete(Equipment equipment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF18181B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Excluir equipamento?',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Esta ação não pode ser desfeita.',
          style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Cancelar', style: GoogleFonts.inter(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Excluir',
              style: GoogleFonts.inter(color: const Color(0xFFDC2626), fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final navigator = Navigator.of(context);
    await EquipmentRepository.instance.delete(equipment.id);
    if (!mounted) return;
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Equipment>>(
      valueListenable: EquipmentRepository.instance.listenable(),
      builder: (context, box, _) {
        final current = EquipmentRepository.instance.getById(widget.equipment.id);
        if (current == null) {
          // The record was deleted (from this screen or elsewhere) — pop
          // back rather than render a broken screen with stale data.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.of(context).maybePop();
          });
          return const Scaffold(
            backgroundColor: Color(0xFF09090B),
            body: SizedBox.shrink(),
          );
        }
        return Scaffold(
          backgroundColor: const Color(0xFF09090B),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context, current)),
                SliverToBoxAdapter(child: _buildStatusBanner(current)),
                SliverToBoxAdapter(child: _buildInfoCard(current)),
                SliverToBoxAdapter(child: _buildTimeline(current)),
                SliverToBoxAdapter(child: _buildScheduleButton()),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Equipment equipment) {
    return FadeSlideIn(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Row(
          children: [
            TapScale(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF18181B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white54, size: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Detalhes',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            TapScale(
              onTap: () => _openEdit(equipment),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF18181B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: const Icon(Icons.edit_outlined, color: Colors.white54, size: 16),
              ),
            ),
            const SizedBox(width: 8),
            TapScale(
              onTap: () => _confirmDelete(equipment),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF18181B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: const Icon(Icons.delete_outline, color: Color(0xFFDC2626), size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(Equipment equipment) {
    final statusColor = _statusColorFor(equipment);
    return FadeSlideIn(
      delay: const Duration(milliseconds: 100),
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                equipment.isOverdue
                    ? Icons.warning_amber_rounded
                    : equipment.isUrgent
                        ? Icons.schedule_rounded
                        : Icons.check_circle_rounded,
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    equipment.status,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    equipment.isOverdue
                        ? 'Atrasado ${-equipment.daysUntilCalibration} dias'
                        : 'Calibra em ${equipment.daysUntilCalibration} dias',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Equipment equipment) {
    return FadeSlideIn(
      delay: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF18181B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'INFORMAÇÕES',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: Colors.white24,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Equipamento', equipment.name),
            _buildInfoRow('Cliente', equipment.client),
            _buildInfoRow('Tipo', equipment.type),
            _buildInfoRow('Marca', equipment.brand),
            _buildInfoRow('Modelo', equipment.model),
            _buildInfoRow('Nº Série', equipment.serialNumber),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white38,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(Equipment equipment) {
    final statusColor = _statusColorFor(equipment);
    return FadeSlideIn(
      delay: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF18181B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HISTÓRICO DE CALIBRAÇÃO',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: Colors.white24,
              ),
            ),
            const SizedBox(height: 20),
            _buildTimelineItem(
              'Próxima calibração',
              '${equipment.nextCalibration.day.toString().padLeft(2, '0')}/${equipment.nextCalibration.month.toString().padLeft(2, '0')}/${equipment.nextCalibration.year}',
              statusColor,
              false,
            ),
            _buildTimelineItem(
              'Última calibração',
              '${equipment.lastCalibration.day.toString().padLeft(2, '0')}/${equipment.lastCalibration.month.toString().padLeft(2, '0')}/${equipment.lastCalibration.year}',
              const Color(0xFF22C55E),
              true,
            ),
            _buildTimelineItem(
              'Calibração anterior',
              '${equipment.lastCalibration.year - 1}/${equipment.lastCalibration.month.toString().padLeft(2, '0')}',
              Colors.white24,
              true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String title, String date, Color color, bool isPast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: isPast
                      ? []
                      : [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isPast ? Colors.white38 : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleButton() {
    return FadeSlideIn(
      delay: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: TapScale(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Agendar Calibração',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
