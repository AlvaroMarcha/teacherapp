import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/router/app_router.dart';
import '../../providers/alumnos_provider.dart';
import '../../providers/cobros_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/sesiones_provider.dart';
import '../../providers/fuentes_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/theme_provider.dart';
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
    final l = ref.watch(appLocalizationsProvider);
    final alumnoAsync = ref.watch(alumnoByIdProvider(alumnoId));
    final periodoMes = DateTime.now().periodoMes;
    final sesionesAsync = ref.watch(sesionesRealizadasMesProvider(periodoMes));
    final sesionesRecurrentesAsync = ref.watch(sesionesRecurrentesProvider);

    return alumnoAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (alumno) {
        if (alumno == null) {
          return const Scaffold(
            body: Center(child: Text('')),
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
                        Text(l.traspasar),
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
                          l.eliminar,
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
                              '${l.tarifas}: ${CurrencyUtils.formatCompact(alumno.tarifaSesion)}/${l.sesion}',
                              style: AppTextStyles.bodySmall,
                            ),
                            Text(
                              '${l.duracion}: ${alumno.duracionMinutos} min',
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
              // Información académica
              if (alumno.materia.isNotEmpty ||
                  alumno.nivel.isNotEmpty ||
                  alumno.materiales.isNotEmpty) ...[
                Text(l.informacionAcademica, style: AppTextStyles.titleSmall),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (alumno.materia.isNotEmpty)
                          _buildInfoRow(
                            context,
                            Icons.book_outlined,
                            l.materia,
                            alumno.materia,
                          ),
                        if (alumno.materia.isNotEmpty &&
                            (alumno.nivel.isNotEmpty ||
                                alumno.materiales.isNotEmpty))
                          const SizedBox(height: 12),
                        if (alumno.nivel.isNotEmpty)
                          _buildInfoRow(
                            context,
                            Icons.grade_outlined,
                            l.nivel,
                            alumno.nivel,
                          ),
                        if (alumno.nivel.isNotEmpty &&
                            alumno.materiales.isNotEmpty)
                          const SizedBox(height: 12),
                        if (alumno.materiales.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(Icons.menu_book_outlined,
                                  size: 20,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                              const SizedBox(width: 12),
                              Text(l.materiales,
                                  style: AppTextStyles.labelMedium),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: alumno.materiales
                                .map(
                                  (material) => Chip(
                                    label: Text(material),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Notas
              if (alumno.notas.isNotEmpty) ...[
                Text(l.notas, style: AppTextStyles.titleSmall),
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
              Text(l.sesionesEsteMes, style: AppTextStyles.titleSmall),
              const SizedBox(height: 8),
              sesionesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
                data: (sesiones) {
                  final realizadas =
                      sesiones.where((s) => s.alumnoId == alumnoId).toList();

                  return sesionesRecurrentesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
                    data: (recurrentes) {
                      // Filtrar sesiones recurrentes del alumno
                      final recurrentesAlumno = recurrentes
                          .where((r) => r.alumnoId == alumnoId && r.activa)
                          .toList();

                      // Separar recurrentes verdaderas (repetitivas) de puntuales
                      final recurrentesVerdaderas =
                          recurrentesAlumno.where((r) => !r.esPuntual).toList();

                      // Separar sesiones realizadas en pendientes y confirmadas
                      final pendientesRealizadas = realizadas
                          .where((s) => s.estado.value == 'pendiente')
                          .toList();
                      final confirmadasRealizadas = realizadas
                          .where((s) => s.estado.value == 'confirmada')
                          .toList();

                      // Generar sesiones pendientes virtuales del mes basadas en recurrentes
                      final now = DateTime.now();
                      final firstDay = DateTime(now.year, now.month, 1);
                      final lastDay = DateTime(now.year, now.month + 1, 0);
                      final List<_SesionPendienteVirtual> pendientesVirtuales =
                          [];

                      for (final r in recurrentesAlumno) {
                        if (r.esPuntual) {
                          // Puntual: chequear si cae en el mes
                          final fecha = DateTime.tryParse(r.fechaInicio);
                          if (fecha != null &&
                              fecha.month == now.month &&
                              fecha.year == now.year) {
                            // Ver si ya existe una sesión realizada para esta fecha
                            final yaExiste = realizadas.any((s) =>
                                s.fecha == r.fechaInicio &&
                                s.sesionRecurrenteId == r.id);
                            if (!yaExiste) {
                              pendientesVirtuales.add(_SesionPendienteVirtual(
                                fecha: r.fechaInicio,
                                horaInicio: r.horaInicio,
                                horaFin: r.horaFin,
                              ));
                            }
                          }
                        } else {
                          // Recurrente: generar para cada día del mes que coincida
                          final fechaInicio = DateTime.tryParse(r.fechaInicio);
                          final fechaFin = r.fechaFin != null
                              ? DateTime.tryParse(r.fechaFin!)
                              : null;

                          if (fechaInicio == null) continue;

                          for (var d = firstDay;
                              d.isBefore(lastDay.add(const Duration(days: 1)));
                              d = d.add(const Duration(days: 1))) {
                            // Verificar si el día está en diasSemana
                            if (!r.diasSemana.contains(d.weekday)) continue;

                            // Verificar si está dentro del rango de la recurrente
                            if (d.isBefore(fechaInicio)) continue;
                            if (fechaFin != null && d.isAfter(fechaFin)) {
                              continue;
                            }

                            final fechaStr =
                                '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

                            // Ver si ya existe una sesión realizada para esta fecha
                            final yaExiste = realizadas.any((s) =>
                                s.fecha == fechaStr &&
                                s.sesionRecurrenteId == r.id);

                            if (!yaExiste &&
                                !d.isBefore(DateTime.now()
                                    .subtract(const Duration(days: 7)))) {
                              pendientesVirtuales.add(_SesionPendienteVirtual(
                                fecha: fechaStr,
                                horaInicio: r.horaInicio,
                                horaFin: r.horaFin,
                              ));
                            }
                          }
                        }
                      }

                      pendientesVirtuales
                          .sort((a, b) => a.fecha.compareTo(b.fecha));

                      // Combinar pendientes: virtuales + realizadas pendientes
                      final todasPendientes = <dynamic>[
                        ...pendientesVirtuales,
                        ...pendientesRealizadas,
                      ];
                      todasPendientes.sort((a, b) {
                        final fechaA = a is _SesionPendienteVirtual
                            ? a.fecha
                            : (a as SesionRealizada).fecha;
                        final fechaB = b is _SesionPendienteVirtual
                            ? b.fecha
                            : (b as SesionRealizada).fecha;
                        return fechaA.compareTo(fechaB);
                      });

                      if (recurrentesVerdaderas.isEmpty &&
                          todasPendientes.isEmpty &&
                          confirmadasRealizadas.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              l.sinSesionesEsteMes,
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Horario recurrente (solo sesiones NO puntuales)
                          if (recurrentesVerdaderas.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Horario recurrente',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            ...recurrentesVerdaderas.map((r) {
                              final diasStr = r.diasSemana
                                  .map((d) => [
                                        '',
                                        'Lun.',
                                        'Mar.',
                                        'Mié.',
                                        'Jue.',
                                        'Vie.',
                                        'Sáb.',
                                        'Dom.'
                                      ][d])
                                  .join(', ');
                              return Card(
                                margin: const EdgeInsets.only(bottom: 6),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 4,
                                      ),
                                    ),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      diasStr,
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                    subtitle: Text(
                                      '${r.horaInicio} - ${r.horaFin}',
                                      style: AppTextStyles.caption,
                                    ),
                                    trailing: Icon(
                                      Icons.repeat,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                          ],

                          // 2. Sesiones pendientes (virtuales + realizadas pendientes)
                          if (todasPendientes.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: 8),
                              child: Text(
                                'Sesiones pendientes',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            ...todasPendientes.map((item) {
                              final isVirtual = item is _SesionPendienteVirtual;
                              final fecha = isVirtual
                                  ? item.fecha
                                  : (item as SesionRealizada).fecha;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 6),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: AppColors.warning,
                                        width: 4,
                                      ),
                                    ),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      AppDateUtils.formatFullDate(
                                          DateTime.parse(fecha)),
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                    subtitle: Text(
                                      'pendiente',
                                      style: AppTextStyles.caption.copyWith(
                                        color: Colors.orange.shade800,
                                      ),
                                    ),
                                    trailing: Text(
                                      isVirtual
                                          ? '${item.horaInicio} - ${item.horaFin}'
                                          : CurrencyUtils.formatCompact(
                                              item.cobro),
                                      style: AppTextStyles.titleSmall,
                                    ),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                          ],

                          // 3. Sesiones confirmadas
                          if (confirmadasRealizadas.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: 8),
                              child: Text(
                                'Sesiones confirmadas',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            ...confirmadasRealizadas.map(
                              (s) {
                                final isPagada = s.cobro > 0;
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          color: isPagada
                                              ? AppColors.sesionParticular
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                          width: 4,
                                        ),
                                      ),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        AppDateUtils.formatFullDate(
                                            DateTime.parse(s.fecha)),
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                      subtitle: Text(
                                        isPagada ? 'pagada' : 'confirmada',
                                        style: AppTextStyles.caption.copyWith(
                                          color: isPagada
                                              ? AppColors.sesionParticular
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                        ),
                                      ),
                                      trailing: Text(
                                        CurrencyUtils.formatCompact(s.cobro),
                                        style: AppTextStyles.titleSmall,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Helper dialogs ───────────────────────────────────────────────────────────

void _showTraspasoDialog(
  BuildContext context,
  WidgetRef ref,
  Alumno alumno,
) {
  final l = ref.read(appLocalizationsProvider);
  final fuentes = ref.read(fuentesProvider).valueOrNull ?? [];
  final disponibles = fuentes.where((f) => f.id != alumno.fuenteId).toList();

  if (disponibles.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.noHayOtrasFuentes)),
    );
    return;
  }

  String? seleccionada = disponibles.first.id;

  showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: Text(l.traspasarAlumno),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: seleccionada,
              decoration: InputDecoration(
                labelText: l.nuevaFuenteLabel,
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
              ),
              items: disponibles
                  .map((f) =>
                      DropdownMenuItem(value: f.id, child: Text(f.nombre)))
                  .toList(),
              onChanged: (v) => setDialogState(() => seleccionada = v),
            ),
            const SizedBox(height: 12),
            Text(
              l.sesionesMantenidas,
              style: AppTextStyles.caption,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancelar),
          ),
          FilledButton(
            onPressed: () async {
              if (seleccionada != null) {
                await ref.read(alumnoRepositoryProvider).saveAlumno(
                      alumno.copyWith(fuenteId: seleccionada!),
                    );
                ref.invalidate(alumnosProvider);
                ref.invalidate(alumnosByFuenteProvider);
                ref.invalidate(alumnoByIdProvider(alumno.id));
                ref.invalidate(dashboardProvider);
                if (ctx.mounted) {
                  final nombre = disponibles
                      .firstWhere((f) => f.id == seleccionada)
                      .nombre;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${l.alumnoTraspasado} → $nombre')),
                  );
                }
              }
            },
            child: Text(l.traspasar),
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
  final l = ref.read(appLocalizationsProvider);
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.eliminarAlumno),
      content: Text(l.confirmarEliminarAlumno),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l.cancelar),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: () async {
            await ref.read(alumnoRepositoryProvider).deleteAlumno(alumno.id);
            ref.invalidate(alumnosProvider);
            ref.invalidate(alumnosByFuenteProvider);
            ref.invalidate(dashboardProvider);
            ref.invalidate(cobrosPendientesProvider);
            if (ctx.mounted) {
              Navigator.pop(ctx);
              context.go(AppRoutes.alumnos);
            }
          },
          child: Text(l.eliminar),
        ),
      ],
    ),
  );
}

/// Clase auxiliar para representar sesiones pendientes virtuales
/// generadas a partir de sesiones recurrentes.
class _SesionPendienteVirtual {
  final String fecha; // 'yyyy-MM-dd'
  final String horaInicio;
  final String horaFin;

  const _SesionPendienteVirtual({
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
  });
}
