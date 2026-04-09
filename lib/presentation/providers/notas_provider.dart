import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/nota.dart';
import '../../domain/models/etiqueta.dart';
import 'database_provider.dart';

// ── Notas ────────────────────────────────────────────────────────────────────

/// Stream de todas las notas (ordenadas por fecha de creación desc).
final notasProvider = StreamProvider<List<Nota>>((ref) {
  return ref.watch(notaRepositoryProvider).watchAllNotas();
});

/// Stream de notas filtradas por tipo.
final notasByTipoProvider = StreamProvider.family<List<Nota>, TipoNota>((
  ref,
  tipo,
) {
  return ref.watch(notaRepositoryProvider).watchNotasByTipo(tipo);
});

/// Nota por ID (para pantalla de detalle/edición).
final notaByIdProvider = FutureProvider.family<Nota?, String>((
  ref,
  id,
) async {
  return ref.watch(notaRepositoryProvider).getNotaById(id);
});

// ── Etiquetas ────────────────────────────────────────────────────────────────

/// Stream de todas las etiquetas disponibles.
final etiquetasProvider = StreamProvider<List<Etiqueta>>((ref) {
  return ref.watch(notaRepositoryProvider).watchAllEtiquetas();
});
