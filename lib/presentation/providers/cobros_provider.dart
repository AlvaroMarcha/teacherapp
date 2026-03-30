import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/cobro.dart';
import 'database_provider.dart';

/// Stream de todos los cobros.
final cobrosProvider = StreamProvider<List<Cobro>>((ref) {
  return ref.watch(cobroRepositoryProvider).watchAllCobros();
});

/// Stream de cobros pendientes (pendiente + parcial), ordenados por antigüedad.
final cobrosPendientesProvider = StreamProvider<List<Cobro>>((ref) {
  return ref.watch(cobroRepositoryProvider).watchCobrosPendientes();
});

/// Stream de cobros de una fuente.
final cobrosByFuenteProvider = StreamProvider.family<List<Cobro>, String>((
  ref,
  fuenteId,
) {
  return ref.watch(cobroRepositoryProvider).watchCobrosByFuente(fuenteId);
});
