import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'base_locale.g.dart';

// =============================================================================
// Tables Drift locales — miroir des 8 tables serveur (migration 01).
//
// Role : rendre le catalogue et les donnees eleve LISIBLES HORS-LIGNE (contrat
// hors-ligne, 02 - Contenu et Experience.pdf §4.5). C'est un cache reconstructible
// depuis Supabase, PAS la source de verite : on n'y met donc pas les contraintes
// d'integrite du serveur (cles etrangeres, CHECK) — elles sont deja garanties a
// la source, et les reproduire ici genererait des conflits d'ordre d'insertion a
// la synchronisation. Chaque colonne suit EXACTEMENT le nom et la nullabilite du
// schema (jamais devine). Les lignes generees portent le suffixe `Locale` pour ne
// pas entrer en collision avec les entites du domaine (`Classe`, `Ressource`...).
//
// La traduction ligne Drift <-> entite du domaine est faite dans data/models/
// (Lot D). Ces tables ne connaissent ni les enums ni les entites : Dart + Drift.
// =============================================================================

@DataClassName('ClasseLocale')
class Classes extends Table {
  TextColumn get id => text()();
  TextColumn get nom => text()();
  TextColumn get cycle => text()();
  IntColumn get ordre => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MatiereLocale')
class Matieres extends Table {
  TextColumn get id => text()();
  TextColumn get nom => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ChapitreLocale')
class Chapitres extends Table {
  TextColumn get id => text()();
  TextColumn get classeId => text()();
  TextColumn get matiereId => text()();
  IntColumn get numero => integer()();
  TextColumn get titre => text()();
  TextColumn get strate => text().nullable()();
  IntColumn get ordre => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RessourceLocale')
class Ressources extends Table {
  TextColumn get id => text()();
  TextColumn get chapitreId => text().nullable()();
  TextColumn get classeId => text().nullable()();
  TextColumn get matiereId => text().nullable()();
  TextColumn get type => text()();
  TextColumn get titre => text()();
  IntColumn get tailleOctets => integer()();
  BoolColumn get premium => boolean()();
  IntColumn get version => integer()();
  TextColumn get cheminStorage => text().nullable()();
  IntColumn get ordre => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('UtilisateurLocale')
class Utilisateurs extends Table {
  TextColumn get id => text()();
  TextColumn get classeId => text().nullable()();
  TextColumn get serie => text().nullable()();
  DateTimeColumn get creeLe => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProgressionLocale')
class Progressions extends Table {
  TextColumn get id => text()();
  TextColumn get utilisateurId => text()();
  TextColumn get chapitreId => text()();
  TextColumn get etat => text()();
  DateTimeColumn get dateMaj => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TelechargementLocale')
class Telechargements extends Table {
  TextColumn get id => text()();
  TextColumn get utilisateurId => text()();
  TextColumn get ressourceId => text()();
  DateTimeColumn get dateTelechargement => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AbonnementLocale')
class Abonnements extends Table {
  TextColumn get id => text()();
  TextColumn get utilisateurId => text()();
  TextColumn get formule => text()();
  DateTimeColumn get dateDebut => dateTime()();
  DateTimeColumn get dateFin => dateTime()();
  TextColumn get referencePaiement => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Base de donnees locale de l'application (Drift + SQLite via drift_flutter).
@DriftDatabase(
  tables: [
    Classes,
    Matieres,
    Chapitres,
    Ressources,
    Utilisateurs,
    Progressions,
    Telechargements,
    Abonnements,
  ],
)
class BaseLocale extends _$BaseLocale {
  BaseLocale() : super(_ouvrirConnexion());

  /// Constructeur de test : injecte un executeur (ex. `NativeDatabase.memory()`)
  /// pour ecrire des tests sans toucher au disque ni aux plugins.
  BaseLocale.avecExecuteur(super.executeur);

  // v1 = la table de demonstration `LignesDemo` (etape 10). v2 = le vrai schema.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // La base locale est un miroir reconstructible du serveur : on jette la
      // table de demonstration jetable et on cree le vrai schema. (La vraie
      // mecanique de synchronisation viendra en Phase 3 ; ici, aucune donnee
      // reelle n'existe encore a preserver.)
      await m.database.customStatement('DROP TABLE IF EXISTS lignes_demo');
      await m.createAll();
    },
  );

  // drift_flutter place le fichier `fayemath.sqlite` dans le dossier de donnees
  // de l'app et embarque le moteur SQLite natif. Brique offline-first.
  static QueryExecutor _ouvrirConnexion() => driftDatabase(name: 'fayemath');
}
