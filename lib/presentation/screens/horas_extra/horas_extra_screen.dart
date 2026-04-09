import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/models/fuente.dart';
import '../../../domain/models/hora_extra.dart';
import '../../providers/alumnos_provider.dart';
import '../../providers/fuentes_provider.dart';
import '../../providers/horas_extra_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/theme_provider.dart';

/// Pantalla de horas extra para una fuente concreta de tipo [FuenteTipo.empleo].
///
/// Recibe [fuenteId] desde el router (query parameter). Muestra el historial
/// de horas extra registradas y permite añadir nuevas o eliminar existentes.
class HorasExtraScreen extends ConsumerWidget {
  const HorasExtraScreen({super.key, this.fuenteId});

  final String? fuenteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fuentesAsync = ref.watch(fuentesProvider);

    return fuentesAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (fuentes) {
        final empleo = fuenteId != null
            ? fuentes.where((f) => f.id == fuenteId).firstOrNull
            : fuentes.where((f) => f.tipo == FuenteTipo.empleo).firstOrNull;

        if (empleo == null) {
          return const Scaffold(
            appBar: null,
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('—'),
              ),
            ),
          );
        }
        return _HorasExtraBody(fuente: empleo);
      },
    );
  }
}

class _HorasExtraBody extends ConsumerStatefulWidget {
  const _HorasExtraBody({required this.fuente});

  final Fuente fuente;

  @override
  ConsumerState<_HorasExtraBody> createState() => _HorasExtraBodyState();
}

