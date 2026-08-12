import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/equipment_repository.dart';
import '../models/equipment.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/tap_scale.dart';

/// The three status literals the rest of the UI understands.
/// `EquipmentTile` and the list page's `_statusColor` switch on these exact
/// strings, so a free-text status would render with the wrong color.
const List<String> kEquipmentStatuses = ['Atrasado', 'Urgente', 'Em dia'];

/// Serves both create and edit, distinguished by whether [equipment] is
/// provided.
class EquipmentFormPage extends StatefulWidget {
  final Equipment? equipment;

  const EquipmentFormPage({super.key, this.equipment});

  bool get isEdit => equipment != null;

  @override
  State<EquipmentFormPage> createState() => _EquipmentFormPageState();
}

class _EquipmentFormPageState extends State<EquipmentFormPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _clientController;
  late final TextEditingController _typeController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _serialController;

  late DateTime _lastCalibration;
  late DateTime _nextCalibration;
  late String _status;

  String? _errorMessage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final equipment = widget.equipment;
    _nameController = TextEditingController(text: equipment?.name ?? '');
    _clientController = TextEditingController(text: equipment?.client ?? '');
    _typeController = TextEditingController(text: equipment?.type ?? '');
    _brandController = TextEditingController(text: equipment?.brand ?? '');
    _modelController = TextEditingController(text: equipment?.model ?? '');
    _serialController =
        TextEditingController(text: equipment?.serialNumber ?? '');
    _lastCalibration = equipment?.lastCalibration ?? DateTime.now();
    _nextCalibration = equipment?.nextCalibration ??
        DateTime.now().add(const Duration(days: 180));
    _status = equipment?.status ?? kEquipmentStatuses.last;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _clientController.dispose();
    _typeController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _serialController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isLast}) async {
    final initial = isLast ? _lastCalibration : _nextCalibration;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFDC2626),
              surface: Color(0xFF18181B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isLast) {
        _lastCalibration = picked;
      } else {
        _nextCalibration = picked;
      }
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final client = _clientController.text.trim();
    final type = _typeController.text.trim();
    final brand = _brandController.text.trim();
    final model = _modelController.text.trim();
    final serial = _serialController.text.trim();

    if (name.isEmpty ||
        client.isEmpty ||
        type.isEmpty ||
        brand.isEmpty ||
        model.isEmpty ||
        serial.isEmpty) {
      setState(() => _errorMessage = 'Preencha todos os campos.');
      return;
    }
    if (_nextCalibration.isBefore(_lastCalibration)) {
      setState(() =>
          _errorMessage = 'A próxima calibração não pode ser antes da última.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final navigator = Navigator.of(context);
    final existing = widget.equipment;
    if (existing == null) {
      final equipment = Equipment(
        id: EquipmentRepository.instance.newId(),
        name: name,
        client: client,
        type: type,
        brand: brand,
        model: model,
        serialNumber: serial,
        lastCalibration: _lastCalibration,
        nextCalibration: _nextCalibration,
        status: _status,
      );
      await EquipmentRepository.instance.add(equipment);
    } else {
      final updated = existing.copyWith(
        name: name,
        client: client,
        type: type,
        brand: brand,
        model: model,
        serialNumber: serial,
        lastCalibration: _lastCalibration,
        nextCalibration: _nextCalibration,
        status: _status,
      );
      await EquipmentRepository.instance.update(updated);
    }

    if (!mounted) return;
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideIn(
                child: Row(
                  children: [
                    TapScale(
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
                    const SizedBox(width: 16),
                    Text(
                      widget.isEdit ? 'Editar Equipamento' : 'Novo Equipamento',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _buildField(0, _nameController, 'Nome do equipamento'),
              _buildField(1, _clientController, 'Cliente'),
              _buildField(2, _typeController, 'Tipo'),
              _buildField(3, _brandController, 'Marca'),
              _buildField(4, _modelController, 'Modelo'),
              _buildField(5, _serialController, 'Número de série'),
              FadeSlideIn(
                delay: Duration(milliseconds: 60 * 6),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        label: 'Última calibração',
                        date: _lastCalibration,
                        onTap: () => _pickDate(isLast: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateField(
                        label: 'Próxima calibração',
                        date: _nextCalibration,
                        onTap: () => _pickDate(isLast: false),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              FadeSlideIn(
                delay: Duration(milliseconds: 60 * 7),
                child: _buildStatusSelector(),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFDC2626)),
                ),
              ],
              const SizedBox(height: 24),
              FadeSlideIn(
                delay: Duration(milliseconds: 60 * 8),
                child: TapScale(
                  onTap: _isSaving ? null : _save,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.isEdit ? 'Salvar alterações' : 'Cadastrar equipamento',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    int index,
    TextEditingController controller,
    String hint,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: FadeSlideIn(
        delay: Duration(milliseconds: 60 * index),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF18181B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.white24),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF18181B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 10, color: Colors.white24),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STATUS',
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.white24),
        ),
        const SizedBox(height: 10),
        Row(
          children: kEquipmentStatuses.map((status) {
            final isSelected = status == _status;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: status != kEquipmentStatuses.last ? 8 : 0,
                ),
                child: TapScale(
                  onTap: () => setState(() => _status = status),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFDC2626) : const Color(0xFF18181B),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFDC2626) : Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        status,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.white54,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
