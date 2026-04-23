import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/fuente.dart';
import '../../domain/models/empleo_config.dart';
import '../../domain/models/empleo_nomina.dart';
import 'database_provider.dart';

/// Stream de todas las fuentes de ingreso.
final fuentesProvider = StreamProvider<List<Fuente>>((ref) {
  return ref.watch(fuenteRepositoryProvider).watchAllFuentes();
});

/// Stream de una fuente por ID.
final fuenteByIdProvider = StreamProvider.family<Fuente?, String>((
  ref,
  id,
) async* {
  final fuentes = await ref.watch(fuenteRepositoryProvider).getAllFuentes();
  yield fuentes.firstWhere(
    (f) => f.id == id,
    orElse: () => throw Exception('Fuente no encontrada'),
  );
});

/// Configuración de empleo (Around) por ID de fuente.
final empleoConfigProvider = FutureProvider.family<EmpleoConfig?, String>((
  ref,
  fuenteId,
) async {
  return ref.watch(fuenteRepositoryProvider).getEmpleoConfig(fuenteId);
});

/// Nómina mensual de una fuente de empleo para un mes concreto.
/// El parámetro es un record: ({fuenteId, anio, mes}).
final empleoNominaDelMesProvider = FutureProvider.family<EmpleoNomina?,
    ({String fuenteId, int anio, int mes})>((ref, args) async {
  return ref
      .watch(fuenteRepositoryProvider)
      .getEmpleoNomina(args.fuenteId, args.anio, args.mes);
});

/// Stream de todas las nóminas de una fuente (historial completo).
final empleoNominasProvider =
    StreamProvider.family<List<EmpleoNomina>, String>((ref, fuenteId) {
  return ref
      .watch(fuenteRepositoryProvider)
      .watchEmpleoNominasByFuente(fuenteId);
});

/// Devuelve true si hoy es posterior al diaCobro configurado y el mes
/// actual aún no tiene nómina introducida → hay que recordar al usuario.
final pendienteIntroducirNominaProvider =
    FutureProvider.family<bool, ({String fuenteId, int diaCobro})>((
  ref,
  args,
) async {
  final hoy = DateTime.now();
  if (hoy.day <= args.diaCobro) return false;
  final nomina = await ref
      .watch(fuenteRepositoryProvider)
      .getEmpleoNomina(args.fuenteId, hoy.year, hoy.month);
  return nomina == null;
});
