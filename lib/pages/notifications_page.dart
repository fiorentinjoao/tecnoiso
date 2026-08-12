import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/tap_scale.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                children: [
                  _buildNotificationItem(
                    'Calibração Atrasada',
                    'O Micrômetro Digital 0-25mm da Heineken está com calibração atrasada há 27 dias.',
                    'Hoje, 09:15',
                    const Color(0xFFDC2626),
                    Icons.warning_amber_rounded,
                    0,
                  ),
                  _buildNotificationItem(
                    'Calibração Urgente',
                    'O Manômetro Digital da Portos do Paraná precisa ser calibrado até 01/07.',
                    'Hoje, 08:30',
                    const Color(0xFFF59E0B),
                    Icons.schedule_rounded,
                    1,
                  ),
                  _buildNotificationItem(
                    'Calibração Concluída',
                    'Dinamômetro Digital 500N da Heineken calibrado com sucesso. Certificado #CAL-2026-0847.',
                    'Ontem, 16:42',
                    const Color(0xFF22C55E),
                    Icons.check_circle_rounded,
                    2,
                  ),
                  _buildNotificationItem(
                    'Novo Equipamento',
                    'Calibrador de Pressão Druck DPI 104 cadastrado para Porto Itapoa.',
                    '10/Jul, 14:20',
                    const Color(0xFF3B82F6),
                    Icons.add_circle_outline,
                    3,
                  ),
                  _buildNotificationItem(
                    'Relatório Gerado',
                    'Relatório mensal de calibrações de junho/2026 disponível para download.',
                    '01/Jul, 10:00',
                    Colors.white38,
                    Icons.picture_as_pdf,
                    4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            Text(
              'Notificações',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String body, String time, Color color, IconData icon, int index) {
    return FadeSlideIn(
      delay: Duration(milliseconds: 100 + index * 80),
      child: TapScale(
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF18181B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      body,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white38,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
