import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/core/errors/echecs_authentification.dart';

/// Traduit un echec en message pour l'eleve. Placee ici (et non dans le code de
/// prod) uniquement pour PROUVER que le `switch` sur le type scelle est
/// exhaustif : si un cas est ajoute a [EchecAuthentification] sans etre traite,
/// ce fichier ne compile plus.
String messagePour(EchecAuthentification echec) => switch (echec) {
  IdentifiantsInvalides() => 'E-mail ou mot de passe incorrect.',
  CompteExistant() => 'Un compte existe deja avec cet e-mail.',
  EmailNonConfirme() => 'Confirme ton e-mail avant de te connecter.',
  PanneReseau() => 'Pas de connexion. Reessaie.',
  EchecAuthentificationInattendu() => 'Une erreur est survenue. Reessaie.',
};

void main() {
  group('EchecAuthentification', () {
    test('le switch scelle couvre chaque cas', () {
      expect(messagePour(const IdentifiantsInvalides()), isNotEmpty);
      expect(messagePour(const CompteExistant()), isNotEmpty);
      expect(messagePour(const EmailNonConfirme()), isNotEmpty);
      expect(messagePour(const PanneReseau()), isNotEmpty);
      expect(messagePour(const EchecAuthentificationInattendu()), isNotEmpty);
    });

    test('toString expose le diagnostic non sensible quand il existe', () {
      expect(
        const EchecAuthentificationInattendu('http 500').toString(),
        equals('EchecAuthentificationInattendu : http 500'),
      );
      expect(
        const IdentifiantsInvalides().toString(),
        equals('IdentifiantsInvalides'),
      );
    });
  });
}
