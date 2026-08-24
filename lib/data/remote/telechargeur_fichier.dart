import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import 'package:fayemath_academy/core/errors/echec_telechargement.dart';

/// La mecanique BAS NIVEAU du transfert d'un fichier, isolee ici (etape 19,
/// Lot B, decision 5.6). Premiere utilisation reelle de `data/remote/`, le dossier
/// prevu par l'architecture pour les appels reseau — et le SEUL endroit ou `dio`
/// est utilise dans tout le projet.
///
/// Ne connait NI Supabase NI le domaine : on lui donne une URL deja prete (l'URL
/// signee est fabriquee par le repository, Lot C, car c'est un appel Supabase) et
/// deux chemins locaux, il rend un flux de progression. Il applique le contrat
/// hors-ligne cote fichier :
///   - ecriture ATOMIQUE : on telecharge dans [cheminPartiel], et on ne renomme en
///     [cheminFinal] qu'a la reussite complete — une interruption ne laisse jamais
///     de PDF final tronque (regle 3) ;
///   - un echec ou une annulation NETTOIE le fichier partiel, sans toucher a quoi
///     que ce soit d'autre (regle 4) ;
///   - annuler l'abonnement au flux annule le transfert `dio` en cours.
///
/// Toute exception technique (`dio`, disque) est traduite en [EchecTelechargement]
/// AVANT de sortir : la couche superieure ne voit jamais une `DioException` brute
/// (docs/CONVENTIONS.md §5).
class TelechargeurFichier {
  TelechargeurFichier(this._dio);

  final Dio _dio;

  /// Telecharge [url] vers [cheminFinal], de facon atomique. Emet la progression
  /// (`0.0` -> `1.0`), se termine a la reussite, ou se termine par une erreur
  /// [EchecTelechargement]. [cheminPartiel] est le fichier temporaire d'ecriture.
  Stream<double> telecharger({
    required String url,
    required String cheminPartiel,
    required String cheminFinal,
  }) {
    // Un controleur plutot qu'`async*` : le progres arrive par un CALLBACK `dio`,
    // pas par des `yield`. `onCancel` (declenche quand plus personne n'ecoute)
    // annule le transfert et nettoie — rien ne continue en arriere-plan.
    final controleur = StreamController<double>();
    final jeton = CancelToken();
    controleur.onCancel = () async {
      if (!jeton.isCancelled) jeton.cancel();
      await _supprimerSiPresent(cheminPartiel);
    };
    unawaited(_executer(controleur, jeton, url, cheminPartiel, cheminFinal));
    return controleur.stream;
  }

  Future<void> _executer(
    StreamController<double> controleur,
    CancelToken jeton,
    String url,
    String cheminPartiel,
    String cheminFinal,
  ) async {
    try {
      // Le dossier des telechargements peut ne pas exister au premier appel.
      await File(cheminPartiel).parent.create(recursive: true);

      await _dio.download(
        url,
        cheminPartiel,
        cancelToken: jeton,
        onReceiveProgress: (recu, total) {
          // `total` vaut -1 si la taille est inconnue : on n'emet alors rien
          // (l'affichage retombe sur la taille deja annoncee, etape 16).
          if (total > 0 && !controleur.isClosed) {
            controleur.add((recu / total).clamp(0.0, 1.0));
          }
        },
      );

      // Renommage ATOMIQUE (meme systeme de fichiers) : c'est l'instant ou le
      // document devient « sur l'appareil ». Avant, rien n'est lisible.
      await File(cheminPartiel).rename(cheminFinal);

      if (!controleur.isClosed) {
        controleur.add(1.0);
        await controleur.close();
      }
    } catch (erreur) {
      // Une annulation volontaire (onCancel) n'est pas un echec a signaler : le
      // nettoyage est deja fait, on se contente de fermer proprement.
      if (jeton.isCancelled) {
        if (!controleur.isClosed) await controleur.close();
        return;
      }
      await _supprimerSiPresent(cheminPartiel);
      if (!controleur.isClosed) {
        // Diagnostic = le seul type d'erreur, JAMAIS l'URL (qui porte un jeton
        // signe) ni un identifiant (SECURITY.md §5).
        controleur.addError(
          EchecTelechargement(
            traduireErreur(erreur),
            diagnostic: erreur.runtimeType.toString(),
          ),
        );
        await controleur.close();
      }
    }
  }

  /// Efface le fichier partiel s'il existe (best-effort : une suppression qui
  /// echoue ne doit pas masquer l'echec d'origine).
  Future<void> _supprimerSiPresent(String chemin) async {
    try {
      final fichier = File(chemin);
      if (await fichier.exists()) await fichier.delete();
    } catch (_) {
      // Ignore : le nettoyage best-effort ne remonte jamais.
    }
  }

  /// Traduit une exception technique en [CauseTelechargement] metier. PURE et
  /// testable sans reseau ni disque : le coeur de la classification des echecs.
  static CauseTelechargement traduireErreur(Object erreur) {
    if (erreur is DioException) {
      switch (erreur.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return CauseTelechargement.reseau;
        case DioExceptionType.badResponse:
          final code = erreur.response?.statusCode;
          if (code == 404) return CauseTelechargement.introuvable;
          if (code == 401 || code == 403) {
            return CauseTelechargement.nonAutorise;
          }
          return CauseTelechargement.inattendu;
        case DioExceptionType.cancel:
          // Ne devrait pas etre traduit (annulation geree a part) ; par surete.
          return CauseTelechargement.inattendu;
        case DioExceptionType.transformTimeout:
        case DioExceptionType.badCertificate:
        case DioExceptionType.unknown:
          // Une erreur d'ecriture (`dio` enveloppe l'exception disque) est le plus
          // souvent un stockage plein — le cas concret de l'ecran 14.
          if (erreur.error is FileSystemException) {
            return CauseTelechargement.stockagePlein;
          }
          return CauseTelechargement.inattendu;
      }
    }
    // Echec du renommage / ecriture hors `dio` : stockage plein en pratique.
    if (erreur is FileSystemException) return CauseTelechargement.stockagePlein;
    return CauseTelechargement.inattendu;
  }
}
