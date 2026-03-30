import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_utils.dart';
import '../../providers/alumnos_provider.dart';
import '../../providers/sesiones_provider.dart';
import '../../../core/extensions/datetime_extension.dart';
import '../../../domain/models/sesion_realizada.dart';

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
                onPressed: () {}, // TODO: navegar a AlumnoFormScreen
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
                                s.fecha,
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
