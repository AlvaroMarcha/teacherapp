import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/currency_utils.dart';
import '../../providers/alumnos_provider.dart';
import '../../providers/theme_provider.dart';
import '../../../domain/models/alumno.dart';

class AlumnosListScreen extends ConsumerWidget {
  const AlumnosListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(appLocalizationsProvider);
    final alumnosAsync = ref.watch(alumnosProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.alumnosTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {}, // TODO: búsqueda
          ),
        ],
      ),
      body: alumnosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (alumnos) {
          if (alumnos.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l.sinAlumnos,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: alumnos.length,
            itemBuilder: (_, i) => _AlumnoTile(alumno: alumnos[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('${AppRoutes.alumnos}/form'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AlumnoTile extends StatelessWidget {
  const _AlumnoTile({required this.alumno});

  final Alumno alumno;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Text(
            alumno.nombre.substring(0, 1).toUpperCase(),
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary),
          ),
        ),
        title: Text(alumno.nombre, style: AppTextStyles.titleSmall),
        subtitle: Text(
          '${CurrencyUtils.formatCompact(alumno.tarifaSesion)}/sesión · ${alumno.duracionMinutos} min',
          style: AppTextStyles.bodySmall,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: () => context.push('/alumnos/${alumno.id}'),
      ),
    );
  }
}
