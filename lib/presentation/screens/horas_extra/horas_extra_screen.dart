import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_utils.dart';
import '../../providers/fuentes_provider.dart';
import '../../providers/database_provider.dart';
import '../../../domain/models/fuente.dart';

/// Pantalla de horas extra (exclusiva para fuente tipo [FuenteTipo.empleo]).
///
/// Permite registrar horas trabajadas más allá de las horas contratadas semanalmente.
/// Proyecta el ingreso mensual extra basándose en el EmpleoConfig: tarifaHoraExtra.
class HorasExtraScreen extends ConsumerStatefulWidget {
  const HorasExtraScreen({super.key});

  @override
  ConsumerState<HorasExtraScreen> createState() => _HorasExtraScreenState();
}

class _HorasExtraScreenState extends ConsumerState<HorasExtraScreen> {
  final _horasCtrl = TextEditingController();
  bool _guardando = false;

  @override
  void dispose() {
    _horasCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fuentesAsync = ref.watch(fuentesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Horas extra (Around)')),
      body: fuentesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (fuentes) {
          final empleo =
              fuentes.where((f) => f.tipo == FuenteTipo.empleo).firstOrNull;
          if (empleo == null) {
            return const Center(
                child: Text('No hay fuente de empleo configurada'));
          }
          return _buildContent(context, empleo);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Fuente empleo) {
    return FutureBuilder(
      future: ref.read(fuenteRepositoryProvider).getEmpleoConfig(empleo.id),
      builder: (context, snap) {
        final config = snap.data;
        final tarifa = config?.tarifaHoraExtra ?? 0;
        final contratadas = config?.horasSemanales ?? 0;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Configuración contrato',
                        style: AppTextStyles.titleSmall),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Horas semanales contratadas',
                      value: '${contratadas}h',
                    ),
                    _InfoRow(
                      label: 'Tarifa hora extra',
                      value: CurrencyUtils.format(tarifa),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Registrar horas extra', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              controller: _horasCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Horas extra esta semana',
                suffixText: 'h',
              ),
            ),
            const SizedBox(height: 16),
            if (_horasCtrl.text.isNotEmpty) ...[
              _ProyeccionCard(
                horas: double.tryParse(_horasCtrl.text) ?? 0,
                tarifa: tarifa,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed:
                  _guardando ? null : () => _registrar(empleo.id, tarifa),
              icon: _guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add),
              label: const Text('Registrar horas extra'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.around,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _registrar(String fuenteId, double tarifa) async {
    final horas = double.tryParse(_horasCtrl.text);
    if (horas == null || horas <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce un número de horas válido')),
      );
      return;
    }
    setState(() => _guardando = true);
    // TODO: persiste horas extra en una tabla dedicada (Sprint 3)
    // Por ahora solo muestra confirmación
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _guardando = false;
      _horasCtrl.clear();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${horas}h extra registradas → ${CurrencyUtils.format(horas * tarifa)} adicionales',
          ),
        ),
      );
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ProyeccionCard extends StatelessWidget {
  final double horas;
  final double tarifa;
  const _ProyeccionCard({required this.horas, required this.tarifa});

  @override
  Widget build(BuildContext context) {
    final total = horas * tarifa;
    return Card(
      color: AppColors.around.withValues(alpha: 0.08),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.around.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Ingreso extra proyectado', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            Text(
              CurrencyUtils.format(total),
              style:
                  AppTextStyles.amountLarge.copyWith(color: AppColors.around),
            ),
            const SizedBox(height: 4),
            Text(
              '${horas}h × ${CurrencyUtils.format(tarifa)}/h',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
