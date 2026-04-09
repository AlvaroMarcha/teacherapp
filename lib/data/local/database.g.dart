// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FuentesTableTable extends FuentesTable
    with TableInfo<$FuentesTableTable, FuentesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FuentesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
      'nombre', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
      'tipo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _monedaMeta = const VerificationMeta('moneda');
  @override
  late final GeneratedColumn<String> moneda = GeneratedColumn<String>(
      'moneda', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('EUR'));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, nombre, tipo, color, moneda, syncStatus];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fuentes';
  @override
  VerificationContext validateIntegrity(Insertable<FuentesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(_nombreMeta,
          nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
          _tipoMeta, tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta));
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('moneda')) {
      context.handle(_monedaMeta,
          moneda.isAcceptableOrUnknown(data['moneda']!, _monedaMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FuentesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FuentesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre'])!,
      tipo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      moneda: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}moneda'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $FuentesTableTable createAlias(String alias) {
    return $FuentesTableTable(attachedDatabase, alias);
  }
}

class FuentesTableData extends DataClass
    implements Insertable<FuentesTableData> {
  final String id;
  final String nombre;

  /// Tipo: 'empleo' | 'academia' | 'particular'
  final String tipo;

  /// Color hex sin # (e.g. "2563EB")
  final String color;
  final String moneda;

  /// Estado de sincronización: 'pending' | 'synced'
  final String syncStatus;
  const FuentesTableData(
      {required this.id,
      required this.nombre,
      required this.tipo,
      required this.color,
      required this.moneda,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nombre'] = Variable<String>(nombre);
    map['tipo'] = Variable<String>(tipo);
    map['color'] = Variable<String>(color);
    map['moneda'] = Variable<String>(moneda);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  FuentesTableCompanion toCompanion(bool nullToAbsent) {
    return FuentesTableCompanion(
      id: Value(id),
      nombre: Value(nombre),
      tipo: Value(tipo),
      color: Value(color),
      moneda: Value(moneda),
      syncStatus: Value(syncStatus),
    );
  }

  factory FuentesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FuentesTableData(
      id: serializer.fromJson<String>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      tipo: serializer.fromJson<String>(json['tipo']),
      color: serializer.fromJson<String>(json['color']),
      moneda: serializer.fromJson<String>(json['moneda']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nombre': serializer.toJson<String>(nombre),
      'tipo': serializer.toJson<String>(tipo),
      'color': serializer.toJson<String>(color),
      'moneda': serializer.toJson<String>(moneda),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  FuentesTableData copyWith(
          {String? id,
          String? nombre,
          String? tipo,
          String? color,
          String? moneda,
          String? syncStatus}) =>
      FuentesTableData(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        tipo: tipo ?? this.tipo,
        color: color ?? this.color,
        moneda: moneda ?? this.moneda,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  FuentesTableData copyWithCompanion(FuentesTableCompanion data) {
    return FuentesTableData(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      color: data.color.present ? data.color.value : this.color,
      moneda: data.moneda.present ? data.moneda.value : this.moneda,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FuentesTableData(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('tipo: $tipo, ')
          ..write('color: $color, ')
          ..write('moneda: $moneda, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, tipo, color, moneda, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FuentesTableData &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.tipo == this.tipo &&
          other.color == this.color &&
          other.moneda == this.moneda &&
          other.syncStatus == this.syncStatus);
}

class FuentesTableCompanion extends UpdateCompanion<FuentesTableData> {
  final Value<String> id;
  final Value<String> nombre;
  final Value<String> tipo;
  final Value<String> color;
  final Value<String> moneda;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const FuentesTableCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.tipo = const Value.absent(),
    this.color = const Value.absent(),
    this.moneda = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FuentesTableCompanion.insert({
    required String id,
    required String nombre,
    required String tipo,
    required String color,
    this.moneda = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        nombre = Value(nombre),
        tipo = Value(tipo),
        color = Value(color);
  static Insertable<FuentesTableData> custom({
    Expression<String>? id,
    Expression<String>? nombre,
    Expression<String>? tipo,
    Expression<String>? color,
    Expression<String>? moneda,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (tipo != null) 'tipo': tipo,
      if (color != null) 'color': color,
      if (moneda != null) 'moneda': moneda,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FuentesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? nombre,
      Value<String>? tipo,
      Value<String>? color,
      Value<String>? moneda,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return FuentesTableCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      color: color ?? this.color,
      moneda: moneda ?? this.moneda,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (moneda.present) {
      map['moneda'] = Variable<String>(moneda.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FuentesTableCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('tipo: $tipo, ')
          ..write('color: $color, ')
          ..write('moneda: $moneda, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmpleoConfigTableTable extends EmpleoConfigTable
    with TableInfo<$EmpleoConfigTableTable, EmpleoConfigTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmpleoConfigTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fuenteIdMeta =
      const VerificationMeta('fuenteId');
  @override
  late final GeneratedColumn<String> fuenteId = GeneratedColumn<String>(
      'fuente_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _salarioBaseMeta =
      const VerificationMeta('salarioBase');
  @override
  late final GeneratedColumn<double> salarioBase = GeneratedColumn<double>(
      'salario_base', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _horasSemanalesMeta =
      const VerificationMeta('horasSemanales');
  @override
  late final GeneratedColumn<double> horasSemanales = GeneratedColumn<double>(
      'horas_semanales', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _tarifaHoraExtraMeta =
      const VerificationMeta('tarifaHoraExtra');
  @override
  late final GeneratedColumn<double> tarifaHoraExtra = GeneratedColumn<double>(
      'tarifa_hora_extra', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _diaCobroMeta =
      const VerificationMeta('diaCobro');
  @override
  late final GeneratedColumn<int> diaCobro = GeneratedColumn<int>(
      'dia_cobro', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [fuenteId, salarioBase, horasSemanales, tarifaHoraExtra, diaCobro];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'empleo_config';
  @override
  VerificationContext validateIntegrity(
      Insertable<EmpleoConfigTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('fuente_id')) {
      context.handle(_fuenteIdMeta,
          fuenteId.isAcceptableOrUnknown(data['fuente_id']!, _fuenteIdMeta));
    } else if (isInserting) {
      context.missing(_fuenteIdMeta);
    }
    if (data.containsKey('salario_base')) {
      context.handle(
          _salarioBaseMeta,
          salarioBase.isAcceptableOrUnknown(
              data['salario_base']!, _salarioBaseMeta));
    } else if (isInserting) {
      context.missing(_salarioBaseMeta);
    }
    if (data.containsKey('horas_semanales')) {
      context.handle(
          _horasSemanalesMeta,
          horasSemanales.isAcceptableOrUnknown(
              data['horas_semanales']!, _horasSemanalesMeta));
    } else if (isInserting) {
      context.missing(_horasSemanalesMeta);
    }
    if (data.containsKey('tarifa_hora_extra')) {
      context.handle(
          _tarifaHoraExtraMeta,
          tarifaHoraExtra.isAcceptableOrUnknown(
              data['tarifa_hora_extra']!, _tarifaHoraExtraMeta));
    } else if (isInserting) {
      context.missing(_tarifaHoraExtraMeta);
    }
    if (data.containsKey('dia_cobro')) {
      context.handle(_diaCobroMeta,
          diaCobro.isAcceptableOrUnknown(data['dia_cobro']!, _diaCobroMeta));
    } else if (isInserting) {
      context.missing(_diaCobroMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fuenteId};
  @override
  EmpleoConfigTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmpleoConfigTableData(
      fuenteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fuente_id'])!,
      salarioBase: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}salario_base'])!,
      horasSemanales: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}horas_semanales'])!,
      tarifaHoraExtra: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}tarifa_hora_extra'])!,
      diaCobro: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dia_cobro'])!,
    );
  }

  @override
  $EmpleoConfigTableTable createAlias(String alias) {
    return $EmpleoConfigTableTable(attachedDatabase, alias);
  }
}

class EmpleoConfigTableData extends DataClass
    implements Insertable<EmpleoConfigTableData> {
  final String fuenteId;
  final double salarioBase;
  final double horasSemanales;
  final double tarifaHoraExtra;

  /// Día del mes en que se cobra (1-31).
  final int diaCobro;
  const EmpleoConfigTableData(
      {required this.fuenteId,
      required this.salarioBase,
      required this.horasSemanales,
      required this.tarifaHoraExtra,
      required this.diaCobro});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['fuente_id'] = Variable<String>(fuenteId);
    map['salario_base'] = Variable<double>(salarioBase);
    map['horas_semanales'] = Variable<double>(horasSemanales);
    map['tarifa_hora_extra'] = Variable<double>(tarifaHoraExtra);
    map['dia_cobro'] = Variable<int>(diaCobro);
    return map;
  }

  EmpleoConfigTableCompanion toCompanion(bool nullToAbsent) {
    return EmpleoConfigTableCompanion(
      fuenteId: Value(fuenteId),
      salarioBase: Value(salarioBase),
      horasSemanales: Value(horasSemanales),
      tarifaHoraExtra: Value(tarifaHoraExtra),
      diaCobro: Value(diaCobro),
    );
  }

  factory EmpleoConfigTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmpleoConfigTableData(
      fuenteId: serializer.fromJson<String>(json['fuenteId']),
      salarioBase: serializer.fromJson<double>(json['salarioBase']),
      horasSemanales: serializer.fromJson<double>(json['horasSemanales']),
      tarifaHoraExtra: serializer.fromJson<double>(json['tarifaHoraExtra']),
      diaCobro: serializer.fromJson<int>(json['diaCobro']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fuenteId': serializer.toJson<String>(fuenteId),
      'salarioBase': serializer.toJson<double>(salarioBase),
      'horasSemanales': serializer.toJson<double>(horasSemanales),
      'tarifaHoraExtra': serializer.toJson<double>(tarifaHoraExtra),
      'diaCobro': serializer.toJson<int>(diaCobro),
    };
  }

  EmpleoConfigTableData copyWith(
          {String? fuenteId,
          double? salarioBase,
          double? horasSemanales,
          double? tarifaHoraExtra,
          int? diaCobro}) =>
      EmpleoConfigTableData(
        fuenteId: fuenteId ?? this.fuenteId,
        salarioBase: salarioBase ?? this.salarioBase,
        horasSemanales: horasSemanales ?? this.horasSemanales,
        tarifaHoraExtra: tarifaHoraExtra ?? this.tarifaHoraExtra,
        diaCobro: diaCobro ?? this.diaCobro,
      );
  EmpleoConfigTableData copyWithCompanion(EmpleoConfigTableCompanion data) {
    return EmpleoConfigTableData(
      fuenteId: data.fuenteId.present ? data.fuenteId.value : this.fuenteId,
      salarioBase:
          data.salarioBase.present ? data.salarioBase.value : this.salarioBase,
      horasSemanales: data.horasSemanales.present
          ? data.horasSemanales.value
          : this.horasSemanales,
      tarifaHoraExtra: data.tarifaHoraExtra.present
          ? data.tarifaHoraExtra.value
          : this.tarifaHoraExtra,
      diaCobro: data.diaCobro.present ? data.diaCobro.value : this.diaCobro,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmpleoConfigTableData(')
          ..write('fuenteId: $fuenteId, ')
          ..write('salarioBase: $salarioBase, ')
          ..write('horasSemanales: $horasSemanales, ')
          ..write('tarifaHoraExtra: $tarifaHoraExtra, ')
          ..write('diaCobro: $diaCobro')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      fuenteId, salarioBase, horasSemanales, tarifaHoraExtra, diaCobro);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmpleoConfigTableData &&
          other.fuenteId == this.fuenteId &&
          other.salarioBase == this.salarioBase &&
          other.horasSemanales == this.horasSemanales &&
          other.tarifaHoraExtra == this.tarifaHoraExtra &&
          other.diaCobro == this.diaCobro);
}

class EmpleoConfigTableCompanion
    extends UpdateCompanion<EmpleoConfigTableData> {
  final Value<String> fuenteId;
  final Value<double> salarioBase;
  final Value<double> horasSemanales;
  final Value<double> tarifaHoraExtra;
  final Value<int> diaCobro;
  final Value<int> rowid;
  const EmpleoConfigTableCompanion({
    this.fuenteId = const Value.absent(),
    this.salarioBase = const Value.absent(),
    this.horasSemanales = const Value.absent(),
    this.tarifaHoraExtra = const Value.absent(),
    this.diaCobro = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmpleoConfigTableCompanion.insert({
    required String fuenteId,
    required double salarioBase,
    required double horasSemanales,
    required double tarifaHoraExtra,
    required int diaCobro,
    this.rowid = const Value.absent(),
  })  : fuenteId = Value(fuenteId),
        salarioBase = Value(salarioBase),
        horasSemanales = Value(horasSemanales),
        tarifaHoraExtra = Value(tarifaHoraExtra),
        diaCobro = Value(diaCobro);
  static Insertable<EmpleoConfigTableData> custom({
    Expression<String>? fuenteId,
    Expression<double>? salarioBase,
    Expression<double>? horasSemanales,
    Expression<double>? tarifaHoraExtra,
    Expression<int>? diaCobro,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fuenteId != null) 'fuente_id': fuenteId,
      if (salarioBase != null) 'salario_base': salarioBase,
      if (horasSemanales != null) 'horas_semanales': horasSemanales,
      if (tarifaHoraExtra != null) 'tarifa_hora_extra': tarifaHoraExtra,
      if (diaCobro != null) 'dia_cobro': diaCobro,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmpleoConfigTableCompanion copyWith(
      {Value<String>? fuenteId,
      Value<double>? salarioBase,
      Value<double>? horasSemanales,
      Value<double>? tarifaHoraExtra,
      Value<int>? diaCobro,
      Value<int>? rowid}) {
    return EmpleoConfigTableCompanion(
      fuenteId: fuenteId ?? this.fuenteId,
      salarioBase: salarioBase ?? this.salarioBase,
      horasSemanales: horasSemanales ?? this.horasSemanales,
      tarifaHoraExtra: tarifaHoraExtra ?? this.tarifaHoraExtra,
      diaCobro: diaCobro ?? this.diaCobro,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fuenteId.present) {
      map['fuente_id'] = Variable<String>(fuenteId.value);
    }
    if (salarioBase.present) {
      map['salario_base'] = Variable<double>(salarioBase.value);
    }
    if (horasSemanales.present) {
      map['horas_semanales'] = Variable<double>(horasSemanales.value);
    }
    if (tarifaHoraExtra.present) {
      map['tarifa_hora_extra'] = Variable<double>(tarifaHoraExtra.value);
    }
    if (diaCobro.present) {
      map['dia_cobro'] = Variable<int>(diaCobro.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmpleoConfigTableCompanion(')
          ..write('fuenteId: $fuenteId, ')
          ..write('salarioBase: $salarioBase, ')
          ..write('horasSemanales: $horasSemanales, ')
          ..write('tarifaHoraExtra: $tarifaHoraExtra, ')
          ..write('diaCobro: $diaCobro, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlumnosTableTable extends AlumnosTable
    with TableInfo<$AlumnosTableTable, AlumnosTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlumnosTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
      'nombre', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fuenteIdMeta =
      const VerificationMeta('fuenteId');
  @override
  late final GeneratedColumn<String> fuenteId = GeneratedColumn<String>(
      'fuente_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tarifaSesionMeta =
      const VerificationMeta('tarifaSesion');
  @override
  late final GeneratedColumn<double> tarifaSesion = GeneratedColumn<double>(
      'tarifa_sesion', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _duracionMinutosMeta =
      const VerificationMeta('duracionMinutos');
  @override
  late final GeneratedColumn<int> duracionMinutos = GeneratedColumn<int>(
      'duracion_minutos', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(60));
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
      'notas', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, nombre, fuenteId, tarifaSesion, duracionMinutos, notas, syncStatus];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alumnos';
  @override
  VerificationContext validateIntegrity(Insertable<AlumnosTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(_nombreMeta,
          nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('fuente_id')) {
      context.handle(_fuenteIdMeta,
          fuenteId.isAcceptableOrUnknown(data['fuente_id']!, _fuenteIdMeta));
    } else if (isInserting) {
      context.missing(_fuenteIdMeta);
    }
    if (data.containsKey('tarifa_sesion')) {
      context.handle(
          _tarifaSesionMeta,
          tarifaSesion.isAcceptableOrUnknown(
              data['tarifa_sesion']!, _tarifaSesionMeta));
    } else if (isInserting) {
      context.missing(_tarifaSesionMeta);
    }
    if (data.containsKey('duracion_minutos')) {
      context.handle(
          _duracionMinutosMeta,
          duracionMinutos.isAcceptableOrUnknown(
              data['duracion_minutos']!, _duracionMinutosMeta));
    }
    if (data.containsKey('notas')) {
      context.handle(
          _notasMeta, notas.isAcceptableOrUnknown(data['notas']!, _notasMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlumnosTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlumnosTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre'])!,
      fuenteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fuente_id'])!,
      tarifaSesion: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tarifa_sesion'])!,
      duracionMinutos: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duracion_minutos'])!,
      notas: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notas'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $AlumnosTableTable createAlias(String alias) {
    return $AlumnosTableTable(attachedDatabase, alias);
  }
}

class AlumnosTableData extends DataClass
    implements Insertable<AlumnosTableData> {
  final String id;
  final String nombre;
  final String fuenteId;
  final double tarifaSesion;
  final int duracionMinutos;
  final String notas;
  final String syncStatus;
  const AlumnosTableData(
      {required this.id,
      required this.nombre,
      required this.fuenteId,
      required this.tarifaSesion,
      required this.duracionMinutos,
      required this.notas,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nombre'] = Variable<String>(nombre);
    map['fuente_id'] = Variable<String>(fuenteId);
    map['tarifa_sesion'] = Variable<double>(tarifaSesion);
    map['duracion_minutos'] = Variable<int>(duracionMinutos);
    map['notas'] = Variable<String>(notas);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  AlumnosTableCompanion toCompanion(bool nullToAbsent) {
    return AlumnosTableCompanion(
      id: Value(id),
      nombre: Value(nombre),
      fuenteId: Value(fuenteId),
      tarifaSesion: Value(tarifaSesion),
      duracionMinutos: Value(duracionMinutos),
      notas: Value(notas),
      syncStatus: Value(syncStatus),
    );
  }

  factory AlumnosTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlumnosTableData(
      id: serializer.fromJson<String>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      fuenteId: serializer.fromJson<String>(json['fuenteId']),
      tarifaSesion: serializer.fromJson<double>(json['tarifaSesion']),
      duracionMinutos: serializer.fromJson<int>(json['duracionMinutos']),
      notas: serializer.fromJson<String>(json['notas']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nombre': serializer.toJson<String>(nombre),
      'fuenteId': serializer.toJson<String>(fuenteId),
      'tarifaSesion': serializer.toJson<double>(tarifaSesion),
      'duracionMinutos': serializer.toJson<int>(duracionMinutos),
      'notas': serializer.toJson<String>(notas),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  AlumnosTableData copyWith(
          {String? id,
          String? nombre,
          String? fuenteId,
          double? tarifaSesion,
          int? duracionMinutos,
          String? notas,
          String? syncStatus}) =>
      AlumnosTableData(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        fuenteId: fuenteId ?? this.fuenteId,
        tarifaSesion: tarifaSesion ?? this.tarifaSesion,
        duracionMinutos: duracionMinutos ?? this.duracionMinutos,
        notas: notas ?? this.notas,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  AlumnosTableData copyWithCompanion(AlumnosTableCompanion data) {
    return AlumnosTableData(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      fuenteId: data.fuenteId.present ? data.fuenteId.value : this.fuenteId,
      tarifaSesion: data.tarifaSesion.present
          ? data.tarifaSesion.value
          : this.tarifaSesion,
      duracionMinutos: data.duracionMinutos.present
          ? data.duracionMinutos.value
          : this.duracionMinutos,
      notas: data.notas.present ? data.notas.value : this.notas,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlumnosTableData(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('fuenteId: $fuenteId, ')
          ..write('tarifaSesion: $tarifaSesion, ')
          ..write('duracionMinutos: $duracionMinutos, ')
          ..write('notas: $notas, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, nombre, fuenteId, tarifaSesion, duracionMinutos, notas, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlumnosTableData &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.fuenteId == this.fuenteId &&
          other.tarifaSesion == this.tarifaSesion &&
          other.duracionMinutos == this.duracionMinutos &&
          other.notas == this.notas &&
          other.syncStatus == this.syncStatus);
}

class AlumnosTableCompanion extends UpdateCompanion<AlumnosTableData> {
  final Value<String> id;
  final Value<String> nombre;
  final Value<String> fuenteId;
  final Value<double> tarifaSesion;
  final Value<int> duracionMinutos;
  final Value<String> notas;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const AlumnosTableCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.fuenteId = const Value.absent(),
    this.tarifaSesion = const Value.absent(),
    this.duracionMinutos = const Value.absent(),
    this.notas = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlumnosTableCompanion.insert({
    required String id,
    required String nombre,
    required String fuenteId,
    required double tarifaSesion,
    this.duracionMinutos = const Value.absent(),
    this.notas = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        nombre = Value(nombre),
        fuenteId = Value(fuenteId),
        tarifaSesion = Value(tarifaSesion);
  static Insertable<AlumnosTableData> custom({
    Expression<String>? id,
    Expression<String>? nombre,
    Expression<String>? fuenteId,
    Expression<double>? tarifaSesion,
    Expression<int>? duracionMinutos,
    Expression<String>? notas,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (fuenteId != null) 'fuente_id': fuenteId,
      if (tarifaSesion != null) 'tarifa_sesion': tarifaSesion,
      if (duracionMinutos != null) 'duracion_minutos': duracionMinutos,
      if (notas != null) 'notas': notas,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlumnosTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? nombre,
      Value<String>? fuenteId,
      Value<double>? tarifaSesion,
      Value<int>? duracionMinutos,
      Value<String>? notas,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return AlumnosTableCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      fuenteId: fuenteId ?? this.fuenteId,
      tarifaSesion: tarifaSesion ?? this.tarifaSesion,
      duracionMinutos: duracionMinutos ?? this.duracionMinutos,
      notas: notas ?? this.notas,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (fuenteId.present) {
      map['fuente_id'] = Variable<String>(fuenteId.value);
    }
    if (tarifaSesion.present) {
      map['tarifa_sesion'] = Variable<double>(tarifaSesion.value);
    }
    if (duracionMinutos.present) {
      map['duracion_minutos'] = Variable<int>(duracionMinutos.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlumnosTableCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('fuenteId: $fuenteId, ')
          ..write('tarifaSesion: $tarifaSesion, ')
          ..write('duracionMinutos: $duracionMinutos, ')
          ..write('notas: $notas, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SesionesRecurrentesTableTable extends SesionesRecurrentesTable
    with
        TableInfo<$SesionesRecurrentesTableTable,
            SesionesRecurrentesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SesionesRecurrentesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _alumnoIdMeta =
      const VerificationMeta('alumnoId');
  @override
  late final GeneratedColumn<String> alumnoId = GeneratedColumn<String>(
      'alumno_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fuenteIdMeta =
      const VerificationMeta('fuenteId');
  @override
  late final GeneratedColumn<String> fuenteId = GeneratedColumn<String>(
      'fuente_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _diasSemanaMeta =
      const VerificationMeta('diasSemana');
  @override
  late final GeneratedColumn<String> diasSemana = GeneratedColumn<String>(
      'dias_semana', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _horaInicioMeta =
      const VerificationMeta('horaInicio');
  @override
  late final GeneratedColumn<String> horaInicio = GeneratedColumn<String>(
      'hora_inicio', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _horaFinMeta =
      const VerificationMeta('horaFin');
  @override
  late final GeneratedColumn<String> horaFin = GeneratedColumn<String>(
      'hora_fin', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fechaInicioMeta =
      const VerificationMeta('fechaInicio');
  @override
  late final GeneratedColumn<String> fechaInicio = GeneratedColumn<String>(
      'fecha_inicio', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fechaFinMeta =
      const VerificationMeta('fechaFin');
  @override
  late final GeneratedColumn<String> fechaFin = GeneratedColumn<String>(
      'fecha_fin', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _esPuntualMeta =
      const VerificationMeta('esPuntual');
  @override
  late final GeneratedColumn<bool> esPuntual = GeneratedColumn<bool>(
      'es_puntual', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("es_puntual" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _activaMeta = const VerificationMeta('activa');
  @override
  late final GeneratedColumn<bool> activa = GeneratedColumn<bool>(
      'activa', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("activa" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        alumnoId,
        fuenteId,
        diasSemana,
        horaInicio,
        horaFin,
        fechaInicio,
        fechaFin,
        esPuntual,
        activa,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sesiones_recurrentes';
  @override
  VerificationContext validateIntegrity(
      Insertable<SesionesRecurrentesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('alumno_id')) {
      context.handle(_alumnoIdMeta,
          alumnoId.isAcceptableOrUnknown(data['alumno_id']!, _alumnoIdMeta));
    }
    if (data.containsKey('fuente_id')) {
      context.handle(_fuenteIdMeta,
          fuenteId.isAcceptableOrUnknown(data['fuente_id']!, _fuenteIdMeta));
    } else if (isInserting) {
      context.missing(_fuenteIdMeta);
    }
    if (data.containsKey('dias_semana')) {
      context.handle(
          _diasSemanaMeta,
          diasSemana.isAcceptableOrUnknown(
              data['dias_semana']!, _diasSemanaMeta));
    } else if (isInserting) {
      context.missing(_diasSemanaMeta);
    }
    if (data.containsKey('hora_inicio')) {
      context.handle(
          _horaInicioMeta,
          horaInicio.isAcceptableOrUnknown(
              data['hora_inicio']!, _horaInicioMeta));
    } else if (isInserting) {
      context.missing(_horaInicioMeta);
    }
    if (data.containsKey('hora_fin')) {
      context.handle(_horaFinMeta,
          horaFin.isAcceptableOrUnknown(data['hora_fin']!, _horaFinMeta));
    } else if (isInserting) {
      context.missing(_horaFinMeta);
    }
    if (data.containsKey('fecha_inicio')) {
      context.handle(
          _fechaInicioMeta,
          fechaInicio.isAcceptableOrUnknown(
              data['fecha_inicio']!, _fechaInicioMeta));
    } else if (isInserting) {
      context.missing(_fechaInicioMeta);
    }
    if (data.containsKey('fecha_fin')) {
      context.handle(_fechaFinMeta,
          fechaFin.isAcceptableOrUnknown(data['fecha_fin']!, _fechaFinMeta));
    }
    if (data.containsKey('es_puntual')) {
      context.handle(_esPuntualMeta,
          esPuntual.isAcceptableOrUnknown(data['es_puntual']!, _esPuntualMeta));
    }
    if (data.containsKey('activa')) {
      context.handle(_activaMeta,
          activa.isAcceptableOrUnknown(data['activa']!, _activaMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SesionesRecurrentesTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SesionesRecurrentesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      alumnoId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alumno_id']),
      fuenteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fuente_id'])!,
      diasSemana: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dias_semana'])!,
      horaInicio: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hora_inicio'])!,
      horaFin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hora_fin'])!,
      fechaInicio: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fecha_inicio'])!,
      fechaFin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fecha_fin']),
      esPuntual: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}es_puntual'])!,
      activa: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}activa'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $SesionesRecurrentesTableTable createAlias(String alias) {
    return $SesionesRecurrentesTableTable(attachedDatabase, alias);
  }
}

class SesionesRecurrentesTableData extends DataClass
    implements Insertable<SesionesRecurrentesTableData> {
  final String id;
  final String? alumnoId;
  final String fuenteId;

  /// JSON array de días de la semana: "[1,3,5]"
  final String diasSemana;

  /// "HH:mm"
  final String horaInicio;

  /// "HH:mm"
  final String horaFin;

  /// "yyyy-MM-dd"
  final String fechaInicio;

  /// "yyyy-MM-dd" | null (indefinida)
  final String? fechaFin;

  /// true = clase puntual/única (no se repite semana a semana)
  final bool esPuntual;

  /// false = sesión archivada (no aparece en el calendario)
  final bool activa;
  final String syncStatus;
  const SesionesRecurrentesTableData(
      {required this.id,
      this.alumnoId,
      required this.fuenteId,
      required this.diasSemana,
      required this.horaInicio,
      required this.horaFin,
      required this.fechaInicio,
      this.fechaFin,
      required this.esPuntual,
      required this.activa,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || alumnoId != null) {
      map['alumno_id'] = Variable<String>(alumnoId);
    }
    map['fuente_id'] = Variable<String>(fuenteId);
    map['dias_semana'] = Variable<String>(diasSemana);
    map['hora_inicio'] = Variable<String>(horaInicio);
    map['hora_fin'] = Variable<String>(horaFin);
    map['fecha_inicio'] = Variable<String>(fechaInicio);
    if (!nullToAbsent || fechaFin != null) {
      map['fecha_fin'] = Variable<String>(fechaFin);
    }
    map['es_puntual'] = Variable<bool>(esPuntual);
    map['activa'] = Variable<bool>(activa);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  SesionesRecurrentesTableCompanion toCompanion(bool nullToAbsent) {
    return SesionesRecurrentesTableCompanion(
      id: Value(id),
      alumnoId: alumnoId == null && nullToAbsent
          ? const Value.absent()
          : Value(alumnoId),
      fuenteId: Value(fuenteId),
      diasSemana: Value(diasSemana),
      horaInicio: Value(horaInicio),
      horaFin: Value(horaFin),
      fechaInicio: Value(fechaInicio),
      fechaFin: fechaFin == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaFin),
      esPuntual: Value(esPuntual),
      activa: Value(activa),
      syncStatus: Value(syncStatus),
    );
  }

  factory SesionesRecurrentesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SesionesRecurrentesTableData(
      id: serializer.fromJson<String>(json['id']),
      alumnoId: serializer.fromJson<String?>(json['alumnoId']),
      fuenteId: serializer.fromJson<String>(json['fuenteId']),
      diasSemana: serializer.fromJson<String>(json['diasSemana']),
      horaInicio: serializer.fromJson<String>(json['horaInicio']),
      horaFin: serializer.fromJson<String>(json['horaFin']),
      fechaInicio: serializer.fromJson<String>(json['fechaInicio']),
      fechaFin: serializer.fromJson<String?>(json['fechaFin']),
      esPuntual: serializer.fromJson<bool>(json['esPuntual']),
      activa: serializer.fromJson<bool>(json['activa']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'alumnoId': serializer.toJson<String?>(alumnoId),
      'fuenteId': serializer.toJson<String>(fuenteId),
      'diasSemana': serializer.toJson<String>(diasSemana),
      'horaInicio': serializer.toJson<String>(horaInicio),
      'horaFin': serializer.toJson<String>(horaFin),
      'fechaInicio': serializer.toJson<String>(fechaInicio),
      'fechaFin': serializer.toJson<String?>(fechaFin),
      'esPuntual': serializer.toJson<bool>(esPuntual),
      'activa': serializer.toJson<bool>(activa),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  SesionesRecurrentesTableData copyWith(
          {String? id,
          Value<String?> alumnoId = const Value.absent(),
          String? fuenteId,
          String? diasSemana,
          String? horaInicio,
          String? horaFin,
          String? fechaInicio,
          Value<String?> fechaFin = const Value.absent(),
          bool? esPuntual,
          bool? activa,
          String? syncStatus}) =>
      SesionesRecurrentesTableData(
        id: id ?? this.id,
        alumnoId: alumnoId.present ? alumnoId.value : this.alumnoId,
        fuenteId: fuenteId ?? this.fuenteId,
        diasSemana: diasSemana ?? this.diasSemana,
        horaInicio: horaInicio ?? this.horaInicio,
        horaFin: horaFin ?? this.horaFin,
        fechaInicio: fechaInicio ?? this.fechaInicio,
        fechaFin: fechaFin.present ? fechaFin.value : this.fechaFin,
        esPuntual: esPuntual ?? this.esPuntual,
        activa: activa ?? this.activa,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  SesionesRecurrentesTableData copyWithCompanion(
      SesionesRecurrentesTableCompanion data) {
    return SesionesRecurrentesTableData(
      id: data.id.present ? data.id.value : this.id,
      alumnoId: data.alumnoId.present ? data.alumnoId.value : this.alumnoId,
      fuenteId: data.fuenteId.present ? data.fuenteId.value : this.fuenteId,
      diasSemana:
          data.diasSemana.present ? data.diasSemana.value : this.diasSemana,
      horaInicio:
          data.horaInicio.present ? data.horaInicio.value : this.horaInicio,
      horaFin: data.horaFin.present ? data.horaFin.value : this.horaFin,
      fechaInicio:
          data.fechaInicio.present ? data.fechaInicio.value : this.fechaInicio,
      fechaFin: data.fechaFin.present ? data.fechaFin.value : this.fechaFin,
      esPuntual: data.esPuntual.present ? data.esPuntual.value : this.esPuntual,
      activa: data.activa.present ? data.activa.value : this.activa,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SesionesRecurrentesTableData(')
          ..write('id: $id, ')
          ..write('alumnoId: $alumnoId, ')
          ..write('fuenteId: $fuenteId, ')
          ..write('diasSemana: $diasSemana, ')
          ..write('horaInicio: $horaInicio, ')
          ..write('horaFin: $horaFin, ')
          ..write('fechaInicio: $fechaInicio, ')
          ..write('fechaFin: $fechaFin, ')
          ..write('esPuntual: $esPuntual, ')
          ..write('activa: $activa, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      alumnoId,
      fuenteId,
      diasSemana,
      horaInicio,
      horaFin,
      fechaInicio,
      fechaFin,
      esPuntual,
      activa,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SesionesRecurrentesTableData &&
          other.id == this.id &&
          other.alumnoId == this.alumnoId &&
          other.fuenteId == this.fuenteId &&
          other.diasSemana == this.diasSemana &&
          other.horaInicio == this.horaInicio &&
          other.horaFin == this.horaFin &&
          other.fechaInicio == this.fechaInicio &&
          other.fechaFin == this.fechaFin &&
          other.esPuntual == this.esPuntual &&
          other.activa == this.activa &&
          other.syncStatus == this.syncStatus);
}

class SesionesRecurrentesTableCompanion
    extends UpdateCompanion<SesionesRecurrentesTableData> {
  final Value<String> id;
  final Value<String?> alumnoId;
  final Value<String> fuenteId;
  final Value<String> diasSemana;
  final Value<String> horaInicio;
  final Value<String> horaFin;
  final Value<String> fechaInicio;
  final Value<String?> fechaFin;
  final Value<bool> esPuntual;
  final Value<bool> activa;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const SesionesRecurrentesTableCompanion({
    this.id = const Value.absent(),
    this.alumnoId = const Value.absent(),
    this.fuenteId = const Value.absent(),
    this.diasSemana = const Value.absent(),
    this.horaInicio = const Value.absent(),
    this.horaFin = const Value.absent(),
    this.fechaInicio = const Value.absent(),
    this.fechaFin = const Value.absent(),
    this.esPuntual = const Value.absent(),
    this.activa = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SesionesRecurrentesTableCompanion.insert({
    required String id,
    this.alumnoId = const Value.absent(),
    required String fuenteId,
    required String diasSemana,
    required String horaInicio,
    required String horaFin,
    required String fechaInicio,
    this.fechaFin = const Value.absent(),
    this.esPuntual = const Value.absent(),
    this.activa = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fuenteId = Value(fuenteId),
        diasSemana = Value(diasSemana),
        horaInicio = Value(horaInicio),
        horaFin = Value(horaFin),
        fechaInicio = Value(fechaInicio);
  static Insertable<SesionesRecurrentesTableData> custom({
    Expression<String>? id,
    Expression<String>? alumnoId,
    Expression<String>? fuenteId,
    Expression<String>? diasSemana,
    Expression<String>? horaInicio,
    Expression<String>? horaFin,
    Expression<String>? fechaInicio,
    Expression<String>? fechaFin,
    Expression<bool>? esPuntual,
    Expression<bool>? activa,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (alumnoId != null) 'alumno_id': alumnoId,
      if (fuenteId != null) 'fuente_id': fuenteId,
      if (diasSemana != null) 'dias_semana': diasSemana,
      if (horaInicio != null) 'hora_inicio': horaInicio,
      if (horaFin != null) 'hora_fin': horaFin,
      if (fechaInicio != null) 'fecha_inicio': fechaInicio,
      if (fechaFin != null) 'fecha_fin': fechaFin,
      if (esPuntual != null) 'es_puntual': esPuntual,
      if (activa != null) 'activa': activa,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SesionesRecurrentesTableCompanion copyWith(
      {Value<String>? id,
      Value<String?>? alumnoId,
      Value<String>? fuenteId,
      Value<String>? diasSemana,
      Value<String>? horaInicio,
      Value<String>? horaFin,
      Value<String>? fechaInicio,
      Value<String?>? fechaFin,
      Value<bool>? esPuntual,
      Value<bool>? activa,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return SesionesRecurrentesTableCompanion(
      id: id ?? this.id,
      alumnoId: alumnoId ?? this.alumnoId,
      fuenteId: fuenteId ?? this.fuenteId,
      diasSemana: diasSemana ?? this.diasSemana,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      esPuntual: esPuntual ?? this.esPuntual,
      activa: activa ?? this.activa,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (alumnoId.present) {
      map['alumno_id'] = Variable<String>(alumnoId.value);
    }
    if (fuenteId.present) {
      map['fuente_id'] = Variable<String>(fuenteId.value);
    }
    if (diasSemana.present) {
      map['dias_semana'] = Variable<String>(diasSemana.value);
    }
    if (horaInicio.present) {
      map['hora_inicio'] = Variable<String>(horaInicio.value);
    }
    if (horaFin.present) {
      map['hora_fin'] = Variable<String>(horaFin.value);
    }
    if (fechaInicio.present) {
      map['fecha_inicio'] = Variable<String>(fechaInicio.value);
    }
    if (fechaFin.present) {
      map['fecha_fin'] = Variable<String>(fechaFin.value);
    }
    if (esPuntual.present) {
      map['es_puntual'] = Variable<bool>(esPuntual.value);
    }
    if (activa.present) {
      map['activa'] = Variable<bool>(activa.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SesionesRecurrentesTableCompanion(')
          ..write('id: $id, ')
          ..write('alumnoId: $alumnoId, ')
          ..write('fuenteId: $fuenteId, ')
          ..write('diasSemana: $diasSemana, ')
          ..write('horaInicio: $horaInicio, ')
          ..write('horaFin: $horaFin, ')
          ..write('fechaInicio: $fechaInicio, ')
          ..write('fechaFin: $fechaFin, ')
          ..write('esPuntual: $esPuntual, ')
          ..write('activa: $activa, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SesionesRealizadasTableTable extends SesionesRealizadasTable
    with TableInfo<$SesionesRealizadasTableTable, SesionesRealizadasTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SesionesRealizadasTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _alumnoIdMeta =
      const VerificationMeta('alumnoId');
  @override
  late final GeneratedColumn<String> alumnoId = GeneratedColumn<String>(
      'alumno_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fuenteIdMeta =
      const VerificationMeta('fuenteId');
  @override
  late final GeneratedColumn<String> fuenteId = GeneratedColumn<String>(
      'fuente_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<String> fecha = GeneratedColumn<String>(
      'fecha', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _horasMeta = const VerificationMeta('horas');
  @override
  late final GeneratedColumn<double> horas = GeneratedColumn<double>(
      'horas', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _cobroMeta = const VerificationMeta('cobro');
  @override
  late final GeneratedColumn<double> cobro = GeneratedColumn<double>(
      'cobro', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
      'estado', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pendiente'));
  static const VerificationMeta _sesionRecurrenteIdMeta =
      const VerificationMeta('sesionRecurrenteId');
  @override
  late final GeneratedColumn<String> sesionRecurrenteId =
      GeneratedColumn<String>('sesion_recurrente_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
      'notas', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        alumnoId,
        fuenteId,
        fecha,
        horas,
        cobro,
        estado,
        sesionRecurrenteId,
        notas,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sesiones_realizadas';
  @override
  VerificationContext validateIntegrity(
      Insertable<SesionesRealizadasTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('alumno_id')) {
      context.handle(_alumnoIdMeta,
          alumnoId.isAcceptableOrUnknown(data['alumno_id']!, _alumnoIdMeta));
    }
    if (data.containsKey('fuente_id')) {
      context.handle(_fuenteIdMeta,
          fuenteId.isAcceptableOrUnknown(data['fuente_id']!, _fuenteIdMeta));
    } else if (isInserting) {
      context.missing(_fuenteIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
          _fechaMeta, fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta));
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('horas')) {
      context.handle(
          _horasMeta, horas.isAcceptableOrUnknown(data['horas']!, _horasMeta));
    } else if (isInserting) {
      context.missing(_horasMeta);
    }
    if (data.containsKey('cobro')) {
      context.handle(
          _cobroMeta, cobro.isAcceptableOrUnknown(data['cobro']!, _cobroMeta));
    } else if (isInserting) {
      context.missing(_cobroMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(_estadoMeta,
          estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta));
    }
    if (data.containsKey('sesion_recurrente_id')) {
      context.handle(
          _sesionRecurrenteIdMeta,
          sesionRecurrenteId.isAcceptableOrUnknown(
              data['sesion_recurrente_id']!, _sesionRecurrenteIdMeta));
    }
    if (data.containsKey('notas')) {
      context.handle(
          _notasMeta, notas.isAcceptableOrUnknown(data['notas']!, _notasMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SesionesRealizadasTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SesionesRealizadasTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      alumnoId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alumno_id']),
      fuenteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fuente_id'])!,
      fecha: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fecha'])!,
      horas: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}horas'])!,
      cobro: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cobro'])!,
      estado: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}estado'])!,
      sesionRecurrenteId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}sesion_recurrente_id']),
      notas: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notas'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $SesionesRealizadasTableTable createAlias(String alias) {
    return $SesionesRealizadasTableTable(attachedDatabase, alias);
  }
}

class SesionesRealizadasTableData extends DataClass
    implements Insertable<SesionesRealizadasTableData> {
  final String id;
  final String? alumnoId;
  final String fuenteId;

  /// "yyyy-MM-dd"
  final String fecha;

  /// Duración en horas (decimal: 0.75 = 45 min)
  final double horas;

  /// Importe calculado (€)
  final double cobro;

  /// 'pendiente' | 'confirmada' | 'cancelada'
  final String estado;

  /// FK opcional a la sesión recurrente que originó este registro.
  final String? sesionRecurrenteId;
  final String notas;
  final String syncStatus;
  const SesionesRealizadasTableData(
      {required this.id,
      this.alumnoId,
      required this.fuenteId,
      required this.fecha,
      required this.horas,
      required this.cobro,
      required this.estado,
      this.sesionRecurrenteId,
      required this.notas,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || alumnoId != null) {
      map['alumno_id'] = Variable<String>(alumnoId);
    }
    map['fuente_id'] = Variable<String>(fuenteId);
    map['fecha'] = Variable<String>(fecha);
    map['horas'] = Variable<double>(horas);
    map['cobro'] = Variable<double>(cobro);
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || sesionRecurrenteId != null) {
      map['sesion_recurrente_id'] = Variable<String>(sesionRecurrenteId);
    }
    map['notas'] = Variable<String>(notas);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  SesionesRealizadasTableCompanion toCompanion(bool nullToAbsent) {
    return SesionesRealizadasTableCompanion(
      id: Value(id),
      alumnoId: alumnoId == null && nullToAbsent
          ? const Value.absent()
          : Value(alumnoId),
      fuenteId: Value(fuenteId),
      fecha: Value(fecha),
      horas: Value(horas),
      cobro: Value(cobro),
      estado: Value(estado),
      sesionRecurrenteId: sesionRecurrenteId == null && nullToAbsent
          ? const Value.absent()
          : Value(sesionRecurrenteId),
      notas: Value(notas),
      syncStatus: Value(syncStatus),
    );
  }

  factory SesionesRealizadasTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SesionesRealizadasTableData(
      id: serializer.fromJson<String>(json['id']),
      alumnoId: serializer.fromJson<String?>(json['alumnoId']),
      fuenteId: serializer.fromJson<String>(json['fuenteId']),
      fecha: serializer.fromJson<String>(json['fecha']),
      horas: serializer.fromJson<double>(json['horas']),
      cobro: serializer.fromJson<double>(json['cobro']),
      estado: serializer.fromJson<String>(json['estado']),
      sesionRecurrenteId:
          serializer.fromJson<String?>(json['sesionRecurrenteId']),
      notas: serializer.fromJson<String>(json['notas']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'alumnoId': serializer.toJson<String?>(alumnoId),
      'fuenteId': serializer.toJson<String>(fuenteId),
      'fecha': serializer.toJson<String>(fecha),
      'horas': serializer.toJson<double>(horas),
      'cobro': serializer.toJson<double>(cobro),
      'estado': serializer.toJson<String>(estado),
      'sesionRecurrenteId': serializer.toJson<String?>(sesionRecurrenteId),
      'notas': serializer.toJson<String>(notas),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  SesionesRealizadasTableData copyWith(
          {String? id,
          Value<String?> alumnoId = const Value.absent(),
          String? fuenteId,
          String? fecha,
          double? horas,
          double? cobro,
          String? estado,
          Value<String?> sesionRecurrenteId = const Value.absent(),
          String? notas,
          String? syncStatus}) =>
      SesionesRealizadasTableData(
        id: id ?? this.id,
        alumnoId: alumnoId.present ? alumnoId.value : this.alumnoId,
        fuenteId: fuenteId ?? this.fuenteId,
        fecha: fecha ?? this.fecha,
        horas: horas ?? this.horas,
        cobro: cobro ?? this.cobro,
        estado: estado ?? this.estado,
        sesionRecurrenteId: sesionRecurrenteId.present
            ? sesionRecurrenteId.value
            : this.sesionRecurrenteId,
        notas: notas ?? this.notas,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  SesionesRealizadasTableData copyWithCompanion(
      SesionesRealizadasTableCompanion data) {
    return SesionesRealizadasTableData(
      id: data.id.present ? data.id.value : this.id,
      alumnoId: data.alumnoId.present ? data.alumnoId.value : this.alumnoId,
      fuenteId: data.fuenteId.present ? data.fuenteId.value : this.fuenteId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      horas: data.horas.present ? data.horas.value : this.horas,
      cobro: data.cobro.present ? data.cobro.value : this.cobro,
      estado: data.estado.present ? data.estado.value : this.estado,
      sesionRecurrenteId: data.sesionRecurrenteId.present
          ? data.sesionRecurrenteId.value
          : this.sesionRecurrenteId,
      notas: data.notas.present ? data.notas.value : this.notas,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SesionesRealizadasTableData(')
          ..write('id: $id, ')
          ..write('alumnoId: $alumnoId, ')
          ..write('fuenteId: $fuenteId, ')
          ..write('fecha: $fecha, ')
          ..write('horas: $horas, ')
          ..write('cobro: $cobro, ')
          ..write('estado: $estado, ')
          ..write('sesionRecurrenteId: $sesionRecurrenteId, ')
          ..write('notas: $notas, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, alumnoId, fuenteId, fecha, horas, cobro,
      estado, sesionRecurrenteId, notas, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SesionesRealizadasTableData &&
          other.id == this.id &&
          other.alumnoId == this.alumnoId &&
          other.fuenteId == this.fuenteId &&
          other.fecha == this.fecha &&
          other.horas == this.horas &&
          other.cobro == this.cobro &&
          other.estado == this.estado &&
          other.sesionRecurrenteId == this.sesionRecurrenteId &&
          other.notas == this.notas &&
          other.syncStatus == this.syncStatus);
}

class SesionesRealizadasTableCompanion
    extends UpdateCompanion<SesionesRealizadasTableData> {
  final Value<String> id;
  final Value<String?> alumnoId;
  final Value<String> fuenteId;
  final Value<String> fecha;
  final Value<double> horas;
  final Value<double> cobro;
  final Value<String> estado;
  final Value<String?> sesionRecurrenteId;
  final Value<String> notas;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const SesionesRealizadasTableCompanion({
    this.id = const Value.absent(),
    this.alumnoId = const Value.absent(),
    this.fuenteId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.horas = const Value.absent(),
    this.cobro = const Value.absent(),
    this.estado = const Value.absent(),
    this.sesionRecurrenteId = const Value.absent(),
    this.notas = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SesionesRealizadasTableCompanion.insert({
    required String id,
    this.alumnoId = const Value.absent(),
    required String fuenteId,
    required String fecha,
    required double horas,
    required double cobro,
    this.estado = const Value.absent(),
    this.sesionRecurrenteId = const Value.absent(),
    this.notas = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fuenteId = Value(fuenteId),
        fecha = Value(fecha),
        horas = Value(horas),
        cobro = Value(cobro);
  static Insertable<SesionesRealizadasTableData> custom({
    Expression<String>? id,
    Expression<String>? alumnoId,
    Expression<String>? fuenteId,
    Expression<String>? fecha,
    Expression<double>? horas,
    Expression<double>? cobro,
    Expression<String>? estado,
    Expression<String>? sesionRecurrenteId,
    Expression<String>? notas,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (alumnoId != null) 'alumno_id': alumnoId,
      if (fuenteId != null) 'fuente_id': fuenteId,
      if (fecha != null) 'fecha': fecha,
      if (horas != null) 'horas': horas,
      if (cobro != null) 'cobro': cobro,
      if (estado != null) 'estado': estado,
      if (sesionRecurrenteId != null)
        'sesion_recurrente_id': sesionRecurrenteId,
      if (notas != null) 'notas': notas,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SesionesRealizadasTableCompanion copyWith(
      {Value<String>? id,
      Value<String?>? alumnoId,
      Value<String>? fuenteId,
      Value<String>? fecha,
      Value<double>? horas,
      Value<double>? cobro,
      Value<String>? estado,
      Value<String?>? sesionRecurrenteId,
      Value<String>? notas,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return SesionesRealizadasTableCompanion(
      id: id ?? this.id,
      alumnoId: alumnoId ?? this.alumnoId,
      fuenteId: fuenteId ?? this.fuenteId,
      fecha: fecha ?? this.fecha,
      horas: horas ?? this.horas,
      cobro: cobro ?? this.cobro,
      estado: estado ?? this.estado,
      sesionRecurrenteId: sesionRecurrenteId ?? this.sesionRecurrenteId,
      notas: notas ?? this.notas,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (alumnoId.present) {
      map['alumno_id'] = Variable<String>(alumnoId.value);
    }
    if (fuenteId.present) {
      map['fuente_id'] = Variable<String>(fuenteId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<String>(fecha.value);
    }
    if (horas.present) {
      map['horas'] = Variable<double>(horas.value);
    }
    if (cobro.present) {
      map['cobro'] = Variable<double>(cobro.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (sesionRecurrenteId.present) {
      map['sesion_recurrente_id'] = Variable<String>(sesionRecurrenteId.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SesionesRealizadasTableCompanion(')
          ..write('id: $id, ')
          ..write('alumnoId: $alumnoId, ')
          ..write('fuenteId: $fuenteId, ')
          ..write('fecha: $fecha, ')
          ..write('horas: $horas, ')
          ..write('cobro: $cobro, ')
          ..write('estado: $estado, ')
          ..write('sesionRecurrenteId: $sesionRecurrenteId, ')
          ..write('notas: $notas, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CobrosTableTable extends CobrosTable
    with TableInfo<$CobrosTableTable, CobrosTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CobrosTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sesionIdMeta =
      const VerificationMeta('sesionId');
  @override
  late final GeneratedColumn<String> sesionId = GeneratedColumn<String>(
      'sesion_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _alumnoIdMeta =
      const VerificationMeta('alumnoId');
  @override
  late final GeneratedColumn<String> alumnoId = GeneratedColumn<String>(
      'alumno_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fuenteIdMeta =
      const VerificationMeta('fuenteId');
  @override
  late final GeneratedColumn<String> fuenteId = GeneratedColumn<String>(
      'fuente_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modoCobroMeta =
      const VerificationMeta('modoCobro');
  @override
  late final GeneratedColumn<String> modoCobro = GeneratedColumn<String>(
      'modo_cobro', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _periodoMesMeta =
      const VerificationMeta('periodoMes');
  @override
  late final GeneratedColumn<String> periodoMes = GeneratedColumn<String>(
      'periodo_mes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<double> monto = GeneratedColumn<double>(
      'monto', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _montoParcialMeta =
      const VerificationMeta('montoParcial');
  @override
  late final GeneratedColumn<double> montoParcial = GeneratedColumn<double>(
      'monto_parcial', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
      'estado', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pendiente'));
  static const VerificationMeta _fechaCobroMeta =
      const VerificationMeta('fechaCobro');
  @override
  late final GeneratedColumn<String> fechaCobro = GeneratedColumn<String>(
      'fecha_cobro', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
      'notas', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sesionId,
        alumnoId,
        fuenteId,
        modoCobro,
        periodoMes,
        monto,
        montoParcial,
        estado,
        fechaCobro,
        notas,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cobros';
  @override
  VerificationContext validateIntegrity(Insertable<CobrosTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sesion_id')) {
      context.handle(_sesionIdMeta,
          sesionId.isAcceptableOrUnknown(data['sesion_id']!, _sesionIdMeta));
    }
    if (data.containsKey('alumno_id')) {
      context.handle(_alumnoIdMeta,
          alumnoId.isAcceptableOrUnknown(data['alumno_id']!, _alumnoIdMeta));
    }
    if (data.containsKey('fuente_id')) {
      context.handle(_fuenteIdMeta,
          fuenteId.isAcceptableOrUnknown(data['fuente_id']!, _fuenteIdMeta));
    } else if (isInserting) {
      context.missing(_fuenteIdMeta);
    }
    if (data.containsKey('modo_cobro')) {
      context.handle(_modoCobroMeta,
          modoCobro.isAcceptableOrUnknown(data['modo_cobro']!, _modoCobroMeta));
    } else if (isInserting) {
      context.missing(_modoCobroMeta);
    }
    if (data.containsKey('periodo_mes')) {
      context.handle(
          _periodoMesMeta,
          periodoMes.isAcceptableOrUnknown(
              data['periodo_mes']!, _periodoMesMeta));
    }
    if (data.containsKey('monto')) {
      context.handle(
          _montoMeta, monto.isAcceptableOrUnknown(data['monto']!, _montoMeta));
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    if (data.containsKey('monto_parcial')) {
      context.handle(
          _montoParcialMeta,
          montoParcial.isAcceptableOrUnknown(
              data['monto_parcial']!, _montoParcialMeta));
    }
    if (data.containsKey('estado')) {
      context.handle(_estadoMeta,
          estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta));
    }
    if (data.containsKey('fecha_cobro')) {
      context.handle(
          _fechaCobroMeta,
          fechaCobro.isAcceptableOrUnknown(
              data['fecha_cobro']!, _fechaCobroMeta));
    }
    if (data.containsKey('notas')) {
      context.handle(
          _notasMeta, notas.isAcceptableOrUnknown(data['notas']!, _notasMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CobrosTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CobrosTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sesionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sesion_id']),
      alumnoId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alumno_id']),
      fuenteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fuente_id'])!,
      modoCobro: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}modo_cobro'])!,
      periodoMes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}periodo_mes']),
      monto: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monto'])!,
      montoParcial: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monto_parcial']),
      estado: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}estado'])!,
      fechaCobro: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fecha_cobro']),
      notas: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notas'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $CobrosTableTable createAlias(String alias) {
    return $CobrosTableTable(attachedDatabase, alias);
  }
}

class CobrosTableData extends DataClass implements Insertable<CobrosTableData> {
  final String id;
  final String? sesionId;
  final String? alumnoId;
  final String fuenteId;

  /// 'sesion' | 'mensual'
  final String modoCobro;

  /// "yyyy-MM" para cobros mensuales
  final String? periodoMes;

  /// Importe total del cobro (€)
  final double monto;

  /// Importe cobrado en pago parcial (€)
  final double? montoParcial;

  /// 'pendiente' | 'cobrado' | 'parcial'
  final String estado;

  /// "yyyy-MM-dd" de cuándo se cobró
  final String? fechaCobro;
  final String notas;
  final String syncStatus;
  const CobrosTableData(
      {required this.id,
      this.sesionId,
      this.alumnoId,
      required this.fuenteId,
      required this.modoCobro,
      this.periodoMes,
      required this.monto,
      this.montoParcial,
      required this.estado,
      this.fechaCobro,
      required this.notas,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || sesionId != null) {
      map['sesion_id'] = Variable<String>(sesionId);
    }
    if (!nullToAbsent || alumnoId != null) {
      map['alumno_id'] = Variable<String>(alumnoId);
    }
    map['fuente_id'] = Variable<String>(fuenteId);
    map['modo_cobro'] = Variable<String>(modoCobro);
    if (!nullToAbsent || periodoMes != null) {
      map['periodo_mes'] = Variable<String>(periodoMes);
    }
    map['monto'] = Variable<double>(monto);
    if (!nullToAbsent || montoParcial != null) {
      map['monto_parcial'] = Variable<double>(montoParcial);
    }
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || fechaCobro != null) {
      map['fecha_cobro'] = Variable<String>(fechaCobro);
    }
    map['notas'] = Variable<String>(notas);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  CobrosTableCompanion toCompanion(bool nullToAbsent) {
    return CobrosTableCompanion(
      id: Value(id),
      sesionId: sesionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sesionId),
      alumnoId: alumnoId == null && nullToAbsent
          ? const Value.absent()
          : Value(alumnoId),
      fuenteId: Value(fuenteId),
      modoCobro: Value(modoCobro),
      periodoMes: periodoMes == null && nullToAbsent
          ? const Value.absent()
          : Value(periodoMes),
      monto: Value(monto),
      montoParcial: montoParcial == null && nullToAbsent
          ? const Value.absent()
          : Value(montoParcial),
      estado: Value(estado),
      fechaCobro: fechaCobro == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaCobro),
      notas: Value(notas),
      syncStatus: Value(syncStatus),
    );
  }

  factory CobrosTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CobrosTableData(
      id: serializer.fromJson<String>(json['id']),
      sesionId: serializer.fromJson<String?>(json['sesionId']),
      alumnoId: serializer.fromJson<String?>(json['alumnoId']),
      fuenteId: serializer.fromJson<String>(json['fuenteId']),
      modoCobro: serializer.fromJson<String>(json['modoCobro']),
      periodoMes: serializer.fromJson<String?>(json['periodoMes']),
      monto: serializer.fromJson<double>(json['monto']),
      montoParcial: serializer.fromJson<double?>(json['montoParcial']),
      estado: serializer.fromJson<String>(json['estado']),
      fechaCobro: serializer.fromJson<String?>(json['fechaCobro']),
      notas: serializer.fromJson<String>(json['notas']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sesionId': serializer.toJson<String?>(sesionId),
      'alumnoId': serializer.toJson<String?>(alumnoId),
      'fuenteId': serializer.toJson<String>(fuenteId),
      'modoCobro': serializer.toJson<String>(modoCobro),
      'periodoMes': serializer.toJson<String?>(periodoMes),
      'monto': serializer.toJson<double>(monto),
      'montoParcial': serializer.toJson<double?>(montoParcial),
      'estado': serializer.toJson<String>(estado),
      'fechaCobro': serializer.toJson<String?>(fechaCobro),
      'notas': serializer.toJson<String>(notas),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  CobrosTableData copyWith(
          {String? id,
          Value<String?> sesionId = const Value.absent(),
          Value<String?> alumnoId = const Value.absent(),
          String? fuenteId,
          String? modoCobro,
          Value<String?> periodoMes = const Value.absent(),
          double? monto,
          Value<double?> montoParcial = const Value.absent(),
          String? estado,
          Value<String?> fechaCobro = const Value.absent(),
          String? notas,
          String? syncStatus}) =>
      CobrosTableData(
        id: id ?? this.id,
        sesionId: sesionId.present ? sesionId.value : this.sesionId,
        alumnoId: alumnoId.present ? alumnoId.value : this.alumnoId,
        fuenteId: fuenteId ?? this.fuenteId,
        modoCobro: modoCobro ?? this.modoCobro,
        periodoMes: periodoMes.present ? periodoMes.value : this.periodoMes,
        monto: monto ?? this.monto,
        montoParcial:
            montoParcial.present ? montoParcial.value : this.montoParcial,
        estado: estado ?? this.estado,
        fechaCobro: fechaCobro.present ? fechaCobro.value : this.fechaCobro,
        notas: notas ?? this.notas,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  CobrosTableData copyWithCompanion(CobrosTableCompanion data) {
    return CobrosTableData(
      id: data.id.present ? data.id.value : this.id,
      sesionId: data.sesionId.present ? data.sesionId.value : this.sesionId,
      alumnoId: data.alumnoId.present ? data.alumnoId.value : this.alumnoId,
      fuenteId: data.fuenteId.present ? data.fuenteId.value : this.fuenteId,
      modoCobro: data.modoCobro.present ? data.modoCobro.value : this.modoCobro,
      periodoMes:
          data.periodoMes.present ? data.periodoMes.value : this.periodoMes,
      monto: data.monto.present ? data.monto.value : this.monto,
      montoParcial: data.montoParcial.present
          ? data.montoParcial.value
          : this.montoParcial,
      estado: data.estado.present ? data.estado.value : this.estado,
      fechaCobro:
          data.fechaCobro.present ? data.fechaCobro.value : this.fechaCobro,
      notas: data.notas.present ? data.notas.value : this.notas,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CobrosTableData(')
          ..write('id: $id, ')
          ..write('sesionId: $sesionId, ')
          ..write('alumnoId: $alumnoId, ')
          ..write('fuenteId: $fuenteId, ')
          ..write('modoCobro: $modoCobro, ')
          ..write('periodoMes: $periodoMes, ')
          ..write('monto: $monto, ')
          ..write('montoParcial: $montoParcial, ')
          ..write('estado: $estado, ')
          ..write('fechaCobro: $fechaCobro, ')
          ..write('notas: $notas, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sesionId, alumnoId, fuenteId, modoCobro,
      periodoMes, monto, montoParcial, estado, fechaCobro, notas, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CobrosTableData &&
          other.id == this.id &&
          other.sesionId == this.sesionId &&
          other.alumnoId == this.alumnoId &&
          other.fuenteId == this.fuenteId &&
          other.modoCobro == this.modoCobro &&
          other.periodoMes == this.periodoMes &&
          other.monto == this.monto &&
          other.montoParcial == this.montoParcial &&
          other.estado == this.estado &&
          other.fechaCobro == this.fechaCobro &&
          other.notas == this.notas &&
          other.syncStatus == this.syncStatus);
}

class CobrosTableCompanion extends UpdateCompanion<CobrosTableData> {
  final Value<String> id;
  final Value<String?> sesionId;
  final Value<String?> alumnoId;
  final Value<String> fuenteId;
  final Value<String> modoCobro;
  final Value<String?> periodoMes;
  final Value<double> monto;
  final Value<double?> montoParcial;
  final Value<String> estado;
  final Value<String?> fechaCobro;
  final Value<String> notas;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const CobrosTableCompanion({
    this.id = const Value.absent(),
    this.sesionId = const Value.absent(),
    this.alumnoId = const Value.absent(),
    this.fuenteId = const Value.absent(),
    this.modoCobro = const Value.absent(),
    this.periodoMes = const Value.absent(),
    this.monto = const Value.absent(),
    this.montoParcial = const Value.absent(),
    this.estado = const Value.absent(),
    this.fechaCobro = const Value.absent(),
    this.notas = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CobrosTableCompanion.insert({
    required String id,
    this.sesionId = const Value.absent(),
    this.alumnoId = const Value.absent(),
    required String fuenteId,
    required String modoCobro,
    this.periodoMes = const Value.absent(),
    required double monto,
    this.montoParcial = const Value.absent(),
    this.estado = const Value.absent(),
    this.fechaCobro = const Value.absent(),
    this.notas = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fuenteId = Value(fuenteId),
        modoCobro = Value(modoCobro),
        monto = Value(monto);
  static Insertable<CobrosTableData> custom({
    Expression<String>? id,
    Expression<String>? sesionId,
    Expression<String>? alumnoId,
    Expression<String>? fuenteId,
    Expression<String>? modoCobro,
    Expression<String>? periodoMes,
    Expression<double>? monto,
    Expression<double>? montoParcial,
    Expression<String>? estado,
    Expression<String>? fechaCobro,
    Expression<String>? notas,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sesionId != null) 'sesion_id': sesionId,
      if (alumnoId != null) 'alumno_id': alumnoId,
      if (fuenteId != null) 'fuente_id': fuenteId,
      if (modoCobro != null) 'modo_cobro': modoCobro,
      if (periodoMes != null) 'periodo_mes': periodoMes,
      if (monto != null) 'monto': monto,
      if (montoParcial != null) 'monto_parcial': montoParcial,
      if (estado != null) 'estado': estado,
      if (fechaCobro != null) 'fecha_cobro': fechaCobro,
      if (notas != null) 'notas': notas,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CobrosTableCompanion copyWith(
      {Value<String>? id,
      Value<String?>? sesionId,
      Value<String?>? alumnoId,
      Value<String>? fuenteId,
      Value<String>? modoCobro,
      Value<String?>? periodoMes,
      Value<double>? monto,
      Value<double?>? montoParcial,
      Value<String>? estado,
      Value<String?>? fechaCobro,
      Value<String>? notas,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return CobrosTableCompanion(
      id: id ?? this.id,
      sesionId: sesionId ?? this.sesionId,
      alumnoId: alumnoId ?? this.alumnoId,
      fuenteId: fuenteId ?? this.fuenteId,
      modoCobro: modoCobro ?? this.modoCobro,
      periodoMes: periodoMes ?? this.periodoMes,
      monto: monto ?? this.monto,
      montoParcial: montoParcial ?? this.montoParcial,
      estado: estado ?? this.estado,
      fechaCobro: fechaCobro ?? this.fechaCobro,
      notas: notas ?? this.notas,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sesionId.present) {
      map['sesion_id'] = Variable<String>(sesionId.value);
    }
    if (alumnoId.present) {
      map['alumno_id'] = Variable<String>(alumnoId.value);
    }
    if (fuenteId.present) {
      map['fuente_id'] = Variable<String>(fuenteId.value);
    }
    if (modoCobro.present) {
      map['modo_cobro'] = Variable<String>(modoCobro.value);
    }
    if (periodoMes.present) {
      map['periodo_mes'] = Variable<String>(periodoMes.value);
    }
    if (monto.present) {
      map['monto'] = Variable<double>(monto.value);
    }
    if (montoParcial.present) {
      map['monto_parcial'] = Variable<double>(montoParcial.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (fechaCobro.present) {
      map['fecha_cobro'] = Variable<String>(fechaCobro.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CobrosTableCompanion(')
          ..write('id: $id, ')
          ..write('sesionId: $sesionId, ')
          ..write('alumnoId: $alumnoId, ')
          ..write('fuenteId: $fuenteId, ')
          ..write('modoCobro: $modoCobro, ')
          ..write('periodoMes: $periodoMes, ')
          ..write('monto: $monto, ')
          ..write('montoParcial: $montoParcial, ')
          ..write('estado: $estado, ')
          ..write('fechaCobro: $fechaCobro, ')
          ..write('notas: $notas, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HorasExtraTableTable extends HorasExtraTable
    with TableInfo<$HorasExtraTableTable, HorasExtraTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HorasExtraTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fuenteIdMeta =
      const VerificationMeta('fuenteId');
  @override
  late final GeneratedColumn<String> fuenteId = GeneratedColumn<String>(
      'fuente_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<String> fecha = GeneratedColumn<String>(
      'fecha', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _horasMeta = const VerificationMeta('horas');
  @override
  late final GeneratedColumn<double> horas = GeneratedColumn<double>(
      'horas', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _alumnoIdMeta =
      const VerificationMeta('alumnoId');
  @override
  late final GeneratedColumn<String> alumnoId = GeneratedColumn<String>(
      'alumno_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
      'notas', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, fuenteId, fecha, horas, alumnoId, notas, syncStatus];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'horas_extra_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<HorasExtraTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('fuente_id')) {
      context.handle(_fuenteIdMeta,
          fuenteId.isAcceptableOrUnknown(data['fuente_id']!, _fuenteIdMeta));
    } else if (isInserting) {
      context.missing(_fuenteIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
          _fechaMeta, fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta));
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('horas')) {
      context.handle(
          _horasMeta, horas.isAcceptableOrUnknown(data['horas']!, _horasMeta));
    } else if (isInserting) {
      context.missing(_horasMeta);
    }
    if (data.containsKey('alumno_id')) {
      context.handle(_alumnoIdMeta,
          alumnoId.isAcceptableOrUnknown(data['alumno_id']!, _alumnoIdMeta));
    }
    if (data.containsKey('notas')) {
      context.handle(
          _notasMeta, notas.isAcceptableOrUnknown(data['notas']!, _notasMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HorasExtraTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HorasExtraTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fuenteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fuente_id'])!,
      fecha: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fecha'])!,
      horas: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}horas'])!,
      alumnoId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alumno_id']),
      notas: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notas'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $HorasExtraTableTable createAlias(String alias) {
    return $HorasExtraTableTable(attachedDatabase, alias);
  }
}

class HorasExtraTableData extends DataClass
    implements Insertable<HorasExtraTableData> {
  final String id;
  final String fuenteId;

  /// Fecha del registro en formato "yyyy-MM-dd".
  final String fecha;
  final double horas;

  /// Alumno asociado a estas horas extra (opcional).
  final String? alumnoId;
  final String notas;
  final String syncStatus;
  const HorasExtraTableData(
      {required this.id,
      required this.fuenteId,
      required this.fecha,
      required this.horas,
      this.alumnoId,
      required this.notas,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['fuente_id'] = Variable<String>(fuenteId);
    map['fecha'] = Variable<String>(fecha);
    map['horas'] = Variable<double>(horas);
    if (!nullToAbsent || alumnoId != null) {
      map['alumno_id'] = Variable<String>(alumnoId);
    }
    map['notas'] = Variable<String>(notas);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  HorasExtraTableCompanion toCompanion(bool nullToAbsent) {
    return HorasExtraTableCompanion(
      id: Value(id),
      fuenteId: Value(fuenteId),
      fecha: Value(fecha),
      horas: Value(horas),
      alumnoId: alumnoId == null && nullToAbsent
          ? const Value.absent()
          : Value(alumnoId),
      notas: Value(notas),
      syncStatus: Value(syncStatus),
    );
  }

  factory HorasExtraTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HorasExtraTableData(
      id: serializer.fromJson<String>(json['id']),
      fuenteId: serializer.fromJson<String>(json['fuenteId']),
      fecha: serializer.fromJson<String>(json['fecha']),
      horas: serializer.fromJson<double>(json['horas']),
      alumnoId: serializer.fromJson<String?>(json['alumnoId']),
      notas: serializer.fromJson<String>(json['notas']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fuenteId': serializer.toJson<String>(fuenteId),
      'fecha': serializer.toJson<String>(fecha),
      'horas': serializer.toJson<double>(horas),
      'alumnoId': serializer.toJson<String?>(alumnoId),
      'notas': serializer.toJson<String>(notas),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  HorasExtraTableData copyWith(
          {String? id,
          String? fuenteId,
          String? fecha,
          double? horas,
          Value<String?> alumnoId = const Value.absent(),
          String? notas,
          String? syncStatus}) =>
      HorasExtraTableData(
        id: id ?? this.id,
        fuenteId: fuenteId ?? this.fuenteId,
        fecha: fecha ?? this.fecha,
        horas: horas ?? this.horas,
        alumnoId: alumnoId.present ? alumnoId.value : this.alumnoId,
        notas: notas ?? this.notas,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  HorasExtraTableData copyWithCompanion(HorasExtraTableCompanion data) {
    return HorasExtraTableData(
      id: data.id.present ? data.id.value : this.id,
      fuenteId: data.fuenteId.present ? data.fuenteId.value : this.fuenteId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      horas: data.horas.present ? data.horas.value : this.horas,
      alumnoId: data.alumnoId.present ? data.alumnoId.value : this.alumnoId,
      notas: data.notas.present ? data.notas.value : this.notas,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HorasExtraTableData(')
          ..write('id: $id, ')
          ..write('fuenteId: $fuenteId, ')
          ..write('fecha: $fecha, ')
          ..write('horas: $horas, ')
          ..write('alumnoId: $alumnoId, ')
          ..write('notas: $notas, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, fuenteId, fecha, horas, alumnoId, notas, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HorasExtraTableData &&
          other.id == this.id &&
          other.fuenteId == this.fuenteId &&
          other.fecha == this.fecha &&
          other.horas == this.horas &&
          other.alumnoId == this.alumnoId &&
          other.notas == this.notas &&
          other.syncStatus == this.syncStatus);
}

class HorasExtraTableCompanion extends UpdateCompanion<HorasExtraTableData> {
  final Value<String> id;
  final Value<String> fuenteId;
  final Value<String> fecha;
  final Value<double> horas;
  final Value<String?> alumnoId;
  final Value<String> notas;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const HorasExtraTableCompanion({
    this.id = const Value.absent(),
    this.fuenteId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.horas = const Value.absent(),
    this.alumnoId = const Value.absent(),
    this.notas = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HorasExtraTableCompanion.insert({
    required String id,
    required String fuenteId,
    required String fecha,
    required double horas,
    this.alumnoId = const Value.absent(),
    this.notas = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fuenteId = Value(fuenteId),
        fecha = Value(fecha),
        horas = Value(horas);
  static Insertable<HorasExtraTableData> custom({
    Expression<String>? id,
    Expression<String>? fuenteId,
    Expression<String>? fecha,
    Expression<double>? horas,
    Expression<String>? alumnoId,
    Expression<String>? notas,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fuenteId != null) 'fuente_id': fuenteId,
      if (fecha != null) 'fecha': fecha,
      if (horas != null) 'horas': horas,
      if (alumnoId != null) 'alumno_id': alumnoId,
      if (notas != null) 'notas': notas,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HorasExtraTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? fuenteId,
      Value<String>? fecha,
      Value<double>? horas,
      Value<String?>? alumnoId,
      Value<String>? notas,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return HorasExtraTableCompanion(
      id: id ?? this.id,
      fuenteId: fuenteId ?? this.fuenteId,
      fecha: fecha ?? this.fecha,
      horas: horas ?? this.horas,
      alumnoId: alumnoId ?? this.alumnoId,
      notas: notas ?? this.notas,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fuenteId.present) {
      map['fuente_id'] = Variable<String>(fuenteId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<String>(fecha.value);
    }
    if (horas.present) {
      map['horas'] = Variable<double>(horas.value);
    }
    if (alumnoId.present) {
      map['alumno_id'] = Variable<String>(alumnoId.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HorasExtraTableCompanion(')
          ..write('id: $id, ')
          ..write('fuenteId: $fuenteId, ')
          ..write('fecha: $fecha, ')
          ..write('horas: $horas, ')
          ..write('alumnoId: $alumnoId, ')
          ..write('notas: $notas, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FuentesTableTable fuentesTable = $FuentesTableTable(this);
  late final $EmpleoConfigTableTable empleoConfigTable =
      $EmpleoConfigTableTable(this);
  late final $AlumnosTableTable alumnosTable = $AlumnosTableTable(this);
  late final $SesionesRecurrentesTableTable sesionesRecurrentesTable =
      $SesionesRecurrentesTableTable(this);
  late final $SesionesRealizadasTableTable sesionesRealizadasTable =
      $SesionesRealizadasTableTable(this);
  late final $CobrosTableTable cobrosTable = $CobrosTableTable(this);
  late final $HorasExtraTableTable horasExtraTable =
      $HorasExtraTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        fuentesTable,
        empleoConfigTable,
        alumnosTable,
        sesionesRecurrentesTable,
        sesionesRealizadasTable,
        cobrosTable,
        horasExtraTable
      ];
}

typedef $$FuentesTableTableCreateCompanionBuilder = FuentesTableCompanion
    Function({
  required String id,
  required String nombre,
  required String tipo,
  required String color,
  Value<String> moneda,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$FuentesTableTableUpdateCompanionBuilder = FuentesTableCompanion
    Function({
  Value<String> id,
  Value<String> nombre,
  Value<String> tipo,
  Value<String> color,
  Value<String> moneda,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$FuentesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FuentesTableTable,
    FuentesTableData,
    $$FuentesTableTableFilterComposer,
    $$FuentesTableTableOrderingComposer,
    $$FuentesTableTableCreateCompanionBuilder,
    $$FuentesTableTableUpdateCompanionBuilder> {
  $$FuentesTableTableTableManager(_$AppDatabase db, $FuentesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$FuentesTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$FuentesTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> nombre = const Value.absent(),
            Value<String> tipo = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<String> moneda = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FuentesTableCompanion(
            id: id,
            nombre: nombre,
            tipo: tipo,
            color: color,
            moneda: moneda,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String nombre,
            required String tipo,
            required String color,
            Value<String> moneda = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FuentesTableCompanion.insert(
            id: id,
            nombre: nombre,
            tipo: tipo,
            color: color,
            moneda: moneda,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
        ));
}

class $$FuentesTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $FuentesTableTable> {
  $$FuentesTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get nombre => $state.composableBuilder(
      column: $state.table.nombre,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get tipo => $state.composableBuilder(
      column: $state.table.tipo,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get moneda => $state.composableBuilder(
      column: $state.table.moneda,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get syncStatus => $state.composableBuilder(
      column: $state.table.syncStatus,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$FuentesTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $FuentesTableTable> {
  $$FuentesTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get nombre => $state.composableBuilder(
      column: $state.table.nombre,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get tipo => $state.composableBuilder(
      column: $state.table.tipo,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get moneda => $state.composableBuilder(
      column: $state.table.moneda,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get syncStatus => $state.composableBuilder(
      column: $state.table.syncStatus,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$EmpleoConfigTableTableCreateCompanionBuilder
    = EmpleoConfigTableCompanion Function({
  required String fuenteId,
  required double salarioBase,
  required double horasSemanales,
  required double tarifaHoraExtra,
  required int diaCobro,
  Value<int> rowid,
});
typedef $$EmpleoConfigTableTableUpdateCompanionBuilder
    = EmpleoConfigTableCompanion Function({
  Value<String> fuenteId,
  Value<double> salarioBase,
  Value<double> horasSemanales,
  Value<double> tarifaHoraExtra,
  Value<int> diaCobro,
  Value<int> rowid,
});

class $$EmpleoConfigTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EmpleoConfigTableTable,
    EmpleoConfigTableData,
    $$EmpleoConfigTableTableFilterComposer,
    $$EmpleoConfigTableTableOrderingComposer,
    $$EmpleoConfigTableTableCreateCompanionBuilder,
    $$EmpleoConfigTableTableUpdateCompanionBuilder> {
  $$EmpleoConfigTableTableTableManager(
      _$AppDatabase db, $EmpleoConfigTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$EmpleoConfigTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$EmpleoConfigTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> fuenteId = const Value.absent(),
            Value<double> salarioBase = const Value.absent(),
            Value<double> horasSemanales = const Value.absent(),
            Value<double> tarifaHoraExtra = const Value.absent(),
            Value<int> diaCobro = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EmpleoConfigTableCompanion(
            fuenteId: fuenteId,
            salarioBase: salarioBase,
            horasSemanales: horasSemanales,
            tarifaHoraExtra: tarifaHoraExtra,
            diaCobro: diaCobro,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String fuenteId,
            required double salarioBase,
            required double horasSemanales,
            required double tarifaHoraExtra,
            required int diaCobro,
            Value<int> rowid = const Value.absent(),
          }) =>
              EmpleoConfigTableCompanion.insert(
            fuenteId: fuenteId,
            salarioBase: salarioBase,
            horasSemanales: horasSemanales,
            tarifaHoraExtra: tarifaHoraExtra,
            diaCobro: diaCobro,
            rowid: rowid,
          ),
        ));
}

class $$EmpleoConfigTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $EmpleoConfigTableTable> {
  $$EmpleoConfigTableTableFilterComposer(super.$state);
  ColumnFilters<String> get fuenteId => $state.composableBuilder(
      column: $state.table.fuenteId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get salarioBase => $state.composableBuilder(
      column: $state.table.salarioBase,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get horasSemanales => $state.composableBuilder(
      column: $state.table.horasSemanales,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get tarifaHoraExtra => $state.composableBuilder(
      column: $state.table.tarifaHoraExtra,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get diaCobro => $state.composableBuilder(
      column: $state.table.diaCobro,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$EmpleoConfigTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $EmpleoConfigTableTable> {
  $$EmpleoConfigTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get fuenteId => $state.composableBuilder(
      column: $state.table.fuenteId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get salarioBase => $state.composableBuilder(
      column: $state.table.salarioBase,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get horasSemanales => $state.composableBuilder(
      column: $state.table.horasSemanales,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get tarifaHoraExtra => $state.composableBuilder(
      column: $state.table.tarifaHoraExtra,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get diaCobro => $state.composableBuilder(
      column: $state.table.diaCobro,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$AlumnosTableTableCreateCompanionBuilder = AlumnosTableCompanion
    Function({
  required String id,
  required String nombre,
  required String fuenteId,
  required double tarifaSesion,
  Value<int> duracionMinutos,
  Value<String> notas,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$AlumnosTableTableUpdateCompanionBuilder = AlumnosTableCompanion
    Function({
  Value<String> id,
  Value<String> nombre,
  Value<String> fuenteId,
  Value<double> tarifaSesion,
  Value<int> duracionMinutos,
  Value<String> notas,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$AlumnosTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AlumnosTableTable,
    AlumnosTableData,
    $$AlumnosTableTableFilterComposer,
    $$AlumnosTableTableOrderingComposer,
    $$AlumnosTableTableCreateCompanionBuilder,
    $$AlumnosTableTableUpdateCompanionBuilder> {
  $$AlumnosTableTableTableManager(_$AppDatabase db, $AlumnosTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AlumnosTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AlumnosTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> nombre = const Value.absent(),
            Value<String> fuenteId = const Value.absent(),
            Value<double> tarifaSesion = const Value.absent(),
            Value<int> duracionMinutos = const Value.absent(),
            Value<String> notas = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AlumnosTableCompanion(
            id: id,
            nombre: nombre,
            fuenteId: fuenteId,
            tarifaSesion: tarifaSesion,
            duracionMinutos: duracionMinutos,
            notas: notas,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String nombre,
            required String fuenteId,
            required double tarifaSesion,
            Value<int> duracionMinutos = const Value.absent(),
            Value<String> notas = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AlumnosTableCompanion.insert(
            id: id,
            nombre: nombre,
            fuenteId: fuenteId,
            tarifaSesion: tarifaSesion,
            duracionMinutos: duracionMinutos,
            notas: notas,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
        ));
}

class $$AlumnosTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AlumnosTableTable> {
  $$AlumnosTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get nombre => $state.composableBuilder(
      column: $state.table.nombre,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fuenteId => $state.composableBuilder(
      column: $state.table.fuenteId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get tarifaSesion => $state.composableBuilder(
      column: $state.table.tarifaSesion,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get duracionMinutos => $state.composableBuilder(
      column: $state.table.duracionMinutos,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get notas => $state.composableBuilder(
      column: $state.table.notas,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get syncStatus => $state.composableBuilder(
      column: $state.table.syncStatus,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$AlumnosTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AlumnosTableTable> {
  $$AlumnosTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get nombre => $state.composableBuilder(
      column: $state.table.nombre,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fuenteId => $state.composableBuilder(
      column: $state.table.fuenteId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get tarifaSesion => $state.composableBuilder(
      column: $state.table.tarifaSesion,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get duracionMinutos => $state.composableBuilder(
      column: $state.table.duracionMinutos,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notas => $state.composableBuilder(
      column: $state.table.notas,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get syncStatus => $state.composableBuilder(
      column: $state.table.syncStatus,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$SesionesRecurrentesTableTableCreateCompanionBuilder
    = SesionesRecurrentesTableCompanion Function({
  required String id,
  Value<String?> alumnoId,
  required String fuenteId,
  required String diasSemana,
  required String horaInicio,
  required String horaFin,
  required String fechaInicio,
  Value<String?> fechaFin,
  Value<bool> esPuntual,
  Value<bool> activa,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$SesionesRecurrentesTableTableUpdateCompanionBuilder
    = SesionesRecurrentesTableCompanion Function({
  Value<String> id,
  Value<String?> alumnoId,
  Value<String> fuenteId,
  Value<String> diasSemana,
  Value<String> horaInicio,
  Value<String> horaFin,
  Value<String> fechaInicio,
  Value<String?> fechaFin,
  Value<bool> esPuntual,
  Value<bool> activa,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$SesionesRecurrentesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SesionesRecurrentesTableTable,
    SesionesRecurrentesTableData,
    $$SesionesRecurrentesTableTableFilterComposer,
    $$SesionesRecurrentesTableTableOrderingComposer,
    $$SesionesRecurrentesTableTableCreateCompanionBuilder,
    $$SesionesRecurrentesTableTableUpdateCompanionBuilder> {
  $$SesionesRecurrentesTableTableTableManager(
      _$AppDatabase db, $SesionesRecurrentesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$SesionesRecurrentesTableTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$SesionesRecurrentesTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> alumnoId = const Value.absent(),
            Value<String> fuenteId = const Value.absent(),
            Value<String> diasSemana = const Value.absent(),
            Value<String> horaInicio = const Value.absent(),
            Value<String> horaFin = const Value.absent(),
            Value<String> fechaInicio = const Value.absent(),
            Value<String?> fechaFin = const Value.absent(),
            Value<bool> esPuntual = const Value.absent(),
            Value<bool> activa = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SesionesRecurrentesTableCompanion(
            id: id,
            alumnoId: alumnoId,
            fuenteId: fuenteId,
            diasSemana: diasSemana,
            horaInicio: horaInicio,
            horaFin: horaFin,
            fechaInicio: fechaInicio,
            fechaFin: fechaFin,
            esPuntual: esPuntual,
            activa: activa,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> alumnoId = const Value.absent(),
            required String fuenteId,
            required String diasSemana,
            required String horaInicio,
            required String horaFin,
            required String fechaInicio,
            Value<String?> fechaFin = const Value.absent(),
            Value<bool> esPuntual = const Value.absent(),
            Value<bool> activa = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SesionesRecurrentesTableCompanion.insert(
            id: id,
            alumnoId: alumnoId,
            fuenteId: fuenteId,
            diasSemana: diasSemana,
            horaInicio: horaInicio,
            horaFin: horaFin,
            fechaInicio: fechaInicio,
            fechaFin: fechaFin,
            esPuntual: esPuntual,
            activa: activa,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
        ));
}

class $$SesionesRecurrentesTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $SesionesRecurrentesTableTable> {
  $$SesionesRecurrentesTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get alumnoId => $state.composableBuilder(
      column: $state.table.alumnoId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fuenteId => $state.composableBuilder(
      column: $state.table.fuenteId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get diasSemana => $state.composableBuilder(
      column: $state.table.diasSemana,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get horaInicio => $state.composableBuilder(
      column: $state.table.horaInicio,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get horaFin => $state.composableBuilder(
      column: $state.table.horaFin,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fechaInicio => $state.composableBuilder(
      column: $state.table.fechaInicio,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fechaFin => $state.composableBuilder(
      column: $state.table.fechaFin,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get esPuntual => $state.composableBuilder(
      column: $state.table.esPuntual,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get activa => $state.composableBuilder(
      column: $state.table.activa,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get syncStatus => $state.composableBuilder(
      column: $state.table.syncStatus,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$SesionesRecurrentesTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $SesionesRecurrentesTableTable> {
  $$SesionesRecurrentesTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get alumnoId => $state.composableBuilder(
      column: $state.table.alumnoId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fuenteId => $state.composableBuilder(
      column: $state.table.fuenteId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get diasSemana => $state.composableBuilder(
      column: $state.table.diasSemana,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get horaInicio => $state.composableBuilder(
      column: $state.table.horaInicio,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get horaFin => $state.composableBuilder(
      column: $state.table.horaFin,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fechaInicio => $state.composableBuilder(
      column: $state.table.fechaInicio,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fechaFin => $state.composableBuilder(
      column: $state.table.fechaFin,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get esPuntual => $state.composableBuilder(
      column: $state.table.esPuntual,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get activa => $state.composableBuilder(
      column: $state.table.activa,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get syncStatus => $state.composableBuilder(
      column: $state.table.syncStatus,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$SesionesRealizadasTableTableCreateCompanionBuilder
    = SesionesRealizadasTableCompanion Function({
  required String id,
  Value<String?> alumnoId,
  required String fuenteId,
  required String fecha,
  required double horas,
  required double cobro,
  Value<String> estado,
  Value<String?> sesionRecurrenteId,
  Value<String> notas,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$SesionesRealizadasTableTableUpdateCompanionBuilder
    = SesionesRealizadasTableCompanion Function({
  Value<String> id,
  Value<String?> alumnoId,
  Value<String> fuenteId,
  Value<String> fecha,
  Value<double> horas,
  Value<double> cobro,
  Value<String> estado,
  Value<String?> sesionRecurrenteId,
  Value<String> notas,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$SesionesRealizadasTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SesionesRealizadasTableTable,
    SesionesRealizadasTableData,
    $$SesionesRealizadasTableTableFilterComposer,
    $$SesionesRealizadasTableTableOrderingComposer,
    $$SesionesRealizadasTableTableCreateCompanionBuilder,
    $$SesionesRealizadasTableTableUpdateCompanionBuilder> {
  $$SesionesRealizadasTableTableTableManager(
      _$AppDatabase db, $SesionesRealizadasTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$SesionesRealizadasTableTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$SesionesRealizadasTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> alumnoId = const Value.absent(),
            Value<String> fuenteId = const Value.absent(),
            Value<String> fecha = const Value.absent(),
            Value<double> horas = const Value.absent(),
            Value<double> cobro = const Value.absent(),
            Value<String> estado = const Value.absent(),
            Value<String?> sesionRecurrenteId = const Value.absent(),
            Value<String> notas = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SesionesRealizadasTableCompanion(
            id: id,
            alumnoId: alumnoId,
            fuenteId: fuenteId,
            fecha: fecha,
            horas: horas,
            cobro: cobro,
            estado: estado,
            sesionRecurrenteId: sesionRecurrenteId,
            notas: notas,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> alumnoId = const Value.absent(),
            required String fuenteId,
            required String fecha,
            required double horas,
            required double cobro,
            Value<String> estado = const Value.absent(),
            Value<String?> sesionRecurrenteId = const Value.absent(),
            Value<String> notas = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SesionesRealizadasTableCompanion.insert(
            id: id,
            alumnoId: alumnoId,
            fuenteId: fuenteId,
            fecha: fecha,
            horas: horas,
            cobro: cobro,
            estado: estado,
            sesionRecurrenteId: sesionRecurrenteId,
            notas: notas,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
        ));
}

class $$SesionesRealizadasTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $SesionesRealizadasTableTable> {
  $$SesionesRealizadasTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get alumnoId => $state.composableBuilder(
      column: $state.table.alumnoId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fuenteId => $state.composableBuilder(
      column: $state.table.fuenteId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fecha => $state.composableBuilder(
      column: $state.table.fecha,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get horas => $state.composableBuilder(
      column: $state.table.horas,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get cobro => $state.composableBuilder(
      column: $state.table.cobro,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get estado => $state.composableBuilder(
      column: $state.table.estado,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get sesionRecurrenteId => $state.composableBuilder(
      column: $state.table.sesionRecurrenteId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get notas => $state.composableBuilder(
      column: $state.table.notas,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get syncStatus => $state.composableBuilder(
      column: $state.table.syncStatus,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$SesionesRealizadasTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $SesionesRealizadasTableTable> {
  $$SesionesRealizadasTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get alumnoId => $state.composableBuilder(
      column: $state.table.alumnoId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fuenteId => $state.composableBuilder(
      column: $state.table.fuenteId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fecha => $state.composableBuilder(
      column: $state.table.fecha,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get horas => $state.composableBuilder(
      column: $state.table.horas,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get cobro => $state.composableBuilder(
      column: $state.table.cobro,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get estado => $state.composableBuilder(
      column: $state.table.estado,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get sesionRecurrenteId => $state.composableBuilder(
      column: $state.table.sesionRecurrenteId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notas => $state.composableBuilder(
      column: $state.table.notas,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get syncStatus => $state.composableBuilder(
      column: $state.table.syncStatus,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$CobrosTableTableCreateCompanionBuilder = CobrosTableCompanion
    Function({
  required String id,
  Value<String?> sesionId,
  Value<String?> alumnoId,
  required String fuenteId,
  required String modoCobro,
  Value<String?> periodoMes,
  required double monto,
  Value<double?> montoParcial,
  Value<String> estado,
  Value<String?> fechaCobro,
  Value<String> notas,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$CobrosTableTableUpdateCompanionBuilder = CobrosTableCompanion
    Function({
  Value<String> id,
  Value<String?> sesionId,
  Value<String?> alumnoId,
  Value<String> fuenteId,
  Value<String> modoCobro,
  Value<String?> periodoMes,
  Value<double> monto,
  Value<double?> montoParcial,
  Value<String> estado,
  Value<String?> fechaCobro,
  Value<String> notas,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$CobrosTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CobrosTableTable,
    CobrosTableData,
    $$CobrosTableTableFilterComposer,
    $$CobrosTableTableOrderingComposer,
    $$CobrosTableTableCreateCompanionBuilder,
    $$CobrosTableTableUpdateCompanionBuilder> {
  $$CobrosTableTableTableManager(_$AppDatabase db, $CobrosTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CobrosTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CobrosTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> sesionId = const Value.absent(),
            Value<String?> alumnoId = const Value.absent(),
            Value<String> fuenteId = const Value.absent(),
            Value<String> modoCobro = const Value.absent(),
            Value<String?> periodoMes = const Value.absent(),
            Value<double> monto = const Value.absent(),
            Value<double?> montoParcial = const Value.absent(),
            Value<String> estado = const Value.absent(),
            Value<String?> fechaCobro = const Value.absent(),
            Value<String> notas = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CobrosTableCompanion(
            id: id,
            sesionId: sesionId,
            alumnoId: alumnoId,
            fuenteId: fuenteId,
            modoCobro: modoCobro,
            periodoMes: periodoMes,
            monto: monto,
            montoParcial: montoParcial,
            estado: estado,
            fechaCobro: fechaCobro,
            notas: notas,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> sesionId = const Value.absent(),
            Value<String?> alumnoId = const Value.absent(),
            required String fuenteId,
            required String modoCobro,
            Value<String?> periodoMes = const Value.absent(),
            required double monto,
            Value<double?> montoParcial = const Value.absent(),
            Value<String> estado = const Value.absent(),
            Value<String?> fechaCobro = const Value.absent(),
            Value<String> notas = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CobrosTableCompanion.insert(
            id: id,
            sesionId: sesionId,
            alumnoId: alumnoId,
            fuenteId: fuenteId,
            modoCobro: modoCobro,
            periodoMes: periodoMes,
            monto: monto,
            montoParcial: montoParcial,
            estado: estado,
            fechaCobro: fechaCobro,
            notas: notas,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
        ));
}

class $$CobrosTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CobrosTableTable> {
  $$CobrosTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get sesionId => $state.composableBuilder(
      column: $state.table.sesionId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get alumnoId => $state.composableBuilder(
      column: $state.table.alumnoId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fuenteId => $state.composableBuilder(
      column: $state.table.fuenteId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get modoCobro => $state.composableBuilder(
      column: $state.table.modoCobro,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get periodoMes => $state.composableBuilder(
      column: $state.table.periodoMes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get monto => $state.composableBuilder(
      column: $state.table.monto,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get montoParcial => $state.composableBuilder(
      column: $state.table.montoParcial,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get estado => $state.composableBuilder(
      column: $state.table.estado,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fechaCobro => $state.composableBuilder(
      column: $state.table.fechaCobro,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get notas => $state.composableBuilder(
      column: $state.table.notas,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get syncStatus => $state.composableBuilder(
      column: $state.table.syncStatus,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$CobrosTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CobrosTableTable> {
  $$CobrosTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get sesionId => $state.composableBuilder(
      column: $state.table.sesionId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get alumnoId => $state.composableBuilder(
      column: $state.table.alumnoId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fuenteId => $state.composableBuilder(
      column: $state.table.fuenteId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get modoCobro => $state.composableBuilder(
      column: $state.table.modoCobro,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get periodoMes => $state.composableBuilder(
      column: $state.table.periodoMes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get monto => $state.composableBuilder(
      column: $state.table.monto,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get montoParcial => $state.composableBuilder(
      column: $state.table.montoParcial,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get estado => $state.composableBuilder(
      column: $state.table.estado,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fechaCobro => $state.composableBuilder(
      column: $state.table.fechaCobro,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notas => $state.composableBuilder(
      column: $state.table.notas,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get syncStatus => $state.composableBuilder(
      column: $state.table.syncStatus,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$HorasExtraTableTableCreateCompanionBuilder = HorasExtraTableCompanion
    Function({
  required String id,
  required String fuenteId,
  required String fecha,
  required double horas,
  Value<String?> alumnoId,
  Value<String> notas,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$HorasExtraTableTableUpdateCompanionBuilder = HorasExtraTableCompanion
    Function({
  Value<String> id,
  Value<String> fuenteId,
  Value<String> fecha,
  Value<double> horas,
  Value<String?> alumnoId,
  Value<String> notas,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$HorasExtraTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HorasExtraTableTable,
    HorasExtraTableData,
    $$HorasExtraTableTableFilterComposer,
    $$HorasExtraTableTableOrderingComposer,
    $$HorasExtraTableTableCreateCompanionBuilder,
    $$HorasExtraTableTableUpdateCompanionBuilder> {
  $$HorasExtraTableTableTableManager(
      _$AppDatabase db, $HorasExtraTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$HorasExtraTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$HorasExtraTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> fuenteId = const Value.absent(),
            Value<String> fecha = const Value.absent(),
            Value<double> horas = const Value.absent(),
            Value<String?> alumnoId = const Value.absent(),
            Value<String> notas = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HorasExtraTableCompanion(
            id: id,
            fuenteId: fuenteId,
            fecha: fecha,
            horas: horas,
            alumnoId: alumnoId,
            notas: notas,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String fuenteId,
            required String fecha,
            required double horas,
            Value<String?> alumnoId = const Value.absent(),
            Value<String> notas = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HorasExtraTableCompanion.insert(
            id: id,
            fuenteId: fuenteId,
            fecha: fecha,
            horas: horas,
            alumnoId: alumnoId,
            notas: notas,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
        ));
}

class $$HorasExtraTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $HorasExtraTableTable> {
  $$HorasExtraTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fuenteId => $state.composableBuilder(
      column: $state.table.fuenteId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fecha => $state.composableBuilder(
      column: $state.table.fecha,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get horas => $state.composableBuilder(
      column: $state.table.horas,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get alumnoId => $state.composableBuilder(
      column: $state.table.alumnoId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get notas => $state.composableBuilder(
      column: $state.table.notas,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get syncStatus => $state.composableBuilder(
      column: $state.table.syncStatus,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$HorasExtraTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $HorasExtraTableTable> {
  $$HorasExtraTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fuenteId => $state.composableBuilder(
      column: $state.table.fuenteId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fecha => $state.composableBuilder(
      column: $state.table.fecha,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get horas => $state.composableBuilder(
      column: $state.table.horas,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get alumnoId => $state.composableBuilder(
      column: $state.table.alumnoId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notas => $state.composableBuilder(
      column: $state.table.notas,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get syncStatus => $state.composableBuilder(
      column: $state.table.syncStatus,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FuentesTableTableTableManager get fuentesTable =>
      $$FuentesTableTableTableManager(_db, _db.fuentesTable);
  $$EmpleoConfigTableTableTableManager get empleoConfigTable =>
      $$EmpleoConfigTableTableTableManager(_db, _db.empleoConfigTable);
  $$AlumnosTableTableTableManager get alumnosTable =>
      $$AlumnosTableTableTableManager(_db, _db.alumnosTable);
  $$SesionesRecurrentesTableTableTableManager get sesionesRecurrentesTable =>
      $$SesionesRecurrentesTableTableTableManager(
          _db, _db.sesionesRecurrentesTable);
  $$SesionesRealizadasTableTableTableManager get sesionesRealizadasTable =>
      $$SesionesRealizadasTableTableTableManager(
          _db, _db.sesionesRealizadasTable);
  $$CobrosTableTableTableManager get cobrosTable =>
      $$CobrosTableTableTableManager(_db, _db.cobrosTable);
  $$HorasExtraTableTableTableManager get horasExtraTable =>
      $$HorasExtraTableTableTableManager(_db, _db.horasExtraTable);
}
