// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_locale.dart';

// ignore_for_file: type=lint
class $LignesDemoTable extends LignesDemo
    with TableInfo<$LignesDemoTable, LignesDemoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LignesDemoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contenuMeta = const VerificationMeta(
    'contenu',
  );
  @override
  late final GeneratedColumn<String> contenu = GeneratedColumn<String>(
    'contenu',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, contenu];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lignes_demo';
  @override
  VerificationContext validateIntegrity(
    Insertable<LignesDemoData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contenu')) {
      context.handle(
        _contenuMeta,
        contenu.isAcceptableOrUnknown(data['contenu']!, _contenuMeta),
      );
    } else if (isInserting) {
      context.missing(_contenuMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LignesDemoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LignesDemoData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contenu: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contenu'],
      )!,
    );
  }

  @override
  $LignesDemoTable createAlias(String alias) {
    return $LignesDemoTable(attachedDatabase, alias);
  }
}

class LignesDemoData extends DataClass implements Insertable<LignesDemoData> {
  final int id;
  final String contenu;
  const LignesDemoData({required this.id, required this.contenu});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['contenu'] = Variable<String>(contenu);
    return map;
  }

  LignesDemoCompanion toCompanion(bool nullToAbsent) {
    return LignesDemoCompanion(id: Value(id), contenu: Value(contenu));
  }

  factory LignesDemoData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LignesDemoData(
      id: serializer.fromJson<int>(json['id']),
      contenu: serializer.fromJson<String>(json['contenu']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contenu': serializer.toJson<String>(contenu),
    };
  }

  LignesDemoData copyWith({int? id, String? contenu}) =>
      LignesDemoData(id: id ?? this.id, contenu: contenu ?? this.contenu);
  LignesDemoData copyWithCompanion(LignesDemoCompanion data) {
    return LignesDemoData(
      id: data.id.present ? data.id.value : this.id,
      contenu: data.contenu.present ? data.contenu.value : this.contenu,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LignesDemoData(')
          ..write('id: $id, ')
          ..write('contenu: $contenu')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, contenu);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LignesDemoData &&
          other.id == this.id &&
          other.contenu == this.contenu);
}

class LignesDemoCompanion extends UpdateCompanion<LignesDemoData> {
  final Value<int> id;
  final Value<String> contenu;
  const LignesDemoCompanion({
    this.id = const Value.absent(),
    this.contenu = const Value.absent(),
  });
  LignesDemoCompanion.insert({
    this.id = const Value.absent(),
    required String contenu,
  }) : contenu = Value(contenu);
  static Insertable<LignesDemoData> custom({
    Expression<int>? id,
    Expression<String>? contenu,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contenu != null) 'contenu': contenu,
    });
  }

  LignesDemoCompanion copyWith({Value<int>? id, Value<String>? contenu}) {
    return LignesDemoCompanion(
      id: id ?? this.id,
      contenu: contenu ?? this.contenu,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contenu.present) {
      map['contenu'] = Variable<String>(contenu.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LignesDemoCompanion(')
          ..write('id: $id, ')
          ..write('contenu: $contenu')
          ..write(')'))
        .toString();
  }
}

abstract class _$BaseLocale extends GeneratedDatabase {
  _$BaseLocale(QueryExecutor e) : super(e);
  $BaseLocaleManager get managers => $BaseLocaleManager(this);
  late final $LignesDemoTable lignesDemo = $LignesDemoTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [lignesDemo];
}

typedef $$LignesDemoTableCreateCompanionBuilder =
    LignesDemoCompanion Function({Value<int> id, required String contenu});
typedef $$LignesDemoTableUpdateCompanionBuilder =
    LignesDemoCompanion Function({Value<int> id, Value<String> contenu});

class $$LignesDemoTableFilterComposer
    extends Composer<_$BaseLocale, $LignesDemoTable> {
  $$LignesDemoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contenu => $composableBuilder(
    column: $table.contenu,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LignesDemoTableOrderingComposer
    extends Composer<_$BaseLocale, $LignesDemoTable> {
  $$LignesDemoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contenu => $composableBuilder(
    column: $table.contenu,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LignesDemoTableAnnotationComposer
    extends Composer<_$BaseLocale, $LignesDemoTable> {
  $$LignesDemoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contenu =>
      $composableBuilder(column: $table.contenu, builder: (column) => column);
}

class $$LignesDemoTableTableManager
    extends
        RootTableManager<
          _$BaseLocale,
          $LignesDemoTable,
          LignesDemoData,
          $$LignesDemoTableFilterComposer,
          $$LignesDemoTableOrderingComposer,
          $$LignesDemoTableAnnotationComposer,
          $$LignesDemoTableCreateCompanionBuilder,
          $$LignesDemoTableUpdateCompanionBuilder,
          (
            LignesDemoData,
            BaseReferences<_$BaseLocale, $LignesDemoTable, LignesDemoData>,
          ),
          LignesDemoData,
          PrefetchHooks Function()
        > {
  $$LignesDemoTableTableManager(_$BaseLocale db, $LignesDemoTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LignesDemoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LignesDemoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LignesDemoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> contenu = const Value.absent(),
              }) => LignesDemoCompanion(id: id, contenu: contenu),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String contenu,
              }) => LignesDemoCompanion.insert(id: id, contenu: contenu),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LignesDemoTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseLocale,
      $LignesDemoTable,
      LignesDemoData,
      $$LignesDemoTableFilterComposer,
      $$LignesDemoTableOrderingComposer,
      $$LignesDemoTableAnnotationComposer,
      $$LignesDemoTableCreateCompanionBuilder,
      $$LignesDemoTableUpdateCompanionBuilder,
      (
        LignesDemoData,
        BaseReferences<_$BaseLocale, $LignesDemoTable, LignesDemoData>,
      ),
      LignesDemoData,
      PrefetchHooks Function()
    >;

class $BaseLocaleManager {
  final _$BaseLocale _db;
  $BaseLocaleManager(this._db);
  $$LignesDemoTableTableManager get lignesDemo =>
      $$LignesDemoTableTableManager(_db, _db.lignesDemo);
}
