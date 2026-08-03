import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

part 'base_locale.g.dart';

/// Table triviale de demonstration (Lot D, etape 10), retiree a l'etape 11.
/// Elle ne sert qu'a prouver que Drift ecrit et relit reellement sur le disque.
class LignesDemo extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get contenu => text()();
}

/// Base de donnees locale de l'application (Drift + SQLite via drift_flutter).
///
/// Les vraies tables (chapitres, ressources, progression...) arriveront a partir
/// de l'etape 11 ; pour l'instant, une seule table de demonstration.
@DriftDatabase(tables: [LignesDemo])
class BaseLocale extends _$BaseLocale {
  BaseLocale() : super(_ouvrirConnexion());

  @override
  int get schemaVersion => 1;

  // drift_flutter place le fichier `fayemath.sqlite` dans le dossier de donnees
  // de l'app et embarque le moteur SQLite natif (sqlite3_flutter_libs, tire en
  // transitif). C'est la brique offline-first : lecture locale d'abord.
  static QueryExecutor _ouvrirConnexion() => driftDatabase(name: 'fayemath');
}

/// Preuve de fonctionnement (Lot D) : insere une ligne, relit toute la table et
/// journalise le nombre de lignes et la derniere valeur. Le compteur augmente a
/// chaque lancement — preuve que les donnees persistent sur le disque, pas en
/// memoire. Temporaire, a retirer a l'etape 11 avec la table de demonstration.
Future<void> verifierBaseLocaleDemo() async {
  final base = BaseLocale();
  await base
      .into(base.lignesDemo)
      .insert(LignesDemoCompanion.insert(contenu: 'ping ${DateTime.now()}'));
  final lignes = await base.select(base.lignesDemo).get();
  debugPrint(
    '[Drift] base locale OK — ${lignes.length} ligne(s) sur le disque, '
    'derniere : "${lignes.last.contenu}"',
  );
  await base.close();
}
