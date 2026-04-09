import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/models/nota.dart';
import '../../providers/notas_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/database_provider.dart';

class NotasScreen extends ConsumerStatefulWidget {
  const NotasScreen({super.key});

  @override
  ConsumerState<NotasScreen> createState() => _NotasScreenState();
}

class _NotasScreenState extends ConsumerState<NotasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(appLocalizationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.notasTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l.todas),
            Tab(text: l.notasLabel),
            Tab(text: l.recordatorios),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _NotasList(tipo: null),
          _NotasList(tipo: TipoNota.nota),
          _NotasList(tipo: TipoNota.recordatorio),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    final l = ref.read(appLocalizationsProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.note_add_outlined),
              title: Text(l.nuevaNota),
              onTap: () {
                Navigator.pop(ctx);
                context.push('${AppRoutes.notaForm}?tipo=nota');
              },
            ),
            ListTile(
              leading: const Icon(Icons.alarm_add_outlined),
              title: Text(l.nuevoRecordatorio),
              onTap: () {
                Navigator.pop(ctx);
                context.push('${AppRoutes.notaForm}?tipo=recordatorio');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NotasList extends ConsumerWidget {
  const _NotasList({required this.tipo});

  final TipoNota? tipo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(appLocalizationsProvider);
    final asyncNotas = tipo == null
        ? ref.watch(notasProvider)
        : ref.watch(notasByTipoProvider(tipo!));

    return asyncNotas.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l.errorGenerico)),
      data: (notas) {
        if (notas.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  tipo == TipoNota.recordatorio
                      ? Icons.alarm_off_outlined
                      : Icons.note_outlined,
                  size: 64,
                  color: AppColors.textDisabled,
                ),
                const SizedBox(height: 16),
                Text(
                  tipo == TipoNota.recordatorio
                      ? l.sinRecordatorios
                      : l.sinNotas,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          itemCount: notas.length,
          itemBuilder: (context, index) => _NotaCard(nota: notas[index]),
        );
      },
    );
  }
}

class _NotaCard extends ConsumerWidget {
  const _NotaCard({required this.nota});

  final Nota nota;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(appLocalizationsProvider);
    final prioridadColor = _prioridadColor(nota.prioridad);
    final esRecordatorio = nota.tipo == TipoNota.recordatorio;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(0, 6, 0, 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('${AppRoutes.notaForm}?id=${nota.id}'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: prioridadColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          esRecordatorio ? Icons.alarm : Icons.note_outlined,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            nota.titulo,
                            style: AppTextStyles.titleSmall.copyWith(
                              decoration: nota.completada
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _PrioridadChip(prioridad: nota.prioridad, l: l),
                      ],
                    ),
                    if (nota.contenido.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        nota.contenido,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (esRecordatorio && nota.fechaRecordatorio != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.schedule,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            _formatFecha(nota.fechaRecordatorio!),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (nota.recurrencia != Recurrencia.ninguna) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.repeat,
                                size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              _recurrenciaLabel(nota.recurrencia, l),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _prioridadColor(Prioridad p) {
    switch (p) {
      case Prioridad.alta:
        return const Color(0xFFDC2626);
      case Prioridad.media:
        return const Color(0xFFF59E0B);
      case Prioridad.baja:
        return const Color(0xFF16A34A);
    }
  }

  String _formatFecha(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  String _recurrenciaLabel(Recurrencia r, dynamic l) {
    switch (r) {
      case Recurrencia.diaria:
        return l.recurrenciaDiaria;
      case Recurrencia.semanal:
        return l.recurrenciaSemanal;
      case Recurrencia.mensual:
        return l.recurrenciaMensual;
      case Recurrencia.ninguna:
        return l.recurrenciaNinguna;
    }
  }
}

class _PrioridadChip extends StatelessWidget {
  const _PrioridadChip({required this.prioridad, required this.l});

  final Prioridad prioridad;
  final dynamic l;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (prioridad) {
      Prioridad.alta => (l.prioridadAlta as String, const Color(0xFFDC2626)),
      Prioridad.media => (l.prioridadMedia as String, const Color(0xFFF59E0B)),
      Prioridad.baja => (l.prioridadBaja as String, const Color(0xFF16A34A)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}
