// Tests de l'ecran « Voir l'offre » (ecran 17 minimal, etape 25 lot F). Prouvent
// les decisions du point 5.5 : les trois tarifs verrouilles sont AFFICHES, il n'y
// a AUCUN bouton d'achat, la matrice est celle du document 2 §2.1 (exercices
// gratuits sur 2 chapitres, 1 sujet gratuit par classe), et la promesse « de la 6e
// a la Terminale » n'est PAS reprise. Le bandeau reseau est present (route racine).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/core/network/etat_reseau.dart';
import 'package:fayemath_academy/core/theme/theme.dart';
import 'package:fayemath_academy/domain/entities/abonnement.dart';
import 'package:fayemath_academy/domain/entities/formule_abonnement.dart';
import 'package:fayemath_academy/presentation/providers/abonnement_provider.dart';
import 'package:fayemath_academy/presentation/providers/etat_reseau_provider.dart';
import 'package:fayemath_academy/presentation/providers/formule_selectionnee_provider.dart';
import 'package:fayemath_academy/presentation/screens/offre_premium_screen.dart';

/// Monte l'ecran avec l'abonnement voulu (`null` = non abonne, l'etat par defaut
/// des tests d'argumentaire). On override directement le flux d'abonnement plutot
/// que tout l'auth : l'ecran ne lit que ce provider pour choisir son etat.
Future<void> _monter(WidgetTester tester, {Abonnement? abonnement}) async {
  // Surface haute : la carte des tarifs est en bas de la ListView et ne serait
  // sinon pas construite dans le viewport 600 px par defaut.
  await tester.binding.setSurfaceSize(const Size(600, 1800));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        etatReseauProvider.overrideWith(
          (ref) => Stream.value(EtatReseau.enLigne),
        ),
        abonnementPremiumProvider.overrideWith((ref) => Stream.value(abonnement)),
      ],
      child: MaterialApp(
        theme: ThemeApplication.clair,
        home: const OffrePremiumScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Abonnement _abonnementActif() => Abonnement(
  id: 'a1',
  utilisateurId: 'u1',
  formule: FormuleAbonnement.anneeScolaire,
  dateDebut: DateTime(2026, 9, 1),
  dateFin: DateTime(2027, 6, 30),
  referencePaiement: null,
);

void main() {
  testWidgets('affiche les trois tarifs verrouilles + « offert au tutorat »', (
    tester,
  ) async {
    await _monter(tester);

    expect(find.text('Ce que change Premium'), findsOneWidget);
    expect(find.text('1 000 FCFA'), findsOneWidget);
    expect(find.text('2 500 FCFA'), findsOneWidget);
    expect(find.text('6 000 FCFA'), findsOneWidget);
    expect(find.text('par mois'), findsOneWidget);
    expect(find.text('par trimestre'), findsOneWidget);
    expect(find.text('par annee scolaire'), findsOneWidget);
    expect(
      find.textContaining('Offert aux eleves inscrits au tutorat'),
      findsOneWidget,
    );
    expect(find.text('Choisis ta formule'), findsOneWidget);
  });

  testWidgets('aucun achat en ligne : pas de verbe d\'achat, seul le CTA contact', (
    tester,
  ) async {
    await _monter(tester);

    // Aucun texte ne propose un achat / paiement EN LIGNE (le paiement est
    // l'etape 27). Le seul appel a l'action est de contacter le tuteur.
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Text &&
            RegExp(
              r'acheter|souscrire|payer|abonner',
              caseSensitive: false,
            ).hasMatch(w.data ?? ''),
      ),
      findsNothing,
    );
    expect(find.text('Ecrire au tuteur (WhatsApp)'), findsOneWidget);
  });

  testWidgets('matrice fidele au document 2 §2.1 (pas la version simplifiee)', (
    tester,
  ) async {
    await _monter(tester);

    // Les deux corrections vis-a-vis de la maquette §4.2.
    expect(find.text('2 premiers chapitres'), findsOneWidget); // exercices
    expect(find.text('1 par classe'), findsOneWidget); // sujets d'examen
    // Les lignes premium clefs.
    expect(find.text('Corriges detailles'), findsOneWidget);
    expect(find.text('Evaluations et leurs corriges'), findsOneWidget);
    // En-tetes de colonnes.
    expect(find.text('Gratuit'), findsOneWidget);
    expect(find.text('Premium'), findsWidgets);
  });

  testWidgets('ne reprend PAS la promesse « de la 6e a la Terminale »', (
    tester,
  ) async {
    await _monter(tester);

    expect(find.textContaining('Terminale'), findsNothing);
  });

  testWidgets('le bandeau reseau est present (route racine)', (tester) async {
    await _monter(tester);

    expect(find.text('En ligne'), findsOneWidget);
  });

  // --- Etape 26 lot A : etat « abonne actif » -----------------------------------

  testWidgets('abonne actif : en-tete « Premium actif » + echeance, PAS de tarif', (
    tester,
  ) async {
    await _monter(tester, abonnement: _abonnementActif());

    // L'etat positif remplace l'argumentaire promotionnel.
    expect(find.text('Premium actif'), findsOneWidget);
    expect(
      find.textContaining('Formule annee scolaire, jusqu\'au 30/06/2027'),
      findsOneWidget,
    );
    // La matrice reste (rappel des droits) mais le bloc tarif disparait.
    expect(find.text('Corriges detailles'), findsOneWidget);
    expect(find.text('1 000 FCFA'), findsNothing);
    expect(find.text('Choisis ta formule'), findsNothing);
    expect(find.text('Conditions'), findsNothing);
  });

  testWidgets('abonne actif : plus d\'argumentaire « Ce que change Premium »', (
    tester,
  ) async {
    await _monter(tester, abonnement: _abonnementActif());

    expect(find.text('Ce que change Premium'), findsNothing);
  });

  // --- Etape 26 lot C : selection de formule + conditions -----------------------

  FormuleAbonnement selectionCourante(WidgetTester tester) =>
      ProviderScope.containerOf(
        tester.element(find.byType(OffrePremiumScreen)),
      ).read(formuleSelectionneeProvider);

  testWidgets('formule presel. par defaut = annee scolaire (a mettre en avant)', (
    tester,
  ) async {
    await _monter(tester);

    expect(selectionCourante(tester), FormuleAbonnement.anneeScolaire);
    // Le liosere « Recommande » marque bien la formule mise en avant.
    expect(find.text('Recommande'), findsOneWidget);
  });

  testWidgets('taper une formule la selectionne (pur affichage, aucun achat)', (
    tester,
  ) async {
    await _monter(tester);

    await tester.tap(find.text('1 000 FCFA'));
    await tester.pump();

    expect(selectionCourante(tester), FormuleAbonnement.mensuel);
  });

  testWidgets('le bloc « Conditions » enonce les 4 phrases factuelles', (
    tester,
  ) async {
    await _monter(tester);

    expect(find.text('Conditions'), findsOneWidget);
    // Le point qui protege l'eleve : ce qui est deja telecharge reste lisible.
    expect(find.textContaining('deja'), findsWidgets);
    expect(find.textContaining('telecharges restent lisibles'), findsOneWidget);
    // La « restauration d'achat » : l'abonnement suit le compte.
    expect(find.textContaining('attache a ton compte'), findsOneWidget);
    expect(find.textContaining('rien a resilier'), findsOneWidget);
  });

  // --- Etape 26 lot D : canal de contact du tuteur ------------------------------

  testWidgets('CTA contact tuteur : bouton WhatsApp + numeros appelables en clair', (
    tester,
  ) async {
    await _monter(tester);

    expect(find.text('Ecrire au tuteur (WhatsApp)'), findsOneWidget);
    // Les deux numeros restent LISIBLES en clair (repli hors-ligne).
    expect(find.text('78 136 43 36'), findsOneWidget);
    expect(find.text('70 461 42 01'), findsOneWidget);
  });

  testWidgets('abonne actif : pas de canal de contact (rien a souscrire)', (
    tester,
  ) async {
    await _monter(tester, abonnement: _abonnementActif());

    expect(find.text('Ecrire au tuteur (WhatsApp)'), findsNothing);
    expect(find.text('78 136 43 36'), findsNothing);
  });
}
