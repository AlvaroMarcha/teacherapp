import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/models/sesion_recurrente.dart';
import '../../providers/alumnos_provider.dart';
import '../../providers/fuentes_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/sesiones_provider.dart';
import '../../providers/cobros_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/horas_extra_provider.dart';
import '../../providers/theme_provider.dart';

class SesionesListScreen extends ConsumerStatefulWidget {
  const SesionesListScreen({super.key});

  @override
  ConsumerState<SesionesListScreen> createState() => _SesionesListScreenState();
}

class _SesionesListScreenState extends ConsumerState<SesionesListScreen> {
  bool _mostrarArchivadas = false;

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(appLocalizationsProvider);
    final sesionesAsync = ref.watch(sesionesRecurrentesProvider);
    final fuentesAsync = ref.watch(fuentesProvider);
    final alumnosAsync = ref.watch(alumnosProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.gestionSesiones),
      ),
      body: sesionesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (sesiones) => fuentesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (fuentes) {
            final alumnos = alumnosAsync.valueOrNull ?? [];
            final alumnosMap = {for (final a in alumnos) a.id: a.nombre};
            final fuentesMap = {for (final f in fuentes) f.id: f};

            final filtradas = sesiones
                .where((s) => _mostrarArchivadas ? !s.activa : s.activa)
                .toList();

            // Agrupar por fuente
            final agrupadas = <String, List<SesionRecurrente>>{};
            for (final s in filtradas) {
              agrupadas.putIfAbsent(s.fuenteId, () => []).add(s);
            }

            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: false,
                        label: Text(l.sesionesActivas),
                        icon: const Icon(Icons.event_available_outlined),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text(l.sesionesArchivadas),
                        icon: const Icon(Icons.archive_outlined),
                      ),
                    ],
                    selected: {_mostrarArchivadas},
                    onSelectionChanged: (s) =>
                        setState(() => _mostrarArchivadas = s.first),
                  ),
                ),
                Expanded(
                  child: filtradas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _mostrarArchivadas
                                    ? Icons.archive_outlined
                                    : Icons.event_note_outlined,
                                size: 64,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _mostrarArchivadas
                                    ? 'No hay sesiones archivadas'
                                    : 'No hay sesiones activas',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 80),
                          children: agrupadas.entries.map((entry) {
                            final fuente = fuentesMap[entry.key];
                            final nombre =
                                fuente?.nombre ?? 'Fuente desconocida';
                            return _GrupoFuente(
                              nombreFuente: nombre,
                              sesiones: entry.value,
                              alumnosMap: alumnosMap,
                              mostrarArchivadas: _mostrarArchivadas,
                              onArchivar: (s) => _toggleActiva(s, false),
                              onActivar: (s) => _toggleActiva(s, true),
                              onEditar: (s) =>
                                  context.push(AppRoutes.sesionForm, extra: s),
                              onEliminar: (s) => _eliminar(s),
                            );
                          }).toList(),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _toggleActiva(SesionRecurrente sesion, bool activa) async {
    final l = ref.read(appLocalizationsProvider);

    if (!activa) {
      // Archivar: pedir confirmación
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.archivarSesion),
          content: Text(l.confirmarArchivar),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancelar),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.archivarSesion),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    final updated = sesion.copyWith(activa: activa);
    await ref.read(sesionRepositoryProvider).saveSesionRecurrente(updated);
    ref.invalidate(sesionesRecurrentesProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(activa ? l.sesionActivada : l.sesionArchivada),
        ),
      );
    }
  }

  Future<void> _eliminar(SesionRecurrente sesion) async {
    final l = ref.read(appLocalizationsProvider);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.eliminarSesion),
        content: Text(l.confirmarEliminarSesionCalendario),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.eliminar),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    // Desvincular realizadas y eliminar recurrente
    await ref
        .read(sesionRepositoryProvider)
        .desvincularSesionesRealizadas(sesion.id);
    await ref.read(sesionRepositoryProvider).deleteSesionRecurrente(sesion.id);

    ref.invalidate(sesionesRecurrentesProvider);
    ref.invalidate(sesionesRealizadasFechaProvider);
    ref.invalidate(cobrosProvider);
    ref.invalidate(dashboardProvider);
    ref.invalidate(horasExtraProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.sesionEliminada)),
      );
    }
  }
}

