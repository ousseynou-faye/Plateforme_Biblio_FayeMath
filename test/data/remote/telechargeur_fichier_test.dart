import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/core/errors/echec_telechargement.dart';
import 'package:fayemath_academy/data/remote/telechargeur_fichier.dart';

void main() {
  final options = RequestOptions(path: '/fichier.pdf');

  DioException erreurDio(
    DioExceptionType type, {
    Response<dynamic>? reponse,
    Object? erreur,
  }) => DioException(
    requestOptions: options,
    type: type,
    response: reponse,
    error: erreur,
  );

  group('TelechargeurFichier.traduireErreur', () {
    test('les timeouts et coupures reseau -> reseau', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.connectionError,
      ]) {
        expect(
          TelechargeurFichier.traduireErreur(erreurDio(type)),
          CauseTelechargement.reseau,
        );
      }
    });

    test('un 404 -> introuvable', () {
      final erreur = erreurDio(
        DioExceptionType.badResponse,
        reponse: Response<dynamic>(requestOptions: options, statusCode: 404),
      );
      expect(
        TelechargeurFichier.traduireErreur(erreur),
        CauseTelechargement.introuvable,
      );
    });

    test('un 401 ou 403 -> nonAutorise (refus de la policy Storage)', () {
      for (final code in [401, 403]) {
        final erreur = erreurDio(
          DioExceptionType.badResponse,
          reponse: Response<dynamic>(requestOptions: options, statusCode: code),
        );
        expect(
          TelechargeurFichier.traduireErreur(erreur),
          CauseTelechargement.nonAutorise,
        );
      }
    });

    test('un autre code de reponse -> inattendu', () {
      final erreur = erreurDio(
        DioExceptionType.badResponse,
        reponse: Response<dynamic>(requestOptions: options, statusCode: 500),
      );
      expect(
        TelechargeurFichier.traduireErreur(erreur),
        CauseTelechargement.inattendu,
      );
    });

    test('une erreur disque enveloppee par dio -> stockagePlein', () {
      final erreur = erreurDio(
        DioExceptionType.unknown,
        erreur: const FileSystemException('no space left on device'),
      );
      expect(
        TelechargeurFichier.traduireErreur(erreur),
        CauseTelechargement.stockagePlein,
      );
    });

    test('une FileSystemException nue (renommage) -> stockagePlein', () {
      expect(
        TelechargeurFichier.traduireErreur(
          const FileSystemException('rename failed'),
        ),
        CauseTelechargement.stockagePlein,
      );
    });

    test('une exception inconnue -> inattendu', () {
      expect(
        TelechargeurFichier.traduireErreur(Exception('bizarre')),
        CauseTelechargement.inattendu,
      );
    });
  });
}
