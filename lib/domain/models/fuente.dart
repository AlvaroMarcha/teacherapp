import 'package:flutter/material.dart';

/// Tipos de fuente de ingreso.
enum FuenteTipo { empleo, academia, particular }

extension FuenteTipoExt on FuenteTipo {
  String get value {
    switch (this) {
      case FuenteTipo.empleo:
        return 'empleo';
      case FuenteTipo.academia:
        return 'academia';
      case FuenteTipo.particular:
        return 'particular';
    }
  }

  static FuenteTipo fromString(String value) {
    switch (value) {
      case 'empleo':
        return FuenteTipo.empleo;
      case 'academia':
        return FuenteTipo.academia;
      case 'particular':
      default:
        return FuenteTipo.particular;
    }
  }
}

/// Fuente de ingresos del profesor (Around, Angels, Particulares, etc.)
class Fuente {
  const Fuente({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.color,
    this.moneda = 'EUR',
    this.syncStatus = 'pending',
  });

  final String id;
  final String nombre;
  final FuenteTipo tipo;

  /// Color hex como string, e.g. "2563EB"
  final String color;
  final String moneda;
  final String syncStatus;

  Color get flutterColor => Color(int.parse('FF$color', radix: 16));

  Fuente copyWith({
    String? id,
    String? nombre,
    FuenteTipo? tipo,
    String? color,
    String? moneda,
    String? syncStatus,
  }) => Fuente(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    tipo: tipo ?? this.tipo,
    color: color ?? this.color,
    moneda: moneda ?? this.moneda,
    syncStatus: syncStatus ?? this.syncStatus,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Fuente && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