class _GrupoFuente extends StatelessWidget {
  const _GrupoFuente({
    required this.nombreFuente,
    required this.sesiones,
    required this.alumnosMap,
    required this.mostrarArchivadas,
    required this.onArchivar,
    required this.onActivar,
    required this.onEditar,
    required this.onEliminar,
  });

  final String nombreFuente;
  final List<SesionRecurrente> sesiones;
  final Map<String, String> alumnosMap;
  final bool mostrarArchivadas;
  final void Function(SesionRecurrente) onArchivar;
  final void Function(SesionRecurrente) onActivar;
  final void Function(SesionRecurrente) onEditar;
  final void Function(SesionRecurrente) onEliminar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            nombreFuente,
            style: AppTextStyles.titleSmall.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...sesiones.map((s) => _SesionTile(
              sesion: s,
              alumnoNombre: s.alumnoId != null ? alumnosMap[s.alumnoId] : null,
              mostrarArchivadas: mostrarArchivadas,
              onArchivar: () => onArchivar(s),
              onActivar: () => onActivar(s),
              onEditar: () => onEditar(s),
              onEliminar: () => onEliminar(s),
            )),
        const Divider(indent: 16, endIndent: 16),
      ],
    );
  }
}

class _SesionTile extends StatelessWidget {
  const _SesionTile({
    required this.sesion,
    required this.alumnoNombre,
    required this.mostrarArchivadas,
    required this.onArchivar,
    required this.onActivar,
    required this.onEditar,
    required this.onEliminar,
  });

  final SesionRecurrente sesion;
  final String? alumnoNombre;
  final bool mostrarArchivadas;
  final VoidCallback onArchivar;
  final VoidCallback onActivar;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  static const _diasLabels = ['', 'L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final diasStr = sesion.diasSemana.map((d) => _diasLabels[d]).join(', ');
    final horario = '${sesion.horaInicio} - ${sesion.horaFin}';
    final subtitle = sesion.esPuntual
        ? '${sesion.fechaInicio} · $horario'
        : '$diasStr · $horario';

    String? fechaFinStr;
    if (sesion.fechaFin != null) {
      final dt = DateTime.tryParse(sesion.fechaFin!);
      if (dt != null) fechaFinStr = AppDateUtils.formatFullDate(dt);
    }

    return ListTile(
      leading: Icon(
        sesion.esPuntual ? Icons.event_outlined : Icons.repeat,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(alumnoNombre ?? subtitle),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (alumnoNombre != null) Text(subtitle),
          if (fechaFinStr != null)
            Text(
              'Hasta: $fechaFinStr',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
        ],
      ),
      isThreeLine: alumnoNombre != null && fechaFinStr != null,
      trailing: PopupMenuButton<String>(
        onSelected: (action) {
          switch (action) {
            case 'editar':
              onEditar();
            case 'archivar':
              onArchivar();
            case 'activar':
              onActivar();
            case 'eliminar':
              onEliminar();
          }
        },
        itemBuilder: (ctx) => [
          const PopupMenuItem(
            value: 'editar',
            child: ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('Editar'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          if (!mostrarArchivadas)
            const PopupMenuItem(
              value: 'archivar',
              child: ListTile(
                leading: Icon(Icons.archive_outlined),
                title: Text('Archivar'),
                contentPadding: EdgeInsets.zero,
              ),
            )
          else
            const PopupMenuItem(
              value: 'activar',
              child: ListTile(
                leading: Icon(Icons.unarchive_outlined),
                title: Text('Activar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          const PopupMenuItem(
            value: 'eliminar',
            child: ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red),
              title: Text('Eliminar', style: TextStyle(color: Colors.red)),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
