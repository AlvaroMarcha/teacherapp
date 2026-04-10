import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/theme_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/alumnos_provider.dart';

/// Pantalla de perfil del usuario con estadísticas y herramientas útiles.
/// Muestra resumen del mes y plantillas de mensajes para uso diario.
class PerfilScreen extends ConsumerStatefulWidget {
  const PerfilScreen({super.key});

  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
  final _nombreCtrl = TextEditingController(text: 'Lau');
  bool _guardando = false;

  // Plantillas de mensajes editables
  Map<String, String> _templates = {};
  String? _editingTemplate;
  final Map<String, TextEditingController> _templateControllers = {};

  @override
  void initState() {
    super.initState();
    // Inicializar plantillas con valores por defecto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l = ref.read(appLocalizationsProvider);
      setState(() {
        _templates = {
          'recordatorioPago': l.recordatorioPago,
          'confirmarClase': l.confirmarClase,
          'cancelarClase': l.cancelarClase,
          'cambioHorario': l.cambioHorario,
          'pagoConfirmado': l.pagoConfirmado,
          'nuevaTarifa': l.nuevaTarifa,
          'claseExtra': l.claseExtra,
          'materialesNecesarios': l.materialesNecesarios,
        };
        // Crear controllers para cada plantilla
        for (final entry in _templates.entries) {
          _templateControllers[entry.key] =
              TextEditingController(text: entry.value);
        }
      });
    });
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    for (final ctrl in _templateControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(appLocalizationsProvider);
    final dashboardAsync = ref.watch(dashboardProvider);
    final alumnosAsync = ref.watch(alumnosProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.miPerfil),
        actions: [
          TextButton(
            onPressed: _guardando ? null : _guardar,
            child: Text(l.guardar),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Avatar y nombre ──
          Center(
            child: Stack(
              children: [
                const CircleAvatar(
                  radius: 48,
                  child: Icon(Icons.person, size: 40),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child:
                        const Icon(Icons.edit, size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l.nombre, style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _nombreCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: l.tuNombre,
            ),
          ),
          const SizedBox(height: 32),
          if (_guardando) const LinearProgressIndicator(),
          const SizedBox(height: 16),

          // ── Estadísticas del mes ──
          Text(l.miResumen, style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text(l.estadisticasDelMes, style: AppTextStyles.bodySmall),
          const SizedBox(height: 12),

          dashboardAsync.when(
            data: (dashboard) {
              final alumnosCount = alumnosAsync.valueOrNull?.length ?? 0;
              final ingresosTotales = dashboard.totalIngresadoMes;
              final horasTotales = dashboard.totalHorasMes;

              // Calcular la fuente más rentable
              String? fuenteMasRentable;
              if (dashboard.fuentesResumen.isNotEmpty) {
                final fuentesMasRentables = dashboard.fuentesResumen.entries
                    .toList()
                  ..sort(
                      (a, b) => b.value.ingresado.compareTo(a.value.ingresado));
                if (fuentesMasRentables.isNotEmpty &&
                    fuentesMasRentables.first.value.ingresado > 0) {
                  fuenteMasRentable =
                      fuentesMasRentables.first.value.fuente.nombre;
                }
              }

              final ingresoPorHora =
                  horasTotales > 0 ? ingresosTotales / horasTotales : 0.0;

              if (ingresosTotales == 0 && horasTotales == 0) {
                return _buildErrorCard(
                    l.sinDatosEstadisticas, Icons.insights_outlined);
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          l.ingresosTotales,
                          NumberFormat.currency(symbol: '€', decimalDigits: 2)
                              .format(ingresosTotales),
                          Icons.euro,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          l.horas,
                          horasTotales.toStringAsFixed(1),
                          Icons.access_time,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          l.totalAlumnosActivos,
                          alumnosCount.toString(),
                          Icons.people,
                          Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          l.ingresoMedioPorClase,
                          NumberFormat.currency(symbol: '€', decimalDigits: 2)
                              .format(ingresoPorHora),
                          Icons.trending_up,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    l.fuenteMasRentable,
                    fuenteMasRentable ?? l.sinDatos,
                    Icons.star,
                    Colors.amber,
                    isWide: true,
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                _buildErrorCard(l.errorGenerico, Icons.error_outline),
          ),

          const SizedBox(height: 32),

          // ── Plantillas de mensajes ──
          Text(l.plantillasMensajes, style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),

          if (_templates.isNotEmpty) ...[
            _buildTemplateCard(
              'recordatorioPago',
              Icons.payment,
              Colors.red,
            ),
            const SizedBox(height: 8),
            _buildTemplateCard(
              'confirmarClase',
              Icons.check_circle_outline,
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildTemplateCard(
              'cancelarClase',
              Icons.cancel_outlined,
              Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildTemplateCard(
              'cambioHorario',
              Icons.schedule,
              Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildTemplateCard(
              'pagoConfirmado',
              Icons.verified,
              Colors.teal,
            ),
            const SizedBox(height: 8),
            _buildTemplateCard(
              'nuevaTarifa',
              Icons.attach_money,
              Colors.purple,
            ),
            const SizedBox(height: 8),
            _buildTemplateCard(
              'claseExtra',
              Icons.add_circle_outline,
              Colors.indigo,
            ),
            const SizedBox(height: 8),
            _buildTemplateCard(
              'materialesNecesarios',
              Icons.backpack,
              Colors.brown,
            ),
          ] else
            const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isWide = false,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[400]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(String templateKey, IconData icon, Color color) {
    final l = ref.read(appLocalizationsProvider);
    final text = _templates[templateKey] ?? '';
    final isEditing = _editingTemplate == templateKey;
    final controller = _templateControllers[templateKey];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                if (!isEditing) ...[
                  // Botones: Copiar y Editar
                  IconButton(
                    icon: Icon(Icons.copy, color: Colors.grey[600], size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l.copiado),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    tooltip: l.copiar,
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.grey[600], size: 20),
                    onPressed: () {
                      setState(() {
                        _editingTemplate = templateKey;
                        controller?.text = text;
                      });
                    },
                    tooltip: l.editar,
                    visualDensity: VisualDensity.compact,
                  ),
                ] else ...[
                  // Botones: Cancelar y Guardar
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _editingTemplate = null;
                        controller?.text = _templates[templateKey] ?? '';
                      });
                    },
                    child: Text(l.cancelar),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _templates[templateKey] = controller?.text ?? '';
                        _editingTemplate = null;
                      });
                      // TODO: Persistir en SharedPreferences
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l.guardar),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Text(l.guardar),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (!isEditing)
              Text(
                text,
                style: AppTextStyles.bodyMedium,
              )
            else
              TextField(
                controller: controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: l.plantillasMensajes,
                  border: const OutlineInputBorder(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    // TODO: persistir en SharedPreferences (Sprint 2)
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _guardando = false);
    if (mounted) {
      final l = ref.read(appLocalizationsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.perfilActualizado)),
      );
    }
  }
}
