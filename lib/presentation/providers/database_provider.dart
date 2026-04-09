import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';
import '../../data/repositories/fuente_repository.dart';
import '../../data/repositories/alumno_repository.dart';
import '../../data/repositories/sesion_repository.dart';
import '../../data/repositories/cobro_repository.dart';
import '../../data/repositories/horas_extra_repository.dart';
import '../../data/repositories/nota_repository.dart';

// ── Database ─────────────────────────────────────────────────────────────────

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Cierra la DB actual e invalida el provider para que se recree al acceder.
/// Usado por el flujo de importar/restaurar backup.
Future<void> closeAndInvalidateDb(ProviderContainer container) async {
  final db = container.read(databaseProvider);
  await db.close();
  container.invalidate(databaseProvider);
}

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

final notaRepositoryProvider = Provider<NotaRepository>((ref) {
  return NotaRepository(ref.watch(databaseProvider));
});
