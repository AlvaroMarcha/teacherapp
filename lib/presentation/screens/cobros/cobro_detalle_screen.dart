import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_utils.dart';
import '../../providers/database_provider.dart';
import '../../../domain/models/cobro.dart';

class CobroDetalleScreen extends ConsumerWidget {
  const CobroDetalleScreen({super.key, required this.cobroId});

  final String cobroId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del cobro')),
      body: FutureBuilder(
        future: ref.read(cobroRepositoryProvider).getCobroById(cobroId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final cobro = snapshot.data;
          if (cobro == null) {
            return const Center(child: Text('Cobro no encontrado'));
          }
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
                        _Row('Período', cobro.periodoMes!),
                      if (cobro.fechaCobro != null)
                        _Row('Fecha cobro', cobro.fechaCobro!),
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
              const SizedBox(height: 16),
              if (cobro.estado.value != 'cobrado') ...[
                ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(cobroRepositoryProvider)
                        .marcarCobrado(cobroId)
                        .then((_) => Navigator.of(context).pop());
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Marcar cobrado'),
                ),
              ],
            ],
          );
        },
      ),
    );
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
