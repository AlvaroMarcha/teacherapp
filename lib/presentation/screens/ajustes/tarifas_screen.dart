import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_utils.dart';
import '../../providers/alumnos_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/theme_provider.dart';

/// Pantalla para ver y editar la jerarquía de tarifas.
///
/// Jerarquía (PDF sección 05):
///   1. Tarifa por alumno (más prioritaria)
///   2. Tarifa por fuente
///   3. Tarifa global del profesor (fallback)
class TarifasScreen extends ConsumerWidget {
  const TarifasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tarifas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _JerarquiaInfo(),
          const SizedBox(height: 24),
          _TarifaGlobal(),
          const SizedBox(height: 24),
          _TarifasPorAlumno(),
        ],
      ),
    );
  }
}

class _JerarquiaInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Cómo funciona?', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            const Text('1️⃣  Tarifa del alumno (si tiene)'),
            const Text('2️⃣  Tarifa de la fuente'),
            const Text('3️⃣  Tu tarifa global (fallback)'),
          ],
        ),
      ),
    );
  }
}

class _TarifaGlobal extends ConsumerStatefulWidget {
  @override
  ConsumerState<_TarifaGlobal> createState() => _TarifaGlobalState();
}

class _TarifaGlobalState extends ConsumerState<_TarifaGlobal> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tarifa = ref.read(tarifaGlobalProvider);
      if (tarifa > 0) _ctrl.text = tarifa.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tarifa global (€/h)', style: AppTextStyles.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: '0,00',
                  prefixText: '€ ',
                  suffixText: '/h',
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: () {
                final v =
                    double.tryParse(_ctrl.text.trim().replaceAll(',', '.'));
                if (v == null || v < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Introduce un número válido')),
                  );
                  return;
                }
                ref.read(tarifaGlobalProvider.notifier).set(v);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tarifa global guardada')),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

class _TarifasPorAlumno extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alumnosAsync = ref.watch(alumnosProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tarifa por alumno', style: AppTextStyles.titleSmall),
        const SizedBox(height: 8),
        alumnosAsync.when(
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
          data: (alumnos) {
            if (alumnos.isEmpty) {
              return const Text('No hay alumnos registrados todavía.');
            }
            return Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: [
                  for (int i = 0; i < alumnos.length; i++) ...[
                    ListTile(
                      title: Text(alumnos[i].nombre),
                      trailing: Text(
                        alumnos[i].tarifaSesion > 0
                            ? '${CurrencyUtils.format(alumnos[i].tarifaSesion)}/h'
                            : 'Tarifa global',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color:
                              alumnos[i].tarifaSesion > 0 ? null : Colors.grey,
                        ),
                      ),
                      onTap: () => _editarTarifa(context, ref, alumnos[i].id,
                          alumnos[i].nombre, alumnos[i].tarifaSesion),
                    ),
                    if (i < alumnos.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _editarTarifa(
    BuildContext context,
    WidgetRef ref,
    String alumnoId,
    String nombre,
    double? tarifaActual,
  ) async {
    final ctrl = TextEditingController(text: tarifaActual?.toStringAsFixed(2));
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tarifa de $nombre'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: '€ ', hintText: '0,00'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final v = double.tryParse(ctrl.text.replaceAll(',', '.'));
              if (v != null && v >= 0) {
                final alumno = await ref
                    .read(alumnoRepositoryProvider)
                    .getAlumnoById(alumnoId);
                if (alumno != null) {
                  await ref
                      .read(alumnoRepositoryProvider)
                      .saveAlumno(alumno.copyWith(tarifaSesion: v));
                  ref.invalidate(alumnosProvider);
                }
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
