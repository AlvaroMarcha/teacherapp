import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';
import '../../data/repositories/fuente_repository.dart';
import '../../data/repositories/alumno_repository.dart';
import '../../data/repositories/sesion_repository.dart';
import '../../data/repositories/cobro_repository.dart';
import '../../data/repositories/horas_extra_repository.dart';

// ── Database ─────────────────────────────────────────────────────────────────

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// ── Repositories ─────────────────────────────────────────────────────────────

final fuenteRepositoryProvider = Provider<FuenteRepository>((ref) {
  return FuenteRepository(ref.watch(databaseProvider));
});

final alumnoRepositoryProvider = Provider<AlumnoRepository>((ref) {
  return AlumnoRepository(ref.watch(databaseProvider));
});

final sesionRepositoryProvider = Provider<SesionRepository>((ref) {
  return SesionRepository(ref.watch(databaseProvider));
});

final cobroRepositoryProvider = Provider<CobroRepository>((ref) {
  return CobroRepository(ref.watch(databaseProvider));
});

final horasExtraRepositoryProvider = Provider<HorasExtraRepository>((ref) {
  return HorasExtraRepository(ref.watch(databaseProvider));
});
