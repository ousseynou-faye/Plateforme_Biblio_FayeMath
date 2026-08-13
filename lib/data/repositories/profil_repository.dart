import 'dart:async';
import 'dart:io' show SocketException;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fayemath_academy/core/errors/echec_enregistrement.dart';
import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/data/models/utilisateur_model.dart';
import 'package:fayemath_academy/domain/entities/serie.dart';
import 'package:fayemath_academy/domain/entities/utilisateur.dart';
import 'package:fayemath_academy/domain/repositories/profil_repository.dart';

/// Implementation du [ProfilRepository] : lecture offline-first du profil de
/// l'eleve courant (cache Drift puis Supabase) et enregistrement de son choix de
/// classe / serie par UPDATE de sa propre ligne.
///
/// La LECTURE suit le contrat offline-first (le reseau absent n'est pas une
/// erreur). L'ECRITURE, elle, exige le reseau : son echec est traduit en
/// [EchecEnregistrement] (docs/CONVENTIONS.md §5).
class ProfilRepositoryOfflineFirst implements ProfilRepository {
  ProfilRepositoryOfflineFirst(this._base, this._supabase);

  final BaseLocale _base;
  final SupabaseClient _supabase;

  @override
  Future<Utilisateur?> profilCourant(String utilisateurId) async {
    final local = await _profilLocal(utilisateurId);
    if (local != null) {
      unawaited(_synchroniserProfil(utilisateurId));
      return local;
    }
    await _synchroniserProfil(utilisateurId);
    return _profilLocal(utilisateurId);
  }

  @override
  Future<void> definirClasseEtSerie({
    required String utilisateurId,
    required String classeId,
    required Serie? serie,
  }) async {
    // UPDATE cible : UNIQUEMENT classe_id + serie, jamais id ni cree_le. La
    // policy `utilisateur_maj_de_soi` (migration 03) autorise l'UPDATE de sa
    // propre ligne ; celle-ci existe deja (trigger d'inscription, etape 13) —
    // donc aucun INSERT.
    try {
      await _supabase
          .from('utilisateur')
          .update({'classe_id': classeId, 'serie': serie?.valeurSql})
          .eq('id', utilisateurId);
    } on SocketException catch (erreur) {
      throw EchecEnregistrement(
        reseau: true,
        diagnostic: erreur.osError?.message,
      );
    } catch (erreur) {
      throw EchecEnregistrement(diagnostic: _diagnostic(erreur));
    }

    // Le serveur a accepte : on met le cache local a jour pour que la
    // redirection go_router ne redemande pas le choix au prochain lancement.
    // Best-effort (on vient d'ecrire en ligne, la resynchro doit passer).
    await _synchroniserProfil(utilisateurId);
  }

  // --- Cache local ------------------------------------------------------------

  Future<Utilisateur?> _profilLocal(String utilisateurId) async {
    final ligne = await (_base.select(
      _base.utilisateurs,
    )..where((u) => u.id.equals(utilisateurId))).getSingleOrNull();
    return ligne == null ? null : UtilisateurModel.depuisLigne(ligne);
  }

  Future<void> _synchroniserProfil(String utilisateurId) async {
    try {
      final json = await _supabase
          .from('utilisateur')
          .select()
          .eq('id', utilisateurId)
          .maybeSingle();
      if (json == null) return; // profil pas (encore) lisible cote serveur
      final profil = UtilisateurModel.depuisJson(json);
      await _base
          .into(_base.utilisateurs)
          .insertOnConflictUpdate(UtilisateurModel.versCompanion(profil));
    } catch (erreur) {
      // Lecture offline-first : un echec de resynchro ne casse rien, mais laisse
      // une trace en debug — jamais un `catch` silencieux (CONVENTIONS §5).
      if (kDebugMode) {
        debugPrint('[profil] resynchro ignoree : ${erreur.runtimeType}');
      }
    }
  }

  String _diagnostic(Object erreur) => erreur is PostgrestException
      ? 'postgrest ${erreur.code}'
      : erreur.runtimeType.toString();
}
