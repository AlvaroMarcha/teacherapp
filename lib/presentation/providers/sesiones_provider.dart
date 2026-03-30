import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/sesion_recurrente.dart';
import '../../domain/models/sesion_realizada.dart';
import 'database_provider.dart';

/// Stream de todas las sesiones recurrentes (para construir el horario).
final sesionesRecurrentesProvider = StreamProvider<List<SesionRecurrente>>((
  ref,
) {
  return ref.watch(sesionRepositoryProvider).watchSesionesRecurrentes();
});

/// Stream de sesiones realizadas de un mes específico ("yyyy-MM").
final sesionesRealizadasMesProvider =
    StreamProvider.family<List<SesionRealizada>, String>((ref, periodoMes) {
      return ref
          .watch(sesionRepositoryProvider)
          .watchSesionesRealizadasByMes(periodoMes);
    });

/// Mes activo para el horario (por defecto el mes actual).
final mesActivoProvider = StateProvider<DateTime>((ref) => DateTime.now());
