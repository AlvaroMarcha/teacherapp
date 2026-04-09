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
    required this.fuentesResumen,
    required this.horasExtraMes,
  });

  /// Total € cobrado en el mes actual (cobros con estado=cobrado).
  final double totalIngresadoMes;

  /// Total € pendiente de cobro (estado=pendiente + estado=parcial).
  final double totalPendienteMes;

  /// Total de horas de sesiones del mes.
  final double totalHorasMes;

  /// Número de cobros en estado pendiente o parcial.
  final int cobrosPendientes;

  /// Resumen por fuente: fuenteId → { ingresado, pendiente, horas }
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
            // Filtra cobros del mes actual
            final cobrosMes = cobros.where((c) {
              if (c.modoCobro == ModoCobro.mensual) {
                return c.periodoMes == periodoMes;
              }
              return true; // sesiones: aproximación por mes
            }).toList();

            final pendientes = cobrosMes.where(
              (c) =>
                  c.estado == EstadoCobro.pendiente ||
                  c.estado == EstadoCobro.parcial,
            );
            final cobrados = cobrosMes.where(
              (c) => c.estado == EstadoCobro.cobrado,
            );

            final totalIngresado = cobrados.fold<double>(
              0,
              (a, c) => a + c.monto,
            );
            final totalPendiente = pendientes.fold<double>(
              0,
              (a, c) => a + c.montoPendiente,
            );
            final totalHoras = sesiones
                .where((s) => s.estado == EstadoSesion.confirmada)
                .fold<double>(0, (a, s) => a + s.horas);

            // Resumen por fuente
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
                totalPendienteMes: totalPendiente,
                totalHorasMes: totalHoras,
                cobrosPendientes: pendientes.length,
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
