import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/datetime_extension.dart';
import '../../domain/models/cobro.dart';
import '../../domain/models/fuente.dart';
import '../../domain/models/sesion_realizada.dart';
import 'cobros_provider.dart';
import 'sesiones_provider.dart';
import 'fuentes_provider.dart';
import 'horas_extra_provider.dart';

/// Datos calculados del dashboard para el mes actual.
class DashboardData {
  const DashboardData({
    required this.totalIngresadoMes,
    required this.totalPendienteMes,
    required this.totalHorasMes,
    required this.cobrosPendientes,
    required this.totalPendienteGlobal,
    required this.cobrosPendientesGlobal,
    required this.fuentesResumen,
    required this.horasExtraMes,
  });

  /// Total € cobrado en el mes actual (cobros con estado=cobrado).
  final double totalIngresadoMes;

  /// Total € pendiente de cobro del mes actual (estado=pendiente + estado=parcial).
  final double totalPendienteMes;

  /// Total de horas de sesiones confirmadas del mes.
  final double totalHorasMes;

  /// Número de cobros pendientes/parciales del mes actual.
  final int cobrosPendientes;

  /// Total € pendiente de todos los meses (alerta global para CobrosPendientesCard).
  final double totalPendienteGlobal;

  /// Número de cobros pendientes/parciales de todos los meses (alerta global).
  final int cobrosPendientesGlobal;

  /// Resumen por fuente: fuenteId → { ingresado, pendiente, horas } — solo mes actual.
  final Map<String, FuenteResumen> fuentesResumen;

  /// Horas extra del mes por fuenteId (solo fuentes tipo empleo).
  final Map<String, double> horasExtraMes;
}

class FuenteResumen {
  const FuenteResumen({
    required this.fuente,
    required this.ingresado,
    required this.pendiente,
    required this.horas,
  });

  final Fuente fuente;
  final double ingresado;
  final double pendiente;
  final double horas;
}

/// Provider del dashboard, combina cobros + sesiones + fuentes + horas extra del mes actual.
final dashboardProvider = Provider<AsyncValue<DashboardData>>((ref) {
  final periodoMes = DateTime.now().periodoMes;
  final cobrosAsync = ref.watch(cobrosProvider);
  final sesionesAsync = ref.watch(sesionesRealizadasMesProvider(periodoMes));
  final fuentesAsync = ref.watch(fuentesProvider);
  final horasExtraAsync = ref.watch(horasExtraProvider);

  return cobrosAsync.when(
    data: (cobros) => sesionesAsync.when(
      data: (sesiones) => fuentesAsync.when(
        data: (fuentes) => horasExtraAsync.when(
          data: (todasHorasExtra) {
            // IDs de sesiones del mes (excluye canceladas) para acotar cobros
            final sesionIdsDelMes = sesiones
                .where((s) => s.estado != EstadoSesion.cancelada)
                .map((s) => s.id)
                .toSet();

            // Filtra cobros del mes actual:
            //   - Mensuales: por periodoMes
            //   - Por sesión: solo si la sesión pertenece al mes actual
            final cobrosMes = cobros.where((c) {
              if (c.modoCobro == ModoCobro.mensual) {
                return c.periodoMes == periodoMes;
              }
              return c.sesionId != null && sesionIdsDelMes.contains(c.sesionId);
            }).toList();

            final pendientesMes = cobrosMes.where(
              (c) =>
                  c.estado == EstadoCobro.pendiente ||
                  c.estado == EstadoCobro.parcial,
            );
            final cobradosMes = cobrosMes.where(
              (c) => c.estado == EstadoCobro.cobrado,
            );

            final totalIngresado = cobradosMes.fold<double>(
              0,
              (a, c) => a + c.monto,
            );
            final totalPendienteMes = pendientesMes.fold<double>(
              0,
              (a, c) => a + c.montoPendiente,
            );
            final totalHoras = sesiones
                .where((s) => s.estado == EstadoSesion.confirmada)
                .fold<double>(0, (a, s) => a + s.horas);

            // Pendientes globales (todos los meses) para la alerta de CobrosPendientesCard
            final pendientesGlobal = cobros.where(
              (c) =>
                  c.estado == EstadoCobro.pendiente ||
                  c.estado == EstadoCobro.parcial,
            );
            final totalPendienteGlobal = pendientesGlobal.fold<double>(
              0,
              (a, c) => a + c.montoPendiente,
            );

            // Resumen por fuente (solo mes actual)
            final resumenMap = <String, FuenteResumen>{};
            for (final fuente in fuentes) {
              final fCobrosMes =
                  cobrosMes.where((c) => c.fuenteId == fuente.id);
              final fSesiones = sesiones.where(
                (s) =>
                    s.fuenteId == fuente.id &&
                    s.estado == EstadoSesion.confirmada,
              );
              resumenMap[fuente.id] = FuenteResumen(
                fuente: fuente,
                ingresado: fCobrosMes
                    .where((c) => c.estado == EstadoCobro.cobrado)
                    .fold<double>(0, (a, c) => a + c.monto),
                pendiente: fCobrosMes
                    .where(
                      (c) =>
                          c.estado == EstadoCobro.pendiente ||
                          c.estado == EstadoCobro.parcial,
                    )
                    .fold<double>(0, (a, c) => a + c.montoPendiente),
                horas: fSesiones.fold<double>(0, (a, s) => a + s.horas),
              );
            }

            // Horas extra del mes por fuenteId
            final horasExtraLocal = <String, double>{};
            for (final he in todasHorasExtra) {
              if (he.fecha.startsWith(periodoMes)) {
                horasExtraLocal[he.fuenteId] =
                    (horasExtraLocal[he.fuenteId] ?? 0) + he.horas;
              }
            }

            return AsyncValue.data(
              DashboardData(
                totalIngresadoMes: totalIngresado,
                totalPendienteMes: totalPendienteMes,
                totalHorasMes: totalHoras,
                cobrosPendientes: pendientesMes.length,
                totalPendienteGlobal: totalPendienteGlobal,
                cobrosPendientesGlobal: pendientesGlobal.length,
                fuentesResumen: resumenMap,
                horasExtraMes: horasExtraLocal,
              ),
            );
          },
          loading: () => const AsyncValue.loading(),
          error: (e, s) => AsyncValue.error(e, s),
        ),
        loading: () => const AsyncValue.loading(),
        error: (e, s) => AsyncValue.error(e, s),
      ),
      loading: () => const AsyncValue.loading(),
      error: (e, s) => AsyncValue.error(e, s),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});
