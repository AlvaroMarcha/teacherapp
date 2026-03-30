import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../providers/fuentes_provider.dart';
import '../../../../domain/models/fuente.dart';
import '../../../providers/alumnos_provider.dart';

/// Tab de academia (Angels): lista alumnos con horario y tarifa.
class AcademiaTab extends ConsumerWidget {
  const AcademiaTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fuentesAsync = ref.watch(fuentesProvider);

    return fuentesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (fuentes) {
        final academia =
            fuentes.where((f) => f.tipo.value == 'academia').toList();
        if (academia.isEmpty) {
          return const Center(child: Text('No hay academia configurada'));
        }
        final fuente = academia.first;
        return Consumer(
          builder: (context, ref, _) {
            final alumnosAsync = ref.watch(alumnosByFuenteProvider(fuente.id));
            return alumnosAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (alumnos) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.angels,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(fuente.nombre, style: AppTextStyles.titleMedium),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => context.push(
                          '${AppRoutes.alumnos}/form?fuenteId=${fuente.id}',
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Alumno'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (alumnos.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Sin alumnos en esta academia'),
                      ),
                    )
                  else
                    ...alumnos.map(
                      (a) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(a.nombre),
                          subtitle: Text(
                            '${CurrencyUtils.formatCompact(a.tarifaSesion)}/sesión · ${a.duracionMinutos} min',
                            style: AppTextStyles.bodySmall,
                          ),
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.angelsLightDark
                                    : AppColors.angelsLight,
                            child: Text(
                              a.nombre.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: AppColors.angels),
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/alumnos/${a.id}'),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
