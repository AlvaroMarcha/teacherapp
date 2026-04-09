import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../providers/alumnos_provider.dart';
import '../../providers/cobros_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/fuentes_provider.dart';
import '../../providers/sesiones_provider.dart';
import '../../providers/theme_provider.dart';
import '../../../domain/models/alumno.dart';
import '../../../domain/models/cobro.dart';
import '../../../domain/models/fuente.dart';
import '../../../domain/models/sesion_realizada.dart';

class CobrosScreen extends ConsumerWidget {
  const CobrosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendientesAsync = ref.watch(cobrosPendientesProvider);
    final alumnosAsync = ref.watch(alumnosProvider);
    final fuentesAsync = ref.watch(fuentesProvider);
    final l = ref.watch(appLocalizationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.cobrosTitle)),
      body: pendientesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (cobros) {
          if (cobros.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l.todoCobrado,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            );
          }

          // Build lookup maps
          final alumnos = alumnosAsync.valueOrNull ?? [];
          final fuentes = fuentesAsync.valueOrNull ?? [];
          final alumnoMap = {for (final a in alumnos) a.id: a};
          final fuenteMap = {for (final f in fuentes) f.id: f};

          final totalPendiente = cobros.fold<double>(
            0,
            (a, c) => a + c.montoPendiente,
          );

          return _CobrosGroupedList(
            cobros: cobros,
            alumnoMap: alumnoMap,
            fuenteMap: fuenteMap,
            totalPendiente: totalPendiente,
          );
        },
      ),
    );
  }
}

/// Widget que agrupa cobros por fecha y los muestra organizados
class _CobrosGroupedList extends ConsumerWidget {
  const _CobrosGroupedList({
    required this.cobros,
    required this.alumnoMap,
    required this.fuenteMap,
    required this.totalPendiente,
  });

  final List<Cobro> cobros;
  final Map<String, Alumno> alumnoMap;
  final Map<String, Fuente> fuenteMap;
  final double totalPendiente;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(appLocalizationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sesionRepo = ref.watch(sesionRepositoryProvider);

    return FutureBuilder<Map<String, List<Cobro>>>(
      future: _groupCobrosByDate(cobros, sesionRepo),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final groupedCobros = snapshot.data ?? {};
        final sortedKeys = _sortGroupKeys(groupedCobros.keys.toList());

        return CustomScrollView(
          slivers: [
            // Banner total pendiente
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.cobroPendienteLightDark
                      : AppColors.cobroPendienteLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Text(
                  '${l.totalPendiente}: ${CurrencyUtils.formatCompact(totalPendiente)}',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.cobroPendiente,
                  ),
                ),
              ),
            ),

            // Grupos de cobros por fecha
            ...sortedKeys.map((groupKey) {
              final cobrosInGroup = groupedCobros[groupKey]!;
              final displayName = _getDisplayNameForGroup(groupKey, l);

              return SliverMainAxisGroup(
                slivers: [
                  // Header de sección
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        displayName,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),

                  // Lista de cobros
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _CobroTile(
                        cobro: cobrosInGroup[index],
                        alumno: cobrosInGroup[index].alumnoId != null
                            ? alumnoMap[cobrosInGroup[index].alumnoId]
                            : null,
                        fuente: fuenteMap[cobrosInGroup[index].fuenteId],
                      ),
                      childCount: cobrosInGroup.length,
                    ),
                  ),
                ],
              );
            }),

            // Espacio final
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        );
      },
    );
  }

  /// Agrupa cobros por fecha (Hoy o por mes yyyy-MM)
  Future<Map<String, List<Cobro>>> _groupCobrosByDate(
    List<Cobro> cobros,
    dynamic sesionRepo,
  ) async {
    final Map<String, List<Cobro>> groups = {};
    final Map<String, DateTime?> cobroFechas = {};

    // Primero, cargar todas las fechas
    for (final cobro in cobros) {
      if (cobro.sesionId != null) {
        final sesion = await sesionRepo.getSesionRealizadaById(cobro.sesionId!);
        if (sesion?.fecha != null) {
          cobroFechas[cobro.id] = DateTime.parse(sesion!.fecha);
        }
      }
    }

    // Agrupar por fecha
    for (final cobro in cobros) {
      String groupKey;
      final fecha = cobroFechas[cobro.id];

      if (fecha != null) {
        if (AppDateUtils.isToday(fecha)) {
          groupKey = 'HOY';
        } else {
          groupKey = AppDateUtils.periodoMes(fecha);
        }
      } else {
        groupKey = 'SIN_FECHA';
      }

      groups.putIfAbsent(groupKey, () => []);
      groups[groupKey]!.add(cobro);
    }

    // Ordenar cobros dentro de cada grupo por fecha
    for (final group in groups.values) {
      group.sort((a, b) {
        final fechaA = cobroFechas[a.id];
        final fechaB = cobroFechas[b.id];

        if (fechaA == null) return 1;
        if (fechaB == null) return -1;

        return fechaA.compareTo(fechaB);
      });
    }

    return groups;
  }

  /// Ordena las claves de grupo (HOY primero, luego meses más recientes primero)
  List<String> _sortGroupKeys(List<String> keys) {
    final sorted = List<String>.from(keys);
    sorted.sort((a, b) {
      if (a == 'HOY') return -1;
      if (b == 'HOY') return 1;
      if (a == 'SIN_FECHA') return 1;
      if (b == 'SIN_FECHA') return -1;

      // Comparar periodos yyyy-MM (más reciente primero)
      return b.compareTo(a);
    });
    return sorted;
  }

  /// Obtiene el nombre a mostrar para cada grupo
  String _getDisplayNameForGroup(String groupKey, dynamic l) {
    if (groupKey == 'HOY') {
      return 'Hoy';
    } else if (groupKey == 'SIN_FECHA') {
      return 'Sin fecha';
    } else {
      // groupKey es yyyy-MM
      try {
        final date = DateTime.parse('$groupKey-01');
        return AppDateUtils.formatMonth(date);
      } catch (e) {
        return groupKey;
      }
    }
  }
}

