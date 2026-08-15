// Tests de l'ecran « Liste des chapitres » (etape 15), monte isolement avec de
// faux repositories. L'etat charge/groupe ne se voit PAS sur appareil (la base
// est vide jusqu'a l'etape 18) : ces tests sont la preuve de l'affichage groupe
// et de l'etat vide. Le tri/regroupement pur est deja couvert par les tests de
// RegroupementParStrate.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/classe.dart';
import 'package:fayemath_academy/domain/entities/cycle.dart';
import 'package:fayemath_academy/domain/entities/matiere.dart';
import 'package:fayemath_academy/domain/entities/serie.dart';
import 'package:fayemath_academy/domain/entities/session_auth.dart';
import 'package:fayemath_academy/domain/entities/utilisateur.dart';
import 'package:fayemath_academy/domain/repositories/auth_repository.dart';
import 'package:fayemath_academy/domain/repositories/catalogue_repository.dart';
import 'package:fayemath_academy/domain/repositories/chapitre_repository.dart';
import 'package:fayemath_academy/domain/repositories/profil_repository.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/providers/catalogue_provider.dart';
import 'package:fayemath_academy/presentation/providers/chapitre_provider.dart';
import 'package:fayemath_academy/presentation/providers/profil_provider.dart';
import 'package:fayemath_academy/presentation/screens/liste_chapitres_screen.dart';

class _FauxAuthRepository implements AuthRepository {
  _FauxAuthRepository({this.session});

  final SessionAuth? session;

  /// Mouchard : passe a vrai des que l'ecran demande la deconnexion.
  bool deconnexionAppelee = false;

  @override
  SessionAuth? get sessionCourante => session;
  @override
  Stream<SessionAuth?> get changementsSession => const Stream.empty();
  @override
  Future<void> sInscrire({
    required String email,
    required String motDePasse,
  }) async {}
  @override
  Future<void> seConnecter({
    required String email,
    required String motDePasse,
  }) async {}
  @override
  Future<void> seDeconnecter() async {
    deconnexionAppelee = true;
  }
}

class _FauxCatalogueRepository implements CatalogueRepository {
  _FauxCatalogueRepository(this.lesClasses, this.lesMatieres);

  final List<Classe> lesClasses;
  final List<Matiere> lesMatieres;

  @override
  Future<List<Classe>> classes() async => lesClasses;
  @override
  Future<List<Matiere>> matieres() async => lesMatieres;
}

class _FauxProfilRepository implements ProfilRepository {
  _FauxProfilRepository(this.profil);

  Utilisateur? profil;

  @override
  Future<Utilisateur?> profilCourant(String utilisateurId) async => profil;
  @override
  Future<void> definirClasseEtSerie({
    required String utilisateurId,
    required String classeId,
    required Serie? serie,
  }) async {}
}

class _FauxChapitreRepository implements ChapitreRepository {
  _FauxChapitreRepository(this.chapitres);

  final List<Chapitre> chapitres;

  @override
  Future<List<Chapitre>> chapitresDe({
    required String classeId,
    required String matiereId,
  }) async => chapitres;
}

const _maths = Matiere(id: 'm-maths', nom: 'Mathématiques');
const _classe6e = Classe(id: 'c-6e', nom: '6e', cycle: Cycle.college, ordre: 1);

Chapitre _chap({
  required int ordre,
  required String titre,
  required String strate,
}) => Chapitre(
  id: 'c-$ordre',
  classeId: 'c-6e',
  matiereId: 'm-maths',
  numero: ordre,
  titre: titre,
  strate: strate,
  ordre: ordre,
);

Future<void> _monterEcran(
  WidgetTester tester, {
  required List<Chapitre> chapitres,
  _FauxAuthRepository? authRepository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          authRepository ??
              _FauxAuthRepository(
                session: const SessionAuth(utilisateurId: 'u1'),
              ),
        ),
        catalogueRepositoryProvider.overrideWithValue(
          _FauxCatalogueRepository(const [_classe6e], const [_maths]),
        ),
        profilRepositoryProvider.overrideWithValue(
          _FauxProfilRepository(
            Utilisateur(
              id: 'u1',
              classeId: 'c-6e',
              serie: null,
              creeLe: DateTime(2026, 8, 13),
            ),
          ),
        ),
        chapitreRepositoryProvider.overrideWithValue(
          _FauxChapitreRepository(chapitres),
        ),
      ],
      child: const MaterialApp(home: ListeChapitresScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('affiche le titre, le compteur, les strates et les chapitres', (
    tester,
  ) async {
    await _monterEcran(
      tester,
      chapitres: [
        _chap(ordre: 1, titre: 'Les nombres entiers', strate: 'Activites numeriques'),
        _chap(ordre: 2, titre: 'Les fractions', strate: 'Activites numeriques'),
        _chap(ordre: 3, titre: 'La symetrie', strate: 'Activites geometriques'),
      ],
    );

    // Titre = « matiere · classe » (derivation option 1 : Mathematiques).
    expect(find.text('Mathématiques · 6e'), findsOneWidget);
    expect(find.text('3 chapitres'), findsOneWidget);

    // En-tetes de strate (pilotes par la donnee, mis en majuscules).
    expect(find.text('ACTIVITES NUMERIQUES'), findsOneWidget);
    expect(find.text('ACTIVITES GEOMETRIQUES'), findsOneWidget);

    // Les titres de chapitres sont rendus.
    expect(find.text('Les nombres entiers'), findsOneWidget);
    expect(find.text('Les fractions'), findsOneWidget);
    expect(find.text('La symetrie'), findsOneWidget);
  });

  testWidgets('base vide -> etat vide adapte (pas une erreur)', (tester) async {
    await _monterEcran(tester, chapitres: const []);

    expect(find.text('Bientot disponible'), findsOneWidget);
    expect(
      find.textContaining('n\'est pas encore disponible'),
      findsOneWidget,
    );
    // Ce n'est pas l'etat d'erreur.
    expect(find.text('Impossible de charger les chapitres.'), findsNothing);
  });

  testWidgets(
    'le bouton de deconnexion (provisoire) declenche seDeconnecter',
    (tester) async {
      final auth = _FauxAuthRepository(
        session: const SessionAuth(utilisateurId: 'u1'),
      );
      await _monterEcran(tester, chapitres: const [], authRepository: auth);

      // Le bouton est present dans l'AppBar (accessible par son tooltip).
      final bouton = find.byTooltip('Se deconnecter');
      expect(bouton, findsOneWidget);

      await tester.tap(bouton);
      await tester.pump();

      expect(auth.deconnexionAppelee, isTrue);
    },
  );
}
