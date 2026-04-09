class Etiqueta {
  const Etiqueta({
    required this.id,
    required this.nombre,
    this.color = '6366F1',
  });

  final String id;
  final String nombre;
  final String color;

  Etiqueta copyWith({
    String? id,
    String? nombre,
    String? color,
  }) =>
      Etiqueta(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        color: color ?? this.color,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Etiqueta && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
