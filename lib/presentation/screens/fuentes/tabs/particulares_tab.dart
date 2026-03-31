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
import '../../../providers/theme_provider.dart';

/// Tab de alumnos particulares propios: Blanca, Pablo, Nil, Arantxa, etc.
class ParticularesTab extends ConsumerWidget {
  const ParticularesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fuentesAsync = ref.watch(fuentesProvider);
    final l = ref.watch(appLocalizationsProvider);

    return fuentesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (fuentes) {
        final particular =
            fuentes.where((f) => f.tipo.value == 'particular').toList();
        if (particular.isEmpty) {
          return Center(
            child: Text(l.noParticularConfigurada),
          );
        }
        final fuente = particular.first;
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
                          color: AppColors.particulares,
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
                        label: Text(l.alumno),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (alumnos.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(l.sinAlumnosParticulares),
                      ),
                    )
                  else
                    ...alumnos.map(
                      (a) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(a.nombre),
                          subtitle: Text(
                            '${CurrencyUtils.formatCompact(a.tarifaSesion)}${l.porSesionEfectivo}',
                            style: AppTextStyles.bodySmall,
                          ),
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.particularesLightDark
                                    : AppColors.particularesLight,
                            child: Text(
                              a.nombre.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.particulares,
                              ),
                            ),
                          ),
                          trailing: Text(
                            CurrencyUtils.formatCompact(a.tarifaSesion),
                            style: AppTextStyles.amountSmall.copyWith(
                              color: AppColors.particulares,
                            ),
                          ),
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
