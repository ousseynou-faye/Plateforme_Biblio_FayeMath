import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fayemath_academy/core/errors/echec_telechargement.dart';
import 'package:fayemath_academy/data/repositories/telechargement_repository.dart';

void main() {
  group('TelechargementRepositoryStorage.traduireEchecSupabase', () {
    test('une coupure reseau -> reseau', () {
      expect(
        TelechargementRepositoryStorage.traduireEchecSupabase(
          const SocketException('offline'),
        ),
        CauseTelechargement.reseau,
      );
    });

    test('un 404 Storage -> introuvable', () {
      expect(
        TelechargementRepositoryStorage.traduireEchecSupabase(
          const StorageException('not found', statusCode: '404'),
        ),
        CauseTelechargement.introuvable,
      );
    });

    test('un 401 ou 403 Storage (refus policy) -> nonAutorise', () {
      for (final code in ['401', '403']) {
        expect(
          TelechargementRepositoryStorage.traduireEchecSupabase(
            StorageException('denied', statusCode: code),
          ),
          CauseTelechargement.nonAutorise,
        );
      }
    });

    test('un autre code Storage -> inattendu', () {
      expect(
        TelechargementRepositoryStorage.traduireEchecSupabase(
          const StorageException('boom', statusCode: '500'),
        ),
        CauseTelechargement.inattendu,
      );
    });

    test('une exception inconnue -> inattendu', () {
      expect(
        TelechargementRepositoryStorage.traduireEchecSupabase(
          Exception('bizarre'),
        ),
        CauseTelechargement.inattendu,
      );
    });
  });
}