class _HorasExtraBodyState extends ConsumerState<_HorasExtraBody> {
  DateTime _selectedMonth = DateTime.now();

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
    );
    // No permitir avanzar más allá del mes actual
    if (nextMonth.isBefore(DateTime(now.year, now.month + 1))) {
      setState(() {
        _selectedMonth = nextMonth;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.fuente.flutterColor;
    final horasAsync = ref.watch(horasExtraByFuenteProvider(widget.fuente.id));
    final configAsync = ref.watch(empleoConfigProvider(widget.fuente.id));
    final l = ref.watch(appLocalizationsProvider);

    // Periodo del mes seleccionado
    final periodoMes = DateFormat('yyyy-MM').format(_selectedMonth);
    final mesActual = DateFormat('yyyy-MM').format(DateTime.now());
    final esMesActual = periodoMes == mesActual;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l.horasExtra} — ${widget.fuente.nombre}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                  tooltip: l.mesAnterior,
                ),
                Text(
                  DateFormat('MMMM yyyy', 'es').format(_selectedMonth),
                  style: AppTextStyles.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: esMesActual ? null : _nextMonth,
                  tooltip: l.mesSiguiente,
                ),
              ],
            ),
          ),
        ),
      ),
      body: horasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (entries) {
          // Todas las horas extra del mes (incluyendo auto-generadas)
          final horasExtrasMes = entries
              .where((e) => e.fecha.startsWith(periodoMes))
              .fold<double>(0, (acc, e) => acc + e.horas);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Solo mostrar resumen de contrato si es el mes actual
              if (esMesActual) ...[
                // ── Resumen contrato ──────────────────────────────
                configAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (config) {
                    if (config == null) return const SizedBox.shrink();

                    // Semanas en el mes actual
                    final now = DateTime.now();
                    final lastDayOfMonth =
                        DateTime(now.year, now.month + 1, 0).day;
                    final semanasEnMes = lastDayOfMonth / 7;
                    final horasContratadas =
                        config.horasSemanales * semanasEnMes;

                    // Horas extra = horas extra registradas
                    final totalExtra = horasExtrasMes;

                    // Sueldo teórico = base + extras
                    final sueldoEsperado = config.salarioBase +
                        totalExtra * config.tarifaHoraExtra;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.configuracionContrato,
                              style: AppTextStyles.titleSmall,
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              label: l.horasSemanalesContratadas,
                              value: '${config.horasSemanales}h',
                            ),
                            _InfoRow(
                              label: l.tarifaHoraExtra,
                              value:
                                  CurrencyUtils.format(config.tarifaHoraExtra),
                            ),
                            const Divider(height: 24),
                            _InfoRow(
                              label: l.horasTrabajadasMes,
                              value: CurrencyUtils.format(sueldoEsperado),
                            ),
                            _InfoRow(
                              label: l.horasContratadasMes,
                              value: '${horasContratadas.toStringAsFixed(1)}h',
                            ),
                            _InfoRow(
                              label: l.horasExtraMes,
                              value: '${totalExtra.toStringAsFixed(1)}h',
                              highlight: totalExtra > 0,
                            ),
                            if (totalExtra > 0)
                              _InfoRow(
                                label: l.extraACobrar,
                                value: CurrencyUtils.format(
                                  totalExtra * config.tarifaHoraExtra,
                                ),
                                highlight: true,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              // ── Historial ─────────────────────────────────────
              if (entries.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      l.sinRegistros,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else ...[
                Text(l.historial, style: AppTextStyles.titleSmall),
                const SizedBox(height: 8),
                // Historial filtrado por mes seleccionado
                ...entries.where((e) => e.fecha.startsWith(periodoMes)).map(
                      (e) => _HoraExtraItem(
                        entry: e,
                        fuenteId: widget.fuente.id,
                        color: color,
                        onDelete: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(l.eliminarRegistro),
                              content: Text(
                                l.confirmarEliminarHoraExtra,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(l.cancelar),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(l.eliminar),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await ref
                                .read(horasExtraRepositoryProvider)
                                .deleteHoraExtra(e.id);
                            // Si es auto (del calendario), eliminar también la sesión
                            if (e.notas.startsWith('Auto')) {
                              await ref
                                  .read(databaseProvider)
                                  .deleteSesionRealizadaByFechaAndFuente(
                                    e.fecha,
                                    e.fuenteId,
                                  );
                            }
                            // Invalidar providers para actualizar dashboard
                            ref.invalidate(dashboardProvider);
                          }
                        },
                      ),
                    ),
              ],
              const SizedBox(height: 80),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRegistrarDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showRegistrarDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final horasCtrl = TextEditingController();
    final notasCtrl = TextEditingController();
    DateTime fecha = DateTime.now();
    String? selectedAlumnoId;
    final formKey = GlobalKey<FormState>();

    // Pre-load alumnos of this fuente
    final alumnos =
        await ref.read(alumnosByFuenteProvider(widget.fuente.id).future);

    if (!context.mounted) return;

    final l = ref.read(appLocalizationsProvider);
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(l.registrarHorasExtra),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fecha
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: fecha,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setStateDialog(() => fecha = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l.fecha,
                      suffixIcon: const Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(DateFormat('dd/MM/yyyy').format(fecha)),
                  ),
                ),
                const SizedBox(height: 12),
                // Horas
                TextFormField(
                  controller: horasCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l.horasExtra,
                    suffixText: 'h',
                  ),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n <= 0) {
                      return l.introduceNumeroValido;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Alumno (opcional)
                if (alumnos.isNotEmpty)
                  DropdownButtonFormField<String?>(
                    value: selectedAlumnoId,
                    decoration: InputDecoration(
                      labelText: l.alumnoOpcional,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l.sinAlumno),
                      ),
                      ...alumnos.map(
                        (a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.nombre),
                        ),
                      ),
                    ],
                    onChanged: (v) =>
                        setStateDialog(() => selectedAlumnoId = v),
                  ),
                if (alumnos.isNotEmpty) const SizedBox(height: 12),
                // Notas
                TextFormField(
                  controller: notasCtrl,
                  decoration: InputDecoration(
                    labelText: l.notasOpcional,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.cancelar),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final entry = HoraExtra(
                  id: '',
                  fuenteId: widget.fuente.id,
                  fecha: DateFormat('yyyy-MM-dd').format(fecha),
                  horas: double.parse(horasCtrl.text),
                  alumnoId: selectedAlumnoId,
                  notas: notasCtrl.text.trim(),
                );
                await ref
                    .read(horasExtraRepositoryProvider)
                    .saveHoraExtra(entry);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(l.guardar),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoraExtraItem extends ConsumerWidget {
  const _HoraExtraItem({
    required this.entry,
    required this.fuenteId,
    required this.color,
    required this.onDelete,
  });

  final HoraExtra entry;
  final String fuenteId;
  final Color color;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fecha = AppDateUtils.formatFullDate(DateTime.parse(entry.fecha));

    // Resolve alumno name if linked
    String? alumnoNombre;
    if (entry.alumnoId != null) {
      final alumnosAsync = ref.watch(alumnosByFuenteProvider(fuenteId));
      alumnosAsync.whenData((alumnos) {
        alumnoNombre = alumnos
            .where((a) => a.id == entry.alumnoId)
            .map((a) => a.nombre)
            .firstOrNull;
      });
    }

    final subtitleParts = <String>[fecha];
    if (alumnoNombre != null) subtitleParts.add(alumnoNombre!);
    if (entry.notas.isNotEmpty) subtitleParts.add(entry.notas);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.access_time, color: color, size: 20),
        ),
        title: Text(
          '${entry.horas.toStringAsFixed(1)}h',
          style: AppTextStyles.titleSmall,
        ),
        subtitle: Text(
          subtitleParts.join(' · '),
          style: AppTextStyles.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final highlightColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: highlight ? highlightColor : null,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: highlight ? highlightColor : null,
            ),
          ),
        ],
      ),
    );
  }
}
