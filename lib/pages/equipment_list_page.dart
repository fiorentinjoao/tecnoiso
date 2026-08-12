import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/equipment.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/tap_scale.dart';
import 'equipment_detail_page.dart';

class EquipmentListPage extends StatefulWidget {
  const EquipmentListPage({super.key});

  @override
  State<EquipmentListPage> createState() => _EquipmentListPageState();
}

class _EquipmentListPageState extends State<EquipmentListPage> {
  String _searchQuery = '';
  String _selectedFilter = 'Todos';
  late List<Equipment> _allEquipments;

  @override
  void initState() {
    super.initState();
    _allEquipments = _getMockEquipments();
  }

  List<Equipment> get _filteredEquipments {
    var list = _allEquipments;
    if (_searchQuery.isNotEmpty) {
      list = list.where((e) =>
        e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        e.client.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        e.brand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        e.type.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    if (_selectedFilter != 'Todos') {
      list = list.where((e) => e.status == _selectedFilter).toList();
    }
    return list;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Atrasado': return const Color(0xFFDC2626);
      case 'Urgente': return const Color(0xFFF59E0B);
      default: return const Color(0xFF22C55E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildSearchBar(),
        _buildFilters(),
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xFFDC2626),
            backgroundColor: const Color(0xFF18181B),
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 1500));
            },
            child: _filteredEquipments.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 60),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.search_off, color: Colors.white12, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum equipamento encontrado',
                              style: GoogleFonts.inter(color: Colors.white24, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    itemCount: _filteredEquipments.length,
                    itemBuilder: (context, index) {
                      final eq = _filteredEquipments[index];
                      return FadeSlideIn(
                        delay: Duration(milliseconds: index * 60),
                        child: TapScale(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EquipmentDetailPage(equipment: eq),
                              ),
                            );
                          },
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
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: _statusColor(eq.status).withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.precision_manufacturing, color: _statusColor(eq.status), size: 20),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(eq.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white)),
                                      const SizedBox(height: 3),
                                      Text('${eq.client}  •  ${eq.brand}', style: GoogleFonts.inter(fontSize: 12, color: Colors.white38)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _statusColor(eq.status).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(eq.status.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: _statusColor(eq.status), letterSpacing: 0.5)),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${eq.nextCalibration.day.toString().padLeft(2, '0')}/${eq.nextCalibration.month.toString().padLeft(2, '0')}/${eq.nextCalibration.year}',
                                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white24),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
              'Equipamentos',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const Spacer(),
            Text(
              '${_filteredEquipments.length}',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFFDC2626)),
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF18181B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.white24, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome, cliente, tipo...',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.white24),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                GestureDetector(
                  onTap: () => setState(() => _searchQuery = ''),
                  child: Icon(Icons.close, color: Colors.white24, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return FadeSlideIn(
      delay: const Duration(milliseconds: 200),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Row(
          children: [
            _buildFilterChip('Todos'),
            const SizedBox(width: 8),
            _buildFilterChip('Atrasado'),
            const SizedBox(width: 8),
            _buildFilterChip('Urgente'),
            const SizedBox(width: 8),
            _buildFilterChip('Em dia'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return TapScale(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDC2626) : const Color(0xFF18181B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFDC2626) : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.white54,
          ),
        ),
      ),
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