class _CobroTile extends ConsumerWidget {
  const _CobroTile({
    required this.cobro,
    this.alumno,
    this.fuente,
  });

  final Cobro cobro;
  final Alumno? alumno;
  final Fuente? fuente;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = AppColors.forEstadoCobro(cobro.estado.value);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = ref.watch(appLocalizationsProvider);
    final theme = Theme.of(context);

    // Obtener fecha de la sesión realizada
    final sesionAsync = cobro.sesionId != null
        ? ref.watch(_sesionRealizadaByIdProvider(cobro.sesionId!))
        : null;
    final fecha = sesionAsync?.valueOrNull?.fecha;

    // Format fecha
    String fechaStr = '';
    if (fecha != null) {
      final parts = fecha.split('-');
      if (parts.length == 3) {
        fechaStr = '${parts[2]}/${parts[1]}';
      }
    }

    // Fuente info
    final fuenteNombre = fuente?.nombre ?? '';
    final fuenteTipo = fuente?.tipo.value ?? 'particular';
    final fuenteColor = AppColors.lightForFuenteTipoAdaptive(
      fuenteTipo,
      isDark,
    );

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _marcarCobrado(ref),
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            icon: Icons.check,
            label: l.cobrado,
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push('/cobros/${cobro.id}'),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Leading icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: fuenteColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      Icon(Icons.receipt_long_outlined, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        alumno?.nombre ?? fuenteNombre,
                        style: AppTextStyles.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (fechaStr.isNotEmpty) ...[
                            Icon(Icons.calendar_today,
                                size: 12,
                                color: theme.textTheme.bodySmall?.color
                                    ?.withOpacity(0.5)),
                            const SizedBox(width: 4),
                            Text(
                              fechaStr,
                              style: AppTextStyles.caption.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (alumno != null && fuenteNombre.isNotEmpty) ...[
                            Icon(Icons.business,
                                size: 12,
                                color: theme.textTheme.bodySmall?.color
                                    ?.withOpacity(0.5)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                fuenteNombre,
                                style: AppTextStyles.caption.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withOpacity(0.7),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Trailing - monto y estado alineados verticalmente
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      CurrencyUtils.formatCompact(cobro.monto),
                      style: AppTextStyles.amountSmall,
                    ),
                    const SizedBox(height: 4),
                    _EstadoBadge(estado: cobro.estado.value),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _marcarCobrado(WidgetRef ref) async {
    await ref.read(cobroRepositoryProvider).marcarCobrado(cobro.id);
    ref.invalidate(dashboardProvider);
    ref.invalidate(sesionesRealizadasFechaProvider);
  }
}

/// Provider para obtener la SesionRealizada por ID del cobro.
final _sesionRealizadaByIdProvider =
    FutureProvider.family<SesionRealizada?, String>((ref, sesionId) {
  return ref.watch(sesionRepositoryProvider).getSesionRealizadaById(sesionId);
});

class _EstadoBadge extends StatelessWidget {
  const _EstadoBadge({required this.estado});

  final String estado;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forEstadoCobro(estado);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = AppColors.lightForEstadoCobroAdaptive(estado, isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        estado,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}
