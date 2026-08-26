// Tests du bandeau d'etat du reseau (etape 21, SPEC §2.3). On pilote l'etat via
// l'override de `etatReseauProvider` (le vrai detecteur depend d'un plugin natif,
// verifie sur appareil). On monte avec le VRAI theme de l'app car le bandeau lit
// l'extension CouleursMarque (l'ambre = ocreDecoratif, le vert = succes).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/core/network/etat_reseau.dart';
import 'package:fayemath_academy/core/theme/theme.dart';
import 'package:fayemath_academy/presentation/providers/etat_reseau_provider.dart';
import 'package:fayemath_academy/presentation/widgets/bandeau_reseau_widget.dart';

Future<void> _monter(WidgetTester tester, Stream<EtatReseau> flux) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [etatReseauProvider.overrideWith((ref) => flux)],
      child: MaterialApp(
        theme: ThemeApplication.clair,
        home: const Scaffold(body: BandeauReseauWidget()),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('en ligne -> libelle « En ligne »', (tester) async {
    await _monter(tester, Stream.value(EtatReseau.enLigne));
    expect(find.text('En ligne'), findsOneWidget);
    expect(find.byIcon(Icons.circle), findsOneWidget);
  });

  testWidgets('hors ligne -> libelle « Hors-ligne »', (tester) async {
    await _monter(tester, Stream.value(EtatReseau.horsLigne));
    expect(find.text('Hors-ligne'), findsOneWidget);
  });

  testWidgets('reconnexion -> libelle « Reconnexion... »', (tester) async {
    await _monter(tester, Stream.value(EtatReseau.reconnexion));
    expect(find.text('Reconnexion...'), findsOneWidget);
  });

  testWidgets('etat inconnu (rien emis) -> aucun bandeau visible', (
    tester,
  ) async {
    await _monter(tester, const Stream<EtatReseau>.empty());
    // Le widget est present dans l'arbre mais rend SizedBox.shrink : ni point, ni
    // libelle, plutot qu'un statut par defaut trompeur.
    expect(find.byType(BandeauReseauWidget), findsOneWidget);
    expect(find.byIcon(Icons.circle), findsNothing);
    expect(find.text('En ligne'), findsNothing);
    expect(find.text('Hors-ligne'), findsNothing);
  });

  testWidgets('region live : l etat est annonce (accessibilite SPEC §6.2)', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _monter(tester, Stream.value(EtatReseau.horsLigne));

    // Le libelle est expose d'un bloc (« Etat du reseau : Hors-ligne ») et porte
    // le drapeau region live -> tout changement est annonce au lecteur d'ecran.
    final finder = find.bySemanticsLabel('Etat du reseau : Hors-ligne');
    expect(finder, findsOneWidget);
    final noeud = tester.getSemantics(finder);
    expect(noeud.getSemanticsData().flagsCollection.isLiveRegion, isTrue);
    handle.dispose();
  });
}
