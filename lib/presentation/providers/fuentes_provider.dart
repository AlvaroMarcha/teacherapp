import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/fuente.dart';
import '../../domain/models/empleo_config.dart';
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
