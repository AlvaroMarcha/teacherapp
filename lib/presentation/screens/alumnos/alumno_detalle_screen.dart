import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/router/app_router.dart';
import '../../providers/alumnos_provider.dart';
import '../../providers/sesiones_provider.dart';
import '../../providers/fuentes_provider.dart';
import '../../providers/database_provider.dart';
import '../../../core/extensions/datetime_extension.dart';
import '../../../domain/models/alumno.dart';
import '../../../domain/models/sesion_realizada.dart';
import '../../../core/utils/date_utils.dart';

enum _AlumnoAccion { traspasar, eliminar }

class AlumnoDetalleScreen extends ConsumerWidget {
  const AlumnoDetalleScreen({super.key, required this.alumnoId});

  final String alumnoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alumnoAsync = ref.watch(alumnoByIdProvider(alumnoId));
    final periodoMes = DateTime.now().periodoMes;
    final sesionesAsync = ref.watch(sesionesRealizadasMesProvider(periodoMes));

    return alumnoAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (alumno) {
        if (alumno == null) {
          return const Scaffold(
            body: Center(child: Text('Alumno no encontrado')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(alumno.nombre),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/alumnos/form?id=${alumno.id}'),
              ),
              PopupMenuButton<_AlumnoAccion>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
                onSelected: (accion) {
                  if (accion == _AlumnoAccion.traspasar) {
                    _showTraspasoDialog(context, ref, alumno);
                  } else if (accion == _AlumnoAccion.eliminar) {
                    _showEliminarDialog(context, ref, alumno);
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: _AlumnoAccion.traspasar,
                    child: Row(
                      children: [
                        Icon(Icons.swap_horiz,
                            size: 20,
                            color: Theme.of(ctx).colorScheme.onSurface),
                        const SizedBox(width: 12),
                        const Text('Traspasar'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(height: 1),
                  PopupMenuItem(
                    value: _AlumnoAccion.eliminar,
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            size: 20, color: Theme.of(ctx).colorScheme.error),
                        const SizedBox(width: 12),
                        Text(
                          'Eliminar',
                          style:
                              TextStyle(color: Theme.of(ctx).colorScheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Cabecera
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          alumno.nombre.substring(0, 1).toUpperCase(),
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alumno.nombre,
                              style: AppTextStyles.titleMedium,
                            ),
                            Text(
                              'Tarifa: ${CurrencyUtils.formatCompact(alumno.tarifaSesion)}/sesión',
                              style: AppTextStyles.bodySmall,
                            ),
                            Text(
                              'Duración: ${alumno.duracionMinutos} min',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Notas
              if (alumno.notas.isNotEmpty) ...[
                Text('Notas', style: AppTextStyles.titleSmall),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(alumno.notas, style: AppTextStyles.bodyMedium),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Sesiones del mes
              Text('Sesiones este mes', style: AppTextStyles.titleSmall),
              const SizedBox(height: 8),
              sesionesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
                data: (sesiones) {
                  final mias =
                      sesiones.where((s) => s.alumnoId == alumnoId).toList();
                  if (mias.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Sin sesiones este mes',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: mias
                        .map(
                          (s) => Card(
                            margin: const EdgeInsets.only(bottom: 6),
                            child: ListTile(
                              title: Text(
                                AppDateUtils.formatFullDate(
                                    DateTime.parse(s.fecha)),
                                style: AppTextStyles.bodyMedium,
                              ),
                              trailing: Text(
                                CurrencyUtils.formatCompact(s.cobro),
                                style: AppTextStyles.amountSmall,
                              ),
                              subtitle: Text(
                                s.estado.value,
                                style: AppTextStyles.caption,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Helper dialogs ───────────────────────────────────────────────────────────

void _showTraspasoDialog(
  BuildContext context,
  WidgetRef ref,
  Alumno alumno,
) {
  final fuentes = ref.read(fuentesProvider).valueOrNull ?? [];
  final disponibles = fuentes.where((f) => f.id != alumno.fuenteId).toList();

  if (disponibles.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No hay otras fuentes disponibles')),
    );
    return;
  }

  String? seleccionada = disponibles.first.id;

  showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: const Text('Traspasar alumno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: seleccionada,
              decoration: const InputDecoration(
                labelText: 'Nueva fuente',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
              items: disponibles
                  .map((f) =>
                      DropdownMenuItem(value: f.id, child: Text(f.nombre)))
                  .toList(),
              onChanged: (v) => setDialogState(() => seleccionada = v),
            ),
            const SizedBox(height: 12),
            Text(
              'Las sesiones anteriores mantendrán su fuente original.',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (seleccionada != null) {
                await ref.read(alumnoRepositoryProvider).saveAlumno(
                      alumno.copyWith(fuenteId: seleccionada!),
                    );
                if (ctx.mounted) {
                  final nombre = disponibles
                      .firstWhere((f) => f.id == seleccionada)
                      .nombre;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Alumno traspasado a $nombre')),
                  );
                }
              }
            },
            child: const Text('Traspasar'),
          ),
        ],
      ),
    ),
  );
}

void _showEliminarDialog(
  BuildContext context,
  WidgetRef ref,
  Alumno alumno,
) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Eliminar alumno'),
      content: const Text(
        '¿Eliminar este alumno? Las sesiones registradas se mantendrán.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: () async {
            await ref.read(alumnoRepositoryProvider).deleteAlumno(alumno.id);
            if (ctx.mounted) {
              Navigator.pop(ctx);
              context.go(AppRoutes.alumnos);
            }
          },
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
}
