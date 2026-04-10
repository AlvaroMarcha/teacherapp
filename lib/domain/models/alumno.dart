/// Alumno del profesor.
///
/// Puede pertenecer a cualquier fuente: academia (Angels) o particular.
/// Cada alumno tiene una tarifa por sesión y un campo de notas libre.
class Alumno {
  const Alumno({
    required this.id,
    required this.nombre,
    required this.fuenteId,
    required this.tarifaSesion,
    this.duracionMinutos = 60,
    this.notas = '',
    this.materia = '',
    this.nivel = '',
    this.materiales = const [],
    this.syncStatus = 'pending',
  });

  final String id;
  final String nombre;
  final String fuenteId;

  /// Tarifa por sesión según la jerarquía:
  /// 1) tarifa específica del alumno (este campo)
  /// 2) tarifa por fuente/clase
  /// 3) tarifa global del profesor
  final double tarifaSesion;

  /// Duración por defecto de sus sesiones en minutos.
  final int duracionMinutos;

  /// Campo libre de notas (contacto, observaciones, etc.).
  final String notas;

  /// Materia o asignatura que se enseña (ej: "Inglés", "Matemáticas").
  final String materia;

  /// Nivel académico (ej: "A2", "1º ESO", "2º Bachillerato").
  final String nivel;

  /// Materiales o libros utilizados (ej: ["English File A2", "Workbook"]).
  final List<String> materiales;

  final String syncStatus;

  Alumno copyWith({
    String? id,
    String? nombre,
    String? fuenteId,
    double? tarifaSesion,
    int? duracionMinutos,
    String? notas,
    String? materia,
    String? nivel,
    List<String>? materiales,
    String? syncStatus,
  }) =>
      Alumno(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        fuenteId: fuenteId ?? this.fuenteId,
        tarifaSesion: tarifaSesion ?? this.tarifaSesion,
        duracionMinutos: duracionMinutos ?? this.duracionMinutos,
        notas: notas ?? this.notas,
        materia: materia ?? this.materia,
        nivel: nivel ?? this.nivel,
        materiales: materiales ?? this.materiales,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Alumno && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
