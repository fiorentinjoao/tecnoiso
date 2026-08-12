import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/tap_scale.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildCalendar(),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Text(
            'AGENDAMENTOS',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: Colors.white24,
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xFFDC2626),
            backgroundColor: const Color(0xFF18181B),
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 1500));
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              children: [
                _buildScheduleItem('Heineken', 'Micrômetro Digital', '09:00', 'Hoje', const Color(0xFFDC2626), 0),
                _buildScheduleItem('Coca-Cola', 'Termômetro IR', '14:00', 'Hoje', const Color(0xFFF59E0B), 1),
                _buildScheduleItem('Docol', 'Balança Analítica', '10:00', 'Amanhã', const Color(0xFF3B82F6), 2),
                _buildScheduleItem('Portos do Paraná', 'Manômetro Digital', '08:30', 'Seg', const Color(0xFF3B82F6), 3),
                _buildScheduleItem('Descarpack', 'Trena Metálica', '11:00', 'Seg', const Color(0xFF3B82F6), 4),
                _buildScheduleItem('Heineken', 'Dinamômetro', '15:00', 'Ter', const Color(0xFF22C55E), 5),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return FadeSlideIn(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Row(
          children: [
            TapScale(
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
            const SizedBox(width: 16),
            Text(
              'Agenda',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return FadeSlideIn(
      delay: const Duration(milliseconds: 100),
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF18181B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Julho 2026',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                Row(
                  children: [
                    TapScale(
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.chevron_left, color: Colors.white38, size: 18),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TapScale(
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDayColumn('SEG', '07', false),
                _buildDayColumn('TER', '08', false),
                _buildDayColumn('QUA', '09', false),
                _buildDayColumn('QUI', '10', false),
                _buildDayColumn('SEX', '11', false),
                _buildDayColumn('SÁB', '12', true),
                _buildDayColumn('DOM', '13', false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayColumn(String day, String number, bool isSelected) {
    return Column(
      children: [
        Text(
          day,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFFDC2626) : Colors.white24,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TapScale(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFDC2626) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : Colors.white38,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleItem(String client, String equipment, String time, String day, Color color, int index) {
    return FadeSlideIn(
      delay: Duration(milliseconds: 200 + index * 80),
      child: TapScale(
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF18181B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipment,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      client,
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white38),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      time,
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: color),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    day,
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.white24),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
