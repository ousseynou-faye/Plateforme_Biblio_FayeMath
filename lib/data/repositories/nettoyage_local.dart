import 'dart:io' show Directory;

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:fayemath_academy/core/telechargement/chemins_telechargement.dart';
import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/domain/repositories/nettoyage_local_repository.dart';

/// Implementation du [NettoyageLocalRepository] : efface le cache Drift PERSONNEL
/// et les PDF telecharges de l'appareil, lors d'une suppression de compte.
///
/// BEST-EFFORT partout (la suppression cote serveur est deja actee, RTBF) :
/// chaque volet est protege, un echec est trace en debug et jamais propage — on
/// ne fait pas echouer un compte deja supprime pour un fichier verrouille.
class NettoyageLocalAppareil implements NettoyageLocalRepository {
  NettoyageLocalAppareil(this._base);

  final BaseLocale _base;

  @override
  Future<void> viderDonneesEleve() async {
    await _viderCacheDrift();
    await _supprimerFichiersTelecharges();
  }

  /// Vide les tables Drift PERSONNELLES. Le catalogue (classe/matiere/chapitre/
  /// ressource) est public et reconstructible depuis Supabase : on n'y touche pas.
  Future<void> _viderCacheDrift() async {
    try {
      await _base.transaction(() async {
        await _base.delete(_base.progressions).go();
        await _base.delete(_base.telechargements).go();
        await _base.delete(_base.abonnements).go();
        await _base.delete(_base.utilisateurs).go();
      });
    } catch (erreur) {
      if (kDebugMode) {
        debugPrint('[nettoyage] cache Drift non vide : ${erreur.runtimeType}');
      }
    }
  }

  /// Supprime le dossier des PDF telecharges (espace prive de l'app, SECURITY.md
  /// §4). Le meme dossier que celui ecrit par le moteur de telechargement.
  Future<void> _supprimerFichiersTelecharges() async {
    try {
      final racine = (await getApplicationSupportDirectory()).path;
      final dossier = Directory(CheminsTelechargement.dossier(racine));
      if (await dossier.exists()) await dossier.delete(recursive: true);
    } catch (erreur) {
      if (kDebugMode) {
        debugPrint('[nettoyage] fichiers non supprimes : ${erreur.runtimeType}');
      }
    }
  }
}
