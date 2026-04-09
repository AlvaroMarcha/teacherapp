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

class AlumnosListScreen extends ConsumerStatefulWidget {
  const AlumnosListScreen({super.key});

  @override
  ConsumerState<AlumnosListScreen> createState() => _AlumnosListScreenState();
}

class _AlumnosListScreenState extends ConsumerState<AlumnosListScreen> {
  bool _searching = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _searching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _searching = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  List<Alumno> _filterAlumnos(List<Alumno> alumnos) {
    if (_searchQuery.isEmpty) return alumnos;

    final query = _searchQuery.toLowerCase();
    return alumnos.where((alumno) {
      return alumno.nombre.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(appLocalizationsProvider);
    final alumnosAsync = ref.watch(alumnosProvider);

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '${l.buscar}...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : Text(l.alumnosTitle),
        actions: [
          if (_searching)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _stopSearch,
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _startSearch,
            ),
        ],
      ),
      body: alumnosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (alumnos) {
          final filteredAlumnos = _filterAlumnos(alumnos);

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

          if (filteredAlumnos.isEmpty && _searchQuery.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l.sinResultados,
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
            itemCount: filteredAlumnos.length,
            itemBuilder: (_, i) => _AlumnoTile(alumno: filteredAlumnos[i]),
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
