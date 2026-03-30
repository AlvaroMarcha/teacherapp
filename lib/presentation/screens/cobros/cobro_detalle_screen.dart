import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../providers/cobros_provider.dart';
import '../../providers/database_provider.dart';
import '../../../domain/models/cobro.dart';

class CobroDetalleScreen extends ConsumerWidget {
  const CobroDetalleScreen({super.key, required this.cobroId});

  final String cobroId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cobroAsync = ref.watch(cobroByIdProvider(cobroId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del cobro')),
      body: cobroAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (cobro) {
          if (cobro == null) {
            return const Center(child: Text('Cobro no encontrado'));
          }
          final pendiente = cobro.estado != EstadoCobro.cobrado;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Importe', style: AppTextStyles.labelMedium),
                      Text(
                        CurrencyUtils.format(cobro.monto),
                        style: AppTextStyles.amountLarge,
                      ),
                      const Divider(height: 24),
                      _Row('Estado', cobro.estado.value),
                      _Row('Modo', cobro.modoCobro.value),
                      if (cobro.periodoMes != null)
                        _Row(
                            'Período',
                            AppDateUtils.formatMonth(
                                DateTime.parse('${cobro.periodoMes!}-01'))),
                      if (cobro.fechaCobro != null)
                        _Row(
                            'Fecha cobro',
                            AppDateUtils.formatFullDate(
                                DateTime.parse(cobro.fechaCobro!))),
                      if (cobro.montoParcial != null)
                        _Row(
                          'Cobrado parcial',
                          CurrencyUtils.format(cobro.montoParcial!),
                        ),
                      if (cobro.notas.isNotEmpty) _Row('Notas', cobro.notas),
                    ],
                  ),
                ),
              ),
              if (pendiente) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    await ref
                        .read(cobroRepositoryProvider)
                        .marcarCobrado(cobroId);
                    if (context.mounted) context.pop();
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Marcar cobrado'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _mostrarDialogParcial(context, ref, cobro),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Registrar cobro parcial'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _mostrarDialogParcial(
    BuildContext context,
    WidgetRef ref,
    Cobro cobro,
  ) async {
    final formKey = GlobalKey<FormState>();
    final importeCtrl = TextEditingController();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cobro parcial'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: importeCtrl,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Importe cobrado (€)',
              hintText: 'Máx. ${CurrencyUtils.format(cobro.monto)}',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Introduce un importe';
              final n = double.tryParse(v);
              if (n == null || n <= 0) return 'Importe inválido';
              if (n > cobro.monto) {
                return 'No puede superar ${CurrencyUtils.format(cobro.monto)}';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !context.mounted) return;

    final monto = double.parse(importeCtrl.text);
    await ref.read(cobroRepositoryProvider).marcarParcial(cobroId, monto);
    // Invalidate para que el watch se actualice
    ref.invalidate(cobroByIdProvider(cobroId));
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
