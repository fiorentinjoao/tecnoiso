import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/auth_repository.dart';
import '../models/equipment.dart';
import '../widgets/stat_card.dart';
import '../widgets/equipment_tile.dart';
import '../widgets/section_header.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/tap_scale.dart';
import '../widgets/status_chart.dart';
import 'equipment_list_page.dart';
import 'schedule_page.dart';
import 'clients_page.dart';
import 'notifications_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late List<Equipment> _equipments;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _equipments = _getMockEquipments();
  }

  @override
  Widget build(BuildContext context) {
    final overdue = _equipments.where((e) => e.isOverdue).length;
    final urgent = _equipments.where((e) => e.isUrgent).length;
    final ok = _equipments.where((e) => !e.isOverdue && !e.isUrgent).length;

    final pages = [
      _buildDashboard(overdue, urgent, ok),
      const EquipmentListPage(),
      const SchedulePage(),
      const ClientsPage(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF09090B),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset('assets/logo.png', width: 48, height: 48, fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TECNOISO',
                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.white),
                        ),
                        Text(
                          'Gestão de Equipamentos',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.06),
            ),
            const SizedBox(height: 8),
            _buildDrawerItem(Icons.dashboard_outlined, 'Dashboard', 0),
            _buildDrawerItem(Icons.inventory_2_outlined, 'Equipamentos', 1),
            _buildDrawerItem(Icons.calendar_today_outlined, 'Agenda', 2),
            _buildDrawerItem(Icons.business_outlined, 'Clientes', 3),
            const SizedBox(height: 8),
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.06),
            ),
            const SizedBox(height: 8),
            _buildDrawerItem(Icons.settings_outlined, 'Configurações', -1),
            _buildDrawerItem(Icons.help_outline, 'Ajuda', -1),
            _buildDrawerItem(
              Icons.logout,
              'Sair',
              -1,
              onTap: () => _logout(context),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'v1.0.0 • PEX 2026',
                style: GoogleFonts.inter(fontSize: 11, color: Colors.white12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String label,
    int index, {
    VoidCallback? onTap,
  }) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFFDC2626) : Colors.white38,
        size: 22,
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? Colors.white : Colors.white54,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: () {
        Navigator.of(context).pop();
        if (onTap != null) {
          onTap();
        } else if (index >= 0) {
          setState(() => _selectedIndex = index);
        }
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    final navigator = Navigator.of(context);
    await AuthRepository.instance.logout();
    if (!mounted) return;
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Widget _buildDashboard(int overdue, int urgent, int ok) {
    return CustomScrollView(
      key: const ValueKey('dashboard'),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(
          child: FadeSlideIn(delay: const Duration(milliseconds: 100), child: _buildWelcomeBanner()),
        ),
        SliverToBoxAdapter(
          child: FadeSlideIn(delay: const Duration(milliseconds: 200), child: _buildStats(overdue, urgent, ok, _equipments.length)),
        ),
        SliverToBoxAdapter(
          child: FadeSlideIn(delay: const Duration(milliseconds: 250), child: _buildChart(overdue, urgent, ok)),
        ),
        SliverToBoxAdapter(
          child: FadeSlideIn(delay: const Duration(milliseconds: 300), child: _buildQuickActions()),
        ),
        SliverToBoxAdapter(
          child: FadeSlideIn(
            delay: const Duration(milliseconds: 400),
            child: SectionHeader(title: 'Requer Atenção', count: overdue, countLabel: 'itens', countColor: const Color(0xFFDC2626)),
          ),
        ),
        if (overdue > 0)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final eq = _equipments.where((e) => e.isOverdue).toList();
                return FadeSlideIn(
                  delay: Duration(milliseconds: 450 + index * 80),
                  child: EquipmentTile(equipment: eq[index], onTap: () {}),
                );
              },
              childCount: overdue,
            ),
          )
        else
          SliverToBoxAdapter(
            child: FadeSlideIn(
              delay: const Duration(milliseconds: 450),
              child: _buildEmptyState('Nenhum item atrasado', Icons.check_circle_outline, const Color(0xFF22C55E)),
            ),
          ),
        SliverToBoxAdapter(
          child: FadeSlideIn(
            delay: const Duration(milliseconds: 500),
            child: SectionHeader(title: 'Próximos 30 dias', count: urgent, countLabel: 'itens', countColor: const Color(0xFFF59E0B)),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final eq = _equipments.where((e) => e.isUrgent).toList();
              if (index >= eq.length) return null;
              return FadeSlideIn(
                delay: Duration(milliseconds: 550 + index * 80),
                child: EquipmentTile(equipment: eq[index], onTap: () {}),
              );
            },
            childCount: _equipments.where((e) => e.isUrgent).length,
          ),
        ),
        SliverToBoxAdapter(
          child: FadeSlideIn(
            delay: const Duration(milliseconds: 600),
            child: SectionHeader(title: 'Todos os Equipamentos', count: _equipments.length, countLabel: 'cadastrados'),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return FadeSlideIn(
                delay: Duration(milliseconds: 650 + index * 80),
                child: EquipmentTile(equipment: _equipments[index], onTap: () {}),
              );
            },
            childCount: _equipments.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildHeader() {
    return FadeSlideIn(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('assets/logo.png', width: 40, height: 40, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TECNOISO',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.white),
                    ),
                    Text(
                      'Gestão de Equipamentos',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white38, letterSpacing: 0.3),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                TapScale(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NotificationsPage()),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF18181B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.notifications_outlined, color: Colors.white54, size: 18),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFDC2626),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TapScale(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF18181B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: const Icon(Icons.help_outline_outlined, color: Colors.white54, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF18181B), Color(0xFF1C1917)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo de volta',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Você tem ${_equipments.where((e) => e.isOverdue).length} calibrações atrasadas',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white54),
                ),
              ],
            ),
          ),
          TapScale(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_forward_ios, color: Color(0xFFDC2626), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(int overdue, int urgent, int ok, int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RESUMO',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.white24),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: TapScale(child: StatCard(title: 'TOTAL', value: '$total', icon: Icons.inventory_2_outlined, color: Colors.white, onTap: () {}))),
              const SizedBox(width: 12),
              Expanded(child: TapScale(child: StatCard(title: 'EM DIA', value: '$ok', icon: Icons.check_circle_outline, color: const Color(0xFF22C55E), onTap: () {}))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TapScale(child: StatCard(title: 'URGENTE', value: '$urgent', icon: Icons.schedule_outlined, color: const Color(0xFFF59E0B), onTap: () {}))),
              const SizedBox(width: 12),
              Expanded(child: TapScale(child: StatCard(title: 'ATRASADO', value: '$overdue', icon: Icons.warning_outlined, color: const Color(0xFFDC2626), onTap: () {}))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart(int overdue, int urgent, int ok) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DISTRIBUIÇÃO',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.white24),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF18181B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: StatusChart(
              total: _equipments.length,
              ok: ok,
              urgent: urgent,
              overdue: overdue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AÇÕES RÁPIDAS',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.white24),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: TapScale(child: _buildActionButton(Icons.add_circle_outline, 'Novo\nEquipamento'))),
              const SizedBox(width: 12),
              Expanded(child: TapScale(child: _buildActionButton(Icons.qr_code_scanner, 'Escanear\nCódigo'))),
              const SizedBox(width: 12),
              Expanded(child: TapScale(child: _buildActionButton(Icons.picture_as_pdf, 'Gerar\nRelatório'))),
              const SizedBox(width: 12),
              Expanded(child: TapScale(child: _buildActionButton(Icons.sync, 'Sincronizar\nDados'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white54, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white54, height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(message, style: GoogleFonts.inter(fontSize: 13, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF09090B),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.transparent,
        indicatorColor: const Color(0xFFDC2626).withValues(alpha: 0.15),
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        elevation: 0,
        destinations: [
          _buildNavDest(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard', 0),
          _buildNavDest(Icons.inventory_2_outlined, Icons.inventory_2, 'Equipamentos', 1),
          _buildNavDest(Icons.calendar_today_outlined, Icons.calendar_today, 'Agenda', 2),
          _buildNavDest(Icons.business_outlined, Icons.business, 'Clientes', 3),
        ],
      ),
    );
  }

  NavigationDestination _buildNavDest(IconData outlined, IconData filled, String label, int index) {
    return NavigationDestination(
      icon: Icon(outlined, color: Colors.white38, size: 22),
      selectedIcon: Icon(filled, color: const Color(0xFFDC2626), size: 22),
      label: label,
    );
  }

  List<Equipment> _getMockEquipments() {
    return [
      Equipment(id: '1', name: 'Micrômetro Digital 0-25mm', client: 'Heineken', type: 'Medição Dimensional', brand: 'Mitutoyo', model: 'MDC-25PX', serialNumber: 'SN-2023-001', lastCalibration: DateTime(2025, 11, 15), nextCalibration: DateTime(2026, 5, 15), status: 'Atrasado'),
      Equipment(id: '2', name: 'Termômetro Infravermelho', client: 'Coca-Cola', type: 'Temperatura', brand: 'Fluke', model: '62 MAX', serialNumber: 'SN-2023-002', lastCalibration: DateTime(2025, 12, 10), nextCalibration: DateTime(2026, 6, 10), status: 'Atrasado'),
      Equipment(id: '3', name: 'Balança Analítica 0.1mg', client: 'Docol', type: 'Massa', brand: 'Mettler Toledo', model: 'ME204', serialNumber: 'SN-2023-003', lastCalibration: DateTime(2026, 1, 20), nextCalibration: DateTime(2026, 7, 20), status: 'Atrasado'),
      Equipment(id: '4', name: 'Manômetro Digital 0-100bar', client: 'Portos do Paraná', type: 'Pressão', brand: 'WIKA', model: 'S-20', serialNumber: 'SN-2024-001', lastCalibration: DateTime(2026, 3, 1), nextCalibration: DateTime(2026, 7, 1), status: 'Urgente'),
      Equipment(id: '5', name: 'Trena Metálica 5m', client: 'Descarpack', type: 'Medição Dimensional', brand: 'Starrett', model: '606M', serialNumber: 'SN-2024-002', lastCalibration: DateTime(2026, 3, 15), nextCalibration: DateTime(2026, 7, 15), status: 'Urgente'),
      Equipment(id: '6', name: 'Dinamômetro Digital 500N', client: 'Heineken', type: 'Força', brand: 'Shimpo', model: 'FGP-500N', serialNumber: 'SN-2024-003', lastCalibration: DateTime(2026, 4, 1), nextCalibration: DateTime(2026, 10, 1), status: 'Em dia'),
      Equipment(id: '7', name: 'Higrômetro Industrial', client: 'Coca-Cola', type: 'Umidade', brand: 'Vaisala', model: 'HMT120', serialNumber: 'SN-2024-004', lastCalibration: DateTime(2026, 4, 10), nextCalibration: DateTime(2026, 10, 10), status: 'Em dia'),
      Equipment(id: '8', name: 'Calibrador de Pressão', client: 'Porto Itapoa', type: 'Pressão', brand: 'Druck', model: 'DPI 104', serialNumber: 'SN-2024-005', lastCalibration: DateTime(2026, 5, 1), nextCalibration: DateTime(2026, 11, 1), status: 'Em dia'),
    ];
  }
}
