import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/tap_scale.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildSearchBar(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            children: [
              _buildClientCard('Heineken', '3.654.xxx/0001-xx', '12', '4', 'assets/client_heineken.png', 0),
              _buildClientCard('Coca-Cola', '3.654.xxx/0002-xx', '8', '2', 'assets/client_coca_cola.webp', 1),
              _buildClientCard('Docol', '3.654.xxx/0003-xx', '6', '1', 'assets/client_docol.png', 2),
              _buildClientCard('Portos do Paraná', '3.654.xxx/0004-xx', '15', '3', 'assets/client_portos_parana.png', 3),
              _buildClientCard('Descarpack', '3.654.xxx/0005-xx', '5', '2', 'assets/client_descarpack.webp', 4),
              _buildClientCard('Porto Itapoa', '3.654.xxx/0006-xx', '9', '1', 'assets/client_porto_itapoa.png', 5),
            ],
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
              'Clientes',
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

  Widget _buildSearchBar() {
    return FadeSlideIn(
      delay: const Duration(milliseconds: 100),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF18181B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.white24, size: 18),
              const SizedBox(width: 12),
              Text(
                'Buscar cliente...',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClientCard(String name, String cnpj, String equipments, String appointments, String logoPath, int index) {
    return FadeSlideIn(
      delay: Duration(milliseconds: 150 + index * 80),
      child: TapScale(
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF18181B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      logoPath,
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              name[0],
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cnpj,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.06),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('EQUIP.', equipments, Icons.inventory_2_outlined),
                  _buildDivider(),
                  _buildStatItem('AGEND.', appointments, Icons.calendar_today_outlined),
                  _buildDivider(),
                  _buildStatItem('PRÓX.', '15/Jul', Icons.event_outlined),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFDC2626), size: 18),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFDC2626),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: Colors.white24,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.06),
    );
  }
}
