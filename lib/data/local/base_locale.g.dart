// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_locale.dart';

// ignore_for_file: type=lint
class $ClassesTable extends Classes
    with TableInfo<$ClassesTable, ClasseLocale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClassesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cycleMeta = const VerificationMeta('cycle');
  @override
  late final GeneratedColumn<String> cycle = GeneratedColumn<String>(
    'cycle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordreMeta = const VerificationMeta('ordre');
  @override
  late final GeneratedColumn<int> ordre = GeneratedColumn<int>(
    'ordre',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, nom, cycle, ordre];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'classes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClasseLocale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('cycle')) {
      context.handle(
        _cycleMeta,
        cycle.isAcceptableOrUnknown(data['cycle']!, _cycleMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleMeta);
    }
    if (data.containsKey('ordre')) {
      context.handle(
        _ordreMeta,
        ordre.isAcceptableOrUnknown(data['ordre']!, _ordreMeta),
      );
    } else if (isInserting) {
      context.missing(_ordreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClasseLocale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClasseLocale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      cycle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cycle'],
      )!,
      ordre: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordre'],
      )!,
    );
  }

  @override
  $ClassesTable createAlias(String alias) {
    return $ClassesTable(attachedDatabase, alias);
  }
}

class ClasseLocale extends DataClass implements Insertable<ClasseLocale> {
  final String id;
  final String nom;
  final String cycle;
  final int ordre;
  const ClasseLocale({
    required this.id,
    required this.nom,
    required this.cycle,
    required this.ordre,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nom'] = Variable<String>(nom);
    map['cycle'] = Variable<String>(cycle);
    map['ordre'] = Variable<int>(ordre);
    return map;
  }

  ClassesCompanion toCompanion(bool nullToAbsent) {
    return ClassesCompanion(
      id: Value(id),
      nom: Value(nom),
      cycle: Value(cycle),
      ordre: Value(ordre),
    );
  }

  factory ClasseLocale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClasseLocale(
      id: serializer.fromJson<String>(json['id']),
      nom: serializer.fromJson<String>(json['nom']),
      cycle: serializer.fromJson<String>(json['cycle']),
      ordre: serializer.fromJson<int>(json['ordre']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nom': serializer.toJson<String>(nom),
      'cycle': serializer.toJson<String>(cycle),
      'ordre': serializer.toJson<int>(ordre),
    };
  }

  ClasseLocale copyWith({String? id, String? nom, String? cycle, int? ordre}) =>
      ClasseLocale(
        id: id ?? this.id,
        nom: nom ?? this.nom,
        cycle: cycle ?? this.cycle,
        ordre: ordre ?? this.ordre,
      );
  ClasseLocale copyWithCompanion(ClassesCompanion data) {
    return ClasseLocale(
      id: data.id.present ? data.id.value : this.id,
      nom: data.nom.present ? data.nom.value : this.nom,
      cycle: data.cycle.present ? data.cycle.value : this.cycle,
      ordre: data.ordre.present ? data.ordre.value : this.ordre,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClasseLocale(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('cycle: $cycle, ')
          ..write('ordre: $ordre')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nom, cycle, ordre);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClasseLocale &&
          other.id == this.id &&
          other.nom == this.nom &&
          other.cycle == this.cycle &&
          other.ordre == this.ordre);
}

class ClassesCompanion extends UpdateCompanion<ClasseLocale> {
  final Value<String> id;
  final Value<String> nom;
  final Value<String> cycle;
  final Value<int> ordre;
  final Value<int> rowid;
  const ClassesCompanion({
    this.id = const Value.absent(),
    this.nom = const Value.absent(),
    this.cycle = const Value.absent(),
    this.ordre = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClassesCompanion.insert({
    required String id,
    required String nom,
    required String cycle,
    required int ordre,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nom = Value(nom),
       cycle = Value(cycle),
       ordre = Value(ordre);
  static Insertable<ClasseLocale> custom({
    Expression<String>? id,
    Expression<String>? nom,
    Expression<String>? cycle,
    Expression<int>? ordre,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nom != null) 'nom': nom,
      if (cycle != null) 'cycle': cycle,
      if (ordre != null) 'ordre': ordre,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClassesCompanion copyWith({
    Value<String>? id,
    Value<String>? nom,
    Value<String>? cycle,
    Value<int>? ordre,
    Value<int>? rowid,
  }) {
    return ClassesCompanion(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      cycle: cycle ?? this.cycle,
      ordre: ordre ?? this.ordre,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (cycle.present) {
      map['cycle'] = Variable<String>(cycle.value);
    }
    if (ordre.present) {
      map['ordre'] = Variable<int>(ordre.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClassesCompanion(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('cycle: $cycle, ')
          ..write('ordre: $ordre, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MatieresTable extends Matieres
    with TableInfo<$MatieresTable, MatiereLocale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatieresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, nom];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'matieres';
  @override
  VerificationContext validateIntegrity(
    Insertable<MatiereLocale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MatiereLocale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatiereLocale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
    );
  }

  @override
  $MatieresTable createAlias(String alias) {
    return $MatieresTable(attachedDatabase, alias);
  }
}

class MatiereLocale extends DataClass implements Insertable<MatiereLocale> {
  final String id;
  final String nom;
  const MatiereLocale({required this.id, required this.nom});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nom'] = Variable<String>(nom);
    return map;
  }

  MatieresCompanion toCompanion(bool nullToAbsent) {
    return MatieresCompanion(id: Value(id), nom: Value(nom));
  }

  factory MatiereLocale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatiereLocale(
      id: serializer.fromJson<String>(json['id']),
      nom: serializer.fromJson<String>(json['nom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nom': serializer.toJson<String>(nom),
    };
  }

  MatiereLocale copyWith({String? id, String? nom}) =>
      MatiereLocale(id: id ?? this.id, nom: nom ?? this.nom);
  MatiereLocale copyWithCompanion(MatieresCompanion data) {
    return MatiereLocale(
      id: data.id.present ? data.id.value : this.id,
      nom: data.nom.present ? data.nom.value : this.nom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatiereLocale(')
          ..write('id: $id, ')
          ..write('nom: $nom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nom);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatiereLocale && other.id == this.id && other.nom == this.nom);
}

class MatieresCompanion extends UpdateCompanion<MatiereLocale> {
  final Value<String> id;
  final Value<String> nom;
  final Value<int> rowid;
  const MatieresCompanion({
    this.id = const Value.absent(),
    this.nom = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatieresCompanion.insert({
    required String id,
    required String nom,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nom = Value(nom);
  static Insertable<MatiereLocale> custom({
    Expression<String>? id,
    Expression<String>? nom,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nom != null) 'nom': nom,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatieresCompanion copyWith({
    Value<String>? id,
    Value<String>? nom,
    Value<int>? rowid,
  }) {
    return MatieresCompanion(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatieresCompanion(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChapitresTable extends Chapitres
    with TableInfo<$ChapitresTable, ChapitreLocale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChapitresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classeIdMeta = const VerificationMeta(
    'classeId',
  );
  @override
  late final GeneratedColumn<String> classeId = GeneratedColumn<String>(
    'classe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _matiereIdMeta = const VerificationMeta(
    'matiereId',
  );
  @override
  late final GeneratedColumn<String> matiereId = GeneratedColumn<String>(
    'matiere_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numeroMeta = const VerificationMeta('numero');
  @override
  late final GeneratedColumn<int> numero = GeneratedColumn<int>(
    'numero',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titreMeta = const VerificationMeta('titre');
  @override
  late final GeneratedColumn<String> titre = GeneratedColumn<String>(
    'titre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strateMeta = const VerificationMeta('strate');
  @override
  late final GeneratedColumn<String> strate = GeneratedColumn<String>(
    'strate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ordreMeta = const VerificationMeta('ordre');
  @override
  late final GeneratedColumn<int> ordre = GeneratedColumn<int>(
    'ordre',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    classeId,
    matiereId,
    numero,
    titre,
    strate,
    ordre,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapitres';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChapitreLocale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('classe_id')) {
      context.handle(
        _classeIdMeta,
        classeId.isAcceptableOrUnknown(data['classe_id']!, _classeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classeIdMeta);
    }
    if (data.containsKey('matiere_id')) {
      context.handle(
        _matiereIdMeta,
        matiereId.isAcceptableOrUnknown(data['matiere_id']!, _matiereIdMeta),
      );
    } else if (isInserting) {
      context.missing(_matiereIdMeta);
    }
    if (data.containsKey('numero')) {
      context.handle(
        _numeroMeta,
        numero.isAcceptableOrUnknown(data['numero']!, _numeroMeta),
      );
    } else if (isInserting) {
      context.missing(_numeroMeta);
    }
    if (data.containsKey('titre')) {
      context.handle(
        _titreMeta,
        titre.isAcceptableOrUnknown(data['titre']!, _titreMeta),
      );
    } else if (isInserting) {
      context.missing(_titreMeta);
    }
    if (data.containsKey('strate')) {
      context.handle(
        _strateMeta,
        strate.isAcceptableOrUnknown(data['strate']!, _strateMeta),
      );
    }
    if (data.containsKey('ordre')) {
      context.handle(
        _ordreMeta,
        ordre.isAcceptableOrUnknown(data['ordre']!, _ordreMeta),
      );
    } else if (isInserting) {
      context.missing(_ordreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChapitreLocale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapitreLocale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      classeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}classe_id'],
      )!,
      matiereId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}matiere_id'],
      )!,
      numero: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}numero'],
      )!,
      titre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titre'],
      )!,
      strate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strate'],
      ),
      ordre: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordre'],
      )!,
    );
  }

  @override
  $ChapitresTable createAlias(String alias) {
    return $ChapitresTable(attachedDatabase, alias);
  }
}

class ChapitreLocale extends DataClass implements Insertable<ChapitreLocale> {
  final String id;
  final String classeId;
  final String matiereId;
  final int numero;
  final String titre;
  final String? strate;
  final int ordre;
  const ChapitreLocale({
    required this.id,
    required this.classeId,
    required this.matiereId,
    required this.numero,
    required this.titre,
    this.strate,
    required this.ordre,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['classe_id'] = Variable<String>(classeId);
    map['matiere_id'] = Variable<String>(matiereId);
    map['numero'] = Variable<int>(numero);
    map['titre'] = Variable<String>(titre);
    if (!nullToAbsent || strate != null) {
      map['strate'] = Variable<String>(strate);
    }
    map['ordre'] = Variable<int>(ordre);
    return map;
  }

  ChapitresCompanion toCompanion(bool nullToAbsent) {
    return ChapitresCompanion(
      id: Value(id),
      classeId: Value(classeId),
      matiereId: Value(matiereId),
      numero: Value(numero),
      titre: Value(titre),
      strate: strate == null && nullToAbsent
          ? const Value.absent()
          : Value(strate),
      ordre: Value(ordre),
    );
  }

  factory ChapitreLocale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapitreLocale(
      id: serializer.fromJson<String>(json['id']),
      classeId: serializer.fromJson<String>(json['classeId']),
      matiereId: serializer.fromJson<String>(json['matiereId']),
      numero: serializer.fromJson<int>(json['numero']),
      titre: serializer.fromJson<String>(json['titre']),
      strate: serializer.fromJson<String?>(json['strate']),
      ordre: serializer.fromJson<int>(json['ordre']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'classeId': serializer.toJson<String>(classeId),
      'matiereId': serializer.toJson<String>(matiereId),
      'numero': serializer.toJson<int>(numero),
      'titre': serializer.toJson<String>(titre),
      'strate': serializer.toJson<String?>(strate),
      'ordre': serializer.toJson<int>(ordre),
    };
  }

  ChapitreLocale copyWith({
    String? id,
    String? classeId,
    String? matiereId,
    int? numero,
    String? titre,
    Value<String?> strate = const Value.absent(),
    int? ordre,
  }) => ChapitreLocale(
    id: id ?? this.id,
    classeId: classeId ?? this.classeId,
    matiereId: matiereId ?? this.matiereId,
    numero: numero ?? this.numero,
    titre: titre ?? this.titre,
    strate: strate.present ? strate.value : this.strate,
    ordre: ordre ?? this.ordre,
  );
  ChapitreLocale copyWithCompanion(ChapitresCompanion data) {
    return ChapitreLocale(
      id: data.id.present ? data.id.value : this.id,
      classeId: data.classeId.present ? data.classeId.value : this.classeId,
      matiereId: data.matiereId.present ? data.matiereId.value : this.matiereId,
      numero: data.numero.present ? data.numero.value : this.numero,
      titre: data.titre.present ? data.titre.value : this.titre,
      strate: data.strate.present ? data.strate.value : this.strate,
      ordre: data.ordre.present ? data.ordre.value : this.ordre,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapitreLocale(')
          ..write('id: $id, ')
          ..write('classeId: $classeId, ')
          ..write('matiereId: $matiereId, ')
          ..write('numero: $numero, ')
          ..write('titre: $titre, ')
          ..write('strate: $strate, ')
          ..write('ordre: $ordre')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, classeId, matiereId, numero, titre, strate, ordre);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapitreLocale &&
          other.id == this.id &&
          other.classeId == this.classeId &&
          other.matiereId == this.matiereId &&
          other.numero == this.numero &&
          other.titre == this.titre &&
          other.strate == this.strate &&
          other.ordre == this.ordre);
}

class ChapitresCompanion extends UpdateCompanion<ChapitreLocale> {
  final Value<String> id;
  final Value<String> classeId;
  final Value<String> matiereId;
  final Value<int> numero;
  final Value<String> titre;
  final Value<String?> strate;
  final Value<int> ordre;
  final Value<int> rowid;
  const ChapitresCompanion({
    this.id = const Value.absent(),
    this.classeId = const Value.absent(),
    this.matiereId = const Value.absent(),
    this.numero = const Value.absent(),
    this.titre = const Value.absent(),
    this.strate = const Value.absent(),
    this.ordre = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChapitresCompanion.insert({
    required String id,
    required String classeId,
    required String matiereId,
    required int numero,
    required String titre,
    this.strate = const Value.absent(),
    required int ordre,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       classeId = Value(classeId),
       matiereId = Value(matiereId),
       numero = Value(numero),
       titre = Value(titre),
       ordre = Value(ordre);
  static Insertable<ChapitreLocale> custom({
    Expression<String>? id,
    Expression<String>? classeId,
    Expression<String>? matiereId,
    Expression<int>? numero,
    Expression<String>? titre,
    Expression<String>? strate,
    Expression<int>? ordre,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (classeId != null) 'classe_id': classeId,
      if (matiereId != null) 'matiere_id': matiereId,
      if (numero != null) 'numero': numero,
      if (titre != null) 'titre': titre,
      if (strate != null) 'strate': strate,
      if (ordre != null) 'ordre': ordre,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChapitresCompanion copyWith({
    Value<String>? id,
    Value<String>? classeId,
    Value<String>? matiereId,
    Value<int>? numero,
    Value<String>? titre,
    Value<String?>? strate,
    Value<int>? ordre,
    Value<int>? rowid,
  }) {
    return ChapitresCompanion(
      id: id ?? this.id,
      classeId: classeId ?? this.classeId,
      matiereId: matiereId ?? this.matiereId,
      numero: numero ?? this.numero,
      titre: titre ?? this.titre,
      strate: strate ?? this.strate,
      ordre: ordre ?? this.ordre,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (classeId.present) {
      map['classe_id'] = Variable<String>(classeId.value);
    }
    if (matiereId.present) {
      map['matiere_id'] = Variable<String>(matiereId.value);
    }
    if (numero.present) {
      map['numero'] = Variable<int>(numero.value);
    }
    if (titre.present) {
      map['titre'] = Variable<String>(titre.value);
    }
    if (strate.present) {
      map['strate'] = Variable<String>(strate.value);
    }
    if (ordre.present) {
      map['ordre'] = Variable<int>(ordre.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChapitresCompanion(')
          ..write('id: $id, ')
          ..write('classeId: $classeId, ')
          ..write('matiereId: $matiereId, ')
          ..write('numero: $numero, ')
          ..write('titre: $titre, ')
          ..write('strate: $strate, ')
          ..write('ordre: $ordre, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RessourcesTable extends Ressources
    with TableInfo<$RessourcesTable, RessourceLocale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RessourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapitreIdMeta = const VerificationMeta(
    'chapitreId',
  );
  @override
  late final GeneratedColumn<String> chapitreId = GeneratedColumn<String>(
    'chapitre_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _classeIdMeta = const VerificationMeta(
    'classeId',
  );
  @override
  late final GeneratedColumn<String> classeId = GeneratedColumn<String>(
    'classe_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _matiereIdMeta = const VerificationMeta(
    'matiereId',
  );
  @override
  late final GeneratedColumn<String> matiereId = GeneratedColumn<String>(
    'matiere_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titreMeta = const VerificationMeta('titre');
  @override
  late final GeneratedColumn<String> titre = GeneratedColumn<String>(
    'titre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tailleOctetsMeta = const VerificationMeta(
    'tailleOctets',
  );
  @override
  late final GeneratedColumn<int> tailleOctets = GeneratedColumn<int>(
    'taille_octets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _premiumMeta = const VerificationMeta(
    'premium',
  );
  @override
  late final GeneratedColumn<bool> premium = GeneratedColumn<bool>(
    'premium',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("premium" IN (0, 1))',
    ),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cheminStorageMeta = const VerificationMeta(
    'cheminStorage',
  );
  @override
  late final GeneratedColumn<String> cheminStorage = GeneratedColumn<String>(
    'chemin_storage',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ordreMeta = const VerificationMeta('ordre');
  @override
  late final GeneratedColumn<int> ordre = GeneratedColumn<int>(
    'ordre',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chapitreId,
    classeId,
    matiereId,
    type,
    titre,
    tailleOctets,
    premium,
    version,
    cheminStorage,
    ordre,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ressources';
  @override
  VerificationContext validateIntegrity(
    Insertable<RessourceLocale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chapitre_id')) {
      context.handle(
        _chapitreIdMeta,
        chapitreId.isAcceptableOrUnknown(data['chapitre_id']!, _chapitreIdMeta),
      );
    }
    if (data.containsKey('classe_id')) {
      context.handle(
        _classeIdMeta,
        classeId.isAcceptableOrUnknown(data['classe_id']!, _classeIdMeta),
      );
    }
    if (data.containsKey('matiere_id')) {
      context.handle(
        _matiereIdMeta,
        matiereId.isAcceptableOrUnknown(data['matiere_id']!, _matiereIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('titre')) {
      context.handle(
        _titreMeta,
        titre.isAcceptableOrUnknown(data['titre']!, _titreMeta),
      );
    } else if (isInserting) {
      context.missing(_titreMeta);
    }
    if (data.containsKey('taille_octets')) {
      context.handle(
        _tailleOctetsMeta,
        tailleOctets.isAcceptableOrUnknown(
          data['taille_octets']!,
          _tailleOctetsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tailleOctetsMeta);
    }
    if (data.containsKey('premium')) {
      context.handle(
        _premiumMeta,
        premium.isAcceptableOrUnknown(data['premium']!, _premiumMeta),
      );
    } else if (isInserting) {
      context.missing(_premiumMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('chemin_storage')) {
      context.handle(
        _cheminStorageMeta,
        cheminStorage.isAcceptableOrUnknown(
          data['chemin_storage']!,
          _cheminStorageMeta,
        ),
      );
    }
    if (data.containsKey('ordre')) {
      context.handle(
        _ordreMeta,
        ordre.isAcceptableOrUnknown(data['ordre']!, _ordreMeta),
      );
    } else if (isInserting) {
      context.missing(_ordreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RessourceLocale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RessourceLocale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      chapitreId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapitre_id'],
      ),
      classeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}classe_id'],
      ),
      matiereId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}matiere_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      titre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titre'],
      )!,
      tailleOctets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}taille_octets'],
      )!,
      premium: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}premium'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      cheminStorage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chemin_storage'],
      ),
      ordre: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordre'],
      )!,
    );
  }

  @override
  $RessourcesTable createAlias(String alias) {
    return $RessourcesTable(attachedDatabase, alias);
  }
}

class RessourceLocale extends DataClass implements Insertable<RessourceLocale> {
  final String id;
  final String? chapitreId;
  final String? classeId;
  final String? matiereId;
  final String type;
  final String titre;
  final int tailleOctets;
  final bool premium;
  final int version;
  final String? cheminStorage;
  final int ordre;
  const RessourceLocale({
    required this.id,
    this.chapitreId,
    this.classeId,
    this.matiereId,
    required this.type,
    required this.titre,
    required this.tailleOctets,
    required this.premium,
    required this.version,
    this.cheminStorage,
    required this.ordre,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || chapitreId != null) {
      map['chapitre_id'] = Variable<String>(chapitreId);
    }
    if (!nullToAbsent || classeId != null) {
      map['classe_id'] = Variable<String>(classeId);
    }
    if (!nullToAbsent || matiereId != null) {
      map['matiere_id'] = Variable<String>(matiereId);
    }
    map['type'] = Variable<String>(type);
    map['titre'] = Variable<String>(titre);
    map['taille_octets'] = Variable<int>(tailleOctets);
    map['premium'] = Variable<bool>(premium);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || cheminStorage != null) {
      map['chemin_storage'] = Variable<String>(cheminStorage);
    }
    map['ordre'] = Variable<int>(ordre);
    return map;
  }

  RessourcesCompanion toCompanion(bool nullToAbsent) {
    return RessourcesCompanion(
      id: Value(id),
      chapitreId: chapitreId == null && nullToAbsent
          ? const Value.absent()
          : Value(chapitreId),
      classeId: classeId == null && nullToAbsent
          ? const Value.absent()
          : Value(classeId),
      matiereId: matiereId == null && nullToAbsent
          ? const Value.absent()
          : Value(matiereId),
      type: Value(type),
      titre: Value(titre),
      tailleOctets: Value(tailleOctets),
      premium: Value(premium),
      version: Value(version),
      cheminStorage: cheminStorage == null && nullToAbsent
          ? const Value.absent()
          : Value(cheminStorage),
      ordre: Value(ordre),
    );
  }

  factory RessourceLocale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RessourceLocale(
      id: serializer.fromJson<String>(json['id']),
      chapitreId: serializer.fromJson<String?>(json['chapitreId']),
      classeId: serializer.fromJson<String?>(json['classeId']),
      matiereId: serializer.fromJson<String?>(json['matiereId']),
      type: serializer.fromJson<String>(json['type']),
      titre: serializer.fromJson<String>(json['titre']),
      tailleOctets: serializer.fromJson<int>(json['tailleOctets']),
      premium: serializer.fromJson<bool>(json['premium']),
      version: serializer.fromJson<int>(json['version']),
      cheminStorage: serializer.fromJson<String?>(json['cheminStorage']),
      ordre: serializer.fromJson<int>(json['ordre']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chapitreId': serializer.toJson<String?>(chapitreId),
      'classeId': serializer.toJson<String?>(classeId),
      'matiereId': serializer.toJson<String?>(matiereId),
      'type': serializer.toJson<String>(type),
      'titre': serializer.toJson<String>(titre),
      'tailleOctets': serializer.toJson<int>(tailleOctets),
      'premium': serializer.toJson<bool>(premium),
      'version': serializer.toJson<int>(version),
      'cheminStorage': serializer.toJson<String?>(cheminStorage),
      'ordre': serializer.toJson<int>(ordre),
    };
  }

  RessourceLocale copyWith({
    String? id,
    Value<String?> chapitreId = const Value.absent(),
    Value<String?> classeId = const Value.absent(),
    Value<String?> matiereId = const Value.absent(),
    String? type,
    String? titre,
    int? tailleOctets,
    bool? premium,
    int? version,
    Value<String?> cheminStorage = const Value.absent(),
    int? ordre,
  }) => RessourceLocale(
    id: id ?? this.id,
    chapitreId: chapitreId.present ? chapitreId.value : this.chapitreId,
    classeId: classeId.present ? classeId.value : this.classeId,
    matiereId: matiereId.present ? matiereId.value : this.matiereId,
    type: type ?? this.type,
    titre: titre ?? this.titre,
    tailleOctets: tailleOctets ?? this.tailleOctets,
    premium: premium ?? this.premium,
    version: version ?? this.version,
    cheminStorage: cheminStorage.present
        ? cheminStorage.value
        : this.cheminStorage,
    ordre: ordre ?? this.ordre,
  );
  RessourceLocale copyWithCompanion(RessourcesCompanion data) {
    return RessourceLocale(
      id: data.id.present ? data.id.value : this.id,
      chapitreId: data.chapitreId.present
          ? data.chapitreId.value
          : this.chapitreId,
      classeId: data.classeId.present ? data.classeId.value : this.classeId,
      matiereId: data.matiereId.present ? data.matiereId.value : this.matiereId,
      type: data.type.present ? data.type.value : this.type,
      titre: data.titre.present ? data.titre.value : this.titre,
      tailleOctets: data.tailleOctets.present
          ? data.tailleOctets.value
          : this.tailleOctets,
      premium: data.premium.present ? data.premium.value : this.premium,
      version: data.version.present ? data.version.value : this.version,
      cheminStorage: data.cheminStorage.present
          ? data.cheminStorage.value
          : this.cheminStorage,
      ordre: data.ordre.present ? data.ordre.value : this.ordre,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RessourceLocale(')
          ..write('id: $id, ')
          ..write('chapitreId: $chapitreId, ')
          ..write('classeId: $classeId, ')
          ..write('matiereId: $matiereId, ')
          ..write('type: $type, ')
          ..write('titre: $titre, ')
          ..write('tailleOctets: $tailleOctets, ')
          ..write('premium: $premium, ')
          ..write('version: $version, ')
          ..write('cheminStorage: $cheminStorage, ')
          ..write('ordre: $ordre')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    chapitreId,
    classeId,
    matiereId,
    type,
    titre,
    tailleOctets,
    premium,
    version,
    cheminStorage,
    ordre,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RessourceLocale &&
          other.id == this.id &&
          other.chapitreId == this.chapitreId &&
          other.classeId == this.classeId &&
          other.matiereId == this.matiereId &&
          other.type == this.type &&
          other.titre == this.titre &&
          other.tailleOctets == this.tailleOctets &&
          other.premium == this.premium &&
          other.version == this.version &&
          other.cheminStorage == this.cheminStorage &&
          other.ordre == this.ordre);
}

class RessourcesCompanion extends UpdateCompanion<RessourceLocale> {
  final Value<String> id;
  final Value<String?> chapitreId;
  final Value<String?> classeId;
  final Value<String?> matiereId;
  final Value<String> type;
  final Value<String> titre;
  final Value<int> tailleOctets;
  final Value<bool> premium;
  final Value<int> version;
  final Value<String?> cheminStorage;
  final Value<int> ordre;
  final Value<int> rowid;
  const RessourcesCompanion({
    this.id = const Value.absent(),
    this.chapitreId = const Value.absent(),
    this.classeId = const Value.absent(),
    this.matiereId = const Value.absent(),
    this.type = const Value.absent(),
    this.titre = const Value.absent(),
    this.tailleOctets = const Value.absent(),
    this.premium = const Value.absent(),
    this.version = const Value.absent(),
    this.cheminStorage = const Value.absent(),
    this.ordre = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RessourcesCompanion.insert({
    required String id,
    this.chapitreId = const Value.absent(),
    this.classeId = const Value.absent(),
    this.matiereId = const Value.absent(),
    required String type,
    required String titre,
    required int tailleOctets,
    required bool premium,
    required int version,
    this.cheminStorage = const Value.absent(),
    required int ordre,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       titre = Value(titre),
       tailleOctets = Value(tailleOctets),
       premium = Value(premium),
       version = Value(version),
       ordre = Value(ordre);
  static Insertable<RessourceLocale> custom({
    Expression<String>? id,
    Expression<String>? chapitreId,
    Expression<String>? classeId,
    Expression<String>? matiereId,
    Expression<String>? type,
    Expression<String>? titre,
    Expression<int>? tailleOctets,
    Expression<bool>? premium,
    Expression<int>? version,
    Expression<String>? cheminStorage,
    Expression<int>? ordre,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapitreId != null) 'chapitre_id': chapitreId,
      if (classeId != null) 'classe_id': classeId,
      if (matiereId != null) 'matiere_id': matiereId,
      if (type != null) 'type': type,
      if (titre != null) 'titre': titre,
      if (tailleOctets != null) 'taille_octets': tailleOctets,
      if (premium != null) 'premium': premium,
      if (version != null) 'version': version,
      if (cheminStorage != null) 'chemin_storage': cheminStorage,
      if (ordre != null) 'ordre': ordre,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RessourcesCompanion copyWith({
    Value<String>? id,
    Value<String?>? chapitreId,
    Value<String?>? classeId,
    Value<String?>? matiereId,
    Value<String>? type,
    Value<String>? titre,
    Value<int>? tailleOctets,
    Value<bool>? premium,
    Value<int>? version,
    Value<String?>? cheminStorage,
    Value<int>? ordre,
    Value<int>? rowid,
  }) {
    return RessourcesCompanion(
      id: id ?? this.id,
      chapitreId: chapitreId ?? this.chapitreId,
      classeId: classeId ?? this.classeId,
      matiereId: matiereId ?? this.matiereId,
      type: type ?? this.type,
      titre: titre ?? this.titre,
      tailleOctets: tailleOctets ?? this.tailleOctets,
      premium: premium ?? this.premium,
      version: version ?? this.version,
      cheminStorage: cheminStorage ?? this.cheminStorage,
      ordre: ordre ?? this.ordre,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chapitreId.present) {
      map['chapitre_id'] = Variable<String>(chapitreId.value);
    }
    if (classeId.present) {
      map['classe_id'] = Variable<String>(classeId.value);
    }
    if (matiereId.present) {
      map['matiere_id'] = Variable<String>(matiereId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (titre.present) {
      map['titre'] = Variable<String>(titre.value);
    }
    if (tailleOctets.present) {
      map['taille_octets'] = Variable<int>(tailleOctets.value);
    }
    if (premium.present) {
      map['premium'] = Variable<bool>(premium.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (cheminStorage.present) {
      map['chemin_storage'] = Variable<String>(cheminStorage.value);
    }
    if (ordre.present) {
      map['ordre'] = Variable<int>(ordre.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RessourcesCompanion(')
          ..write('id: $id, ')
          ..write('chapitreId: $chapitreId, ')
          ..write('classeId: $classeId, ')
          ..write('matiereId: $matiereId, ')
          ..write('type: $type, ')
          ..write('titre: $titre, ')
          ..write('tailleOctets: $tailleOctets, ')
          ..write('premium: $premium, ')
          ..write('version: $version, ')
          ..write('cheminStorage: $cheminStorage, ')
          ..write('ordre: $ordre, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UtilisateursTable extends Utilisateurs
    with TableInfo<$UtilisateursTable, UtilisateurLocale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UtilisateursTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classeIdMeta = const VerificationMeta(
    'classeId',
  );
  @override
  late final GeneratedColumn<String> classeId = GeneratedColumn<String>(
    'classe_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serieMeta = const VerificationMeta('serie');
  @override
  late final GeneratedColumn<String> serie = GeneratedColumn<String>(
    'serie',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creeLeMeta = const VerificationMeta('creeLe');
  @override
  late final GeneratedColumn<DateTime> creeLe = GeneratedColumn<DateTime>(
    'cree_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, classeId, serie, creeLe];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'utilisateurs';
  @override
  VerificationContext validateIntegrity(
    Insertable<UtilisateurLocale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('classe_id')) {
      context.handle(
        _classeIdMeta,
        classeId.isAcceptableOrUnknown(data['classe_id']!, _classeIdMeta),
      );
    }
    if (data.containsKey('serie')) {
      context.handle(
        _serieMeta,
        serie.isAcceptableOrUnknown(data['serie']!, _serieMeta),
      );
    }
    if (data.containsKey('cree_le')) {
      context.handle(
        _creeLeMeta,
        creeLe.isAcceptableOrUnknown(data['cree_le']!, _creeLeMeta),
      );
    } else if (isInserting) {
      context.missing(_creeLeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UtilisateurLocale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UtilisateurLocale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      classeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}classe_id'],
      ),
      serie: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serie'],
      ),
      creeLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cree_le'],
      )!,
    );
  }

  @override
  $UtilisateursTable createAlias(String alias) {
    return $UtilisateursTable(attachedDatabase, alias);
  }
}

class UtilisateurLocale extends DataClass
    implements Insertable<UtilisateurLocale> {
  final String id;
  final String? classeId;
  final String? serie;
  final DateTime creeLe;
  const UtilisateurLocale({
    required this.id,
    this.classeId,
    this.serie,
    required this.creeLe,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || classeId != null) {
      map['classe_id'] = Variable<String>(classeId);
    }
    if (!nullToAbsent || serie != null) {
      map['serie'] = Variable<String>(serie);
    }
    map['cree_le'] = Variable<DateTime>(creeLe);
    return map;
  }

  UtilisateursCompanion toCompanion(bool nullToAbsent) {
    return UtilisateursCompanion(
      id: Value(id),
      classeId: classeId == null && nullToAbsent
          ? const Value.absent()
          : Value(classeId),
      serie: serie == null && nullToAbsent
          ? const Value.absent()
          : Value(serie),
      creeLe: Value(creeLe),
    );
  }

  factory UtilisateurLocale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UtilisateurLocale(
      id: serializer.fromJson<String>(json['id']),
      classeId: serializer.fromJson<String?>(json['classeId']),
      serie: serializer.fromJson<String?>(json['serie']),
      creeLe: serializer.fromJson<DateTime>(json['creeLe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'classeId': serializer.toJson<String?>(classeId),
      'serie': serializer.toJson<String?>(serie),
      'creeLe': serializer.toJson<DateTime>(creeLe),
    };
  }

  UtilisateurLocale copyWith({
    String? id,
    Value<String?> classeId = const Value.absent(),
    Value<String?> serie = const Value.absent(),
    DateTime? creeLe,
  }) => UtilisateurLocale(
    id: id ?? this.id,
    classeId: classeId.present ? classeId.value : this.classeId,
    serie: serie.present ? serie.value : this.serie,
    creeLe: creeLe ?? this.creeLe,
  );
  UtilisateurLocale copyWithCompanion(UtilisateursCompanion data) {
    return UtilisateurLocale(
      id: data.id.present ? data.id.value : this.id,
      classeId: data.classeId.present ? data.classeId.value : this.classeId,
      serie: data.serie.present ? data.serie.value : this.serie,
      creeLe: data.creeLe.present ? data.creeLe.value : this.creeLe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UtilisateurLocale(')
          ..write('id: $id, ')
          ..write('classeId: $classeId, ')
          ..write('serie: $serie, ')
          ..write('creeLe: $creeLe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, classeId, serie, creeLe);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UtilisateurLocale &&
          other.id == this.id &&
          other.classeId == this.classeId &&
          other.serie == this.serie &&
          other.creeLe == this.creeLe);
}

class UtilisateursCompanion extends UpdateCompanion<UtilisateurLocale> {
  final Value<String> id;
  final Value<String?> classeId;
  final Value<String?> serie;
  final Value<DateTime> creeLe;
  final Value<int> rowid;
  const UtilisateursCompanion({
    this.id = const Value.absent(),
    this.classeId = const Value.absent(),
    this.serie = const Value.absent(),
    this.creeLe = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UtilisateursCompanion.insert({
    required String id,
    this.classeId = const Value.absent(),
    this.serie = const Value.absent(),
    required DateTime creeLe,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       creeLe = Value(creeLe);
  static Insertable<UtilisateurLocale> custom({
    Expression<String>? id,
    Expression<String>? classeId,
    Expression<String>? serie,
    Expression<DateTime>? creeLe,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (classeId != null) 'classe_id': classeId,
      if (serie != null) 'serie': serie,
      if (creeLe != null) 'cree_le': creeLe,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UtilisateursCompanion copyWith({
    Value<String>? id,
    Value<String?>? classeId,
    Value<String?>? serie,
    Value<DateTime>? creeLe,
    Value<int>? rowid,
  }) {
    return UtilisateursCompanion(
      id: id ?? this.id,
      classeId: classeId ?? this.classeId,
      serie: serie ?? this.serie,
      creeLe: creeLe ?? this.creeLe,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (classeId.present) {
      map['classe_id'] = Variable<String>(classeId.value);
    }
    if (serie.present) {
      map['serie'] = Variable<String>(serie.value);
    }
    if (creeLe.present) {
      map['cree_le'] = Variable<DateTime>(creeLe.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UtilisateursCompanion(')
          ..write('id: $id, ')
          ..write('classeId: $classeId, ')
          ..write('serie: $serie, ')
          ..write('creeLe: $creeLe, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProgressionsTable extends Progressions
    with TableInfo<$ProgressionsTable, ProgressionLocale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgressionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _utilisateurIdMeta = const VerificationMeta(
    'utilisateurId',
  );
  @override
  late final GeneratedColumn<String> utilisateurId = GeneratedColumn<String>(
    'utilisateur_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapitreIdMeta = const VerificationMeta(
    'chapitreId',
  );
  @override
  late final GeneratedColumn<String> chapitreId = GeneratedColumn<String>(
    'chapitre_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _etatMeta = const VerificationMeta('etat');
  @override
  late final GeneratedColumn<String> etat = GeneratedColumn<String>(
    'etat',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMajMeta = const VerificationMeta(
    'dateMaj',
  );
  @override
  late final GeneratedColumn<DateTime> dateMaj = GeneratedColumn<DateTime>(
    'date_maj',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    utilisateurId,
    chapitreId,
    etat,
    dateMaj,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'progressions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgressionLocale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('utilisateur_id')) {
      context.handle(
        _utilisateurIdMeta,
        utilisateurId.isAcceptableOrUnknown(
          data['utilisateur_id']!,
          _utilisateurIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_utilisateurIdMeta);
    }
    if (data.containsKey('chapitre_id')) {
      context.handle(
        _chapitreIdMeta,
        chapitreId.isAcceptableOrUnknown(data['chapitre_id']!, _chapitreIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapitreIdMeta);
    }
    if (data.containsKey('etat')) {
      context.handle(
        _etatMeta,
        etat.isAcceptableOrUnknown(data['etat']!, _etatMeta),
      );
    } else if (isInserting) {
      context.missing(_etatMeta);
    }
    if (data.containsKey('date_maj')) {
      context.handle(
        _dateMajMeta,
        dateMaj.isAcceptableOrUnknown(data['date_maj']!, _dateMajMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMajMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgressionLocale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgressionLocale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      utilisateurId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}utilisateur_id'],
      )!,
      chapitreId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapitre_id'],
      )!,
      etat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etat'],
      )!,
      dateMaj: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_maj'],
      )!,
    );
  }

  @override
  $ProgressionsTable createAlias(String alias) {
    return $ProgressionsTable(attachedDatabase, alias);
  }
}

class ProgressionLocale extends DataClass
    implements Insertable<ProgressionLocale> {
  final String id;
  final String utilisateurId;
  final String chapitreId;
  final String etat;
  final DateTime dateMaj;
  const ProgressionLocale({
    required this.id,
    required this.utilisateurId,
    required this.chapitreId,
    required this.etat,
    required this.dateMaj,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['utilisateur_id'] = Variable<String>(utilisateurId);
    map['chapitre_id'] = Variable<String>(chapitreId);
    map['etat'] = Variable<String>(etat);
    map['date_maj'] = Variable<DateTime>(dateMaj);
    return map;
  }

  ProgressionsCompanion toCompanion(bool nullToAbsent) {
    return ProgressionsCompanion(
      id: Value(id),
      utilisateurId: Value(utilisateurId),
      chapitreId: Value(chapitreId),
      etat: Value(etat),
      dateMaj: Value(dateMaj),
    );
  }

  factory ProgressionLocale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgressionLocale(
      id: serializer.fromJson<String>(json['id']),
      utilisateurId: serializer.fromJson<String>(json['utilisateurId']),
      chapitreId: serializer.fromJson<String>(json['chapitreId']),
      etat: serializer.fromJson<String>(json['etat']),
      dateMaj: serializer.fromJson<DateTime>(json['dateMaj']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'utilisateurId': serializer.toJson<String>(utilisateurId),
      'chapitreId': serializer.toJson<String>(chapitreId),
      'etat': serializer.toJson<String>(etat),
      'dateMaj': serializer.toJson<DateTime>(dateMaj),
    };
  }

  ProgressionLocale copyWith({
    String? id,
    String? utilisateurId,
    String? chapitreId,
    String? etat,
    DateTime? dateMaj,
  }) => ProgressionLocale(
    id: id ?? this.id,
    utilisateurId: utilisateurId ?? this.utilisateurId,
    chapitreId: chapitreId ?? this.chapitreId,
    etat: etat ?? this.etat,
    dateMaj: dateMaj ?? this.dateMaj,
  );
  ProgressionLocale copyWithCompanion(ProgressionsCompanion data) {
    return ProgressionLocale(
      id: data.id.present ? data.id.value : this.id,
      utilisateurId: data.utilisateurId.present
          ? data.utilisateurId.value
          : this.utilisateurId,
      chapitreId: data.chapitreId.present
          ? data.chapitreId.value
          : this.chapitreId,
      etat: data.etat.present ? data.etat.value : this.etat,
      dateMaj: data.dateMaj.present ? data.dateMaj.value : this.dateMaj,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgressionLocale(')
          ..write('id: $id, ')
          ..write('utilisateurId: $utilisateurId, ')
          ..write('chapitreId: $chapitreId, ')
          ..write('etat: $etat, ')
          ..write('dateMaj: $dateMaj')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, utilisateurId, chapitreId, etat, dateMaj);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgressionLocale &&
          other.id == this.id &&
          other.utilisateurId == this.utilisateurId &&
          other.chapitreId == this.chapitreId &&
          other.etat == this.etat &&
          other.dateMaj == this.dateMaj);
}

class ProgressionsCompanion extends UpdateCompanion<ProgressionLocale> {
  final Value<String> id;
  final Value<String> utilisateurId;
  final Value<String> chapitreId;
  final Value<String> etat;
  final Value<DateTime> dateMaj;
  final Value<int> rowid;
  const ProgressionsCompanion({
    this.id = const Value.absent(),
    this.utilisateurId = const Value.absent(),
    this.chapitreId = const Value.absent(),
    this.etat = const Value.absent(),
    this.dateMaj = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProgressionsCompanion.insert({
    required String id,
    required String utilisateurId,
    required String chapitreId,
    required String etat,
    required DateTime dateMaj,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       utilisateurId = Value(utilisateurId),
       chapitreId = Value(chapitreId),
       etat = Value(etat),
       dateMaj = Value(dateMaj);
  static Insertable<ProgressionLocale> custom({
    Expression<String>? id,
    Expression<String>? utilisateurId,
    Expression<String>? chapitreId,
    Expression<String>? etat,
    Expression<DateTime>? dateMaj,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (utilisateurId != null) 'utilisateur_id': utilisateurId,
      if (chapitreId != null) 'chapitre_id': chapitreId,
      if (etat != null) 'etat': etat,
      if (dateMaj != null) 'date_maj': dateMaj,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProgressionsCompanion copyWith({
    Value<String>? id,
    Value<String>? utilisateurId,
    Value<String>? chapitreId,
    Value<String>? etat,
    Value<DateTime>? dateMaj,
    Value<int>? rowid,
  }) {
    return ProgressionsCompanion(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      chapitreId: chapitreId ?? this.chapitreId,
      etat: etat ?? this.etat,
      dateMaj: dateMaj ?? this.dateMaj,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (utilisateurId.present) {
      map['utilisateur_id'] = Variable<String>(utilisateurId.value);
    }
    if (chapitreId.present) {
      map['chapitre_id'] = Variable<String>(chapitreId.value);
    }
    if (etat.present) {
      map['etat'] = Variable<String>(etat.value);
    }
    if (dateMaj.present) {
      map['date_maj'] = Variable<DateTime>(dateMaj.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgressionsCompanion(')
          ..write('id: $id, ')
          ..write('utilisateurId: $utilisateurId, ')
          ..write('chapitreId: $chapitreId, ')
          ..write('etat: $etat, ')
          ..write('dateMaj: $dateMaj, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TelechargementsTable extends Telechargements
    with TableInfo<$TelechargementsTable, TelechargementLocale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TelechargementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _utilisateurIdMeta = const VerificationMeta(
    'utilisateurId',
  );
  @override
  late final GeneratedColumn<String> utilisateurId = GeneratedColumn<String>(
    'utilisateur_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ressourceIdMeta = const VerificationMeta(
    'ressourceId',
  );
  @override
  late final GeneratedColumn<String> ressourceId = GeneratedColumn<String>(
    'ressource_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateTelechargementMeta =
      const VerificationMeta('dateTelechargement');
  @override
  late final GeneratedColumn<DateTime> dateTelechargement =
      GeneratedColumn<DateTime>(
        'date_telechargement',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    utilisateurId,
    ressourceId,
    dateTelechargement,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'telechargements';
  @override
  VerificationContext validateIntegrity(
    Insertable<TelechargementLocale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('utilisateur_id')) {
      context.handle(
        _utilisateurIdMeta,
        utilisateurId.isAcceptableOrUnknown(
          data['utilisateur_id']!,
          _utilisateurIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_utilisateurIdMeta);
    }
    if (data.containsKey('ressource_id')) {
      context.handle(
        _ressourceIdMeta,
        ressourceId.isAcceptableOrUnknown(
          data['ressource_id']!,
          _ressourceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ressourceIdMeta);
    }
    if (data.containsKey('date_telechargement')) {
      context.handle(
        _dateTelechargementMeta,
        dateTelechargement.isAcceptableOrUnknown(
          data['date_telechargement']!,
          _dateTelechargementMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateTelechargementMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TelechargementLocale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TelechargementLocale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      utilisateurId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}utilisateur_id'],
      )!,
      ressourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ressource_id'],
      )!,
      dateTelechargement: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_telechargement'],
      )!,
    );
  }

  @override
  $TelechargementsTable createAlias(String alias) {
    return $TelechargementsTable(attachedDatabase, alias);
  }
}

class TelechargementLocale extends DataClass
    implements Insertable<TelechargementLocale> {
  final String id;
  final String utilisateurId;
  final String ressourceId;
  final DateTime dateTelechargement;
  const TelechargementLocale({
    required this.id,
    required this.utilisateurId,
    required this.ressourceId,
    required this.dateTelechargement,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['utilisateur_id'] = Variable<String>(utilisateurId);
    map['ressource_id'] = Variable<String>(ressourceId);
    map['date_telechargement'] = Variable<DateTime>(dateTelechargement);
    return map;
  }

  TelechargementsCompanion toCompanion(bool nullToAbsent) {
    return TelechargementsCompanion(
      id: Value(id),
      utilisateurId: Value(utilisateurId),
      ressourceId: Value(ressourceId),
      dateTelechargement: Value(dateTelechargement),
    );
  }

  factory TelechargementLocale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TelechargementLocale(
      id: serializer.fromJson<String>(json['id']),
      utilisateurId: serializer.fromJson<String>(json['utilisateurId']),
      ressourceId: serializer.fromJson<String>(json['ressourceId']),
      dateTelechargement: serializer.fromJson<DateTime>(
        json['dateTelechargement'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'utilisateurId': serializer.toJson<String>(utilisateurId),
      'ressourceId': serializer.toJson<String>(ressourceId),
      'dateTelechargement': serializer.toJson<DateTime>(dateTelechargement),
    };
  }

  TelechargementLocale copyWith({
    String? id,
    String? utilisateurId,
    String? ressourceId,
    DateTime? dateTelechargement,
  }) => TelechargementLocale(
    id: id ?? this.id,
    utilisateurId: utilisateurId ?? this.utilisateurId,
    ressourceId: ressourceId ?? this.ressourceId,
    dateTelechargement: dateTelechargement ?? this.dateTelechargement,
  );
  TelechargementLocale copyWithCompanion(TelechargementsCompanion data) {
    return TelechargementLocale(
      id: data.id.present ? data.id.value : this.id,
      utilisateurId: data.utilisateurId.present
          ? data.utilisateurId.value
          : this.utilisateurId,
      ressourceId: data.ressourceId.present
          ? data.ressourceId.value
          : this.ressourceId,
      dateTelechargement: data.dateTelechargement.present
          ? data.dateTelechargement.value
          : this.dateTelechargement,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TelechargementLocale(')
          ..write('id: $id, ')
          ..write('utilisateurId: $utilisateurId, ')
          ..write('ressourceId: $ressourceId, ')
          ..write('dateTelechargement: $dateTelechargement')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, utilisateurId, ressourceId, dateTelechargement);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TelechargementLocale &&
          other.id == this.id &&
          other.utilisateurId == this.utilisateurId &&
          other.ressourceId == this.ressourceId &&
          other.dateTelechargement == this.dateTelechargement);
}

class TelechargementsCompanion extends UpdateCompanion<TelechargementLocale> {
  final Value<String> id;
  final Value<String> utilisateurId;
  final Value<String> ressourceId;
  final Value<DateTime> dateTelechargement;
  final Value<int> rowid;
  const TelechargementsCompanion({
    this.id = const Value.absent(),
    this.utilisateurId = const Value.absent(),
    this.ressourceId = const Value.absent(),
    this.dateTelechargement = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TelechargementsCompanion.insert({
    required String id,
    required String utilisateurId,
    required String ressourceId,
    required DateTime dateTelechargement,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       utilisateurId = Value(utilisateurId),
       ressourceId = Value(ressourceId),
       dateTelechargement = Value(dateTelechargement);
  static Insertable<TelechargementLocale> custom({
    Expression<String>? id,
    Expression<String>? utilisateurId,
    Expression<String>? ressourceId,
    Expression<DateTime>? dateTelechargement,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (utilisateurId != null) 'utilisateur_id': utilisateurId,
      if (ressourceId != null) 'ressource_id': ressourceId,
      if (dateTelechargement != null) 'date_telechargement': dateTelechargement,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TelechargementsCompanion copyWith({
    Value<String>? id,
    Value<String>? utilisateurId,
    Value<String>? ressourceId,
    Value<DateTime>? dateTelechargement,
    Value<int>? rowid,
  }) {
    return TelechargementsCompanion(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      ressourceId: ressourceId ?? this.ressourceId,
      dateTelechargement: dateTelechargement ?? this.dateTelechargement,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (utilisateurId.present) {
      map['utilisateur_id'] = Variable<String>(utilisateurId.value);
    }
    if (ressourceId.present) {
      map['ressource_id'] = Variable<String>(ressourceId.value);
    }
    if (dateTelechargement.present) {
      map['date_telechargement'] = Variable<DateTime>(dateTelechargement.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TelechargementsCompanion(')
          ..write('id: $id, ')
          ..write('utilisateurId: $utilisateurId, ')
          ..write('ressourceId: $ressourceId, ')
          ..write('dateTelechargement: $dateTelechargement, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AbonnementsTable extends Abonnements
    with TableInfo<$AbonnementsTable, AbonnementLocale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AbonnementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _utilisateurIdMeta = const VerificationMeta(
    'utilisateurId',
  );
  @override
  late final GeneratedColumn<String> utilisateurId = GeneratedColumn<String>(
    'utilisateur_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formuleMeta = const VerificationMeta(
    'formule',
  );
  @override
  late final GeneratedColumn<String> formule = GeneratedColumn<String>(
    'formule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateDebutMeta = const VerificationMeta(
    'dateDebut',
  );
  @override
  late final GeneratedColumn<DateTime> dateDebut = GeneratedColumn<DateTime>(
    'date_debut',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateFinMeta = const VerificationMeta(
    'dateFin',
  );
  @override
  late final GeneratedColumn<DateTime> dateFin = GeneratedColumn<DateTime>(
    'date_fin',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referencePaiementMeta = const VerificationMeta(
    'referencePaiement',
  );
  @override
  late final GeneratedColumn<String> referencePaiement =
      GeneratedColumn<String>(
        'reference_paiement',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    utilisateurId,
    formule,
    dateDebut,
    dateFin,
    referencePaiement,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'abonnements';
  @override
  VerificationContext validateIntegrity(
    Insertable<AbonnementLocale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('utilisateur_id')) {
      context.handle(
        _utilisateurIdMeta,
        utilisateurId.isAcceptableOrUnknown(
          data['utilisateur_id']!,
          _utilisateurIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_utilisateurIdMeta);
    }
    if (data.containsKey('formule')) {
      context.handle(
        _formuleMeta,
        formule.isAcceptableOrUnknown(data['formule']!, _formuleMeta),
      );
    } else if (isInserting) {
      context.missing(_formuleMeta);
    }
    if (data.containsKey('date_debut')) {
      context.handle(
        _dateDebutMeta,
        dateDebut.isAcceptableOrUnknown(data['date_debut']!, _dateDebutMeta),
      );
    } else if (isInserting) {
      context.missing(_dateDebutMeta);
    }
    if (data.containsKey('date_fin')) {
      context.handle(
        _dateFinMeta,
        dateFin.isAcceptableOrUnknown(data['date_fin']!, _dateFinMeta),
      );
    } else if (isInserting) {
      context.missing(_dateFinMeta);
    }
    if (data.containsKey('reference_paiement')) {
      context.handle(
        _referencePaiementMeta,
        referencePaiement.isAcceptableOrUnknown(
          data['reference_paiement']!,
          _referencePaiementMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AbonnementLocale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AbonnementLocale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      utilisateurId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}utilisateur_id'],
      )!,
      formule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}formule'],
      )!,
      dateDebut: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_debut'],
      )!,
      dateFin: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_fin'],
      )!,
      referencePaiement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_paiement'],
      ),
    );
  }

  @override
  $AbonnementsTable createAlias(String alias) {
    return $AbonnementsTable(attachedDatabase, alias);
  }
}

class AbonnementLocale extends DataClass
    implements Insertable<AbonnementLocale> {
  final String id;
  final String utilisateurId;
  final String formule;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String? referencePaiement;
  const AbonnementLocale({
    required this.id,
    required this.utilisateurId,
    required this.formule,
    required this.dateDebut,
    required this.dateFin,
    this.referencePaiement,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['utilisateur_id'] = Variable<String>(utilisateurId);
    map['formule'] = Variable<String>(formule);
    map['date_debut'] = Variable<DateTime>(dateDebut);
    map['date_fin'] = Variable<DateTime>(dateFin);
    if (!nullToAbsent || referencePaiement != null) {
      map['reference_paiement'] = Variable<String>(referencePaiement);
    }
    return map;
  }

  AbonnementsCompanion toCompanion(bool nullToAbsent) {
    return AbonnementsCompanion(
      id: Value(id),
      utilisateurId: Value(utilisateurId),
      formule: Value(formule),
      dateDebut: Value(dateDebut),
      dateFin: Value(dateFin),
      referencePaiement: referencePaiement == null && nullToAbsent
          ? const Value.absent()
          : Value(referencePaiement),
    );
  }

  factory AbonnementLocale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AbonnementLocale(
      id: serializer.fromJson<String>(json['id']),
      utilisateurId: serializer.fromJson<String>(json['utilisateurId']),
      formule: serializer.fromJson<String>(json['formule']),
      dateDebut: serializer.fromJson<DateTime>(json['dateDebut']),
      dateFin: serializer.fromJson<DateTime>(json['dateFin']),
      referencePaiement: serializer.fromJson<String?>(
        json['referencePaiement'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'utilisateurId': serializer.toJson<String>(utilisateurId),
      'formule': serializer.toJson<String>(formule),
      'dateDebut': serializer.toJson<DateTime>(dateDebut),
      'dateFin': serializer.toJson<DateTime>(dateFin),
      'referencePaiement': serializer.toJson<String?>(referencePaiement),
    };
  }

  AbonnementLocale copyWith({
    String? id,
    String? utilisateurId,
    String? formule,
    DateTime? dateDebut,
    DateTime? dateFin,
    Value<String?> referencePaiement = const Value.absent(),
  }) => AbonnementLocale(
    id: id ?? this.id,
    utilisateurId: utilisateurId ?? this.utilisateurId,
    formule: formule ?? this.formule,
    dateDebut: dateDebut ?? this.dateDebut,
    dateFin: dateFin ?? this.dateFin,
    referencePaiement: referencePaiement.present
        ? referencePaiement.value
        : this.referencePaiement,
  );
  AbonnementLocale copyWithCompanion(AbonnementsCompanion data) {
    return AbonnementLocale(
      id: data.id.present ? data.id.value : this.id,
      utilisateurId: data.utilisateurId.present
          ? data.utilisateurId.value
          : this.utilisateurId,
      formule: data.formule.present ? data.formule.value : this.formule,
      dateDebut: data.dateDebut.present ? data.dateDebut.value : this.dateDebut,
      dateFin: data.dateFin.present ? data.dateFin.value : this.dateFin,
      referencePaiement: data.referencePaiement.present
          ? data.referencePaiement.value
          : this.referencePaiement,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AbonnementLocale(')
          ..write('id: $id, ')
          ..write('utilisateurId: $utilisateurId, ')
          ..write('formule: $formule, ')
          ..write('dateDebut: $dateDebut, ')
          ..write('dateFin: $dateFin, ')
          ..write('referencePaiement: $referencePaiement')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    utilisateurId,
    formule,
    dateDebut,
    dateFin,
    referencePaiement,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AbonnementLocale &&
          other.id == this.id &&
          other.utilisateurId == this.utilisateurId &&
          other.formule == this.formule &&
          other.dateDebut == this.dateDebut &&
          other.dateFin == this.dateFin &&
          other.referencePaiement == this.referencePaiement);
}

class AbonnementsCompanion extends UpdateCompanion<AbonnementLocale> {
  final Value<String> id;
  final Value<String> utilisateurId;
  final Value<String> formule;
  final Value<DateTime> dateDebut;
  final Value<DateTime> dateFin;
  final Value<String?> referencePaiement;
  final Value<int> rowid;
  const AbonnementsCompanion({
    this.id = const Value.absent(),
    this.utilisateurId = const Value.absent(),
    this.formule = const Value.absent(),
    this.dateDebut = const Value.absent(),
    this.dateFin = const Value.absent(),
    this.referencePaiement = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AbonnementsCompanion.insert({
    required String id,
    required String utilisateurId,
    required String formule,
    required DateTime dateDebut,
    required DateTime dateFin,
    this.referencePaiement = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       utilisateurId = Value(utilisateurId),
       formule = Value(formule),
       dateDebut = Value(dateDebut),
       dateFin = Value(dateFin);
  static Insertable<AbonnementLocale> custom({
    Expression<String>? id,
    Expression<String>? utilisateurId,
    Expression<String>? formule,
    Expression<DateTime>? dateDebut,
    Expression<DateTime>? dateFin,
    Expression<String>? referencePaiement,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (utilisateurId != null) 'utilisateur_id': utilisateurId,
      if (formule != null) 'formule': formule,
      if (dateDebut != null) 'date_debut': dateDebut,
      if (dateFin != null) 'date_fin': dateFin,
      if (referencePaiement != null) 'reference_paiement': referencePaiement,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AbonnementsCompanion copyWith({
    Value<String>? id,
    Value<String>? utilisateurId,
    Value<String>? formule,
    Value<DateTime>? dateDebut,
    Value<DateTime>? dateFin,
    Value<String?>? referencePaiement,
    Value<int>? rowid,
  }) {
    return AbonnementsCompanion(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      formule: formule ?? this.formule,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      referencePaiement: referencePaiement ?? this.referencePaiement,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (utilisateurId.present) {
      map['utilisateur_id'] = Variable<String>(utilisateurId.value);
    }
    if (formule.present) {
      map['formule'] = Variable<String>(formule.value);
    }
    if (dateDebut.present) {
      map['date_debut'] = Variable<DateTime>(dateDebut.value);
    }
    if (dateFin.present) {
      map['date_fin'] = Variable<DateTime>(dateFin.value);
    }
    if (referencePaiement.present) {
      map['reference_paiement'] = Variable<String>(referencePaiement.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AbonnementsCompanion(')
          ..write('id: $id, ')
          ..write('utilisateurId: $utilisateurId, ')
          ..write('formule: $formule, ')
          ..write('dateDebut: $dateDebut, ')
          ..write('dateFin: $dateFin, ')
          ..write('referencePaiement: $referencePaiement, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BaseLocale extends GeneratedDatabase {
  _$BaseLocale(QueryExecutor e) : super(e);
  $BaseLocaleManager get managers => $BaseLocaleManager(this);
  late final $ClassesTable classes = $ClassesTable(this);
  late final $MatieresTable matieres = $MatieresTable(this);
  late final $ChapitresTable chapitres = $ChapitresTable(this);
  late final $RessourcesTable ressources = $RessourcesTable(this);
  late final $UtilisateursTable utilisateurs = $UtilisateursTable(this);
  late final $ProgressionsTable progressions = $ProgressionsTable(this);
  late final $TelechargementsTable telechargements = $TelechargementsTable(
    this,
  );
  late final $AbonnementsTable abonnements = $AbonnementsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    classes,
    matieres,
    chapitres,
    ressources,
    utilisateurs,
    progressions,
    telechargements,
    abonnements,
  ];
}

typedef $$ClassesTableCreateCompanionBuilder =
    ClassesCompanion Function({
      required String id,
      required String nom,
      required String cycle,
      required int ordre,
      Value<int> rowid,
    });
typedef $$ClassesTableUpdateCompanionBuilder =
    ClassesCompanion Function({
      Value<String> id,
      Value<String> nom,
      Value<String> cycle,
      Value<int> ordre,
      Value<int> rowid,
    });

class $$ClassesTableFilterComposer
    extends Composer<_$BaseLocale, $ClassesTable> {
  $$ClassesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cycle => $composableBuilder(
    column: $table.cycle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordre => $composableBuilder(
    column: $table.ordre,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClassesTableOrderingComposer
    extends Composer<_$BaseLocale, $ClassesTable> {
  $$ClassesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cycle => $composableBuilder(
    column: $table.cycle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordre => $composableBuilder(
    column: $table.ordre,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClassesTableAnnotationComposer
    extends Composer<_$BaseLocale, $ClassesTable> {
  $$ClassesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get cycle =>
      $composableBuilder(column: $table.cycle, builder: (column) => column);

  GeneratedColumn<int> get ordre =>
      $composableBuilder(column: $table.ordre, builder: (column) => column);
}

class $$ClassesTableTableManager
    extends
        RootTableManager<
          _$BaseLocale,
          $ClassesTable,
          ClasseLocale,
          $$ClassesTableFilterComposer,
          $$ClassesTableOrderingComposer,
          $$ClassesTableAnnotationComposer,
          $$ClassesTableCreateCompanionBuilder,
          $$ClassesTableUpdateCompanionBuilder,
          (
            ClasseLocale,
            BaseReferences<_$BaseLocale, $ClassesTable, ClasseLocale>,
          ),
          ClasseLocale,
          PrefetchHooks Function()
        > {
  $$ClassesTableTableManager(_$BaseLocale db, $ClassesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClassesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClassesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClassesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nom = const Value.absent(),
                Value<String> cycle = const Value.absent(),
                Value<int> ordre = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClassesCompanion(
                id: id,
                nom: nom,
                cycle: cycle,
                ordre: ordre,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nom,
                required String cycle,
                required int ordre,
                Value<int> rowid = const Value.absent(),
              }) => ClassesCompanion.insert(
                id: id,
                nom: nom,
                cycle: cycle,
                ordre: ordre,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClassesTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseLocale,
      $ClassesTable,
      ClasseLocale,
      $$ClassesTableFilterComposer,
      $$ClassesTableOrderingComposer,
      $$ClassesTableAnnotationComposer,
      $$ClassesTableCreateCompanionBuilder,
      $$ClassesTableUpdateCompanionBuilder,
      (ClasseLocale, BaseReferences<_$BaseLocale, $ClassesTable, ClasseLocale>),
      ClasseLocale,
      PrefetchHooks Function()
    >;
typedef $$MatieresTableCreateCompanionBuilder =
    MatieresCompanion Function({
      required String id,
      required String nom,
      Value<int> rowid,
    });
typedef $$MatieresTableUpdateCompanionBuilder =
    MatieresCompanion Function({
      Value<String> id,
      Value<String> nom,
      Value<int> rowid,
    });

class $$MatieresTableFilterComposer
    extends Composer<_$BaseLocale, $MatieresTable> {
  $$MatieresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MatieresTableOrderingComposer
    extends Composer<_$BaseLocale, $MatieresTable> {
  $$MatieresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MatieresTableAnnotationComposer
    extends Composer<_$BaseLocale, $MatieresTable> {
  $$MatieresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);
}

class $$MatieresTableTableManager
    extends
        RootTableManager<
          _$BaseLocale,
          $MatieresTable,
          MatiereLocale,
          $$MatieresTableFilterComposer,
          $$MatieresTableOrderingComposer,
          $$MatieresTableAnnotationComposer,
          $$MatieresTableCreateCompanionBuilder,
          $$MatieresTableUpdateCompanionBuilder,
          (
            MatiereLocale,
            BaseReferences<_$BaseLocale, $MatieresTable, MatiereLocale>,
          ),
          MatiereLocale,
          PrefetchHooks Function()
        > {
  $$MatieresTableTableManager(_$BaseLocale db, $MatieresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatieresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatieresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatieresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MatieresCompanion(id: id, nom: nom, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String nom,
                Value<int> rowid = const Value.absent(),
              }) => MatieresCompanion.insert(id: id, nom: nom, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MatieresTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseLocale,
      $MatieresTable,
      MatiereLocale,
      $$MatieresTableFilterComposer,
      $$MatieresTableOrderingComposer,
      $$MatieresTableAnnotationComposer,
      $$MatieresTableCreateCompanionBuilder,
      $$MatieresTableUpdateCompanionBuilder,
      (
        MatiereLocale,
        BaseReferences<_$BaseLocale, $MatieresTable, MatiereLocale>,
      ),
      MatiereLocale,
      PrefetchHooks Function()
    >;
typedef $$ChapitresTableCreateCompanionBuilder =
    ChapitresCompanion Function({
      required String id,
      required String classeId,
      required String matiereId,
      required int numero,
      required String titre,
      Value<String?> strate,
      required int ordre,
      Value<int> rowid,
    });
typedef $$ChapitresTableUpdateCompanionBuilder =
    ChapitresCompanion Function({
      Value<String> id,
      Value<String> classeId,
      Value<String> matiereId,
      Value<int> numero,
      Value<String> titre,
      Value<String?> strate,
      Value<int> ordre,
      Value<int> rowid,
    });

class $$ChapitresTableFilterComposer
    extends Composer<_$BaseLocale, $ChapitresTable> {
  $$ChapitresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classeId => $composableBuilder(
    column: $table.classeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matiereId => $composableBuilder(
    column: $table.matiereId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titre => $composableBuilder(
    column: $table.titre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strate => $composableBuilder(
    column: $table.strate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordre => $composableBuilder(
    column: $table.ordre,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChapitresTableOrderingComposer
    extends Composer<_$BaseLocale, $ChapitresTable> {
  $$ChapitresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classeId => $composableBuilder(
    column: $table.classeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matiereId => $composableBuilder(
    column: $table.matiereId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titre => $composableBuilder(
    column: $table.titre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strate => $composableBuilder(
    column: $table.strate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordre => $composableBuilder(
    column: $table.ordre,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChapitresTableAnnotationComposer
    extends Composer<_$BaseLocale, $ChapitresTable> {
  $$ChapitresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get classeId =>
      $composableBuilder(column: $table.classeId, builder: (column) => column);

  GeneratedColumn<String> get matiereId =>
      $composableBuilder(column: $table.matiereId, builder: (column) => column);

  GeneratedColumn<int> get numero =>
      $composableBuilder(column: $table.numero, builder: (column) => column);

  GeneratedColumn<String> get titre =>
      $composableBuilder(column: $table.titre, builder: (column) => column);

  GeneratedColumn<String> get strate =>
      $composableBuilder(column: $table.strate, builder: (column) => column);

  GeneratedColumn<int> get ordre =>
      $composableBuilder(column: $table.ordre, builder: (column) => column);
}

class $$ChapitresTableTableManager
    extends
        RootTableManager<
          _$BaseLocale,
          $ChapitresTable,
          ChapitreLocale,
          $$ChapitresTableFilterComposer,
          $$ChapitresTableOrderingComposer,
          $$ChapitresTableAnnotationComposer,
          $$ChapitresTableCreateCompanionBuilder,
          $$ChapitresTableUpdateCompanionBuilder,
          (
            ChapitreLocale,
            BaseReferences<_$BaseLocale, $ChapitresTable, ChapitreLocale>,
          ),
          ChapitreLocale,
          PrefetchHooks Function()
        > {
  $$ChapitresTableTableManager(_$BaseLocale db, $ChapitresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChapitresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChapitresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChapitresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> classeId = const Value.absent(),
                Value<String> matiereId = const Value.absent(),
                Value<int> numero = const Value.absent(),
                Value<String> titre = const Value.absent(),
                Value<String?> strate = const Value.absent(),
                Value<int> ordre = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChapitresCompanion(
                id: id,
                classeId: classeId,
                matiereId: matiereId,
                numero: numero,
                titre: titre,
                strate: strate,
                ordre: ordre,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String classeId,
                required String matiereId,
                required int numero,
                required String titre,
                Value<String?> strate = const Value.absent(),
                required int ordre,
                Value<int> rowid = const Value.absent(),
              }) => ChapitresCompanion.insert(
                id: id,
                classeId: classeId,
                matiereId: matiereId,
                numero: numero,
                titre: titre,
                strate: strate,
                ordre: ordre,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChapitresTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseLocale,
      $ChapitresTable,
      ChapitreLocale,
      $$ChapitresTableFilterComposer,
      $$ChapitresTableOrderingComposer,
      $$ChapitresTableAnnotationComposer,
      $$ChapitresTableCreateCompanionBuilder,
      $$ChapitresTableUpdateCompanionBuilder,
      (
        ChapitreLocale,
        BaseReferences<_$BaseLocale, $ChapitresTable, ChapitreLocale>,
      ),
      ChapitreLocale,
      PrefetchHooks Function()
    >;
typedef $$RessourcesTableCreateCompanionBuilder =
    RessourcesCompanion Function({
      required String id,
      Value<String?> chapitreId,
      Value<String?> classeId,
      Value<String?> matiereId,
      required String type,
      required String titre,
      required int tailleOctets,
      required bool premium,
      required int version,
      Value<String?> cheminStorage,
      required int ordre,
      Value<int> rowid,
    });
typedef $$RessourcesTableUpdateCompanionBuilder =
    RessourcesCompanion Function({
      Value<String> id,
      Value<String?> chapitreId,
      Value<String?> classeId,
      Value<String?> matiereId,
      Value<String> type,
      Value<String> titre,
      Value<int> tailleOctets,
      Value<bool> premium,
      Value<int> version,
      Value<String?> cheminStorage,
      Value<int> ordre,
      Value<int> rowid,
    });

class $$RessourcesTableFilterComposer
    extends Composer<_$BaseLocale, $RessourcesTable> {
  $$RessourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapitreId => $composableBuilder(
    column: $table.chapitreId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classeId => $composableBuilder(
    column: $table.classeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matiereId => $composableBuilder(
    column: $table.matiereId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titre => $composableBuilder(
    column: $table.titre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tailleOctets => $composableBuilder(
    column: $table.tailleOctets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get premium => $composableBuilder(
    column: $table.premium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cheminStorage => $composableBuilder(
    column: $table.cheminStorage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordre => $composableBuilder(
    column: $table.ordre,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RessourcesTableOrderingComposer
    extends Composer<_$BaseLocale, $RessourcesTable> {
  $$RessourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapitreId => $composableBuilder(
    column: $table.chapitreId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classeId => $composableBuilder(
    column: $table.classeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matiereId => $composableBuilder(
    column: $table.matiereId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titre => $composableBuilder(
    column: $table.titre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tailleOctets => $composableBuilder(
    column: $table.tailleOctets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get premium => $composableBuilder(
    column: $table.premium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cheminStorage => $composableBuilder(
    column: $table.cheminStorage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordre => $composableBuilder(
    column: $table.ordre,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RessourcesTableAnnotationComposer
    extends Composer<_$BaseLocale, $RessourcesTable> {
  $$RessourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get chapitreId => $composableBuilder(
    column: $table.chapitreId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get classeId =>
      $composableBuilder(column: $table.classeId, builder: (column) => column);

  GeneratedColumn<String> get matiereId =>
      $composableBuilder(column: $table.matiereId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get titre =>
      $composableBuilder(column: $table.titre, builder: (column) => column);

  GeneratedColumn<int> get tailleOctets => $composableBuilder(
    column: $table.tailleOctets,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get premium =>
      $composableBuilder(column: $table.premium, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get cheminStorage => $composableBuilder(
    column: $table.cheminStorage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ordre =>
      $composableBuilder(column: $table.ordre, builder: (column) => column);
}

class $$RessourcesTableTableManager
    extends
        RootTableManager<
          _$BaseLocale,
          $RessourcesTable,
          RessourceLocale,
          $$RessourcesTableFilterComposer,
          $$RessourcesTableOrderingComposer,
          $$RessourcesTableAnnotationComposer,
          $$RessourcesTableCreateCompanionBuilder,
          $$RessourcesTableUpdateCompanionBuilder,
          (
            RessourceLocale,
            BaseReferences<_$BaseLocale, $RessourcesTable, RessourceLocale>,
          ),
          RessourceLocale,
          PrefetchHooks Function()
        > {
  $$RessourcesTableTableManager(_$BaseLocale db, $RessourcesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RessourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RessourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RessourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> chapitreId = const Value.absent(),
                Value<String?> classeId = const Value.absent(),
                Value<String?> matiereId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> titre = const Value.absent(),
                Value<int> tailleOctets = const Value.absent(),
                Value<bool> premium = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String?> cheminStorage = const Value.absent(),
                Value<int> ordre = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RessourcesCompanion(
                id: id,
                chapitreId: chapitreId,
                classeId: classeId,
                matiereId: matiereId,
                type: type,
                titre: titre,
                tailleOctets: tailleOctets,
                premium: premium,
                version: version,
                cheminStorage: cheminStorage,
                ordre: ordre,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> chapitreId = const Value.absent(),
                Value<String?> classeId = const Value.absent(),
                Value<String?> matiereId = const Value.absent(),
                required String type,
                required String titre,
                required int tailleOctets,
                required bool premium,
                required int version,
                Value<String?> cheminStorage = const Value.absent(),
                required int ordre,
                Value<int> rowid = const Value.absent(),
              }) => RessourcesCompanion.insert(
                id: id,
                chapitreId: chapitreId,
                classeId: classeId,
                matiereId: matiereId,
                type: type,
                titre: titre,
                tailleOctets: tailleOctets,
                premium: premium,
                version: version,
                cheminStorage: cheminStorage,
                ordre: ordre,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RessourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseLocale,
      $RessourcesTable,
      RessourceLocale,
      $$RessourcesTableFilterComposer,
      $$RessourcesTableOrderingComposer,
      $$RessourcesTableAnnotationComposer,
      $$RessourcesTableCreateCompanionBuilder,
      $$RessourcesTableUpdateCompanionBuilder,
      (
        RessourceLocale,
        BaseReferences<_$BaseLocale, $RessourcesTable, RessourceLocale>,
      ),
      RessourceLocale,
      PrefetchHooks Function()
    >;
typedef $$UtilisateursTableCreateCompanionBuilder =
    UtilisateursCompanion Function({
      required String id,
      Value<String?> classeId,
      Value<String?> serie,
      required DateTime creeLe,
      Value<int> rowid,
    });
typedef $$UtilisateursTableUpdateCompanionBuilder =
    UtilisateursCompanion Function({
      Value<String> id,
      Value<String?> classeId,
      Value<String?> serie,
      Value<DateTime> creeLe,
      Value<int> rowid,
    });

class $$UtilisateursTableFilterComposer
    extends Composer<_$BaseLocale, $UtilisateursTable> {
  $$UtilisateursTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classeId => $composableBuilder(
    column: $table.classeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serie => $composableBuilder(
    column: $table.serie,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creeLe => $composableBuilder(
    column: $table.creeLe,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UtilisateursTableOrderingComposer
    extends Composer<_$BaseLocale, $UtilisateursTable> {
  $$UtilisateursTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classeId => $composableBuilder(
    column: $table.classeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serie => $composableBuilder(
    column: $table.serie,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creeLe => $composableBuilder(
    column: $table.creeLe,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UtilisateursTableAnnotationComposer
    extends Composer<_$BaseLocale, $UtilisateursTable> {
  $$UtilisateursTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get classeId =>
      $composableBuilder(column: $table.classeId, builder: (column) => column);

  GeneratedColumn<String> get serie =>
      $composableBuilder(column: $table.serie, builder: (column) => column);

  GeneratedColumn<DateTime> get creeLe =>
      $composableBuilder(column: $table.creeLe, builder: (column) => column);
}

class $$UtilisateursTableTableManager
    extends
        RootTableManager<
          _$BaseLocale,
          $UtilisateursTable,
          UtilisateurLocale,
          $$UtilisateursTableFilterComposer,
          $$UtilisateursTableOrderingComposer,
          $$UtilisateursTableAnnotationComposer,
          $$UtilisateursTableCreateCompanionBuilder,
          $$UtilisateursTableUpdateCompanionBuilder,
          (
            UtilisateurLocale,
            BaseReferences<_$BaseLocale, $UtilisateursTable, UtilisateurLocale>,
          ),
          UtilisateurLocale,
          PrefetchHooks Function()
        > {
  $$UtilisateursTableTableManager(_$BaseLocale db, $UtilisateursTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UtilisateursTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UtilisateursTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UtilisateursTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> classeId = const Value.absent(),
                Value<String?> serie = const Value.absent(),
                Value<DateTime> creeLe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UtilisateursCompanion(
                id: id,
                classeId: classeId,
                serie: serie,
                creeLe: creeLe,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> classeId = const Value.absent(),
                Value<String?> serie = const Value.absent(),
                required DateTime creeLe,
                Value<int> rowid = const Value.absent(),
              }) => UtilisateursCompanion.insert(
                id: id,
                classeId: classeId,
                serie: serie,
                creeLe: creeLe,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UtilisateursTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseLocale,
      $UtilisateursTable,
      UtilisateurLocale,
      $$UtilisateursTableFilterComposer,
      $$UtilisateursTableOrderingComposer,
      $$UtilisateursTableAnnotationComposer,
      $$UtilisateursTableCreateCompanionBuilder,
      $$UtilisateursTableUpdateCompanionBuilder,
      (
        UtilisateurLocale,
        BaseReferences<_$BaseLocale, $UtilisateursTable, UtilisateurLocale>,
      ),
      UtilisateurLocale,
      PrefetchHooks Function()
    >;
typedef $$ProgressionsTableCreateCompanionBuilder =
    ProgressionsCompanion Function({
      required String id,
      required String utilisateurId,
      required String chapitreId,
      required String etat,
      required DateTime dateMaj,
      Value<int> rowid,
    });
typedef $$ProgressionsTableUpdateCompanionBuilder =
    ProgressionsCompanion Function({
      Value<String> id,
      Value<String> utilisateurId,
      Value<String> chapitreId,
      Value<String> etat,
      Value<DateTime> dateMaj,
      Value<int> rowid,
    });

class $$ProgressionsTableFilterComposer
    extends Composer<_$BaseLocale, $ProgressionsTable> {
  $$ProgressionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get utilisateurId => $composableBuilder(
    column: $table.utilisateurId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapitreId => $composableBuilder(
    column: $table.chapitreId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etat => $composableBuilder(
    column: $table.etat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateMaj => $composableBuilder(
    column: $table.dateMaj,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProgressionsTableOrderingComposer
    extends Composer<_$BaseLocale, $ProgressionsTable> {
  $$ProgressionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get utilisateurId => $composableBuilder(
    column: $table.utilisateurId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapitreId => $composableBuilder(
    column: $table.chapitreId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etat => $composableBuilder(
    column: $table.etat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateMaj => $composableBuilder(
    column: $table.dateMaj,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProgressionsTableAnnotationComposer
    extends Composer<_$BaseLocale, $ProgressionsTable> {
  $$ProgressionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get utilisateurId => $composableBuilder(
    column: $table.utilisateurId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chapitreId => $composableBuilder(
    column: $table.chapitreId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get etat =>
      $composableBuilder(column: $table.etat, builder: (column) => column);

  GeneratedColumn<DateTime> get dateMaj =>
      $composableBuilder(column: $table.dateMaj, builder: (column) => column);
}

class $$ProgressionsTableTableManager
    extends
        RootTableManager<
          _$BaseLocale,
          $ProgressionsTable,
          ProgressionLocale,
          $$ProgressionsTableFilterComposer,
          $$ProgressionsTableOrderingComposer,
          $$ProgressionsTableAnnotationComposer,
          $$ProgressionsTableCreateCompanionBuilder,
          $$ProgressionsTableUpdateCompanionBuilder,
          (
            ProgressionLocale,
            BaseReferences<_$BaseLocale, $ProgressionsTable, ProgressionLocale>,
          ),
          ProgressionLocale,
          PrefetchHooks Function()
        > {
  $$ProgressionsTableTableManager(_$BaseLocale db, $ProgressionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgressionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgressionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgressionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> utilisateurId = const Value.absent(),
                Value<String> chapitreId = const Value.absent(),
                Value<String> etat = const Value.absent(),
                Value<DateTime> dateMaj = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgressionsCompanion(
                id: id,
                utilisateurId: utilisateurId,
                chapitreId: chapitreId,
                etat: etat,
                dateMaj: dateMaj,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String utilisateurId,
                required String chapitreId,
                required String etat,
                required DateTime dateMaj,
                Value<int> rowid = const Value.absent(),
              }) => ProgressionsCompanion.insert(
                id: id,
                utilisateurId: utilisateurId,
                chapitreId: chapitreId,
                etat: etat,
                dateMaj: dateMaj,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProgressionsTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseLocale,
      $ProgressionsTable,
      ProgressionLocale,
      $$ProgressionsTableFilterComposer,
      $$ProgressionsTableOrderingComposer,
      $$ProgressionsTableAnnotationComposer,
      $$ProgressionsTableCreateCompanionBuilder,
      $$ProgressionsTableUpdateCompanionBuilder,
      (
        ProgressionLocale,
        BaseReferences<_$BaseLocale, $ProgressionsTable, ProgressionLocale>,
      ),
      ProgressionLocale,
      PrefetchHooks Function()
    >;
typedef $$TelechargementsTableCreateCompanionBuilder =
    TelechargementsCompanion Function({
      required String id,
      required String utilisateurId,
      required String ressourceId,
      required DateTime dateTelechargement,
      Value<int> rowid,
    });
typedef $$TelechargementsTableUpdateCompanionBuilder =
    TelechargementsCompanion Function({
      Value<String> id,
      Value<String> utilisateurId,
      Value<String> ressourceId,
      Value<DateTime> dateTelechargement,
      Value<int> rowid,
    });

class $$TelechargementsTableFilterComposer
    extends Composer<_$BaseLocale, $TelechargementsTable> {
  $$TelechargementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get utilisateurId => $composableBuilder(
    column: $table.utilisateurId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ressourceId => $composableBuilder(
    column: $table.ressourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateTelechargement => $composableBuilder(
    column: $table.dateTelechargement,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TelechargementsTableOrderingComposer
    extends Composer<_$BaseLocale, $TelechargementsTable> {
  $$TelechargementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get utilisateurId => $composableBuilder(
    column: $table.utilisateurId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ressourceId => $composableBuilder(
    column: $table.ressourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateTelechargement => $composableBuilder(
    column: $table.dateTelechargement,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TelechargementsTableAnnotationComposer
    extends Composer<_$BaseLocale, $TelechargementsTable> {
  $$TelechargementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get utilisateurId => $composableBuilder(
    column: $table.utilisateurId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ressourceId => $composableBuilder(
    column: $table.ressourceId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateTelechargement => $composableBuilder(
    column: $table.dateTelechargement,
    builder: (column) => column,
  );
}

class $$TelechargementsTableTableManager
    extends
        RootTableManager<
          _$BaseLocale,
          $TelechargementsTable,
          TelechargementLocale,
          $$TelechargementsTableFilterComposer,
          $$TelechargementsTableOrderingComposer,
          $$TelechargementsTableAnnotationComposer,
          $$TelechargementsTableCreateCompanionBuilder,
          $$TelechargementsTableUpdateCompanionBuilder,
          (
            TelechargementLocale,
            BaseReferences<
              _$BaseLocale,
              $TelechargementsTable,
              TelechargementLocale
            >,
          ),
          TelechargementLocale,
          PrefetchHooks Function()
        > {
  $$TelechargementsTableTableManager(
    _$BaseLocale db,
    $TelechargementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TelechargementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TelechargementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TelechargementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> utilisateurId = const Value.absent(),
                Value<String> ressourceId = const Value.absent(),
                Value<DateTime> dateTelechargement = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TelechargementsCompanion(
                id: id,
                utilisateurId: utilisateurId,
                ressourceId: ressourceId,
                dateTelechargement: dateTelechargement,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String utilisateurId,
                required String ressourceId,
                required DateTime dateTelechargement,
                Value<int> rowid = const Value.absent(),
              }) => TelechargementsCompanion.insert(
                id: id,
                utilisateurId: utilisateurId,
                ressourceId: ressourceId,
                dateTelechargement: dateTelechargement,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TelechargementsTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseLocale,
      $TelechargementsTable,
      TelechargementLocale,
      $$TelechargementsTableFilterComposer,
      $$TelechargementsTableOrderingComposer,
      $$TelechargementsTableAnnotationComposer,
      $$TelechargementsTableCreateCompanionBuilder,
      $$TelechargementsTableUpdateCompanionBuilder,
      (
        TelechargementLocale,
        BaseReferences<
          _$BaseLocale,
          $TelechargementsTable,
          TelechargementLocale
        >,
      ),
      TelechargementLocale,
      PrefetchHooks Function()
    >;
typedef $$AbonnementsTableCreateCompanionBuilder =
    AbonnementsCompanion Function({
      required String id,
      required String utilisateurId,
      required String formule,
      required DateTime dateDebut,
      required DateTime dateFin,
      Value<String?> referencePaiement,
      Value<int> rowid,
    });
typedef $$AbonnementsTableUpdateCompanionBuilder =
    AbonnementsCompanion Function({
      Value<String> id,
      Value<String> utilisateurId,
      Value<String> formule,
      Value<DateTime> dateDebut,
      Value<DateTime> dateFin,
      Value<String?> referencePaiement,
      Value<int> rowid,
    });

class $$AbonnementsTableFilterComposer
    extends Composer<_$BaseLocale, $AbonnementsTable> {
  $$AbonnementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get utilisateurId => $composableBuilder(
    column: $table.utilisateurId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formule => $composableBuilder(
    column: $table.formule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateDebut => $composableBuilder(
    column: $table.dateDebut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateFin => $composableBuilder(
    column: $table.dateFin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referencePaiement => $composableBuilder(
    column: $table.referencePaiement,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AbonnementsTableOrderingComposer
    extends Composer<_$BaseLocale, $AbonnementsTable> {
  $$AbonnementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get utilisateurId => $composableBuilder(
    column: $table.utilisateurId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formule => $composableBuilder(
    column: $table.formule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateDebut => $composableBuilder(
    column: $table.dateDebut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateFin => $composableBuilder(
    column: $table.dateFin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referencePaiement => $composableBuilder(
    column: $table.referencePaiement,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AbonnementsTableAnnotationComposer
    extends Composer<_$BaseLocale, $AbonnementsTable> {
  $$AbonnementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get utilisateurId => $composableBuilder(
    column: $table.utilisateurId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get formule =>
      $composableBuilder(column: $table.formule, builder: (column) => column);

  GeneratedColumn<DateTime> get dateDebut =>
      $composableBuilder(column: $table.dateDebut, builder: (column) => column);

  GeneratedColumn<DateTime> get dateFin =>
      $composableBuilder(column: $table.dateFin, builder: (column) => column);

  GeneratedColumn<String> get referencePaiement => $composableBuilder(
    column: $table.referencePaiement,
    builder: (column) => column,
  );
}

class $$AbonnementsTableTableManager
    extends
        RootTableManager<
          _$BaseLocale,
          $AbonnementsTable,
          AbonnementLocale,
          $$AbonnementsTableFilterComposer,
          $$AbonnementsTableOrderingComposer,
          $$AbonnementsTableAnnotationComposer,
          $$AbonnementsTableCreateCompanionBuilder,
          $$AbonnementsTableUpdateCompanionBuilder,
          (
            AbonnementLocale,
            BaseReferences<_$BaseLocale, $AbonnementsTable, AbonnementLocale>,
          ),
          AbonnementLocale,
          PrefetchHooks Function()
        > {
  $$AbonnementsTableTableManager(_$BaseLocale db, $AbonnementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AbonnementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AbonnementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AbonnementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> utilisateurId = const Value.absent(),
                Value<String> formule = const Value.absent(),
                Value<DateTime> dateDebut = const Value.absent(),
                Value<DateTime> dateFin = const Value.absent(),
                Value<String?> referencePaiement = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AbonnementsCompanion(
                id: id,
                utilisateurId: utilisateurId,
                formule: formule,
                dateDebut: dateDebut,
                dateFin: dateFin,
                referencePaiement: referencePaiement,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String utilisateurId,
                required String formule,
                required DateTime dateDebut,
                required DateTime dateFin,
                Value<String?> referencePaiement = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AbonnementsCompanion.insert(
                id: id,
                utilisateurId: utilisateurId,
                formule: formule,
                dateDebut: dateDebut,
                dateFin: dateFin,
                referencePaiement: referencePaiement,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AbonnementsTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseLocale,
      $AbonnementsTable,
      AbonnementLocale,
      $$AbonnementsTableFilterComposer,
      $$AbonnementsTableOrderingComposer,
      $$AbonnementsTableAnnotationComposer,
      $$AbonnementsTableCreateCompanionBuilder,
      $$AbonnementsTableUpdateCompanionBuilder,
      (
        AbonnementLocale,
        BaseReferences<_$BaseLocale, $AbonnementsTable, AbonnementLocale>,
      ),
      AbonnementLocale,
      PrefetchHooks Function()
    >;

class $BaseLocaleManager {
  final _$BaseLocale _db;
  $BaseLocaleManager(this._db);
  $$ClassesTableTableManager get classes =>
      $$ClassesTableTableManager(_db, _db.classes);
  $$MatieresTableTableManager get matieres =>
      $$MatieresTableTableManager(_db, _db.matieres);
  $$ChapitresTableTableManager get chapitres =>
      $$ChapitresTableTableManager(_db, _db.chapitres);
  $$RessourcesTableTableManager get ressources =>
      $$RessourcesTableTableManager(_db, _db.ressources);
  $$UtilisateursTableTableManager get utilisateurs =>
      $$UtilisateursTableTableManager(_db, _db.utilisateurs);
  $$ProgressionsTableTableManager get progressions =>
      $$ProgressionsTableTableManager(_db, _db.progressions);
  $$TelechargementsTableTableManager get telechargements =>
      $$TelechargementsTableTableManager(_db, _db.telechargements);
  $$AbonnementsTableTableManager get abonnements =>
      $$AbonnementsTableTableManager(_db, _db.abonnements);
}
