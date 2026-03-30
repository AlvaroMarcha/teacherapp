import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/alumno.dart';
import 'database_provider.dart';

/// Stream de todos los alumnos.
final alumnosProvider = StreamProvider<List<Alumno>>((ref) {
  return ref.watch(alumnoRepositoryProvider).watchAllAlumnos();
});

/// Stream de alumnos de una fuente concreta.
final alumnosByFuenteProvider = StreamProvider.family<List<Alumno>, String>((
  ref,
  fuenteId,
) {
  return ref.watch(alumnoRepositoryProvider).watchAlumnosByFuente(fuenteId);
});

/// Alumno por ID (future, para pantallas de detalle).
final alumnoByIdProvider = FutureProvider.family<Alumno?, String>((
  ref,
  id,
) async {
  return ref.watch(alumnoRepositoryProvider).getAlumnoById(id);
});
