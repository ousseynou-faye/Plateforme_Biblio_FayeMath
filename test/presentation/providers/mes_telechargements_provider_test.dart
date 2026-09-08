// Test de la NOUVELLE regle de l'anneau « Mes telechargements » (etape 25, lot F,
// point 5.7). Avant l'etape 25, « accessible » = non premium. Desormais c'est le
// vrai droit d'acces : pour un abonne, les documents premium comptent dans le
// denominateur (la couverture peut donc BAISSER a telechargements egaux). Ce test
// le prouve avec le meme disque (seul le cours present) sous deux profils.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/domain/entities/abonnement.dart';
import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/formule_abonnement.dart';
import 'package:fayemath_academy/domain/entities/ressource.dart';
import 'package:fayemath_academy/domain/entities/session_auth.dart';
import 'package:fayemath_academy/domain/entities/type_ressource.dart';
import 'package:fayemath_academy/domain/repositories/abonnement_repository.dart';
import 'package:fayemath_academy/domain/repositories/chapitre_repository.dart';
import 'package:fayemath_academy/domain/repositories/ressource_repository.dart';
import 'package:fayemath_academy/domain/repositories/telechargement_repository.dart';
import 'package:fayemath_academy/presentation/providers/abonnement_provider.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/providers/chapitre_provider.dart';
import 'package:fayemath_academy/presentation/providers/mes_telechargements_provider.dart';
import 'package:fayemath_academy/presentation/providers/ressource_provider.dart';
import 'package:fayemath_academy/presentation/providers/telechargement_provider.dart';

class _FauxChapitreRepository implements ChapitreRepository {
  _FauxChapitreRepository(this.chapitres);
  final List<Chapitre> chapitres;

  @override
  Stream<List<Chapitre>> observerChapitresDe({
    required String classeId,
    required String matiereId,
  }) => Stream.value(chapitres);
}

class _FauxRessourceRepository implements RessourceRepository {
  _FauxRessourceRepository(this.parChapitre);
  final Map<String, List<Ressource>> parChapitre;

  @override
  Stream<List<Ressource>> observerRessourcesDuChapitre({
    required String chapitreId,
  }) => Stream.value(parChapitre[chapitreId] ?? const []);
}

/// Telechargement : seuls [presents] sont sur le disque.
class _FauxTelechargementRepository implements TelechargementRepository {
  _FauxTelechargementRepository(this.presents);
  final List<Ressource> presents;

  @override
  Future<List<Ressource>> listerPresents() async => presents;
  @override
  Future<String?> cheminLocalSiPresent(String ressourceId) async => null;
  @override
  Stream<double> telecharger(Ressource ressource) => const Stream.empty();
  @override
  Future<void> supprimer(String ressourceId) async {}
}

class _FauxAbonnementRepository implements AbonnementRepository {
  _FauxAbonnementRepository(this.abonnement);
  final Abonnement? abonnement;

  @override
  Stream<Abonnement?> observerAbonnement(String utilisateurId) =>
      Stream.value(abonnement);
}

class _EtatAuthFixe extends EtatAuthNotifier {
  _EtatAuthFixe(this._initial);
  final EtatAuth _initial;
  @override
  EtatAuth build() => _initial;
}

const _chapitre = Chapitre(
  id: 'ch1',
  classeId: 'c-6e',
  matiereId: 'm-maths',
  numero: 1,
  titre: 'Les entiers naturels',
  strate: 'Activites numeriques',
  ordre: 1,
);

Ressource _cours() => const Ressource(
  id: 'r-cours',
  chapitreId: 'ch1',
  classeId: null,
  matiereId: null,
  type: TypeRessource.cours,
  titre: 'Cours',
  tailleOctets: 44000,
  premium: false,
  version: 1,
  cheminStorage: '6e/mathematiques/01/cours.pdf',
  ordre: 1,
);

Ressource _corrige() => const Ressource(
  id: 'r-corrige',
  chapitreId: 'ch1',
  classeId: null,
  matiereId: null,
  type: TypeRessource.corrige,
  titre: 'Corrige',
  tailleOctets: 60000,
  premium: true,
  version: 1,
  cheminStorage: '6e/mathematiques/01/corrige.pdf',
  ordre: 4,
);

Abonnement _abonnementActif() => Abonnement(
  id: 'a1',
  utilisateurId: 'u1',
  formule: FormuleAbonnement.mensuel,
  dateDebut: DateTime(2026, 1, 1),
  dateFin: DateTime.now().add(const Duration(days: 30)),
  referencePaiement: null,
);

/// Chapitre = { cours (gratuit), corrige (premium) } ; SEUL le cours est present.
Future<ApercuHorsLigne> _apercu({required Abonnement? abonnement}) async {
  final container = ProviderContainer(
    overrides: [
      etatAuthProvider.overrideWith(
        () => _EtatAuthFixe(
          const AuthConnecte(SessionAuth(utilisateurId: 'u1')),
        ),
      ),
      abonnementRepositoryProvider.overrideWithValue(
        _FauxAbonnementRepository(abonnement),
      ),
      chapitreRepositoryProvider.overrideWithValue(
        _FauxChapitreRepository(const [_chapitre]),
      ),
      ressourceRepositoryProvider.overrideWithValue(
        _FauxRessourceRepository({
          'ch1': [_cours(), _corrige()],
        }),
      ),
      telechargementRepositoryProvider.overrideWithValue(
        _FauxTelechargementRepository([_cours()]),
      ),
    ],
  );
  addTearDown(container.dispose);
  const cle = (classeId: 'c-6e', matiereId: 'm-maths');
  container.listen(apercuHorsLigneProvider(cle), (_, _) {});
  // Forcer la 1re emission de l'abonnement avant de lire l'apercu, pour que le
  // droit d'acces soit deja resolu (sinon un abonne serait lu « sans abonnement »
  // le temps d'un microtache).
  await container.read(abonnementPremiumProvider.future);
  return container.read(apercuHorsLigneProvider(cle).future);
}

void main() {
  test('sans abonnement : le corrige premium ne compte pas -> chapitre complet', () async {
    final apercu = await _apercu(abonnement: null);

    // Seul le cours est accessible ; il est present -> chapitre complet (100 %).
    expect(apercu.ratio.chapitresHorsLigne, 1);
    expect(apercu.ratio.chapitresTotal, 1);
    expect(apercu.ratio.pourcentage, 100);
    // La seconde ligne compte le disque reel : 1 document present.
    expect(apercu.nombrePresents, 1);
  });

  test('avec abonnement actif : le corrige premium compte -> chapitre incomplet', () async {
    final apercu = await _apercu(abonnement: _abonnementActif());

    // Le corrige premium devient accessible mais n'est PAS present -> le chapitre
    // n'est plus « complet » (couverture 0 %). Meme disque que le cas gratuit :
    // c'est bien le DENOMINATEUR qui a change (point 5.7).
    expect(apercu.ratio.chapitresHorsLigne, 0);
    expect(apercu.ratio.pourcentage, 0);
    // Le compte de documents presents, lui, ne bouge pas.
    expect(apercu.nombrePresents, 1);
  });
}
