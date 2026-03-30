import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/hora_extra.dart';
import 'database_provider.dart';

/// Stream reactivo de todas las horas extra (para el dashboard).
final horasExtraProvider = StreamProvider<List<HoraExtra>>((ref) {
  return ref.watch(horasExtraRepositoryProvider).watchAllHorasExtra();
});

/// Stream reactivo de horas extra filtradas por fuente.
final horasExtraByFuenteProvider =
    StreamProvider.family<List<HoraExtra>, String>((ref, fuenteId) {
  return ref
      .watch(horasExtraRepositoryProvider)
      .watchHorasExtraByFuente(fuenteId);
});
